# Shorten demo reconciliation

## Why

The demo environment currently waits up to ten minutes for Flux to poll Git
and another ten minutes before Karpenter consolidates empty workload capacity.
That feedback cycle is unnecessarily slow for an interactive demo.

## What changes

- Reduce the Flux bootstrap Git-source interval from ten minutes to one minute.
- Reduce the dynamic Todo workload NodePool empty-node consolidation delay from
  ten minutes to one minute.

## Impact

Reviewed commits reach Flux sooner and empty Karpenter nodes are removed more
quickly. This increases Git polling and makes workload-node churn more likely,
which is acceptable for this demo environment but should be reconsidered before
production use.
