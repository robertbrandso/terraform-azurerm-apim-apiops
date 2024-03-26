# ------------
# CERTIFICATES
# ------------
locals {
  # Path where the certificate information file are located
  certificates_path = "${var.artifacts_path}/certificates"

  # Name of the file holding the information
  certificates_information_file = var.certificates_information_filename

  # Certificate information file full path
  certificates = "${local.certificates_path}/${local.certificates_information_file}"
}

# Add certificates on API Management scope
resource "azurerm_api_management_certificate" "main" {
  for_each = can(jsondecode(file(local.certificates)).certificates) ? toset(jsondecode(file(local.certificates)).certificates) : []

  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  # Using regex to extract certificate name. The certificate name is at the end of the string after the slash ("/")
  name = regex("[^/]+$", each.key)

  key_vault_secret_id = each.key

  # System Assigned identity of the API Management Service will be used as default to authenticate against Key Vault
}
