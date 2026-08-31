# Tasks: Add OKE Todo platform

## Repository foundation

- [x] Create application, platform, agent-skill, and OpenSpec directories.
- [x] Define read-only local `kubectl` guardrails and primitive.
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
- [ ] Declare Object Storage, workload identity, and required database resources
  through Crossplane.
  - [x] Install the OCI Database Crossplane provider through Flux.
  - [ ] Create a dedicated private subnet and network security rules for the
    Autonomous Database private endpoint.
  - [ ] Create an OCI Vault, encryption key, and a generated database-admin
    password with Terraform. Keep the password out of Git; Terraform state is
    local and contains it as a sensitive value.
  - [ ] Grant the Crossplane OCI workload only Object Storage and Autonomous
    Database permissions, and grant the External Secrets workload only the OCI
    Vault secret-family permissions it needs.
  - [ ] Install External Secrets Operator through Flux and use OKE Workload
    Identity to synchronize the Vault database-admin secret to
    `crossplane-system`.
  - [ ] Declare a private Autonomous Database Serverless instance through
    Crossplane with `ECPU` compute model, 2 ECPUs, 20 GB initial storage, and
    auto scaling disabled.
  - [ ] Declare the private versioned UI artefact bucket through Crossplane.
  - [ ] Create the Todo UI release-downloader ServiceAccount and grant it read
    access only to that bucket through OKE Workload Identity.
- [ ] Add UI and API Kubernetes manifests, Gateway, and HTTPRoute.
- [ ] Build, test, and publish a versioned UI artefact to Object Storage.
- [ ] Verify Flux reconciliation and the browser request flow.
