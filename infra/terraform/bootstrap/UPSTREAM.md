# OKE Terraform upstream

The initial bootstrap will be derived from Oracle DevRel's OKE Resource Manager
quickstart, reviewed at repository revision `2234c2f` on 2026-08-28:

- [OKE Quickstart](https://github.com/oracle-devrel/technology-engineering/tree/main/oci-and-db/cloud-native/devops-and-containers/oke/oke-rm)
- [Network stack source](https://github.com/oracle-devrel/technology-engineering/tree/main/oci-and-db/cloud-native/devops-and-containers/oke/oke-rm/infra)
- [OKE control-plane source](https://github.com/oracle-devrel/technology-engineering/tree/main/oci-and-db/cloud-native/devops-and-containers/oke/oke-rm/oke)

The upstream separates network provisioning from OKE control-plane provisioning
and uses the `oracle-terraform-modules/oke/oci` module. This project owns a
single bootstrap configuration around the same pinned module, so Terraform can
create the VCN, cluster and fixed system pool in one dependency-aware apply.
The component boundaries remain explicit in the inputs and outputs.

Do not copy the upstream `stack.zip` as an opaque artifact or apply its default
values without review. In particular, node pools are disabled by default and
the network options include public load-balancer and bastion paths that may not
be needed here.

The project baseline is a new VCN in `eu-frankfurt-1`, a public Kubernetes API
endpoint restricted to trusted administration CIDRs, private worker and pod
subnets, a public application load-balancer subnet, and one initial managed
system node. The follow-up Flux change installs Karpenter and creates its OCI
workload-identity policies. Environment-specific values belong in the ignored
`terraform.tfvars`; see `terraform.tfvars.example` for the versioned shape.
