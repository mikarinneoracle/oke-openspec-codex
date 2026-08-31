# Flux read-only

Use the local Flux CLI only to inspect GitOps state after the user has installed
it and configured the OKE kubeconfig. It must never trigger a reconciliation or
change cluster, Git, or remote state.

Read and follow [`../primitives/flux-read-only.md`](../primitives/flux-read-only.md)
before every Flux CLI interaction.

## Allowed commands

`flux version`, `flux check`, `flux get`, `flux events`, `flux logs`, `flux
tree`, `flux trace`, `flux export`, and `flux build`.

## Explicitly prohibited

Do not run `bootstrap`, `install`, `reconcile`, `create`, `delete`, `suspend`,
`resume`, `tag`, `trigger`, `push`, `pull`, or a mutating plugin command.
