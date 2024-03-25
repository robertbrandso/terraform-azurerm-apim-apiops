# ------------
# NAMED VALUES
# ------------
locals {
  # Path where the named value files are located
  named_values_path = "${var.artifacts_path}/namedValues"

  # Name of the file holding the information
  named_value_information_file = var.named_value_information_filename

  # Lists all files in named value folder
  all_named_values_files = fileset(local.named_values_path, "**")

  # Extracts directory names and removes duplicates. Each directory holds information about one named value.
  named_values = toset(distinct([for key in local.all_named_values_files : dirname(key)]))
}

# Create named value
resource "azurerm_api_management_named_value" "main" {
  # Only create if named value information file exists in folder
  for_each = toset([for named_value in local.named_values : named_value if fileexists("${local.named_values_path}/${named_value}/${local.named_value_information_file}")])

  name                = each.key
  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  display_name = jsondecode(file("${local.named_values_path}/${each.key}/${local.named_value_information_file}")).properties.displayName

  value  = can(jsondecode(file("${local.named_values_path}/${each.key}/${local.named_value_information_file}")).properties.value) ? jsondecode(file("${local.named_values_path}/${each.key}/${local.named_value_information_file}")).properties.value : null
  secret = can(jsondecode(file("${local.named_values_path}/${each.key}/${local.named_value_information_file}")).properties.keyVaultSecretId) ? true : false

  # System Assigned identity of the API Management Service will be used as default to authenticate against Key Vault
  dynamic "value_from_key_vault" {
    for_each = can(jsondecode(file("${local.named_values_path}/${each.key}/${local.named_value_information_file}")).properties.keyVaultSecretId) ? ["true"] : []
    content {
      secret_id = jsondecode(file("${local.named_values_path}/${each.key}/${local.named_value_information_file}")).properties.keyVaultSecretId
    }
  }

  tags = can(jsondecode(file("${local.named_values_path}/${each.key}/${local.named_value_information_file}")).properties.tags) ? jsondecode(file("${local.named_values_path}/${each.key}/${local.named_value_information_file}")).properties.tags : null
}
