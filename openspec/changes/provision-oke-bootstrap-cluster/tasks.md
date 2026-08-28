# Tasks: Provision the OKE bootstrap cluster

## Decision record

- [x] Select Terraform for first-cluster infrastructure.
- [x] Select GitHub Actions for CI and artefact publication.
- [x] Select Flux in OKE for continuous Kubernetes reconciliation.
- [x] Record the reviewed OKE Resource Manager upstream and its boundaries.
- [x] Resolve the active `mika.rinne` compartment and default OCI region.
- [x] Select a new VCN, public API endpoint, private worker/pod subnets, and
  one initial managed system node.
- [x] Select Karpenter Provider for OCI for dynamic capacity after bootstrap.
- [x] Select a tainted fixed system pool plus separate Karpenter dynamic and
  optional static-capacity NodePools.

## Terraform implementation

- [ ] Record approved CIDRs, node shape, availability domain, and budget.
- [ ] Create project-owned network Terraform configuration.
- [ ] Create project-owned enhanced OKE cluster and managed node-pool
  configuration.
- [ ] Add Terraform tags and least-privilege IAM resources required by KPO.
- [ ] Pin provider and module versions and add non-secret example inputs.
- [ ] Run `terraform fmt`, `validate`, and a reviewed plan.
- [ ] Obtain explicit approval before the first Terraform apply.

## GitHub Actions

- [ ] Add a pull-request workflow for Terraform formatting, validation, and
  plan output.
- [ ] Add protected environment configuration for any OCI publish credential.
- [ ] Add build, test, image publication, and UI artefact publication after the
  application source is imported.
- [ ] Commit release references for Flux; never apply manifests from Actions.

## Cluster handoff

- [ ] Configure local kubeconfig after Terraform creates the cluster.
- [ ] Verify the context and cluster using only the `kubectl-read-only`
  primitive.
- [ ] Define and approve the one-time Flux bootstrap handoff.
- [ ] Add KPO, `OCINodeClass`, dynamic NodePool, and system-component placement
  manifests to the Flux platform layer.
- [ ] Add an optional Git-managed static Karpenter NodePool only when a manual
  capacity floor is needed.
