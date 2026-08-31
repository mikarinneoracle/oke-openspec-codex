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
- [ ] Add a protected GitHub Environment secret named
  `OCI_TODO_UI_WRITE_PAR_URL`, containing only a time-bound `AnyObjectWrite`
  PAR restricted to the Todo UI bucket's `releases/` prefix. Do not configure
  an OCI user/API key for UI artefact publication.
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
  - KPO runs as `karpenter/karpenter`, constrained by OKE Workload Identity to
    this cluster. Its policy permits `manage instance-family`, `manage
    volumes`, `manage volume-attachments`, `manage virtual-network-family`,
    and `inspect compartments` only in the `mika.rinne` compartment. These are
    the provider's documented base permissions for node launch, VNIC and boot
    volume lifecycle; no optional spot, reservation, placement-group, or
    defined-tag permissions are granted.
  - A dedicated dynamic group matches compute instances in `mika.rinne`. Its
    `CLUSTER_JOIN` policy is restricted to this OKE cluster OCID, allowing
    Karpenter-created nodes to join this cluster but no other cluster.
  - The dynamic `todo-workload` NodePool uses only on-demand
    `VM.Standard.E5.Flex` nodes with 1 OCPU and 8 GB per node, a 4-OCPU total
    limit, and OCI VCN-native secondary VNIC pod networking. It consolidates
    empty capacity after ten minutes. No static floor, spot capacity, or
    additional optional KPO feature is enabled.
  - The OKE-managed `kube-dns-autoscaler` must tolerate
    `CriticalAddonsOnly:NoSchedule` so it stays on the fixed system pool and
    does not create an artificial Karpenter scale-out demand. Manage this as a
    narrow, non-pruning Flux server-side-apply overlay; do not replace the OKE
    add-on Deployment or patch it manually.
  - KPO node registration was validated with a temporary Git-managed
    `karpenter-registration-probe` targeted to the application NodePool. The
    probe was removed and KPO logging restored to `info` after a workload node
    registered successfully.
  - Set `settings.apiserverEndpoint` to the OKE private endpoint IP only (for
    this cluster, `10.42.0.12`), without `:6443`. KPO passes the value to
    `oke-install.sh`, which owns the API port selection during worker bootstrap.
- [ ] Add an optional Git-managed static Karpenter NodePool only when a manual
  capacity floor is needed.
