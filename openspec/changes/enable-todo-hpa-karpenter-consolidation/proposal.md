# Enable Todo HPA and Karpenter consolidation

## Why

The Todo application has a fixed two-replica floor but cannot scale out under
load because its HPA is absent. Karpenter is configured for empty-only
consolidation, so it cannot remove a partially used node after an HPA scale-in.

## What changes

- Restore the Todo API HPA with a minimum of two replicas and its existing
  CPU-based target and maximum of twenty replicas.
- Change the dynamic workload NodePool consolidation policy from `WhenEmpty` to
  `WhenEmptyOrUnderutilized`.

## Impact

CPU load above the HPA target creates additional API pods. Karpenter provisions
additional workers only when those pods cannot be scheduled on existing
capacity. After CPU demand falls, the HPA's existing five-minute scale-down
stabilization reduces replicas; one minute later Karpenter can consolidate
empty or underutilized workers. Two API pods remain as the fixed availability
floor.
