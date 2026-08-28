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
