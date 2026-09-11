# Tasks: HPA-driven Todo capacity

- [x] Restore the API HPA with a two-replica minimum.
- [x] Enable Karpenter underutilized-node consolidation.
- [ ] Commit and push the reviewed GitOps change to `main` after explicit
  approval.
- [ ] Verify HPA scaling, Karpenter NodeClaims, and consolidation through
  read-only inspection during a controlled load test.
