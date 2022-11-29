# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OCI Provider
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}


# App defaults
variable "app_name" {
  default     = "Generic"
  description = "Application name. Will be used as prefix to identify resources, such as OKE, VCN, ATP, and others"
}
variable "tag_values" {
  type = map(any)
  default = { "freeformTags" = {
    "Environment" = "Development",  # e.g.: Demo, Sandbox, Development, QA, Stage, ...
    "DeploymentType" = "generic" }, # e.g.: App Type 1, App Type 2, Red, Purple, ...
  "definedTags" = {} }
  description = "Use Tagging to add metadata to resources. All resources created by this stack will be tagged with the selected tag values."
}

################################################################################
# OCI Network - VCN Variables
################################################################################
variable "create_new_vcn" {
  default     = true
  description = "Creates a new Virtual Cloud Network (VCN). If false, the VCN must be provided in the variable 'existent_vcn_ocid'."
}
variable "create_new_compartment_for_vcn" {
  default     = false
  description = "Creates new compartment for VCN.  NOTE: The creation of the compartment increases the deployment time by at least 3 minutes, and can increase by 15 minutes when destroying"
}
variable "vcn_compartment_description" {
  default = "Compartment for VCN and Network resources"
  description = "Description for new VCN Compartment"
}
variable "existent_vcn_ocid" {
  default     = ""
  description = "Using existent Virtual Cloud Network (VCN) OCID."
}
variable "existent_vcn_compartment_ocid" {
  default     = ""
  description = "Compartment OCID for existent Virtual Cloud Network (VCN)."
}
variable "vcn_cidr_blocks" {
  default     = "10.0.0.0/16"
  description = "IPv4 CIDR Blocks for the Virtual Cloud Network (VCN). If use more than one block, separate them with comma. e.g.: 10.20.0.0/16,10.80.0.0/16. If you plan to peer this VCN with another VCN, the VCNs must not have overlapping CIDRs."
}
variable "is_ipv6enabled" {
  default     = false
  description = "Whether IPv6 is enabled for the Virtual Cloud Network (VCN)."
}
variable "ipv6private_cidr_blocks" {
  default     = []
  description = "The list of one or more ULA or Private IPv6 CIDR blocks for the Virtual Cloud Network (VCN)."
}
variable "create_subnets" {
  default     = true
  description = "Create subnets for the Virtual Cloud Network (VCN). If false, the subnets must be provided in the variable 'subnets'."
}
variable "subnets" {
  default     = []
  description = "Subnets for the Virtual Cloud Network (VCN)."
}
variable "route_tables" {
  default     = []
  description = "Route Tables for the Virtual Cloud Network (VCN)."
}
variable "security_lists" {
  default     = []
  description = "Security Lists for the Virtual Cloud Network (VCN)."
}

locals {
  vcn_cidr_blocks      = split(",", var.vcn_cidr_blocks)
}