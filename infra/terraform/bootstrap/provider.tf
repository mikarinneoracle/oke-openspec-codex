provider "oci" {
  region = var.region
}

# The OKE module uses this alias for tenancy-scoped operations.
provider "oci" {
  alias  = "home"
  region = var.region
}
