module "subnets" {
  for_each = { for map in local.subnets : map.subnet_name => map }
  source   = "github.com/oracle-quickstart/terraform-oci-networking//modules/subnet?ref=0.3.2"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  compartment_ocid = var.compartment_ocid
  vcn_id           = module.vcn.vcn_id

  # Deployment Tags + Freeform Tags + Defined Tags
  subnet_tags = local.oci_tag_values

  # Subnet arguments
  create_subnet              = true
  subnet_name                = each.value.subnet_name
  cidr_block                 = each.value.cidr_block
  display_name               = each.value.display_name # If null, is autogenerated
  dns_label                  = each.value.dns_label    # If null, is autogenerated
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
  prohibit_internet_ingress  = each.value.prohibit_internet_ingress
  route_table_id             = each.value.route_table_id    # If null, the VCN's default route table is used
  dhcp_options_id            = each.value.dhcp_options_id   # If null, the VCN's default set of DHCP options is used
  security_list_ids          = each.value.security_list_ids # If null, the VCN's default security list is used
  ipv6cidr_block             = each.value.ipv6cidr_block    # If null, no IPv6 CIDR block is assigned
}

locals {
  subnets = [
    {
      subnet_name                = "test_subnet"
      cidr_block                 = cidrsubnet("10.0.0.0/16", 8, 35) # e.g.: "10.0.35.0/24" = 254 usable IPs (10.20.35.0 - 10.20.35.255)
      display_name               = "Test subnet (${local.deploy_id})"
      dns_label                  = "test${local.deploy_id}"
      prohibit_public_ip_on_vnic = false
      prohibit_internet_ingress  = false
      route_table_id             = "" # module.route_tables["public"].route_table_id
      dhcp_options_id            = module.vcn.default_dhcp_options_id
      security_list_ids          = [] # [module.security_lists["test_security_list"].security_list_id]
      ipv6cidr_block             = null
    },
  ]
}