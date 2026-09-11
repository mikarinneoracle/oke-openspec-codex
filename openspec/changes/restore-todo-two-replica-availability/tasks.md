# Tasks: restore Todo two-replica availability

- [x] Set the Todo API and UI bridge Deployments to two replicas.
- [x] Keep the API HPA absent to preserve the fixed availability floor.
- [ ] Commit and push the reviewed GitOps change to `main` after explicit
  approval.
- [ ] Verify through read-only Flux and Kubernetes inspection that two ready
  API pods, two ready UI pods, and their Karpenter capacity are present.
