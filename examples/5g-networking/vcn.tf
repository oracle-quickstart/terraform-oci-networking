
################################################################################
# Module: Virtual Cloud Network (VCN)
################################################################################
module "vcn" {
  source = "github.com/oracle-quickstart/terraform-oci-networking//modules/vcn?ref=0.3.2"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  compartment_ocid = local.vcn_compartment_ocid

  # Deployment Tags + Freeform Tags + Defined Tags
  vcn_tags = local.oci_tag_values

  # Virtual Cloud Network (VCN) arguments
  create_new_vcn          = local.create_new_vcn
  existent_vcn_ocid       = var.existent_vcn_ocid
  cidr_blocks             = local.vcn_cidr_blocks
  display_name            = local.vcn_display_name
  dns_label               = "${local.app_name_for_dns}${local.deploy_id}"
  is_ipv6enabled          = var.is_ipv6enabled
  ipv6private_cidr_blocks = var.ipv6private_cidr_blocks
}

resource "oci_identity_compartment" "vcn_compartment" {
  compartment_id = var.compartment_ocid
  name           = "${local.app_name_normalized}-${local.deploy_id}"
  description    = "${local.app_name} ${var.vcn_compartment_description} (Deployment ${local.deploy_id})"
  enable_delete  = true

  count = var.create_new_compartment_for_vcn ? 1 : 0
}
locals {
  vcn_compartment_ocid = local.create_new_vcn ? (var.create_new_compartment_for_vcn ? oci_identity_compartment.vcn_compartment.0.id : var.compartment_ocid) : var.existent_vcn_ocid
}