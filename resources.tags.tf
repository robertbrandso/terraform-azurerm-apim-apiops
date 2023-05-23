# --------
# API TAGS
# --------
locals {
  # Path where the tags information file are located
  tags_path = "${var.artifacts_path}/tags"

  # Name of the file holding the information
  tags_information_file = "tagsInformation.json"

  # Tags information file full path
  apim_tags = "${local.tags_path}/${local.tags_information_file}"
}

# Create tag on API Management scope
resource "azurerm_api_management_tag" "main" {
  for_each = can(jsondecode(file(local.apim_tags)).tags) ? { for name, display_name in jsondecode(file(local.apim_tags)).tags : name => display_name } : {}

  api_management_id = data.azurerm_api_management.main.id
  name              = each.key
  display_name      = each.value
}
