################################################################################
# Module: Security Lists
################################################################################
module "security_lists" {
  for_each = { for map in local.security_lists : map.security_list_name => map }
  source   = "github.com/oracle-quickstart/terraform-oci-networking//modules/security_list?ref=0.3.2"

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
      egress_security_rules  = [{
    description      = "Allow 5G subnets to communicate with pods"
    destination      = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.security_list_ports.all_protocols
    stateless        = false
    tcp_options      = { max = -1, min = -1, source_port_range = null }
    udp_options      = { max = -1, min = -1, source_port_range = null }
    icmp_options     = null
    }, {
    description      = "Path discovery"
    destination      = lookup(local.network_cidrs, "ALL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.security_list_ports.icmp_protocol_number
    stateless        = false
    tcp_options      = { max = -1, min = -1, source_port_range = null }
    udp_options      = { max = -1, min = -1, source_port_range = null }
    icmp_options     = { type = "3", code = "4" }
  }]
      ingress_security_rules = [{
    description  = "Allow pods to communicate with 5G subnets"
    source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
    source_type  = "CIDR_BLOCK"
    protocol     = local.security_list_ports.all_protocols
    stateless    = false
    tcp_options  = { max = -1, min = -1, source_port_range = null }
    udp_options  = { max = -1, min = -1, source_port_range = null }
    icmp_options = null
    }, {
    description  = "Path discovery"
    source       = lookup(local.network_cidrs, "ALL-CIDR")
    source_type  = "CIDR_BLOCK"
    protocol     = local.security_list_ports.icmp_protocol_number
    stateless    = false
    tcp_options  = { max = -1, min = -1, source_port_range = null }
    udp_options  = { max = -1, min = -1, source_port_range = null }
    icmp_options = { type = "3", code = "4" }
  }]
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
  security_list_ports = {
    http_port_number                        = 80
    https_port_number                       = 443
    k8s_api_endpoint_port_number            = 6443
    k8s_api_endpoint_to_worker_port_number  = 10250
    k8s_worker_to_control_plane_port_number = 12250
    ssh_port_number                         = 22
    tcp_protocol_number                     = "6"
    udp_protocol_number                     = "17"
    icmp_protocol_number                    = "1"
    sctp_protocol_number                    = "132"
    all_protocols                           = "all"
  }
  network_cidrs = {
    VCN-MAIN-CIDR                                  = "10.75.0.0/16"                      # e.g.: "10.75.0.0/16" = 65536 usable IPs
    VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR = cidrsubnet(local.vcn_cidr_blocks[0], 1, 1)    # e.g.: "10.75.128.0/17" = 32766 usable IPs (10.20.128.0 - 10.20.255.255)
    SUBNET-5GC-OAM-CIDR                            = cidrsubnet(local.vcn_cidr_blocks[0], 9, 128)  # e.g.: "10.75.64.0/25" = 128 usable IPs
    SUBNET-5GC-SIGNALLING-CIDR                     = cidrsubnet(local.vcn_cidr_blocks[0], 9, 129)  # e.g.: "10.75.64.128/25" = 128 usable IPs
    SUBNET-5G-RAN-CIDR                             = cidrsubnet(local.vcn_cidr_blocks[0], 11, 520) # e.g.: "10.75.65.0/27" = 32 usable IPs
    SUBNET-LEGAL-INTERCEPT-CIDR                    = cidrsubnet(local.vcn_cidr_blocks[0], 11, 521) # e.g.: "10.75.65.32/27" = 32 usable IPs
    SUBNET-5G-EPC-CIDR                             = cidrsubnet(local.vcn_cidr_blocks[0], 11, 522) # e.g.: "10.75.65.64/27" = 32 usable IPs
    ALL-CIDR                                       = "0.0.0.0/0"
  }
}