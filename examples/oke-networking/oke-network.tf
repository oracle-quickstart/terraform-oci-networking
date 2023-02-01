# OKE Subnets definitions

locals {
  subnets_oke = concat(local.subnets_oke_standard, local.subnet_vcn_native_pod_networking, local.subnet_bastion, local.subnet_fss_mount_targets)
  subnets_oke_standard = [
    {
      subnet_name                  = "oke_k8s_endpoint_subnet"
      cidr_block                   = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
      display_name                 = "OKE K8s Endpoint subnet (${local.deploy_id})"
      dns_label                    = "okek8s${local.deploy_id}"
      prohibit_public_ip_on_vnic   = (var.cluster_endpoint_visibility == "Private") ? true : false
      prohibit_internet_ingress    = (var.cluster_endpoint_visibility == "Private") ? true : false
      route_table_id               = (var.cluster_endpoint_visibility == "Private") ? module.route_tables["private"].route_table_id : module.route_tables["public"].route_table_id
      alternative_route_table_name = null
      dhcp_options_id              = module.vcn.default_dhcp_options_id
      security_list_ids            = [module.security_lists["oke_endpoint_security_list"].security_list_id]
      extra_security_list_names    = anytrue([(var.extra_security_list_name_for_api_endpoint == ""), (var.extra_security_list_name_for_api_endpoint == null)]) ? [] : [var.extra_security_list_name_for_api_endpoint]
      ipv6cidr_block               = null
    },
    {
      subnet_name                  = "oke_nodes_subnet"
      cidr_block                   = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
      display_name                 = "OKE Nodes subnet (${local.deploy_id})"
      dns_label                    = "okenodes${local.deploy_id}"
      prohibit_public_ip_on_vnic   = (var.cluster_workers_visibility == "Private") ? true : false
      prohibit_internet_ingress    = (var.cluster_workers_visibility == "Private") ? true : false
      route_table_id               = (var.cluster_workers_visibility == "Private") ? module.route_tables["private"].route_table_id : module.route_tables["public"].route_table_id
      alternative_route_table_name = null
      dhcp_options_id              = module.vcn.default_dhcp_options_id
      security_list_ids            = [module.security_lists["oke_nodes_security_list"].security_list_id]
      extra_security_list_names    = anytrue([(var.extra_security_list_name_for_nodes == ""), (var.extra_security_list_name_for_nodes == null)]) ? [] : [var.extra_security_list_name_for_nodes]
      ipv6cidr_block               = null
    },
    {
      subnet_name                  = "oke_lb_subnet"
      cidr_block                   = lookup(local.network_cidrs, "LB-REGIONAL-SUBNET-CIDR")
      display_name                 = "OKE LoadBalancers subnet (${local.deploy_id})"
      dns_label                    = "okelb${local.deploy_id}"
      prohibit_public_ip_on_vnic   = (var.cluster_load_balancer_visibility == "Private") ? true : false
      prohibit_internet_ingress    = (var.cluster_load_balancer_visibility == "Private") ? true : false
      route_table_id               = (var.cluster_load_balancer_visibility == "Private") ? module.route_tables["private"].route_table_id : module.route_tables["public"].route_table_id
      alternative_route_table_name = null
      dhcp_options_id              = module.vcn.default_dhcp_options_id
      security_list_ids            = [module.security_lists["oke_lb_security_list"].security_list_id]
      extra_security_list_names    = []
      ipv6cidr_block               = null
    }
  ]
  subnet_vcn_native_pod_networking = (var.create_pod_network_subnet) ? [
    {
      subnet_name                  = "oke_pods_network_subnet"
      cidr_block                   = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR") # e.g.: 10.20.128.0/17 (1,1) = 32766 usable IPs (10.20.128.0 - 10.20.255.255)
      display_name                 = "OKE PODs Network subnet (${local.deploy_id})"
      dns_label                    = "okenpn${local.deploy_id}"
      prohibit_public_ip_on_vnic   = (var.pods_network_visibility == "Private") ? true : false
      prohibit_internet_ingress    = (var.pods_network_visibility == "Private") ? true : false
      route_table_id               = (var.pods_network_visibility == "Private") ? module.route_tables["private"].route_table_id : module.route_tables["public"].route_table_id
      alternative_route_table_name = null
      dhcp_options_id              = module.vcn.default_dhcp_options_id
      security_list_ids            = [module.security_lists["oke_pod_network_security_list"].security_list_id]
      extra_security_list_names    = anytrue([(var.extra_security_list_name_for_vcn_native_pod_networking == ""), (var.extra_security_list_name_for_vcn_native_pod_networking == null)]) ? [] : [var.extra_security_list_name_for_vcn_native_pod_networking]
      ipv6cidr_block               = null
  }] : []
  subnet_bastion           = [] # 10.20.2.0/28 (12,32) = 15 usable IPs (10.20.2.0 - 10.20.2.15)
  subnet_fss_mount_targets = [] # 10.20.20.64/26 (10,81) = 62 usable IPs (10.20.20.64 - 10.20.20.255)
}

# OKE Route Tables definitions
locals {
  route_tables_oke = [
    {
      route_table_name = "private"
      display_name     = "OKE Private Route Table (${local.deploy_id})"
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
      display_name     = "OKE Public Route Table (${local.deploy_id})"
      route_rules = [
        {
          description       = "Traffic to/from internet"
          destination       = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.gateways.internet_gateway_id
      }]
  }]
}

# OKE Security Lists definitions
locals {
  security_lists_oke = [
    {
      security_list_name = "oke_nodes_security_list"
      display_name       = "OKE Node Workers Security List (${local.deploy_id})"
      egress_security_rules = [
        {
          description      = "Allows communication from (or to) worker nodes"
          destination      = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Allow worker nodes to communicate with pods on other worker nodes (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "(optional) Allow worker nodes to communicate with internet"
          destination      = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
          destination      = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "ICMP Access from Kubernetes Control Plane"
          destination      = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.icmp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = { type = "3", code = "4" }
          }, {
          description      = "Access to Kubernetes API Endpoint"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Kubernetes worker to control plane communication"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_worker_to_control_plane_port_number, min = local.security_list_ports.k8s_worker_to_control_plane_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Path discovery"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.icmp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = { type = "3", code = "4" }
      }]
      ingress_security_rules = [
        {
          description  = "Allows communication from (or to) worker nodes"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Allow pods on one worker node to communicate with pods on other worker nodes (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "(optional) Allow inbound SSH traffic to worker nodes"
          source       = lookup(local.network_cidrs, (var.cluster_workers_visibility == "Private") ? "VCN-MAIN-CIDR" : "ALL-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.ssh_port_number, min = local.security_list_ports.ssh_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Allow control plane to communicate with worker nodes"
          source       = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Kubernetes API endpoint to worker node communication (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_api_endpoint_to_worker_port_number, min = local.security_list_ports.k8s_api_endpoint_to_worker_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Path discovery - Kubernetes API Endpoint"
          source       = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.icmp_protocol_number
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = { type = "3", code = "4" }
          }, {
          description  = "Path discovery"
          source       = lookup(local.network_cidrs, "ALL-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.icmp_protocol_number
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = { type = "3", code = "4" }
          }, {
          description  = "Load Balancer to Worker nodes node ports"
          source       = lookup(local.network_cidrs, "LB-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number # all_protocols
          stateless    = false
          tcp_options  = { max = 32767, min = 30000, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
      }]
    },
    {
      security_list_name = "oke_lb_security_list"
      display_name       = "OKE Load Balancer Security List (${local.deploy_id})"
      egress_security_rules = [
        {
          description      = "Allow traffic to worker nodes"
          destination      = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number # all_protocols
          stateless        = false
          tcp_options      = { max = 32767, min = 30000, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
      }]
      ingress_security_rules = [
        {
          description  = "Allow inbound traffic to Load Balancer"
          source       = lookup(local.network_cidrs, "ALL-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.https_port_number, min = local.security_list_ports.https_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
      }]
    },
    {
      security_list_name = "oke_endpoint_security_list"
      display_name       = "OKE K8s API Endpoint Security List (${local.deploy_id})"
      egress_security_rules = [
        {
          description      = "Allow Kubernetes API Endpoint to communicate with OKE"
          destination      = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.https_port_number, min = local.security_list_ports.https_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Path discovery"
          destination      = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.icmp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = { type = "3", code = "4" }
          }, {
          description      = "All traffic to worker nodes (when using flannel for pod networking)"
          destination      = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Kubernetes API endpoint to pod communication (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Kubernetes API endpoint to worker node communication (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_api_endpoint_to_worker_port_number, min = local.security_list_ports.k8s_api_endpoint_to_worker_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
      }]
      ingress_security_rules = [
        {
          description  = "(optional) Client access to Kubernetes API endpoint"
          source       = lookup(local.network_cidrs, (var.cluster_endpoint_visibility == "Private") ? "VCN-MAIN-CIDR" : "ALL-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Kubernetes worker to Kubernetes API endpoint communication"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Kubernetes worker to control plane communication"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_worker_to_control_plane_port_number, min = local.security_list_ports.k8s_worker_to_control_plane_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Path discovery"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.icmp_protocol_number
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = { type = "3", code = "4" }
          }, {
          description  = "Pod to Kubernetes API endpoint communication (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Pod to control plane communication (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_worker_to_control_plane_port_number, min = local.security_list_ports.k8s_worker_to_control_plane_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
      }]
    },
    {
      security_list_name = "oke_pod_network_security_list"
      display_name       = "OKE VCN Native Pod Networking Security List (${local.deploy_id})"
      egress_security_rules = [
        {
          description      = "Allow pods to communicate with each other"
          destination      = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Path discovery"
          destination      = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = local.security_list_ports.icmp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = { type = "3", code = "4" }
          }, {
          description      = "Allow worker nodes to communicate with OCI services"
          destination      = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Allow Pods to communicate with Worker Nodes"
          destination      = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Pod to Kubernetes API endpoint communication (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Pod to Kubernetes API endpoint communication (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_worker_to_control_plane_port_number, min = local.security_list_ports.k8s_worker_to_control_plane_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "(optional) Allow pods to communicate with internet"
          destination      = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.https_port_number, min = local.security_list_ports.https_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
      }]
      ingress_security_rules = [
        {
          description  = "Kubernetes API endpoint to pod communication (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Allow pods on one worker node to communicate with pods on other worker nodes"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Allow pods to communicate with each other"
          source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
      }]
    }
  ]
  security_list_ports = {
    http_port_number                        = 80
    https_port_number                       = 443
    k8s_api_endpoint_port_number            = 6443
    k8s_api_endpoint_to_worker_port_number  = 10250
    k8s_worker_to_control_plane_port_number = 12250
    ssh_port_number                         = 22
    tcp_protocol_number                     = "6"
    icmp_protocol_number                    = "1"
    all_protocols                           = "all"
  }
}