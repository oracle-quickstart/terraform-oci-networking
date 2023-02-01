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

################################################################################
# App Name to identify deployment. Used for naming resources.
################################################################################
variable "app_name" {
  default     = "APIGW-FN Subnet"
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
variable "existent_vcn_ocid" {
  description = "Using existent Virtual Cloud Network (VCN) OCID."
}
variable "vcn_cidr_blocks" {
  default     = "10.11.0.0/16"
  description = "IPv4 CIDR Blocks for the Virtual Cloud Network (VCN). If use more than one block, separate them with comma. e.g.: 10.20.0.0/16,10.80.0.0/16. If you plan to peer this VCN with another VCN, the VCNs must not have overlapping CIDRs."
}
variable "existent_internet_gateway_ocid" {
  default     = ""
  description = "Using existent Internet Gateway (IGW) OCID."
}
