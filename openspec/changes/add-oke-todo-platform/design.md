# Design: OKE Todo platform

## Request flow

```text
Browser
  -> Envoy Gateway (Gateway API)
     -> /       Todo UI Service -> Nginx UI pod
     -> /api/*  Todo API Service -> Node.js API pod -> Autonomous Database

OCI Object Storage -> versioned UI dist/ artefact -> UI pod initContainer
```

The UI pod obtains only the selected release from a private Object Storage
bucket. The bucket is an artefact store, not a developer working directory.

## Reconciliation and ownership

```text
Reviewed Git manifests -> Flux -> OKE
Crossplane manifests  -> Crossplane -> OCI resources
CI build              -> Object Storage UI release
```

Flux is the only planned route for applying application and platform manifests
after bootstrap. Local `kubectl` remains read-only.

The one-time Flux bootstrap uses a short-lived, local GitHub fine-grained PAT
only to create a read-only GitHub deploy key. The deploy key is the Flux
runtime credential; the PAT is never committed, added to GitHub Actions, or
stored as a Flux HTTPS token. Record and rotate the deploy key through the
bootstrap procedure when its originating PAT expires.

## Repository ownership

- `apps/todo-db-app/`: React/Vite UI source, imported in a later change.
- `services/todo-api/`: Node.js REST API source and database integration.
- `platform/bootstrap/flux/`: Flux bootstrap declarations.
- `platform/gateway/envoy-gateway/`: Envoy Gateway installation and shared
  Gateway resources.
- `platform/crossplane/`: providers, compositions, and claims.
- `platform/tenants/todo/`: Todo application manifests and routes.

## Security decisions

- Database connection details are supplied to the API only through runtime
  secret references; no secret values are committed.
- The Crossplane OCI provider uses OKE Workload Identity through the
  `crossplane-provider-oci` ServiceAccount. Terraform grants that workload only
  Object Storage permissions in the project compartment, constrained to this
  cluster and namespace; no OCI API key is stored in Git or Kubernetes.
- Workload identity grants the UI release downloader read access only to its
  designated bucket/path.
- The Todo database is a private Autonomous Database Serverless instance using
  the `ECPU` compute model with 2 ECPUs, 20 GB initial storage, and auto
  scaling disabled. Its private endpoint has a dedicated subnet and security
  rules rather than a public database endpoint.
- Terraform creates the OCI Vault, its encryption key, and the generated
  database-admin password. The password is stored in OCI Vault and in local
  Terraform state as a sensitive value; it is never committed. External
  Secrets Operator, installed by Flux, uses a dedicated OKE Workload Identity
  to synchronize the password only to the namespace Crossplane needs while
  provisioning the database.
- API access uses the same public origin (`/api`) as the UI, avoiding a browser
  CORS dependency.
