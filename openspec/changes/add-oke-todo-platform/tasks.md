# Tasks: Add OKE Todo platform

## Repository foundation

- [x] Create application, platform, agent-skill, and OpenSpec directories.
- [x] Define read-only local `kubectl` guardrails and primitive.
- [x] Define read-only local `flux` guardrails and primitive for GitOps status
  inspection; local Flux commands must not trigger reconciliation.
- [x] Describe the intended OKE Todo platform.

## Prerequisites supplied by the user

- [x] Create the OKE enhanced cluster.
- [x] Configure the local `kubectl` context for that cluster.
- [x] Provide confirmation that read-only cluster validation may begin.
- [x] Upgrade the OKE control plane and system node pool to `v1.36.1` through
  Terraform, using rolling node cycling, and verify the replacement node.

## Platform bootstrap

- [x] Validate the current context and cluster access using the read-only
  primitive.
- [x] Record the one-time Flux bootstrap credential process: a short-lived,
  local-only GitHub fine-grained PAT creates a read-only deploy key; never
  commit it, add it to GitHub Actions, or store it as a runtime Flux token.
- [x] Add reviewed Flux bootstrap declarations and perform the approved Flux
  bootstrap.
- [x] Install Envoy Gateway through Flux.
- [x] Verify Envoy Gateway's GatewayClass and the LoadBalancer created by the
  shared Gateway resource.
- [x] Install Crossplane through Flux.
- [x] Install Crossplane's OCI provider configuration through Flux using OKE
  Workload Identity and the Object Storage provider.

## Application delivery

- [x] Install Metrics Server through Flux on the tainted system node and add a
  Todo API HPA for the Loader.io experiment: 1–20 replicas, 60% CPU target,
  rapid scale-up, and five-minute scale-down stabilization. Validate Metrics
  API availability and HPA status before starting the external load test.
  - [ ] Run the load-driven HPA-to-Karpenter capacity experiment from the
    normal one-replica floor. Use Loader.io `GET /api/tasks`, observe CPU-driven
    HPA replica growth, pod placement, and any NodeClaims/nodes, and record the
    HPA, pod, node, and request-result observations. This validates the
    load-driven HPA-to-Karpenter path without pre-provisioning excess replicas.
  - [x] Seed the Todo table through Flux with 1,000 idempotent English
    load-test rows. The seed Job uses the existing API image and scoped
    ESO-delivered runtime secret, has no OCI identity, and never stores a
    credential in Git.
  - [x] Remove the static API Deployment replica count so HPA is the sole
    replica-count owner and Flux cannot reset an HPA scale-up.
  - [x] Align the Karpenter NodePool CPU limit with OCI OCPU accounting: four
    1-OCPU E5 nodes expose eight Kubernetes vCPUs, so retain `memory: 32Gi`
    and set `cpu: "8"`.
  - [ ] Remove the temporary public Loader.io HTTP verification route from the
    Nginx demo bridge after the experiment is complete.

- [x] Import the Todo UI source under `apps/todo-db-app/`.
- [x] Implement the Node.js REST API and its `node-oracledb` persistence.
  - [x] Limit each API replica to a lazy one-connection database pool
    (`poolMin: 0`, `poolMax: 1`) so horizontal scaling adds database
    concurrency predictably.
- [x] Declare Object Storage and required database resources
  through Crossplane.
  - [x] Install the OCI Database Crossplane provider through Flux.
  - [x] Declare a dedicated private subnet and network security rules for the
    Autonomous Database private endpoint through Crossplane.
  - [x] Treat the existing tenancy Vault as an external prerequisite. Do not
    create application Vault resources with Terraform; establish the GitOps
    secret-generation and synchronization flow without placing values in Git or
    Terraform state.
  - [x] Ensure the initial OKE bootstrap grants the Crossplane OCI workload only
    the Object Storage, Autonomous Database, and network permissions it needs,
    and grants the External Secrets workload only the OCI Vault secret-family
    permissions it needs. Do not add these through a post-bootstrap Terraform
    apply.
    - Crossplane principal:
      `crossplane-system/crossplane-provider-oci`, constrained by this OKE
      cluster ID. Its OCI IAM policy needs:
      - `read objectstorage-namespaces in tenancy`, so bucket declarations can
        resolve the tenancy namespace.
      - `manage object-family in compartment`, so Crossplane creates and
        reconciles only the Todo UI artefact bucket and its objects.
      - `manage autonomous-database-family in compartment`, so Crossplane
        creates and reconciles the private Todo Autonomous Database Serverless
        instance.
      - `manage virtual-network-family in compartment`, so Crossplane creates
        the ADB private subnet and network security group/rules.
      - `read vaults in compartment`, `use vaults` restricted to the existing
        Vault OCID, and `manage keys in compartment`, so Crossplane can use the
        existing Vault and create the application-owned encryption key required
        by ESO PushSecret. It must not create a Vault.
    - ESO Vault principal:
      `crossplane-system/todo-vault-reader`, constrained by this OKE cluster
      ID and referenced by the namespaced `SecretStore`. Its OCI IAM policy
      needs `use vaults`, `use keys`, and `manage secret-family` in the
      compartment, restricted to the existing Vault where OCI policy conditions
      allow it. Add `read secret-bundles` restricted to the generated Todo
      secret name, because OCI's `GetSecretBundleByName` data-plane request is
      authorized against that secret target. This permits ESO to generate,
      push, read, and rotate the Todo database-admin secret; it does not permit
      database, network, or Object Storage operations.
    - Create or update these policies once through OCI IAM/CLI as an explicit
      bootstrap-access exception. The policies enable Crossplane and ESO to act
      but are not application infrastructure and are never managed by a
      post-bootstrap Terraform apply.
  - [x] Install External Secrets Operator (ESO) through Flux. Use OKE Workload
    Identity to generate the database-admin password, store it in the existing
    OCI Vault, and materialize it only as the scoped
    `crossplane-system` Kubernetes Secret required by Crossplane.
  - [x] Declare a private Autonomous Database Serverless instance through
    Crossplane with `ECPU` compute model, 2 ECPUs, 20 GB initial storage, and
    auto scaling disabled.
  - [x] Declare the public, no-list versioned UI artefact bucket through
    Crossplane (`ObjectReadWithoutList`). No UI ServiceAccount or OKE Workload
    Identity is needed because browsers load public static files directly.
  - [x] Remove the Terraform-created ADB subnet, NSG, Vault key, Vault secret,
    and local generated password after explicit approval. The shared existing
    OCI Vault remains an external platform prerequisite.
- [x] Add UI and API Kubernetes manifests, Gateway, and HTTPRoute.
  - [x] Add an idempotent API schema-migration command for the initial
    `todo_items` table. The Deployment will run it as an initContainer using
    the scoped database runtime secret.
  - [x] Allow only server-TLS ADB traffic on TCP `1521` from the OKE pod CIDR;
    the demo does not use the mTLS/wallet port `1522`.
  - [x] Deliver the ADB password independently to `todo-app/todo-adb-runtime`
    through ESO, then deploy the single-replica Todo API from its immutable
    OCIR Git SHA image. The workload has no OCI identity, uses a
    non-sensitive ConfigMap for the server-TLS connect string, and runs the
    idempotent schema migration as an initContainer.
  - [x] Add the documented demo Nginx UI bridge: its initContainer retrieves a
    pinned public Object Storage `bundle.tar.gz` release, while Envoy routes
    `/` to Nginx and `/api` to the API on one HTTP origin. The archive is
    necessary because public bucket reads intentionally do not permit listing
    the hashed Vite assets.
  - [x] Clearly label the no-DNS/no-certificate HTTP bridge as demo-only. When
    DNS and TLS are available, replace it with direct HTTPS bucket/CDN UI
    delivery plus HTTPS API and scoped CORS.
- [x] Build, test, and publish a versioned UI artefact to Object Storage.
  - [x] Add the `Publish Todo UI` GitHub Actions workflow. It has only GitHub
    read access, uses the `ui-publish` environment, and uploads immutable
    `releases/<git-sha>/` files through the write-only PAR.
  - [x] Create a time-bound `AnyObjectWrite` PAR restricted to the UI bucket's
    `releases/` prefix and store its complete URL only as the protected GitHub
    Environment secret `OCI_TODO_UI_WRITE_PAR_URL`, following the OCI CLI
    runbook `docs/runbooks/create-ui-write-par.md`; do not use the OCI Console.
  - [x] Upload the immutable UI release through that write-only PAR without
    logging its URL. Do not grant GitHub Actions an OCI user/API key or
    Kubernetes access.
  - [x] Document manual GitOps promotion: after a successful UI build, a
    developer updates only the Git-SHA-pinned `UI_RELEASE_BUNDLE_URL` in the
    Nginx bridge manifest with `scripts/promote-ui-release.sh`, commits it, and
    lets Flux perform the rolling update. Document immutable-release rollback
    and direct Object Storage/CDN delivery as the TLS-enabled future path.
  - [x] Add a UI source pull-request validation workflow for `npm ci`, lint,
    and production build. Add a PR template that records the change summary,
    local preview browser test, successful immutable build SHA, promotion SHA,
    and rollback SHA before a release-promotion PR is approved.
  - [x] Add the demo-only post-promotion data reset: the promotion script
    updates a release-specific Flux Job, which waits for the same application
    revision to be Ready, deletes all Todo rows, and inserts 1,000 deterministic
    test rows. Keep the completed Job until it is replaced by the next release;
    do not configure TTL cleanup.
  - [ ] Optionally automate UI promotion by having GitHub Actions open a
    reviewable pull request that changes only the pinned release SHA. It must
    not write to Kubernetes or bypass the Git review and Flux reconciliation
    boundary.
  - [ ] Add the production alternative to serve the UI directly from Object
    Storage or a CDN after public DNS and TLS are available. Define a reviewed
    active-release promotion mechanism (custom-domain/CDN route or equivalent)
    that switches between immutable `releases/<git-sha>/` versions without an
    OKE UI bridge, and configure the HTTPS API origin plus scoped CORS.
- [x] Publish Todo API images to the Crossplane-managed OCIR repository at
  `fra.ocir.io` through the protected `ocir-publish` GitHub Environment.
  - [x] Install the OCI Artifacts Crossplane provider through Flux and declare
    the private `oke-openspec-codex/todo-api` repository in the
    developer-selected OCI compartment. Releases use unique Git SHA tags and the workflow never
    overwrites a tag; OCI Artifacts does not currently support enforcing
    `isImmutable` when creating this repository. Crossplane needs `manage repos
    in compartment` in addition to its existing least-privilege OCI policy.
    Apply and verify that one-time post-bootstrap policy change with
    `docs/runbooks/grant-crossplane-ocir-repository-access.md`; do not update
    Terraform.
  - [x] Store `OCI_REGISTRY_USERNAME` and `OCI_REGISTRY_AUTH_TOKEN` using the
    manual CLI procedure in `docs/runbooks/configure-ocir-actions-secrets.md`.
  - [x] Consolidate OCIR Actions setup through
    `scripts/configure-ocir-actions-secrets.sh`: retain the public registry as
    an Environment Variable and store the tenancy namespace, username, and
    token as protected Environment Secrets before changing the workflow to
    consume them.
  - [x] Deliver the private OCIR image-pull secret through the existing Vault
    and ESO before deploying the API to OKE. The user enters the token only in
    `scripts/configure-ocir-pull-secret.sh`; the script never reads GitHub
    secrets. Flux then creates the `todo-app/todo-ocir-pull`
    `kubernetes.io/dockerconfigjson` Secret through `ClusterSecretStore`
    `todo-runtime-vault`; the API later references it through
    `imagePullSecrets`. Image signing remains optional and is not a
    prerequisite for the initial image publication.
- [x] Verify Flux reconciliation and the public HTTP request flow through Envoy:
  the UI returns `200 OK` and `/api/tasks` returns a successful API response.

## Decommissioning

- [ ] Document and rehearse the complete teardown in dependency order:
  - Remove Todo GitOps resources first, while Crossplane and ESO still have
    permission to deprovision the database, bucket, key, network resources,
    and secrets they manage.
  - Remove ESO, Crossplane, Envoy Gateway, and Flux after application resource
    cleanup has completed.
  - Remove the dedicated Crossplane and ESO OCI IAM policies only after their
    managed resources are gone.
  - Run the bootstrap Terraform teardown last to remove the OKE cluster and
    its VCN foundation.
