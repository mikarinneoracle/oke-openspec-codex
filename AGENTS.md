# Project guardrails

## Kubernetes access

- Use the local `kubectl` only through the `kubectl-read-only` skill and its
  primitive.
- Read-only commands are limited to `version`, `config current-context`,
  `cluster-info`, `api-resources`, `get`, `describe`, `logs`, `top`, and
  `events`.
- Never run a mutating `kubectl` command: `apply`, `create`, `replace`,
  `patch`, `delete`, `edit`, `scale`, `rollout`, `exec`, `cp`, or
  `port-forward`.
- Do not alter kubeconfig, contexts, namespaces, cluster resources, or OCI
  resources outside an approved GitOps change.

## GitOps workflow

- Describe a change in `openspec/changes/` before adding deployment manifests.
- Commit reviewed declarative manifests to Git; Flux performs cluster mutation
  only after the user has created the OKE cluster and explicitly approved the
  bootstrap step.

## Terraform boundary

- Follow the [`terraform-bootstrap-only`](.agents/primitives/terraform-bootstrap-only.md)
  primitive.
- Terraform is limited to the one-time initial OKE cluster bootstrap, including
  only the cluster foundation and bootstrap IAM required before OKE Workload
  Identity consumers can run.
- After that handoff, Terraform must not create, update, import, or destroy
  application or post-bootstrap platform infrastructure. Flux and Crossplane
  own those resources through reviewed Git manifests.

## External secrets

- Follow the [`external-secrets-vault`](.agents/primitives/external-secrets-vault.md)
  primitive for Vault-backed secret delivery.
- Flux installs and configures External Secrets Operator (ESO); Crossplane
  consumes only scoped Kubernetes Secret references, never literal values.
