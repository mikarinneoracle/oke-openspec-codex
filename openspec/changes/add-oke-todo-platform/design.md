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

Terraform is limited to the one-time initial OKE bootstrap: the cluster
foundation and the least-privilege IAM policies needed before OKE Workload
Identity consumers can start. It must not create, update, import, or destroy
application or post-bootstrap platform infrastructure after that handoff.
Crossplane owns the Todo application's OCI resources through Flux.

GitHub Actions publishes a versioned UI artefact using a time-bound,
write-only Object Storage pre-authenticated request (PAR) scoped to the
bucket's `releases/` prefix. The full PAR URL is a protected GitHub Environment
secret and never enters Git, Kubernetes, Terraform state, or workflow output.
This avoids an OCI user/API key in Actions. It does not replace the UI
workload's separate read-only OKE Workload Identity.

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
  `crossplane-provider-oci` ServiceAccount. Its least-privilege bootstrap IAM
  policy is established as part of the initial OKE bootstrap, before the
  provider runs; no OCI API key is stored in Git or Kubernetes.
- Workload identity grants the UI release downloader read access only to its
  designated bucket/path.
- GitHub Actions uses no OCI IAM principal for UI publication. Its protected
  environment holds only a write-only, expiry-bound PAR URL limited to the UI
  artefact `releases/` prefix; it must not be used by the UI runtime.
- The Todo database is a private Autonomous Database Serverless instance using
  the `ECPU` compute model with 2 ECPUs, 20 GB initial storage, and auto
  scaling disabled. Its private endpoint has a dedicated subnet and security
  rules rather than a public database endpoint.
- The tenancy's existing OCI Vault is an external platform prerequisite because
  its Vault limit prevents creating an additional Vault. Crossplane declares
  the application-owned OCI resources; External Secrets Operator, installed by
  Flux, generates and synchronizes the database-admin secret through OCI Vault
  to the namespace Crossplane needs. Secret values are never committed or held
  in Terraform state.
- API access uses the same public origin (`/api`) as the UI, avoiding a browser
  CORS dependency.
