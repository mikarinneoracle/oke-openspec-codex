# OCI authorization for the Crossplane OCI provider running in this OKE cluster.
# The workload identity condition prevents a different cluster, namespace, or
# ServiceAccount from using these permissions.
resource "oci_identity_policy" "crossplane_oci_workload" {
  provider       = oci.home
  compartment_id = var.tenancy_id
  name           = "${var.cluster_name}-crossplane-oci-workload"
  description    = "Least-privilege Object Storage access for the Crossplane OCI provider workload."

  statements = [
    "Allow any-user to read objectstorage-namespaces in tenancy where all {request.principal.type = 'workload', request.principal.namespace = 'crossplane-system', request.principal.service_account = 'crossplane-provider-oci', request.principal.cluster_id = '${module.oke.cluster_id}'}",
    "Allow any-user to manage object-family in compartment id ${var.compartment_id} where all {request.principal.type = 'workload', request.principal.namespace = 'crossplane-system', request.principal.service_account = 'crossplane-provider-oci', request.principal.cluster_id = '${module.oke.cluster_id}'}",
  ]
}
