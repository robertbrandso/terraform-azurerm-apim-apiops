# -------
# OUTPUTS
# -------

output "apim_api_version_set_id" {
  description = "The ID of the API Version Sets created."
  value       = azurerm_api_management_api_version_set.main[*].id
}

output "apim_api_id" {
  description = "The ID of the APIs created."
  value       = azurerm_api_management_api.main[*].id
}

output "apim_backend_id" {
  description = "The ID of the Backends created."
  value       = azurerm_api_management_backend.main[*].id
}

output "apim_named_value_id" {
  description = "The ID of the Named Values created."
  value       = azurerm_api_management_named_value.main[*].id
}

output "apim_product_id" {
  description = "The ID of the Products created."
  value       = azurerm_api_management_product.main[*].id
}
