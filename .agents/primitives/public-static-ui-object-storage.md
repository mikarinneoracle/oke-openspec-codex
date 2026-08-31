# Public static UI Object Storage primitive

## Purpose

Keep the Todo UI release in OCI Object Storage while providing an explicitly
documented HTTP-only demo bridge when a public DNS name and TLS certificate are
not available.

## Required design

- Crossplane declares the UI artefact bucket with `accessType:
  ObjectReadWithoutList` and versioning enabled.
- Public access is limited to downloading known object URLs. Anonymous callers
  must not list bucket contents or write objects.
- Each UI build is immutable and uploaded under `releases/<version>/`. Vite
  uses relative asset URLs so that `index.html` and its assets work below that
  prefix.
- A temporary Nginx UI pod downloads the selected public release and is routed
  at `/` through Envoy Gateway. Envoy routes `/api` to the Todo API, giving the
  browser one HTTP origin and avoiding mixed content without a certificate.
- This bridge is demo-only. A production deployment replaces it with direct
  HTTPS bucket/CDN delivery and an HTTPS API origin with tightly scoped CORS.

## Ownership and safety boundary

- Crossplane owns the bucket lifecycle and visibility. GitHub Actions owns only
  release-object upload through the separate write-PAR primitive.
- The public bucket may contain only UI assets. Never put database material,
  PAR URLs, source maps containing secrets, logs, or unreviewed files there.
- The demo bridge has an Nginx Deployment and an initContainer, but no UI OCI
  identity because its deliberately public release is read over HTTPS. Envoy
  Gateway remains the one public Kubernetes ingress for both UI and API.
- A public read/no-list bucket is appropriate only for intentionally public
  static content. Revert it to `NoPublicAccess` if the bucket's purpose changes.
