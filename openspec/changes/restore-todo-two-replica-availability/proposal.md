# Restore Todo two-replica availability

## Why

The Todo application was intentionally suspended while the demo released all
Karpenter workload VMs. It now needs to remain online with two replicas of each
public application component.

## What changes

- Set the Todo API Deployment to two replicas.
- Set the Todo UI bridge Deployment to two replicas.
- Keep the API HPA absent so no controller can reduce the fixed replica count.

## Impact

Flux deploys two API and two UI pods. Karpenter provisions dynamic capacity for
them as needed and retains it while those pods run. The public UI and API
become available after their pods are ready.
