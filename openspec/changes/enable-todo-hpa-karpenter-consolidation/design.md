# Design: HPA-driven Todo capacity

The Todo API HPA uses CPU utilization with `minReplicas: 2`, `maxReplicas: 20`,
and the existing 60 percent target. The API Deployment's `replicas: 2` remains
the initial desired state, while the HPA becomes the runtime owner of the API
replica count.

The Karpenter NodePool uses `WhenEmptyOrUnderutilized` with its existing one
minute consolidation delay and 100 percent disruption budget. This allows
extra workload nodes to be deleted or replaced after HPA-created pods can fit
onto fewer nodes. Karpenter still does not respond to HTTP traffic directly;
it responds only after the HPA has created unschedulable pods.
