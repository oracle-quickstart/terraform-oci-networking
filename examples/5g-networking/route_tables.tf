
################################################################################
# Module: Route Tables
################################################################################
module "route_tables" {
  for_each = { for map in local.route_tables : map.route_table_name => map }
  source   = "github.com/oracle-quickstart/terraform-oci-networking//modules/route_table?ref=0.2.0"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  compartment_ocid = local.vcn_compartment_ocid
  vcn_id           = module.vcn.vcn_id

  # Deployment Tags + Freeform Tags + Defined Tags
  route_table_tags = local.oci_tag_values

  # Route Table attributes
  create_route_table = local.create_subnets
  route_table_name   = each.value.route_table_name
  display_name       = each.value.display_name
  route_rules        = each.value.route_rules
}

locals {
  route_tables = [
    {
      route_table_name = "private"
      display_name     = "Private Route Table (${local.deploy_id})"
      route_rules = [
        {
          description       = "Traffic to the internet"
          destination       = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.gateways.nat_gateway_id
        },
        {
          description       = "Traffic to OCI services"
          destination       = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type  = "SERVICE_CIDR_BLOCK"
          network_entity_id = module.gateways.service_gateway_id
      }]

    },
    {
      route_table_name = "public"
      display_name     = "Public Route Table (${local.deploy_id})"
      route_rules = [
        {
          description       = "Traffic to/from internet"
          destination       = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.gateways.internet_gateway_id
      }]
  }]
}

data "oci_core_services" "all_services_network" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}
