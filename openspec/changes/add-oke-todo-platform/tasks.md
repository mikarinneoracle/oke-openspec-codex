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

- [x] Import the Todo UI source under `apps/todo-db-app/`.
- [x] Implement the Node.js REST API and its `node-oracledb` persistence.
  - [x] Limit each API replica to a lazy one-connection database pool
    (`poolMin: 0`, `poolMax: 1`) so horizontal scaling adds database
    concurrency predictably.
- [ ] Declare Object Storage and required database resources
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
  - [ ] Declare the public, no-list versioned UI artefact bucket through
    Crossplane (`ObjectReadWithoutList`). No UI ServiceAccount or OKE Workload
    Identity is needed because browsers load public static files directly.
  - [x] Remove the Terraform-created ADB subnet, NSG, Vault key, Vault secret,
    and local generated password after explicit approval. The shared existing
    OCI Vault remains an external platform prerequisite.
- [ ] Add UI and API Kubernetes manifests, Gateway, and HTTPRoute.
  - [ ] Add the documented demo Nginx UI bridge: its initContainer retrieves a
    pinned public Object Storage release, while Envoy routes `/` to Nginx and
    `/api` to the API on one HTTP origin.
  - [ ] Clearly label the no-DNS/no-certificate HTTP bridge as demo-only. When
    DNS and TLS are available, replace it with direct HTTPS bucket/CDN UI
    delivery plus HTTPS API and scoped CORS.
- [ ] Build, test, and publish a versioned UI artefact to Object Storage.
  - [x] Add the `Publish Todo UI` GitHub Actions workflow. It has only GitHub
    read access, uses the `ui-publish` environment, and uploads immutable
    `releases/<git-sha>/` files through the write-only PAR.
  - [ ] Create a time-bound `AnyObjectWrite` PAR restricted to the UI bucket's
    `releases/` prefix and store its complete URL only as the protected GitHub
    Environment secret `OCI_TODO_UI_WRITE_PAR_URL`, following the OCI CLI
    runbook `docs/runbooks/create-ui-write-par.md`; do not use the OCI Console.
  - [ ] Upload the immutable UI release through that write-only PAR without
    logging its URL. Do not grant GitHub Actions an OCI user/API key or
    Kubernetes access.
- [ ] Verify Flux reconciliation and the browser request flow.

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
