# Provision the OKE bootstrap cluster

## Why

The Todo platform requires a reproducible OKE foundation before Flux and
Crossplane can run. Creating the first cluster through Crossplane would create
a bootstrap dependency, so Terraform owns this layer.

## What changes

- Add project-owned Terraform configuration under `infra/terraform/bootstrap/`
  derived from the reviewed OKE Resource Manager quickstart.
- Provision the network, OKE enhanced cluster, required managed node pool, and
  minimum IAM/network policy foundation through Terraform.
- Keep one tainted managed system node pool for bootstrap-critical controllers.
  Add Karpenter Provider for OCI (KPO) after Flux bootstrap for elastic
  application capacity.
- Add GitHub Actions for Terraform formatting, validation, plan review, and
  later application-artifact publication.
- Keep Kubernetes delivery pull-based: GitHub Actions publishes artefacts and
  Git commits; Flux running in OKE reconciles the cluster.

## Non-goals

- GitHub Actions does not have Kubernetes write credentials and does not apply
  Kubernetes resources.
- Local `kubectl` remains read-only.
- Terraform apply, Flux bootstrap, and OCI resource creation require separate
  explicit approval after the environment inputs are reviewed.
