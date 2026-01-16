# -------
# OUTPUTS
# -------

output "api_management" {
  description = "The API Management resource."
  value = data.azurerm_api_management.main.resource_group_name
}

output "api_version_sets" {
  description = "The API Version Sets created."
  value       = azurerm_api_management_api_version_set.main[*]
}

output "apis" {
  description = "The APIs created."
  value       = azurerm_api_management_api.main[*]
}

output "backends" {
  description = "The Backends created."
  value       = azurerm_api_management_backend.main[*]
}

output "named_values" {
  description = "The Named Values created."
  value       = azurerm_api_management_named_value.main[*]
}

output "products" {
  description = "The Products created."
  value       = azurerm_api_management_product.main[*]
}
