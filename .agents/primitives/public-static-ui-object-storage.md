# Public static UI Object Storage primitive

## Purpose

Serve the Todo UI directly to browsers from OCI Object Storage while keeping
the bucket declaratively owned by Crossplane and avoiding an unnecessary UI
pod, Nginx container, or runtime OCI identity.

## Required design

- Crossplane declares the UI artefact bucket with `accessType:
  ObjectReadWithoutList` and versioning enabled.
- Public access is limited to downloading known object URLs. Anonymous callers
  must not list bucket contents or write objects.
- Each UI build is immutable and uploaded under `releases/<version>/`. Vite
  uses relative asset URLs so that `index.html` and its assets work below that
  prefix.
- The browser calls the Todo API through an explicit HTTPS Envoy Gateway origin
  supplied at UI build time as `VITE_TODO_API_BASE_URL`.
- The API permits CORS only from the chosen Object Storage UI origin. Do not
  use an HTTP API origin because the HTTPS UI would be blocked as mixed content.

## Ownership and safety boundary

- Crossplane owns the bucket lifecycle and visibility. GitHub Actions owns only
  release-object upload through the separate write-PAR primitive.
- The public bucket may contain only UI assets. Never put database material,
  PAR URLs, source maps containing secrets, logs, or unreviewed files there.
- There is no UI Kubernetes Deployment, Nginx server, initContainer, or UI
  ServiceAccount. Envoy Gateway remains the Kubernetes ingress for the API.
- A public read/no-list bucket is appropriate only for intentionally public
  static content. Revert it to `NoPublicAccess` if the bucket's purpose changes.
