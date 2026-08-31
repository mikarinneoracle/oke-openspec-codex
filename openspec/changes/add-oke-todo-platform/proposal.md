# Add OKE Todo platform

## Why

Create a compact, end-to-end OCI reference project that demonstrates OpenSpec,
GitOps, OKE, Gateway API, Object Storage, Crossplane, Flux, a Node.js REST API,
and Oracle database access without exposing database credentials to a browser.

## What changes

- Add a React/Vite Todo UI under `apps/todo-db-app/`.
- Add a Node.js Todo REST API under `services/todo-api/`, using `node-oracledb`.
- Use Envoy Gateway with standard Gateway API resources for the Todo API.
- Store and serve immutable, versioned UI build artefacts directly from a
  Crossplane-managed public-read/no-list OCI Object Storage bucket.
- Use a clearly labeled temporary Nginx UI bridge behind Envoy Gateway when no
  public DNS name or TLS certificate is available; replace it with direct HTTPS
  bucket/CDN delivery when those prerequisites exist.
- Publish UI artefacts from GitHub Actions through a scoped write-only PAR;
  Actions never receives OCI API credentials or Kubernetes access.
- Bootstrap Flux and use Crossplane to declare the OCI resources needed by the
  platform.

## Out of scope for the initial bootstrap

- Creating the OKE cluster or configuring the user's local kubeconfig.
- Applying manifests with local `kubectl`.
- Implementing authentication, a public DNS name, or production CI credentials.
