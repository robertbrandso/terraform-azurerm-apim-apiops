# -------
# OUTPUTS
# -------

output "api_management" {
  description = "The API Management resource."
  value       = data.azurerm_api_management.main
}

output "api_version_sets" {
  description = "The API Version Sets created."
  value = {
    for version_set in azurerm_api_management_api_version_set.main :
    version_set.name => version_set
  }
}

output "apis" {
  description = "The APIs created."
  value = {
    for api in azurerm_api_management_api.main :
    api.name => api
  }
}

output "backends" {
  description = "The Backends created."
  value = {
    for backend in azurerm_api_management_backend.main :
    backend.name => backend
  }
}

output "named_values" {
  description = "The Named Values created."
  value = {
    for named_value in azurerm_api_management_named_value.main :
    named_value.name => named_value
  }
  sensitive = true
}

output "products" {
  description = "The Products created."
  value = {
    for product in azurerm_api_management_product.main :
    product.product_id => product
  }
}
