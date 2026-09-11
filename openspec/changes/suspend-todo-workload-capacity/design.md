# Design: suspend Todo workload capacity

The Karpenter `todo-workload` NodePool is a dynamic pool, not a static pool
with a replica count. Its `WhenEmpty` policy cannot terminate nodes carrying
the Todo UI or API pods. Converting it to static mode solely to set a zero
replica count would change the pool's scaling model and is not required.

Instead, Flux applies the desired application state of zero replicas. The API
HPA manifest is removed from the rendered application Kustomization, and the
application Flux Kustomization has pruning enabled, so the HPA is deleted. This
prevents its `minReplicas: 1` setting from overriding the API Deployment's zero
replicas.

After Flux has stopped the UI and API pods, Karpenter can consider empty
NodeClaims after its existing ten-minute consolidation period. The managed
system node remains unchanged.

Live inspection found five CoreDNS replicas because the OKE autoscaler used
`nodesPerReplica: 1`. Two were already on the managed system node and three
occupied a Karpenter node. The system node had only 140m unrequested CPU, so it
could not host all five replicas. Its live CPU usage was only 333m (18%),
however, and one CoreDNS replica needs 100m. Setting `nodesPerReplica: 5` while
retaining `min: 1` reduces the target to one replica for this five-node demo;
the existing system-node placement can satisfy it without a new node.

The NodePool budget changes from `10%` to `100%`. This applies only after nodes
are eligible for its existing `WhenEmpty` policy and allows the two empty Ready
workload NodeClaims to be consolidated together, even while the two previously
stopped NodeClaims remain NotReady.
