# kubectl read-only primitive

## Purpose

Inspect the locally configured Kubernetes context without changing the cluster,
the workstation kubeconfig, or network-exposed workloads.

## Preconditions

1. The user has created the OKE cluster and configured the local kubeconfig.
2. Confirm the context with `kubectl config current-context` before any other
   cluster query.
3. State that the command is read-only and identify the namespace when one is
   relevant.

## Command allowlist

`version`, `config current-context`, `cluster-info`, `api-resources`, `get`,
`describe`, `logs`, `top`, and `get events`.

## Safety boundary

All other `kubectl` subcommands are forbidden. In particular, never create,
update, delete, execute in, copy to, forward to, or otherwise alter a cluster
resource. Cluster installation and reconciliation are performed later by Flux
from reviewed Git manifests, not with local `kubectl` writes.
