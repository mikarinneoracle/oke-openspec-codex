# Tasks: suspend Todo workload capacity

- [x] Confirm that the Todo UI and API occupy the dynamic Karpenter nodes and
  that `WhenEmpty` prevents their consolidation.
- [x] Define GitOps desired state with zero UI/API replicas and no API HPA.
- [x] Reduce CoreDNS autoscaler density to one replica per five nodes so its
  workload does not block Karpenter empty-node consolidation.
- [x] Allow all eligible empty workload nodes to be consolidated together.
- [ ] Commit and push the reviewed change to `main` after explicit approval.
- [ ] Verify through read-only Flux and Kubernetes inspection that the
  application replicas are zero, CoreDNS has one replica on the managed system
  node, and Karpenter has deprovisioned workload NodeClaims.
