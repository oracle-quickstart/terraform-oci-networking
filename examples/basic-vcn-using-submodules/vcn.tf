module "vcn" {
  source = "github.com/oracle-quickstart/terraform-oci-networking//modules/vcn?ref=0.1.0"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  compartment_ocid = var.compartment_ocid

  # Deployment Tags + Freeform Tags + Defined Tags
  vcn_tags = local.oci_tag_values

  # Virtual Cloud Network (VCN) arguments
  create_new_vcn          = true
  existent_vcn_ocid       = ""
  cidr_blocks             = ["10.0.0.0/16"]
  display_name            = "Dev VCN"
  dns_label               = ""
  is_ipv6enabled          = false
  ipv6private_cidr_blocks = []
}