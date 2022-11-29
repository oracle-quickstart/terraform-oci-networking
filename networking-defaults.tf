# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# File Version: 0.1.0

# Dependencies:
#   - defaults.tf file

################################################################################
# Required locals for the oci-networking module
################################################################################
locals {
  create_new_vcn                = var.create_new_vcn == null ? true : var.create_new_vcn
  vcn_display_name              = "[${local.app_name}] VCN (${local.deploy_id})"
  create_subnets                = var.create_subnets == null ? true : var.create_subnets
  subnets                       = concat(var.subnets, local.extra_subnets)
  route_tables                  = concat(var.route_tables)
  security_lists                = concat(var.security_lists)
}

################################################################################
# Extra Subnets
# Example commented out below
################################################################################
locals {
  extra_subnets = [
    # {
    #   subnet_name                = "opensearch_subnet"
    #   cidr_block                 = cidrsubnet(local.vcn_cidr_blocks[0], 8, 35) # e.g.: "10.20.35.0/24" = 254 usable IPs (10.20.35.0 - 10.20.35.255)
    #   display_name               = "OCI OpenSearch Service subnet (${local.deploy_id})"
    #   dns_label                  = "opensearch${local.deploy_id}"
    #   prohibit_public_ip_on_vnic = false
    #   prohibit_internet_ingress  = false
    #   route_table_id             = module.route_tables["public"].route_table_id
    #   dhcp_options_id            = module.vcn.default_dhcp_options_id
    #   security_list_ids          = [module.security_lists["opensearch_security_list"].security_list_id]
    #   ipv6cidr_block             = null
    # },
  ]
}