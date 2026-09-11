# Avoid release surge capacity

## Why

A Todo UI or API rolling update uses Kubernetes' default surge behavior. On
the small demo worker this temporarily creates a third application pod, fills
its pod-count capacity, and causes Karpenter to provision another node even
when CPU and memory are available.

## What changes

- Configure the Todo UI bridge and API Deployments with zero surge and one
  unavailable replica during a rolling update.
- Leave the API HPA floor, CPU target, and scale-out limits unchanged so load
  tests continue to exercise HPA and Karpenter.

## Impact

Routine application releases use no extra pod capacity and retain one ready
replica while each two-replica Deployment updates. Load-driven API scale-out
remains able to create unschedulable pods and trigger Karpenter.
