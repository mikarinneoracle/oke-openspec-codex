# Private networking and secret material required before Crossplane creates the
# Autonomous Database. The database itself remains Flux/Crossplane managed.
resource "oci_core_subnet" "todo_adb" {
  compartment_id             = var.compartment_id
  vcn_id                     = module.oke.vcn_id
  cidr_block                 = var.adb_private_subnet_cidr
  display_name               = "${var.cluster_name}-adb-private"
  dns_label                  = "adb"
  prohibit_public_ip_on_vnic = true

  freeform_tags = {
    project = "oke-openspec-codex"
    purpose = "todo-adb-private-endpoint"
  }
}

resource "oci_core_network_security_group" "todo_adb" {
  compartment_id = var.compartment_id
  vcn_id         = module.oke.vcn_id
  display_name   = "${var.cluster_name}-adb"

  freeform_tags = {
    project = "oke-openspec-codex"
    purpose = "todo-adb-private-endpoint"
  }
}

resource "oci_core_network_security_group_security_rule" "todo_adb_from_pods" {
  network_security_group_id = oci_core_network_security_group.todo_adb.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.pod_subnet_cidr
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 1522
      max = 1522
    }
  }
}

data "oci_kms_vault" "todo" {
  vault_id = var.todo_vault_id
}

resource "oci_kms_key" "todo_secrets" {
  compartment_id      = var.compartment_id
  display_name        = "${var.cluster_name}-secrets"
  management_endpoint = data.oci_kms_vault.todo.management_endpoint

  key_shape {
    algorithm = "AES"
    length    = 32
  }
}

resource "random_password" "todo_adb_admin" {
  length           = 24
  special          = true
  override_special = "_#"
}

resource "oci_vault_secret" "todo_adb_admin" {
  compartment_id = var.compartment_id
  vault_id       = data.oci_kms_vault.todo.id
  key_id         = oci_kms_key.todo_secrets.id
  secret_name    = "${var.cluster_name}-todo-adb-admin"
  description    = "Administrative password for the Todo Autonomous Database."

  secret_content {
    content_type = "BASE64"
    content      = base64encode(random_password.todo_adb_admin.result)
  }
}
