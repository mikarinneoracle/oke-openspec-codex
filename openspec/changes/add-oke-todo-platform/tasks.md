# Tasks: Add OKE Todo platform

## Repository foundation

- [x] Create application, platform, agent-skill, and OpenSpec directories.
- [x] Define read-only local `kubectl` guardrails and primitive.
- [x] Describe the intended OKE Todo platform.

## Prerequisites supplied by the user

- [ ] Create the OKE enhanced cluster.
- [ ] Configure the local `kubectl` context for that cluster.
- [ ] Provide confirmation that read-only cluster validation may begin.

## Platform bootstrap

- [ ] Validate the current context and cluster access using the read-only
  primitive.
- [ ] Add reviewed Flux bootstrap declarations and perform the approved Flux
  bootstrap.
- [ ] Install Envoy Gateway and verify its GatewayClass and LoadBalancer.
- [ ] Install Crossplane and its OCI provider configuration.

## Application delivery

- [ ] Import the Todo UI source under `apps/todo-db-app/`.
- [ ] Implement the Node.js REST API and its `node-oracledb` persistence.
- [ ] Declare Object Storage, workload identity, and required database resources
  through Crossplane.
- [ ] Add UI and API Kubernetes manifests, Gateway, and HTTPRoute.
- [ ] Build, test, and publish a versioned UI artefact to Object Storage.
- [ ] Verify Flux reconciliation and the browser request flow.
