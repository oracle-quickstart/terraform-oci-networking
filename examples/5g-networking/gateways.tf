################################################################################
# Module: Gateways
################################################################################
module "gateways" {
  source = "github.com/oracle-quickstart/terraform-oci-networking//modules/gateways?ref=0.1.2"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  compartment_ocid = local.vcn_compartment_ocid
  vcn_id           = module.vcn.vcn_id

  # Deployment Tags + Freeform Tags + Defined Tags
  gateways_tags = local.oci_tag_values

  # Internet Gateway
  create_internet_gateway       = local.create_subnets
  internet_gateway_display_name = "Internet Gateway (${local.deploy_id})"
  internet_gateway_enabled      = true

  # NAT Gateway
  create_nat_gateway       = local.create_subnets
  nat_gateway_display_name = "NAT Gateway (${local.deploy_id})"
  nat_gateway_public_ip_id = null

  # Service Gateway
  create_service_gateway       = local.create_subnets
  service_gateway_display_name = "Service Gateway (${local.deploy_id})"

  # Local Peering Gateway (LPG)
  create_local_peering_gateway       = false
  local_peering_gateway_display_name = "Local Peering Gateway (${local.deploy_id})"
  local_peering_gateway_peer_id      = null
}