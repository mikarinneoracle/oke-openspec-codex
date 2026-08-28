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

## Repository ownership

- `apps/todo-web-ui/`: React/Vite UI source, imported in a later change.
- `services/todo-api/`: Node.js REST API source and database integration.
- `platform/bootstrap/flux/`: Flux bootstrap declarations.
- `platform/gateway/envoy-gateway/`: Envoy Gateway installation and shared
  Gateway resources.
- `platform/crossplane/`: providers, compositions, and claims.
- `platform/tenants/todo/`: Todo application manifests and routes.

## Security decisions

- Database connection details are supplied to the API only through runtime
  secret references; no secret values are committed.
- Workload identity grants the UI release downloader read access only to its
  designated bucket/path.
- API access uses the same public origin (`/api`) as the UI, avoiding a browser
  CORS dependency.
