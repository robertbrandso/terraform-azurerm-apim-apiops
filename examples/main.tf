provider "azurerm" {
  features {}
}

module "apiops" {
  source = ".."

  # Basics
  artifacts_path         = "artifacts"
  allow_api_without_path = true

  # API Management
  api_management_name                = "apim-example-prod"
  api_management_resource_group_name = "rg-example-apim-prod"

  # Application Insights
  ## Only needed if diagnostic logs are configured on an API
  application_insights_name                = "appi-apim-example-prod"
  application_insights_resource_group_name = "rg-example-apim-prod"
}