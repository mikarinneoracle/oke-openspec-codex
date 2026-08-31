# Design: OKE bootstrap with Terraform and GitHub Actions

## Ownership boundary

```text
Terraform / OCI Resource Manager
  -> VCN, subnets, NSGs, OKE enhanced cluster, managed node pool

GitHub Actions
  -> validate and plan Terraform
  -> build API image and UI dist/ artefacts
  -> publish artefacts and commit release references

Flux in OKE
  -> poll GitHub
  -> reconcile platform and application manifests
```

GitHub Actions has no Kubernetes write permission. Flux is installed once by an
approved bootstrap handoff and becomes the only continuous Kubernetes writer.

The Todo UI is public static content served directly from a Crossplane-managed
Object Storage bucket with object listing disabled. Envoy Gateway remains the
ingress for the Todo API only. The browser-facing UI build contains the HTTPS
API origin and the API permits CORS only from that UI origin.

## Terraform source strategy

Use the reviewed `oke-rm` source as a transparent reference, not as an opaque
zip import. Preserve its separation between network and OKE control plane, then
select only the capabilities required for this single-cluster Todo platform.

The initial node pool must be explicitly enabled. It hosts Flux, Envoy Gateway,
Crossplane, the Todo API, and the UI workload before any later autoscaling work.

## System and Karpenter capacity

The first managed node pool is the cluster survival pool. It has one
non-preemptible node initially, is labeled `node-role/system: "true"`, and is
tainted `CriticalAddonsOnly=true:NoSchedule`. Flux, Karpenter, CoreDNS, the
OKE `kube-dns-autoscaler`, Envoy Gateway, and Crossplane must declare the
matching toleration when they are placed on this pool. The autoscaler is an
OKE-managed add-on; Flux applies a narrow, non-pruning server-side-apply
overlay that manages only its tolerations.

Karpenter Provider for OCI (KPO) is installed by Flux after bootstrap. Its
`OCINodeClass` selects the Terraform-created worker and pod subnets and NSGs by
dedicated tags. A dynamic Karpenter NodePool is the primary target for Todo
application capacity. If a manually maintained capacity floor is needed, it is
a separate static Karpenter NodePool with a Git-managed replica count; it is not
mixed into the dynamic pool.

Karpenter-created capacity is visible in Kubernetes as Nodes and NodeClaims and
in OCI Console as Compute instances. It does not appear as membership of an OKE
managed node pool in the Console, because KPO launches and owns the Compute
instances directly. This is expected behavior, not a missing node-pool
registration.

CoreDNS uses a toleration and preferred affinity for the system pool, rather
than a hard node selector. This favors fixed capacity while allowing overflow
to Karpenter nodes when necessary.

## Confirmed baseline decisions

- Region: `eu-frankfurt-1`.
- Target compartment: `mika.rinne` (the OCID is supplied only in local
  `terraform.tfvars` or Resource Manager stack variables).
- Terraform creates a new VCN.
- The Kubernetes API endpoint is public, while workers and pods run in private
  subnets.
- A public load balancer subnet is retained for the Envoy Gateway entry point.
- One managed system node is created initially.
- Karpenter Provider for OCI is installed after Flux bootstrap. It owns
  dynamic workload capacity; any manually maintained Karpenter capacity is a
  separate, Git-managed static NodePool.

## Required decisions before an apply

- Approved VCN and subnet CIDR ranges.
- Trusted administration CIDR ranges allowed to reach the public Kubernetes API
  endpoint.
- Managed system-node shape, availability domain, size, CPU, memory, and
  budget.
- Pod-subnet IP capacity and the KPO `OCINodeClass` image and VNIC settings.
- Terraform execution location: OCI Resource Manager stack or an approved
  GitHub Actions apply workflow with protected environment approval.

## GitHub Actions credentials

Initial workflows only validate and plan. The Todo UI publication workflow uses
a time-bound, write-only Object Storage PAR scoped to the `releases/` prefix,
stored only as a protected GitHub Environment secret. It therefore needs no OCI
user, API key, or Workload Identity. Do not add Kubernetes credentials. The
PAR is a bearer secret: rotate it before expiry or immediately after suspected
exposure, and never emit it to logs or commit it to Git.
