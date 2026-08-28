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

output "worker_pool_ids" {
  description = "Fixed OKE system node-pool OCID."
  value       = module.oke.worker_pool_ids
}
