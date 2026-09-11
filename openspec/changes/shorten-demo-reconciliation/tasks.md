# Tasks: shorten demo reconciliation

- [x] Reduce the Flux Git-source polling interval to one minute.
- [x] Reduce Karpenter empty-node consolidation delay to one minute.
- [ ] Commit and push the reviewed demo-only change to `main` after explicit
  approval.
- [ ] Verify the applied Flux revision and Karpenter NodePool settings using
  read-only inspection.
