# Design: No-surge Todo rollouts

Kubernetes Deployments default to a rolling update that may create surge pods.
For two replicas, that can mean a temporary third pod. The demo workload node
is pod-count constrained before it is CPU- or memory-constrained, so that pod
causes an otherwise unnecessary Karpenter node.

Both application Deployments use a `RollingUpdate` strategy with
`maxSurge: 0` and `maxUnavailable: 1`. Kubernetes terminates one old pod
before creating its replacement, retaining one available replica and requiring
no extra release capacity.

The `todo-api` HPA remains at a two-replica minimum, 20-replica maximum, and
60-percent CPU target. It remains independent of a Deployment's revision
rollout and can still add replicas during a load test.
