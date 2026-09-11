# Design: shorten demo reconciliation

The Flux `flux-system` Kustomization polls the repository source on its
`spec.interval`. Reducing it to one minute lowers the maximum delay before the
platform Kustomizations can see a reviewed `main` revision.

The Karpenter NodePool keeps `consolidationPolicy: WhenEmpty`; only its
`consolidateAfter` delay changes from ten minutes to one minute. Nodes carrying
workloads remain ineligible, so this does not turn on underutilized-node
disruption.
