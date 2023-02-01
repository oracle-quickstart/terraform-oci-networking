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
  default     = "OKE Networking"
  description = "Application name. Will be used as prefix to identify resources, such as OKE, VCN, ATP, and others"
}
variable "tag_values" {
  type = map(any)
  default = { "freeformTags" = {
    "Environment" = "Development",      # e.g.: Demo, Sandbox, Development, QA, Stage, ...
    "DeploymentType" = "OKE_Network" }, # e.g.: App Type 1, App Type 2, Red, Purple, ...
  "definedTags" = {} }
  description = "Use Tagging to add metadata to resources. All resources created by this stack will be tagged with the selected tag values."
}

################################################################################
# Variables: OCI Networking
################################################################################
## VCN
variable "create_new_vcn" {
  default     = true
  description = "Creates a new Virtual Cloud Network (VCN). If false, the VCN must be provided in the variable 'existent_vcn_ocid'."
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
  default     = "10.15.0.0/16"
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
## Subnets
variable "create_subnets" {
  default     = true
  description = "Create subnets for OKE: Endpoint, Nodes, Load Balancers. If CNI Type OCI_VCN_IP_NATIVE, also creates the PODs VCN. If FSS Mount Targets, also creates the FSS Mount Targets Subnet"
}
variable "create_pod_network_subnet" {
  default     = false
  description = "Create PODs Network subnet for OKE. To be used with CNI Type OCI_VCN_IP_NATIVE"
}
variable "existent_oke_k8s_endpoint_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes cluster endpoint will be hosted"
}
variable "existent_oke_nodes_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes worker nodes will be hosted"
}
variable "existent_oke_load_balancer_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes load balancers will be hosted"
}
variable "existent_oke_vcn_native_pod_networking_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes VCN Native Pod Networking will be hosted"
}
variable "existent_oke_fss_mount_targets_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes FSS mount targets will be hosted"
}
# variable "existent_apigw_fn_subnet_ocid" {
#   default     = ""
#   description = "The OCID of the subnet where the API Gateway and Functions will be hosted"
# }
variable "extra_subnets" {
  default     = []
  description = "Extra subnets to be created."
}
variable "extra_route_tables" {
  default     = []
  description = "Extra route tables to be created."
}
variable "extra_security_lists" {
  default     = []
  description = "Extra security lists to be created."
}
variable "extra_security_list_name_for_api_endpoint" {
  default     = null
  description = "Extra security list name previosly created to be used by the K8s API Endpoint Subnet."
}
variable "extra_security_list_name_for_nodes" {
  default     = null
  description = "Extra security list name previosly created to be used by the Nodes Subnet."
}
variable "extra_security_list_name_for_vcn_native_pod_networking" {
  default     = null
  description = "Extra security list name previosly created to be used by the VCN Native Pod Networking Subnet."
}

################################################################################
# Variables: OKE Network
################################################################################
# OKE Network Visibility (Workers, Endpoint and Load Balancers)
variable "cluster_workers_visibility" {
  default     = "Private"
  description = "The Kubernetes worker nodes that are created will be hosted in public or private subnet(s)"

  validation {
    condition     = var.cluster_workers_visibility == "Private" || var.cluster_workers_visibility == "Public"
    error_message = "Sorry, but cluster visibility can only be Private or Public."
  }
}
variable "cluster_endpoint_visibility" {
  default     = "Public"
  description = "The Kubernetes cluster that is created will be hosted on a public subnet with a public IP address auto-assigned or on a private subnet. If Private, additional configuration will be necessary to run kubectl commands"

  validation {
    condition     = var.cluster_endpoint_visibility == "Private" || var.cluster_endpoint_visibility == "Public"
    error_message = "Sorry, but cluster endpoint visibility can only be Private or Public."
  }
}
variable "cluster_load_balancer_visibility" {
  default     = "Public"
  description = "The Load Balancer that is created will be hosted on a public subnet with a public IP address auto-assigned or on a private subnet. This affects the Kubernetes services, ingress controller and other load balancers resources"

  validation {
    condition     = var.cluster_load_balancer_visibility == "Private" || var.cluster_load_balancer_visibility == "Public"
    error_message = "Sorry, but cluster load balancer visibility can only be Private or Public."
  }
}
variable "pods_network_visibility" {
  default     = "Private"
  description = "The PODs that are created will be hosted on a public subnet with a public IP address auto-assigned or on a private subnet. This affects the Kubernetes services and pods"

  validation {
    condition     = var.pods_network_visibility == "Private" || var.pods_network_visibility == "Public"
    error_message = "Sorry, but PODs Network visibility can only be Private or Public."
  }
}
