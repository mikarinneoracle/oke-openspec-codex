module "oke" {
  source  = "oracle-terraform-modules/oke/oci"
  version = "5.5.1"

  providers = {
    oci.home = oci.home
  }

  tenancy_id     = var.tenancy_id
  compartment_id = var.compartment_id

  # New, project-owned network. Control-plane access is public but restricted
  # to the explicit administration CIDRs in terraform.tfvars.
  create_vcn                        = true
  vcn_name                          = "${var.cluster_name}-vcn"
  vcn_cidrs                         = [var.vcn_cidr]
  control_plane_is_public           = true
  assign_public_ip_to_control_plane = true
  control_plane_allowed_cidrs       = var.control_plane_allowed_cidrs
  load_balancers                    = "public"
  preferred_load_balancer           = "public"
  create_bastion                    = false
  create_operator                   = false
  allow_worker_ssh_access           = false
  worker_is_public                  = false
  allow_worker_internet_access      = true
  allow_pod_internet_access         = true

  # VCN-native pod networking creates separate private worker and pod subnets.
  cni_type           = "npn"
  oke_ip_families    = ["IPv4"]
  services_cidr      = var.services_cidr
  kubernetes_version = var.kubernetes_version
  cluster_name       = var.cluster_name
  cluster_type       = "enhanced"

  # OIDC discovery is required later by the Karpenter OCI provider's workload
  # identity. OIDC token authentication is a separate client-ID based feature
  # and is deliberately not enabled for this bootstrap.
  oidc_discovery_enabled  = true
  oidc_token_auth_enabled = false

  worker_pool_mode                      = "node-pool"
  worker_image_type                     = "oke"
  worker_image_os                       = "Oracle Linux"
  worker_image_os_version               = "9"
  worker_legacy_imds_endpoints_disabled = true
  worker_node_metadata = {
    areLegacyImdsEndpointsDisabled = "true"
  }

  # This pool intentionally remains fixed. Flux, Envoy Gateway, Crossplane,
  # Karpenter, and CoreDNS use it before Karpenter adds workload capacity.
  worker_pools = {
    system = {
      shape              = var.system_node_shape
      size               = var.system_node_count
      ocpus              = var.system_node_ocpus
      memory             = var.system_node_memory_gb
      boot_volume_size   = 100
      placement_ads      = ["1"]
      kubernetes_version = var.kubernetes_version
      node_labels = {
        "node-role/system" = "true"
      }
      disable_default_cloud_init = true
      cloud_init = [{
        content_type = "text/cloud-config"
        content      = file("${path.module}/cloud-init/system.yml")
      }]
    }
  }

  cluster_freeform_tags = {
    project = "oke-openspec-codex"
    purpose = "gitops-todo-platform"
  }
  network_freeform_tags = {
    project = "oke-openspec-codex"
    purpose = "gitops-todo-platform"
  }
  workers_freeform_tags = {
    project = "oke-openspec-codex"
    purpose = "gitops-todo-platform"
  }
}
