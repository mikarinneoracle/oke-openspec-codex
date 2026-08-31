output "cluster_id" {
  description = "OKE cluster OCID."
  value       = module.oke.cluster_id
}

output "cluster_endpoints" {
  description = "Public and private OKE API endpoints."
  value       = module.oke.cluster_endpoints
}

output "vcn_id" {
  description = "Project VCN OCID."
  value       = module.oke.vcn_id
}

output "todo_adb_foundation" {
  description = "Non-secret OCI identifiers used by Flux-managed Todo database and secret resources."
  value = {
    private_subnet_id         = oci_core_subnet.todo_adb.id
    network_security_group_id = oci_core_network_security_group.todo_adb.id
    vault_id                  = data.oci_kms_vault.todo.id
    vault_secret_id           = oci_vault_secret.todo_adb_admin.id
  }
}

output "worker_pool_ids" {
  description = "Fixed OKE system node-pool OCID."
  value       = module.oke.worker_pool_ids
}
