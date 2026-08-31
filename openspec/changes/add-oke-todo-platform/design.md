# Design: OKE Todo platform

## Request flow

```text
Browser
  -> Envoy Gateway (Gateway API, HTTP demo endpoint)
     -> /       Nginx UI pod -> selected Object Storage UI release
     -> /api/*  Todo API Service -> Node.js API pod -> Autonomous Database

GitHub Actions -> versioned UI dist/ artefact -> OCI Object Storage
GitHub Actions -> immutable Todo API image -> private OCIR repository
```

The UI bucket provides anonymous object reads without object listing. It stores
only immutable, versioned static UI releases. Each release also contains a
single `bundle.tar.gz` for the no-list demo bridge; Crossplane owns the bucket and
GitHub Actions can write only through its scoped write-PAR. It is not a
developer working directory.

The temporary Nginx bridge downloads only the public, immutable
`releases/<git-sha>/bundle.tar.gz` object through the Object Storage object URL
and extracts it to an `emptyDir`. It does not use the write-only CI PAR, OCI
credentials, an OCI Workload Identity, or a listing operation. Gateway API
routes `/api` to the Todo API Service and `/` to the Nginx Service, giving the
browser one HTTP demo origin.

OKE's CRI-O enforces fully-qualified public image names. The bridge therefore
uses `docker.io/nginxinc/nginx-unprivileged`, not an ambiguous short image name.

## Load-driven autoscaling

Flux installs the Kubernetes Metrics Server on the fixed, tainted system node.
It provides the aggregated Metrics API used by `kubectl top` and the Todo API
HorizontalPodAutoscaler (HPA). Its normal floor is one replica, it targets 60%
of the API container's requested CPU, and is bounded at 20 replicas. It may
grow by up to 100% or four pods per minute, then waits five minutes before
gradually scaling down. The 20-replica limit also caps the initial worst-case
database concurrency at 20 lazy `node-oracledb` connections.

The API Deployment deliberately omits `spec.replicas`. HPA is the sole owner
of the replica count; Flux owns the remaining Deployment fields. This prevents
each Flux reconciliation from resetting an HPA scale-up to a static replica
count and preserves the configured five-minute scale-down stabilization.

The capacity test starts from the normal one-replica floor; it does not
pre-provision API capacity. Loader.io traffic must raise CPU utilization above
the HPA target before HPA creates additional API pods. Karpenter then adds
workload capacity only if the scheduler cannot place those HPA-created pods on
existing nodes. Each replica can create at most one lazy ADB connection when it
receives traffic. Record the HPA, pod placement, NodeClaims/nodes, and
Loader.io result during the test. Afterwards, the HPA's five-minute scale-down
stabilization and Karpenter's empty-node consolidation return capacity
gradually.

Before the load-driven phase, a one-time Flux Job seeds 1,000 deterministic-ID
English Todo rows. It uses the existing API image, the scoped ESO-delivered
database runtime secret, and an idempotent Oracle `MERGE`; rerunning it does
not create duplicate rows. The API currently returns the complete Todo list,
so this data increases database read work, Node.js JSON serialization, and
response transfer for `GET /api/tasks`. HPA still reacts only to container CPU,
not database I/O or response size.

Karpenter does not react to HTTP traffic directly. It provisions an additional
workload node only when the HPA-created API pods cannot be scheduled from their
CPU or memory requests. The current `todo-workload` NodePool permits at most
four 1-OCPU/8-GB nodes; any higher load-test target requires an explicit review
of both that capacity limit and the ADB session limit.


## Reconciliation and ownership

```text
Reviewed Git manifests -> Flux -> OKE
Crossplane manifests  -> Crossplane -> OCI resources
CI publish            -> Object Storage UI release or private OCIR API image
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
This avoids an OCI user/API key in Actions. The PAR is not used to serve UI
content and is never given to browser or Kubernetes workloads.

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
- The UI is intentionally public static content, served directly by its Object
  Storage bucket with object listing disabled. No UI downloader pod or OKE
  Workload Identity is used.
- GitHub Actions uses no OCI IAM principal for UI publication. Its protected
  environment holds only a write-only, expiry-bound PAR URL limited to the UI
  artefact `releases/` prefix; it must not be used by browser or UI runtime.
- The Todo API image is published from the protected `ocir-publish` GitHub
  Environment to the private Crossplane-managed OCIR repository at
  the environment-configured registry and tenancy namespace. The registry is a
  public Environment Variable; the tenancy namespace, OCI username, and auth
  token are Environment Secrets. The workflow uses an OCI auth token limited to
  that repository and has no Kubernetes credentials.
  Releases use unique Git SHA tags and the workflow never overwrites a tag,
  because OCI Artifacts does not currently support enforcing `isImmutable` when
  creating this repository. OKE image-pull secret automation and image signing
  are intentionally optional for the initial demo.
- The Todo API runtime has no OCI Workload Identity. ESO materializes the
  database password into `todo-app/todo-adb-runtime`; the non-sensitive `ADMIN`
  username and private server-TLS connect string are held in a ConfigMap. The
  Deployment references the immutable OCIR image by Git SHA and runs the
  schema migration as an initContainer before serving requests. Both
  containers run explicitly as the image's non-root UID/GID `1000` because the
  upstream Node image exposes its `node` user by name rather than a numeric
  Dockerfile `USER` value.
- The Todo database is a private Autonomous Database Serverless instance using
  the `ECPU` compute model with 2 ECPUs, 20 GB initial storage, and auto
  scaling disabled. Its private endpoint has a dedicated subnet and security
  rules rather than a public database endpoint. The API uses the server-TLS
  connection string on TCP `1521`; the NSG allows that port only from the OKE
  pod CIDR. Port `1522` remains reserved for a future mTLS/wallet design.
- The tenancy's existing OCI Vault is an external platform prerequisite because
  its Vault limit prevents creating an additional Vault. Crossplane declares
  the application-owned OCI resources; External Secrets Operator, installed by
  Flux, generates and synchronizes the database-admin secret through OCI Vault
  to the namespace Crossplane needs. Secret values are never committed or held
  in Terraform state.
- The temporary demo bridge serves the UI and API through the same Envoy
  Gateway HTTP origin, avoiding browser CORS and mixed-content failures without
  a domain or certificate. The browser-to-gateway hop is plaintext and is not a
  production design. Replace the bridge with direct HTTPS bucket/CDN UI delivery
  and an HTTPS API origin with scoped CORS when DNS and TLS become available.
- Each API replica maintains a lazy, one-connection `node-oracledb` pool
  (`poolMin: 0`, `poolMax: 1`). This avoids a per-request connection handshake
  while keeping aggregate ADB concurrency proportional to the replica count.
- The Todo API image includes an idempotent database migration command. The
  later API Deployment executes it as an initContainer using the same scoped
  ESO-backed runtime secret; no manual SQL session is required for the initial
  `todo_items` schema.
