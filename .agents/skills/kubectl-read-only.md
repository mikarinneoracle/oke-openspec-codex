# kubectl read-only

Use this skill only after the user has configured access to their OKE cluster.
Its purpose is discovery and validation; it must never change cluster state.

## Allowed commands

```sh
kubectl version --client
kubectl config current-context
kubectl cluster-info
kubectl api-resources
kubectl get <resource> [-n <namespace>]
kubectl describe <resource> <name> [-n <namespace>]
kubectl logs <pod> [-c <container>] [-n <namespace>]
kubectl top nodes|pods [-n <namespace>]
kubectl get events [-n <namespace>]
```

Read and follow [`../primitives/kubectl-read-only.md`](../primitives/kubectl-read-only.md)
before every cluster interaction.

## Explicitly prohibited

Do not use `apply`, `create`, `replace`, `patch`, `delete`, `edit`, `scale`,
`rollout`, `exec`, `cp`, or `port-forward`. Do not modify kubeconfig or switch
contexts. Report any missing access or unexpected context to the user.
