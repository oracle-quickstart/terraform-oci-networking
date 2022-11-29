# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# File Version: 0.1.0

# Locals
locals {
  deploy_id   = random_string.deploy_id.result
  deploy_tags = { "DeploymentID" = local.deploy_id, "AppName" = local.app_name, "Quickstart" = "terraform-oci-networking", "QuickstartExample" = "5g-networking" }
  oci_tag_values = {
    "freeformTags" = merge(var.tag_values.freeformTags, local.deploy_tags),
    "definedTags"  = var.tag_values.definedTags
  }
  app_name            = var.app_name
  app_name_normalized = substr(replace(lower(local.app_name), " ", "-"), 0, 6)
  app_name_for_dns    = substr(lower(replace(local.app_name, "/\\W|_|\\s/", "")), 0, 6)
}

resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

################################################################################
# Required locals for the oci-networking module
################################################################################
locals {
  create_new_vcn   = var.create_new_vcn == null ? true : var.create_new_vcn
  vcn_display_name = "[${local.app_name}] VCN (${local.deploy_id})"
  create_subnets   = var.create_subnets == null ? true : var.create_subnets
  vcn_cidr_blocks  = split(",", var.vcn_cidr_blocks)
  network_cidrs = {
    VCN-MAIN-CIDR                                  = local.vcn_cidr_blocks[0]                      # e.g.: "10.20.0.0/16" = 65536 usable IPs
    SUBNET-5GC-OAM-CIDR                            = cidrsubnet(local.vcn_cidr_blocks[0], 9, 128)  # e.g.: "10.75.64.0/25" = 128 usable IPs
    SUBNET-5GC-SIGNALLING-CIDR                     = cidrsubnet(local.vcn_cidr_blocks[0], 9, 129)  # e.g.: "10.75.64.128/25" = 128 usable IPs
    SUBNET-5G-RAN-CIDR                             = cidrsubnet(local.vcn_cidr_blocks[0], 11, 520) # e.g.: "10.75.65.0/27" = 32 usable IPs
    SUBNET-LEGAL-INTERCEPT-CIDR                    = cidrsubnet(local.vcn_cidr_blocks[0], 11, 521) # e.g.: "10.75.65.32/27" = 32 usable IPs
    SUBNET-5G-EPC-CIDR                             = cidrsubnet(local.vcn_cidr_blocks[0], 11, 522) # e.g.: "10.75.65.64/27" 
    SUBNET-VCN-NATIVE-POD-NETWORKING-REGIONAL-CIDR = cidrsubnet(local.vcn_cidr_blocks[0], 1, 1)    # e.g.: "10.75.128.0/17" = 32766 usable IPs (10.20.128.0 - 10.20.255.255)
    SUBNET-BASTION-REGIONAL-CIDR                   = cidrsubnet(local.vcn_cidr_blocks[0], 12, 32)  # e.g.: "10.75.2.0/28" = 15 usable IPs (10.20.2.0 - 10.20.2.15)
    PODS-CIDR                                      = "10.244.0.0/16"
    KUBERNETES-SERVICE-CIDR                        = "10.96.0.0/16"
    ALL-CIDR                                       = "0.0.0.0/0"
  }
}