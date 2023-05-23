# --------
# BACKENDS
# --------
locals {
  # Path where the backend files are located
  backend_path = "${var.artifacts_path}/backends"

  # Name of the file holding the information
  backend_information_file = "backendInformation.json"

  # Lists all files in backend folder
  all_backend_files = fileset(local.backend_path, "**")

  # Extracts directory names and removes duplicates. Each directory holds information about one backend.
  backends = toset(distinct([for key in local.all_backend_files : dirname(key)]))
}

# Create backend
resource "azurerm_api_management_backend" "main" {
  # Only create if backend information file exists in folder
  for_each = toset([for backend in local.backends : backend if fileexists("${local.backend_path}/${backend}/${local.backend_information_file}")])

  name                = each.key
  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  description = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.description) ? jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.description : null
  protocol    = "http"

  url         = jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.url
  resource_id = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.azureResourceManagerId) ? jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.azureResourceManagerId : null

  dynamic "tls" {
    # Only create if validateCertificateChain and/or validateCertificateName is defined
    for_each = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.validateCertificateChain) || can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.validateCertificateName) ? ["true"] : []
    content {
      validate_certificate_chain = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.validateCertificateChain) ? jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.validateCertificateChain : null
      validate_certificate_name  = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.validateCertificateName) ? jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.validateCertificateName : null
    }
  }

  dynamic "credentials" {
    for_each = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials) ? ["true"] : []
    content {
      # Reference to a named value in "header" need to be referenced as "{{named-value-name}}". Source: https://github.com/hashicorp/terraform-provider-azurerm/issues/14548
      header = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials.headers) ? jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials.headers : null
      query  = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials.query) ? jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials.query : null

      # If the certificate property in backend information file is present, add the certificate(s).
      # For loop creates new list with thumbprints which is retrived from azurerm_api_management_certificate.main.
      # Value in certificate property in backend information file need to be the same value as in certificate information file.
      certificate = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials.certificates) ? [
        for certificate in jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials.certificates
        : azurerm_api_management_certificate.main[certificate].thumbprint
      ] : null

      dynamic "authorization" {
        for_each = can(jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials.authorization) ? ["true"] : []
        content {
          scheme    = jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials.authorization.scheme
          parameter = jsondecode(file("${local.backend_path}/${each.key}/${local.backend_information_file}")).properties.credentials.authorization.parameter
        }
      }
    }
  }

  # If referenced, named value and certificate must exist before backend is created
  depends_on = [
    azurerm_api_management_named_value.main,
    azurerm_api_management_certificate.main
  ]
}
