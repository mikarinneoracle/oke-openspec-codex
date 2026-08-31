# Terraform bootstrap-only primitive

## Purpose

Constrain Terraform to the one-time creation of the initial OKE foundation.
After that handoff, Flux and Crossplane are the declarative owners of platform
and application resources.

## Allowed scope

Terraform may be used only for the initial, approved OKE bootstrap apply:

- the OKE cluster, its initial node pool, and the VCN, subnets, and network
  rules required to run that cluster;
- bootstrap IAM policies that must exist before Flux, Crossplane, or External
  Secrets Operator can authenticate with OKE Workload Identity.

Bootstrap IAM must be deliberately least-privilege and included in the initial
cluster bootstrap review. It is not a route for later application-resource
creation.

## Forbidden scope after bootstrap

Do not use Terraform to create, update, import, or destroy application or
post-bootstrap platform resources. This includes Autonomous Database instances,
database subnets and NSGs, Object Storage buckets, Vault keys, Vault secrets,
application workload identities, Flux-managed add-ons, and Kubernetes
manifests.

Declare those resources in reviewed Git manifests and reconcile them through
Flux and Crossplane. Generate and distribute secret values through the approved
GitOps secret flow; never place secret values in Git or Terraform state.

## Handoff check

Before running any Terraform command after the initial cluster bootstrap,
confirm that it is only a read-only format, validation, plan, or state
inspection. A Terraform apply for a post-bootstrap resource is prohibited.
