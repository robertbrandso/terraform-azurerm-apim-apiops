# Azure API Management (APIM) APIOps Terraform module
APIM APIOps allows you to publish and manage your APIs through Azure API Management (APIM) in a GitOps way. This means that all publishing and configuration of the APIs are done through a git repository. This is accomplished through configuration in JSON files, as well as the OpenAPI specification in either JSON or YAML format.

The API developers don't have to have any knowledge about Terraform, since all the configuration are done through JSON files.

## Resources
* [Wiki](https://github.com/robertbrandso/terraform-azurerm-apim-apiops/wiki)
* [Example configuration](https://github.com/robertbrandso/terraform-azurerm-apim-apiops/tree/main/examples)
* [Terraform registry](https://registry.terraform.io/modules/robertbrandso/apim-apiops)

## Architecture
The diagram below illustrates the flow of APIM APIOps.

![APIM APIOps flow](https://github.com/robertbrandso/terraform-azurerm-apim-apiops/wiki/images/apiops-flow.png)