# terraform-oci-networking
Terraform module to Quickstart deploy network resources on OCI and to be reused by other projects

# Terraform Oracle Cloud Infrastructure ([OCI][oci]) Networking Module

---
> __Warning__

$${\color{red}This \space is \space a \space pre-release \space version \space of \space the \space module, \space some \space features}$$
$${\color{red}have \space not \space been \space migrated \space from \space MuShop's}$$
$${\color{red}OKE \space Cluster \space deployment \space yet.}$$
---

[![Stack Release](https://img.shields.io/github/v/release/oracle-quickstart/terraform-oci-networking.svg)](https://github.com/oracle-quickstart/terraform-oci-networking/releases)
[![Stack Build](https://img.shields.io/github/workflow/status/oracle-quickstart/terraform-oci-networking/Generate%20stacks%20and%20publish%20release?label=stack&logo=oracle&logoColor=red)][magic_oke_stack]
![AquaSec TFSec](https://img.shields.io/github/workflow/status/oracle-quickstart/terraform-oci-networking/tfsec?label=tfsec&logo=aqua)
![Terraform](https://img.shields.io/badge/terraform->%3D%201.1-%235835CC.svg?logo=terraform)
![Stack License](https://img.shields.io/github/license/oracle-quickstart/terraform-oci-networking)
![Stack Downloads](https://img.shields.io/github/downloads/oracle-quickstart/terraform-oci-networking/total?logo=terraform)
[![GitHub issues](https://img.shields.io/github/issues/oracle-quickstart/terraform-oci-networking.svg)](https://github.com/oracle-quickstart/terraform-oci-networking/issues)

Terraform module to Quickstart deploy network resources on OCI and to be reused by other projects. This module is designed to be used with the [OCI Resource Manager][oci_rm] to deploy a cluster in a single step. The module can also be used with the [OCI Terraform Provider][oci_tf_provider] to deploy a cluster using local or CloudShell Terraform cli.

Sub modules are provided to create a cluster with a single node pool, or a cluster with multiple node pools. Enables Cluster Autoscaler, OCI Vault(KMS) for customer-managed encryption keys for secrets, block volumes. The module also provides a sub module to create a cluster with a single node pool and a private endpoint to Oracle Resource Manager (ORM).

## How is this Terraform Module versioned?

This Terraform Module follows the principles of [Semantic Versioning](http://semver.org/). You can find each new release,
along with the changelog, in the [Releases Page](https://github.com/hashicorp/terraform-google-consul/releases).

During initial development, the major version will be 0 (e.g., `0.x.y`), which indicates the code does not yet have a
stable API. Once we hit `1.0.0`, we will make every effort to maintain a backwards compatible API and use the MAJOR,
MINOR, and PATCH versions on each release to indicate any incompatibilities.

## Questions

If you have an issue or a question, please take a look at our [FAQs](./FAQs.md) or [open an issue](https://github.com/oracle-quickstart/terraform-oci-networking/issues/new).

## Contributing

This project welcomes contributions from the community. Before submitting a pull
request, see [CONTRIBUTING](./CONTRIBUTING.md) for details.

## License

Copyright (c) 2022 Oracle and/or its affiliates.
Released under the Universal Permissive License (UPL), Version 1.0.
See [LICENSE](./LICENSE) for more details.

[oci]: https://cloud.oracle.com/en_US/cloud-infrastructure
[oci_rm]: https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm
[oci_tf_provider]: https://www.terraform.io/docs/providers/oci/index.html
[magic_button]: https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg
[magic_oke_stack]: https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/terraform-oci-networking/releases/latest/download/terraform-oci-networking-stack.zip
