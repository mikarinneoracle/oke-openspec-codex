# OKE Todo platform

## Purpose

Provide a GitOps-managed reference application on Oracle Kubernetes Engine
(OKE). The application consists of a React user interface, a Node.js REST API,
and Oracle Autonomous Database persistence.

## Desired topology

- Envoy Gateway implements Kubernetes Gateway API ingress.
- The Todo UI is served directly from its public, no-list Object Storage bucket;
  `/api` routes through Envoy Gateway to the Todo REST API.
- The UI release artefact is stored in OCI Object Storage under an immutable,
  versioned prefix. It is public static content; application and bucket writes
  remain restricted.
- The REST API uses `node-oracledb` on the server side only. Browser code never
  receives database credentials.
- Each Todo API pod uses a lazy `node-oracledb` pool with `poolMin: 0` and
  `poolMax: 1`. Horizontal scaling therefore increases database concurrency in
  one-connection increments rather than multiplying a large per-pod pool.
- The static UI uses an explicit HTTPS Envoy Gateway API origin. The API permits
  CORS only from the configured Object Storage UI origin.
- Crossplane declares OCI infrastructure required by the application.
- Flux reconciles reviewed Git manifests to the cluster.
- External Secrets Operator (ESO), reconciled by Flux, is the approved bridge
  from OCI Vault to scoped Kubernetes Secrets. Crossplane and workloads consume
  references only; no secret values are committed to Git.

## Delivery model

- Terraform provisions only the initial OKE bootstrap infrastructure before
  Flux exists: the cluster foundation and bootstrap IAM required for OKE
  Workload Identity. It does not manage application or post-bootstrap platform
  infrastructure after that handoff.
- GitHub Actions validates Terraform and application changes, builds release
  artefacts, publishes the versioned UI artefact through a time-bound,
  write-only Object Storage PAR stored as a protected GitHub Environment
  secret, and commits approved release references to Git.
- GitHub Actions does not receive Kubernetes write access and does not run
  `kubectl apply`.
- The PAR is scoped to the UI bucket's `releases/` prefix and is a CI-only
  bearer secret. It is never exposed to a browser or Kubernetes workload.
- Flux runs in OKE and polls the GitHub repository. It is the continuous
  Kubernetes reconciler after the one-time approved bootstrap handoff.

## Safety requirement

Local `kubectl` access is discovery-only. Cluster changes are made only by the
approved GitOps bootstrap and reconciliation workflow.

## Decommissioning requirement

The platform must support a documented, complete teardown that removes both
the application resources and their dedicated OCI IAM policies. Teardown must
preserve the permissions required for Crossplane and ESO to deprovision their
managed OCI resources before those policies are removed.

The required order is:

1. Remove the Todo GitOps resources so Flux, Crossplane, and ESO can delete
   the application database, bucket, key, network resources, and secrets.
2. Remove post-bootstrap platform components, including ESO, Crossplane, Envoy
   Gateway, and Flux.
3. Remove the dedicated Crossplane and ESO OCI IAM policies.
4. Run the bootstrap Terraform teardown to remove the OKE cluster and its
   bootstrap VCN resources.
