# Flux read-only primitive

## Purpose

Inspect the GitOps reconciliation state without triggering reconciliation,
changing suspended state, applying manifests, or otherwise mutating the OKE
cluster.

## Preconditions

1. Confirm the intended context with `kubectl config current-context` before a
   Flux CLI query.
2. State that the command is read-only and identify its Flux resource scope.

## Command allowlist

`flux version`, `flux check`, `flux get`, `flux events`, `flux logs`, `flux
tree`, `flux trace`, `flux export`, and `flux build`.

## Safety boundary

Do not use `flux bootstrap`, `flux install`, `flux reconcile`, `flux create`,
`flux delete`, `flux suspend`, `flux resume`, `flux tag`, `flux trigger`,
`flux push`, `flux pull`, or plugin commands that mutate cluster or remote
state. Flux reconciles only from reviewed commits pushed to `main`.
