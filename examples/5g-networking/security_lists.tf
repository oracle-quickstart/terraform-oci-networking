################################################################################
# Module: Security Lists
################################################################################
module "security_lists" {
  for_each = { for map in local.security_lists : map.security_list_name => map }
  source   = "github.com/oracle-quickstart/terraform-oci-networking//modules/security_list?ref=0.1.2"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  compartment_ocid = local.vcn_compartment_ocid
  vcn_id           = module.vcn.vcn_id

  # Deployment Tags + Freeform Tags + Defined Tags
  security_list_tags = local.oci_tag_values

  # Security List attributes
  create_security_list   = local.create_subnets
  security_list_name     = each.value.security_list_name
  display_name           = each.value.display_name
  egress_security_rules  = each.value.egress_security_rules
  ingress_security_rules = each.value.ingress_security_rules
}

locals {
  security_lists = [
    {
      security_list_name     = "5gc_oam_security_list"
      display_name           = "5GC OAM Security List (${local.deploy_id})"
      egress_security_rules  = []
      ingress_security_rules = []
    },
    {
      security_list_name     = "5gc_signalling_security_list"
      display_name           = "5GC Signalling (SBI) Security List (${local.deploy_id})"
      egress_security_rules  = []
      ingress_security_rules = []
    },
    {
      security_list_name     = "5g_ran_security_list"
      display_name           = "5G RAN Security List (${local.deploy_id})"
      egress_security_rules  = []
      ingress_security_rules = []
    },
    {
      security_list_name     = "legal_intercept_security_list"
      display_name           = "Legal Intercept Security List (${local.deploy_id})"
      egress_security_rules  = []
      ingress_security_rules = []
    },
    {
      security_list_name     = "5g_epc_security_list"
      display_name           = "5G EPC Security List (${local.deploy_id})"
      egress_security_rules  = []
      ingress_security_rules = []
    },
  ]
}