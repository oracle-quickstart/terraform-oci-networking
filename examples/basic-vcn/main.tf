module "oci-networking" {
  source = "github.com/oracle-quickstart/terraform-oci-networking?ref=0.2.0"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region

  # Note: Just few arguments are showing here to simplify the basic example. All other arguments are using default values.
  # App Name to identify deployment. Used for naming resources.
  app_name = "Basic"

  # Freeform Tags + Defined Tags. Tags are applied to all resources.
  tag_values = { "freeformTags" = { "Environment" = "Development", "DeploymentType" = "basic", "QuickstartExample" = "basic-vcn" }, "definedTags" = {} }

  subnets = [
    {
      subnet_name                = "test_subnet"
      cidr_block                 = cidrsubnet("10.10.0.0/16", 8, 35) # e.g.: "10.0.35.0/24" = 254 usable IPs (10.20.35.0 - 10.20.35.255)
      display_name               = "Test subnet (Basic)"
      dns_label                  = null
      prohibit_public_ip_on_vnic = false
      prohibit_internet_ingress  = false
      route_table_id             = ""
      dhcp_options_id            = ""
      security_list_ids          = []
      ipv6cidr_block             = null
    },
  ]
}