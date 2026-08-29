variable "tenancy_id" {
  description = "OCI tenancy OCID that owns the target compartment."
  type        = string
}

variable "compartment_id" {
  description = "OCI compartment OCID for this OKE environment."
  type        = string
}

variable "region" {
  description = "OCI region for the OKE environment."
  type        = string
  default     = "eu-frankfurt-1"
}

variable "cluster_name" {
  description = "OKE cluster display name."
  type        = string
  default     = "oke-openspec-codex"
}

variable "kubernetes_version" {
  description = "OKE Kubernetes version to provision."
  type        = string
  default     = "v1.36.1"
}

variable "vcn_cidr" {
  description = "CIDR range for the new project VCN."
  type        = string
  default     = "10.42.0.0/16"
}

variable "services_cidr" {
  description = "Kubernetes service CIDR; it must not overlap with the VCN."
  type        = string
  default     = "10.96.0.0/16"
}

variable "control_plane_allowed_cidrs" {
  description = "Public source CIDRs allowed to reach the Kubernetes API endpoint."
  type        = list(string)
}

variable "system_node_count" {
  description = "Fixed managed system-pool node count."
  type        = number
  default     = 1
}

variable "system_node_shape" {
  description = "Flexible compute shape for the fixed system pool."
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "system_node_ocpus" {
  description = "OCPUs per fixed system-pool node."
  type        = number
  default     = 1
}

variable "system_node_memory_gb" {
  description = "Memory in GB per fixed system-pool node."
  type        = number
  default     = 8
}
