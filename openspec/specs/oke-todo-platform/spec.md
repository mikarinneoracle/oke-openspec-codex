# OKE Todo platform

## Purpose

Provide a GitOps-managed reference application on Oracle Kubernetes Engine
(OKE). The application consists of a React user interface, a Node.js REST API,
and Oracle Autonomous Database persistence.

## Desired topology

- Envoy Gateway implements Kubernetes Gateway API ingress.
- `/` routes to the Todo UI service and `/api` routes to the Todo REST API.
- The UI release artefact is stored in OCI Object Storage. An OKE workload
  retrieves a pinned release using least-privilege workload identity.
- The REST API uses `node-oracledb` on the server side only. Browser code never
  receives database credentials.
- Crossplane declares OCI infrastructure required by the application.
- Flux reconciles reviewed Git manifests to the cluster.
- External Secrets Operator (ESO), reconciled by Flux, is the approved bridge
  from OCI Vault to scoped Kubernetes Secrets. Crossplane and workloads consume
  references only; no secret values are committed to Git.

## Delivery model

- Terraform provisions only the initial OKE bootstrap infrastructure before
  Flux exists: the cluster foundation and bootstrap IAM required for OKE
  Workload Identity. It does not manage application or post-bootstrap platform
  infrastructure after that handoff.
- GitHub Actions validates Terraform and application changes, builds release
  artefacts, and commits approved release references to Git.
- GitHub Actions does not receive Kubernetes write access and does not run
  `kubectl apply`.
- Flux runs in OKE and polls the GitHub repository. It is the continuous
  Kubernetes reconciler after the one-time approved bootstrap handoff.

## Safety requirement

Local `kubectl` access is discovery-only. Cluster changes are made only by the
approved GitOps bootstrap and reconciliation workflow.
