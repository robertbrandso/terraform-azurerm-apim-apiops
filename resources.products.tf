# --------
# PRODUCTS
# --------
locals {
  # Path where the product files are located
  products_path = "${var.artifacts_path}/products"

  # Name of the files holding the information and policy
  product_information_file = var.product_information_filename
  product_policy_file      = var.product_policy_filename
  product_policy_fallback_file    = "policy.xml"

  # Lists all files in products folder
  all_product_files = fileset(local.products_path, "**")

  # Extracts directory names and removes duplicates. Each directory holds information about one API.
  products = toset(distinct([for key in local.all_product_files : dirname(key)]))
}

# Create product
resource "azurerm_api_management_product" "main" {
  for_each = toset([for product in local.products : product if fileexists("${local.products_path}/${product}/${local.product_information_file}")])

  product_id          = each.key
  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  display_name = jsondecode(file("${local.products_path}/${each.key}/${local.product_information_file}")).properties.displayName
  description  = jsondecode(file("${local.products_path}/${each.key}/${local.product_information_file}")).properties.description
  published    = jsondecode(file("${local.products_path}/${each.key}/${local.product_information_file}")).properties.published
  terms        = can(jsondecode(file("${local.products_path}/${each.key}/${local.product_information_file}")).properties.terms) ? jsondecode(file("${local.products_path}/${each.key}/${local.product_information_file}")).properties.terms : null

  subscription_required = jsondecode(file("${local.products_path}/${each.key}/${local.product_information_file}")).properties.subscriptionRequired
  approval_required     = jsondecode(file("${local.products_path}/${each.key}/${local.product_information_file}")).properties.approvalRequired
  subscriptions_limit   = can(jsondecode(file("${local.products_path}/${each.key}/${local.product_information_file}")).properties.subscriptionsLimit) ? jsondecode(file("${local.products_path}/${each.key}/${local.product_information_file}")).properties.subscriptionsLimit : null
}

# Add API(s) to product 
resource "azurerm_api_management_product_api" "main" {
  # Create set with "<product name>/<api name>". In this way we can then itterate over all APIs for each product
  for_each = toset(flatten(
    [for directory in local.products :
      [for api in jsondecode(file("${local.products_path}/${directory}/${local.product_information_file}")).properties.apis :
      "${directory}/${api}"] if
      fileexists("${local.products_path}/${directory}/${local.product_information_file}") &&
      can(jsondecode(file("${local.products_path}/${directory}/${local.product_information_file}")).properties.apis)
  ]))

  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  # Using regex to extract key product ID. The product ID is at the start of the string before the slash ("/")
  product_id = azurerm_api_management_product.main[regex("[^/]+", each.key)].product_id

  # Using regex to extract the API name. The API name is at the end of the string after the slash ("/")
  api_name = azurerm_api_management_api.main[regex("[^/]+$", each.key)].name
}

# Add group(s) to product
resource "azurerm_api_management_product_group" "main" {
  # Create set with "<product name>/<api name>". In this way we can then itterate over all groups for each product
  for_each = toset(flatten(
    [for directory in local.products :
      [for group in jsondecode(file("${local.products_path}/${directory}/${local.product_information_file}")).properties.groups :
      "${directory}/${group}"] if
      fileexists("${local.products_path}/${directory}/${local.product_information_file}") &&
      can(jsondecode(file("${local.products_path}/${directory}/${local.product_information_file}")).properties.groups)
  ]))

  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  # Using regex to extract key product ID. The product ID is at the start of the string before the slash ("/")
  product_id = azurerm_api_management_product.main[regex("[^/]+", each.key)].product_id

  # Using regex to extract the group name. The group name is at the end of the string after the slash ("/")
  # We do not reference another resource in Terraform configuration here, since a group may be both an Azure AD group, a local group and an already existing built-in group in APIM.
  # Also, we need to run the same lower and replace as done in azurerm_api_management_group.aad and azurerm_api_management_group.local, since group names may only contain alphanumeric characters, underscores and dashes up to 80 characters in length.
  group_name = lower(replace(regex("[^/]+$", each.key), "/[ .]/", "-"))

  # Groups needs to be created at APIM scope before assigned to product
  depends_on = [
    azurerm_api_management_group.aad,
    azurerm_api_management_group.local
  ]
}

# Assign tag(s) to Product
resource "azurerm_api_management_product_tag" "main" {
  # Create set with "<product name>/<tag name>". In this way we can then itterate over all tags for each product
  for_each = toset(flatten(
    [for directory in local.products :
      [for tag in jsondecode(file("${local.products_path}/${directory}/${local.product_information_file}")).properties.tags :
      "${directory}/${tag}"] if
      fileexists("${local.products_path}/${directory}/${local.product_information_file}") &&
      can(jsondecode(file("${local.products_path}/${directory}/${local.product_information_file}")).properties.tags)
  ]))

  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  # Using regex to extract key product ID. The product ID is at the start of the string before the slash ("/")
  api_management_product_id = azurerm_api_management_product.main[regex("[^/]+", each.key)].product_id

  # Using regex to extract the tag name. The tag name is at the end of the string after the slash ("/")
  name = azurerm_api_management_tag.main[regex("[^/]+$", each.key)].name
}

# Create Product policy
resource "azurerm_api_management_product_policy" "main" {
  # Only create if policy file and product information file exists.
  for_each = toset([
    for directory in local.products : directory if
    fileexists("${local.products_path}/${directory}/${local.product_information_file}") ||
    (
      fileexists("${local.products_path}/${directory}/${local.product_policy_file}") &&
      (
        var.product_policy_fallback_to_default_filename &&
        fileexists("${local.apis_path}/${directory}/${local.product_policy_fallback_file}")
      )
    )
  ])

  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  product_id  = azurerm_api_management_product.main[each.key].product_id

  # Using the value configured in local.product_policy_file if it exists. If the file doesn't exist, it looks for the fallback file (policy.xml) if the option is set to true in var.product_policy_fallback_to_default_filename.
  xml_content = fileexists("${local.apis_path}/${each.key}/${local.product_policy_file}") ? file("${local.apis_path}/${each.key}/${local.product_policy_file}") : (var.product_policy_fallback_to_default_filename && fileexists("${local.apis_path}/${each.key}/${local.product_policy_fallback_file}")) ? file("${local.apis_path}/${each.key}/${local.product_policy_fallback_file}") : null
}
