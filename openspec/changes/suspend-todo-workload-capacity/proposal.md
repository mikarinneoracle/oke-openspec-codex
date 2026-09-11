# Suspend Todo workload capacity

## Why

The Todo UI and API currently keep Karpenter workload nodes non-empty. The
demo environment needs to release all dynamic workload capacity while retaining
the managed system node and platform controllers.

## What changes

- Scale the Todo UI bridge and API Deployments to zero replicas.
- Omit the API HPA from the application Kustomization so Flux prunes it and it
  cannot restore the API's one-replica minimum while the application is
  suspended.
- Configure the OKE CoreDNS autoscaler for one DNS replica per five nodes (with
  a minimum of one), so CoreDNS remains on the managed system node rather than
  occupying dynamic workload capacity.
- Retain the dynamic Karpenter NodePool and allow all empty nodes to be
  disrupted together.

## Impact

The public Todo UI, API, and health endpoint will be unavailable. Flux applies
the change from `main`; no local `kubectl` mutation is used. Resuming service
requires restoring the HPA resource and the normal replica settings through a
reviewed GitOps change.

The live cluster currently has CoreDNS pods on Karpenter nodes. This change
reduces the replica target to one and retains it on managed system capacity
before empty workload nodes are consolidated.
