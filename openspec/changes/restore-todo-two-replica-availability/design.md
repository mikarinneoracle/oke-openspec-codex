# Design: restore Todo two-replica availability

The Todo API and UI bridge both use fixed `spec.replicas: 2`. This expresses a
durable two-pod availability requirement without reintroducing the CPU-based
HPA, whose prior `minReplicas: 1` did not meet this requirement.

The managed system node remains reserved for platform components. The Todo
pods are unschedulable there because of its `CriticalAddonsOnly` taint, so
Karpenter's dynamic `todo-workload` NodePool launches workload capacity when
the scheduler needs it. Karpenter must not consolidate that capacity while the
four application pods are running.
