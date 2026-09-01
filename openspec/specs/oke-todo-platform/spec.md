# OKE Todo platform

## Purpose

Provide a GitOps-managed reference application on Oracle Kubernetes Engine
(OKE). The application consists of a React user interface, a Node.js REST API,
and Oracle Autonomous Database persistence.

## Desired topology

- Envoy Gateway implements Kubernetes Gateway API ingress.
- The UI release is stored in a public, no-list Object Storage bucket. Until a
  public DNS name and TLS certificate are available, a demo Nginx UI pod serves
  the selected release through Envoy Gateway at `/`; `/api` routes through the
  same Gateway to the Todo REST API.
- The UI release artefact is stored in OCI Object Storage under an immutable,
  versioned prefix. It is public static content; application and bucket writes
  remain restricted.
- The REST API uses `node-oracledb` on the server side only. Browser code never
  receives database credentials.
- Each Todo API pod uses a lazy `node-oracledb` pool with `poolMin: 0` and
  `poolMax: 1`. Horizontal scaling therefore increases database concurrency in
  one-connection increments rather than multiplying a large per-pod pool.
- Flux installs Metrics Server on the fixed system node and a CPU-based HPA
  manages Todo API replicas. The initial HPA range is 1–20 replicas with a 60%
  CPU utilization target. Karpenter provisions workload nodes only for
  HPA-created pods that cannot be scheduled; the current NodePool ceiling is
  four 1-OCPU/8-GB nodes. Because OCI exposes each 1-OCPU E5 node as two
  Kubernetes vCPUs, that ceiling is represented by `limits.cpu: "8"` and
  `limits.memory: 32Gi`.
- The Todo API Deployment does not declare `spec.replicas`; HPA is the sole
  replica-count owner, while Flux manages all other Deployment fields. This
  preserves HPA scale-up and its five-minute scale-down stabilization.
- The documented capacity experiment starts from the normal one-replica HPA
  floor. Loader.io traffic must exceed the CPU target before HPA creates pods;
  Karpenter only provisions nodes when those HPA-created pods cannot be
  scheduled. This verifies the load-driven HPA-to-Karpenter path without
  pre-provisioning excess replicas.
- The demo UI and API share the Envoy Gateway HTTP origin, so browser CORS is
  not required. This is not a production transport: direct bucket/CDN delivery
  requires an HTTPS API origin and scoped CORS before the demo bridge is removed.
- The demo Nginx bridge downloads a Git-SHA-pinned public
  `releases/<sha>/bundle.tar.gz` Object Storage object into an ephemeral volume.
  It has no OCI identity, PAR URL, or object-listing capability. Envoy Gateway
  sends `/api` to the Todo API Service and all other paths to that Nginx Service.
- Crossplane declares OCI infrastructure required by the application.
- Flux reconciles reviewed Git manifests to the cluster.
- External Secrets Operator (ESO), reconciled by Flux, is the approved bridge
  from OCI Vault to scoped Kubernetes Secrets. Crossplane and workloads consume
  references only; no secret values are committed to Git.
- The private Todo API image pull configuration is held in the existing OCI
  Vault. A Flux-managed `ClusterSecretStore` lets ESO materialize it only as
  the `todo-app/todo-ocir-pull` `kubernetes.io/dockerconfigjson` Secret; the
  API Deployment consumes it through `imagePullSecrets`.

## Delivery model

- Terraform provisions only the initial OKE bootstrap infrastructure before
  Flux exists: the cluster foundation and bootstrap IAM required for OKE
  Workload Identity. It does not manage application or post-bootstrap platform
  infrastructure after that handoff.
- GitHub Actions validates Terraform and application changes, builds immutable
  release artefacts, publishes the versioned UI artefact through a time-bound,
  write-only Object Storage PAR stored as a protected GitHub Environment
  secret, and publishes the private Todo API image to OCIR with a unique Git
  SHA tag. Publishing does not change a running workload.
- A reviewed GitOps promotion pins the selected UI release or API image SHA in
  a manifest and is the deployment decision. Flux reconciles that reviewed
  change; GitHub Actions does not commit a deployment or access Kubernetes.
- In this demo environment, every promoted release creates a uniquely named
  post-deployment reset Job. After the Todo application Kustomization is
  Ready, it deliberately replaces all Todo rows with the deterministic
  1,000-row dataset. This destructive reset is not a production-data pattern.
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
