# ----
# DATA
# ----

data "azuread_client_config" "current" {}

data "azurerm_api_management" "main" {
  name                = var.api_management_name
  resource_group_name = var.api_management_resource_group_name
}

data "azurerm_application_insights" "main" {
  count = var.application_insights_name != null && var.application_insights_resource_group_name != null ? 1 : 0

  name                = var.application_insights_name
  resource_group_name = var.api_management_resource_group_name
}

# ------------------------------------------------
# Other resources are placed in seperated TF-files
# ------------------------------------------------
