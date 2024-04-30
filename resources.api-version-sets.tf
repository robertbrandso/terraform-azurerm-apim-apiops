# ----------------
# API VERSION SETS
# ----------------
locals {
  # Path where the API version set files are located
  api_version_sets_path = "${var.artifacts_path}/apiVersionSets"

  # Name of the file holding the information
  api_version_set_information_file = var.api_version_set_information_filename

  # Lists all files in API version set folders
  all_api_version_sets_files = fileset(local.api_version_sets_path, "**")

  # Extracts directory names and removes duplicates. Each directory holds information about one API version set.
  api_version_sets = toset(distinct([for key in local.all_api_version_sets_files : dirname(key)]))
}

resource "azurerm_api_management_api_version_set" "main" {
  for_each = toset([for api_version_set in local.api_version_sets : api_version_set if fileexists("${local.api_version_sets_path}/${api_version_set}/${local.api_version_set_information_file}")])

  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  name              = each.key
  display_name      = jsondecode(file("${local.api_version_sets_path}/${each.key}/${local.api_version_set_information_file}")).properties.displayName
  versioning_scheme = jsondecode(file("${local.api_version_sets_path}/${each.key}/${local.api_version_set_information_file}")).properties.versioningScheme

  description         = try(jsondecode(file("${local.api_version_sets_path}/${each.key}/${local.api_version_set_information_file}")).properties.description, null)
  version_header_name = try(jsondecode(file("${local.api_version_sets_path}/${each.key}/${local.api_version_set_information_file}")).properties.versionHeaderName, null)
  version_query_name  = try(jsondecode(file("${local.api_version_sets_path}/${each.key}/${local.api_version_set_information_file}")).properties.versionQueryName, null)
}
