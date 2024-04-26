# ----
# APIS
# ----
locals {
  # Path where the API files are located
  apis_path = "${var.artifacts_path}/apis"

  # Name of the files holding the information, specification and policy
  api_information_file        = var.api_information_filename
  api_specification_file_json = var.api_specification_filename_json
  api_specification_file_yaml = var.api_specification_filename_yaml
  api_policy_file             = var.api_policy_filename
  api_policy_fallback_file    = "policy.xml"

  # Lists all json files in apis folder
  all_api_files = fileset(local.apis_path, "**")

  # Extracts directory names and removes duplicates. Each directory holds information about one API.
  apis = distinct([for key in local.all_api_files : dirname(key)])
}

# Create API
resource "azurerm_api_management_api" "main" {
  # Create map with directory name as key and file type as value and only create if API files exists.
  # File type check only checks if json file exists, if not it assumes yaml.
  for_each = {
    for directory in local.apis : directory => fileexists("${local.apis_path}/${directory}/${local.api_specification_file_json}") ? "json" : "yaml" if
    fileexists("${local.apis_path}/${directory}/${local.api_information_file}") && (
      fileexists("${local.apis_path}/${directory}/${local.api_specification_file_json}") ||
      fileexists("${local.apis_path}/${directory}/${local.api_specification_file_yaml}")
    )
  }

  name                = lower(replace(each.key, " ", "-"))
  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name
  api_type            = "http"

  display_name = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.displayName
  description  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.description

  revision              = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.apiRevision) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.apiRevision : 1
  subscription_required = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.subscriptionRequired) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.subscriptionRequired : true
  protocols             = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.protocols) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.protocols : ["https"]

  service_url          = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.serviceUrl) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.serviceUrl : null
  terms_of_service_url = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.termsOfService) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.termsOfService : null

  # Set var.allow_api_without_path to false or true to choose between if the path property should be mandatory or not.
  # This is controlled and checked in the postcondition block.
  path = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.path) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.path : null

  # If version is set, version_set_id also need to be set.
  # version_set_id depends on azurerm_api_management_api_version_set.main
  version        = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.apiVersionSet) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.apiVersionSet.version : null
  version_set_id = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.apiVersionSet) ? azurerm_api_management_api_version_set.main[jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.apiVersionSet.versionSetName].id : null

  # Subscription key parameter names
  dynamic "subscription_key_parameter_names" {
    # Only create if subscriptionKeyParameterNames is defined in API information file
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.subscriptionKeyParameterNames) ? ["true"] : []
    content {
      header = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.subscriptionKeyParameterNames.header
      query  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.subscriptionKeyParameterNames.query
    }
  }

  # License
  dynamic "license" {
    # Only create if license is defined in API information file
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.license) ? ["true"] : []
    content {
      # Only create each property if value exists in specification file
      name = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.license.name) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.license.name : null
      url  = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.license.url) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.license.url : null
    }
  }

  # Contact
  dynamic "contact" {
    # Only create if contact is defined in API information file
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.contact) ? ["true"] : []
    content {
      # Only create each property if value exists in specification file
      name  = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.contact.name) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.contact.name : null
      email = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.contact.email) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.contact.email : null
      url   = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.contact.url) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.contact.url : null
    }
  }

  # Import specification file
  ## JSON
  dynamic "import" {
    # Checks if value is JSON
    for_each = each.value == "json" ? ["json"] : []
    content {
      content_format = "openapi+json"
      content_value  = file("${local.apis_path}/${each.key}/${local.api_specification_file_json}")
    }
  }
  ## YAML
  dynamic "import" {
    # Checks if value is YAML
    for_each = each.value == "yaml" ? ["yaml"] : []
    content {
      content_format = "openapi"
      content_value  = file("${local.apis_path}/${each.key}/${local.api_specification_file_yaml}")
    }
  }

  lifecycle {
    # Checking if no path is set to be allowed, and the actual value of the path property.
    # Set var.allow_api_without_path to false or true to choose between if the path property should be mandatory or not.
    postcondition {
      condition     = (self.path == "" || self.path == null) && var.allow_api_without_path == false ? false : true
      error_message = "API without path is not allowed. Set 'allow_api_without_path' to 'true' to allow this."
    }
  }
}

# Assign tag(s) on API
resource "azurerm_api_management_api_tag" "main" {
  # Create set with "<api name>/<tag name>". In this way we can then itterate over all tags for each API.
  # Only create if tags are defined in API information file, and a API specification file exists.
  for_each = toset(flatten(
    [for directory in local.apis :
      [for tag in jsondecode(file("${local.apis_path}/${directory}/${local.api_information_file}")).properties.tags :
      "${directory}/${tag}"] if
      can(jsondecode(file("${local.apis_path}/${directory}/${local.api_information_file}")).properties.tags) && (
        fileexists("${local.apis_path}/${directory}/${local.api_specification_file_json}") ||
      fileexists("${local.apis_path}/${directory}/${local.api_specification_file_yaml}"))
  ]))

  # Using regex to extract the API name. The API name is at the start of the string before the slash ("/")
  api_id = azurerm_api_management_api.main[regex("[^/]+", each.key)].id

  # Using regex to extract the tag name. The tag name is at the end of the string after the slash ("/")
  name = azurerm_api_management_tag.main[regex("[^/]+$", each.key)].name
}

# Create API policy
resource "azurerm_api_management_api_policy" "main" {
  # Only create if policy file exists. API files must also exists - if not the policy will not be created.
  for_each = toset([
    for directory in local.apis : directory if
    fileexists("${local.apis_path}/${directory}/${local.api_information_file}") &&
    (
      fileexists("${local.apis_path}/${directory}/${local.api_policy_file}") ||
      (
        var.api_policy_fallback_to_default_filename &&
        fileexists("${local.apis_path}/${directory}/${local.api_policy_fallback_file}")
      )
    ) &&
    (
      fileexists("${local.apis_path}/${directory}/${local.api_specification_file_json}") ||
      fileexists("${local.apis_path}/${directory}/${local.api_specification_file_yaml}")
    )
  ])

  api_management_name = data.azurerm_api_management.main.name
  resource_group_name = data.azurerm_api_management.main.resource_group_name

  api_name    = azurerm_api_management_api.main[each.key].name
  
  # Using the value configured in local.api_policy_file if it exists. If the file doesn't exist, it looks for the fallback file (policy.xml) if the option is set to true in var.api_policy_fallback_to_default_filename.
  xml_content = fileexists("${local.apis_path}/${each.key}/${local.api_policy_file}") ? file("${local.apis_path}/${each.key}/${local.api_policy_file}") : (var.api_policy_fallback_to_default_filename && fileexists("${local.apis_path}/${each.key}/${local.api_policy_fallback_file}")) ? file("${local.apis_path}/${each.key}/${local.api_policy_fallback_file}") : null
}

# Diagnostic log settings for API
resource "azurerm_api_management_api_diagnostic" "main" {
  # Only create if API files exists and diagnosticLogs is defined in API information file.
  # If not the diagnostic log settings will not be created.
  for_each = toset([
    for directory in local.apis : directory if
    fileexists("${local.apis_path}/${directory}/${local.api_information_file}") &&
    (
      fileexists("${local.apis_path}/${directory}/${local.api_specification_file_json}") ||
      fileexists("${local.apis_path}/${directory}/${local.api_specification_file_yaml}")
    ) &&
    can(jsondecode(file("${local.apis_path}/${directory}/${local.api_information_file}")).properties.diagnosticLogs)
  ])

  api_management_name      = data.azurerm_api_management.main.name
  resource_group_name      = data.azurerm_api_management.main.resource_group_name
  api_management_logger_id = "${data.azurerm_api_management.main.id}/loggers/${data.azurerm_application_insights.main[0].name}"

  api_name   = azurerm_api_management_api.main[each.key].name
  identifier = "applicationinsights"

  sampling_percentage       = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.samplingPercentage) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.samplingPercentage : 100
  always_log_errors         = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.alwaysLogErrors) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.alwaysLogErrors : false
  log_client_ip             = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.logClientIp) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.logClientIp : true
  verbosity                 = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.verbosity) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.verbosity : "information"
  http_correlation_protocol = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.correlationProtocol) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.correlationProtocol : "Legacy"
  operation_name_format     = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.operationNameFormat) ? jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.operationNameFormat : "Name"

  # Advanced options
  ## Frontend request
  dynamic "frontend_request" {
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests) ? ["true"] : []
    content {
      headers_to_log = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests.headersToLog
      body_bytes     = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests.bodyBytes
      dynamic "data_masking" {
        for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests.dataMasking) ? ["true"] : []
        content {
          dynamic "headers" {
            for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests.dataMasking.headers) ? ["true"] : []
            content {
              mode  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests.dataMasking.headers.mode
              value = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests.dataMasking.headers.value
            }
          }
          dynamic "query_params" {
            for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests.dataMasking.queryParams) ? ["true"] : []
            content {
              mode  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests.dataMasking.queryParams.mode
              value = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests.dataMasking.queryParams.value
            }
          }
        }
      }
    }
  }

  ### If removed from JSON, set values to null
  dynamic "frontend_request" {
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendRequests) ? [] : ["false"]
    content {
      headers_to_log = null
      body_bytes     = null
    }
  }

  ## Frontend response
  dynamic "frontend_response" {
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse) ? ["true"] : []
    content {
      headers_to_log = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse.headersToLog
      body_bytes     = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse.bodyBytes
      dynamic "data_masking" {
        for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse.dataMasking) ? ["true"] : []
        content {
          dynamic "headers" {
            for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse.dataMasking.headers) ? ["true"] : []
            content {
              mode  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse.dataMasking.headers.mode
              value = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse.dataMasking.headers.value
            }
          }
          dynamic "query_params" {
            for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse.dataMasking.queryParams) ? ["true"] : []
            content {
              mode  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse.dataMasking.queryParams.mode
              value = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse.dataMasking.queryParams.value
            }
          }
        }
      }
    }
  }

  ### If removed from JSON, set values to null
  dynamic "frontend_response" {
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.frontendResponse) ? [] : ["false"]
    content {
      headers_to_log = null
      body_bytes     = null
    }
  }

  ## Backend request
  dynamic "backend_request" {
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest) ? ["true"] : []
    content {
      headers_to_log = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest.headersToLog
      body_bytes     = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest.bodyBytes
      dynamic "data_masking" {
        for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest.dataMasking) ? ["true"] : []
        content {
          dynamic "headers" {
            for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest.dataMasking.headers) ? ["true"] : []
            content {
              mode  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest.dataMasking.headers.mode
              value = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest.dataMasking.headers.value
            }
          }
          dynamic "query_params" {
            for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest.dataMasking.queryParams) ? ["true"] : []
            content {
              mode  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest.dataMasking.queryParams.mode
              value = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest.dataMasking.queryParams.value
            }
          }
        }
      }
    }
  }

  ### If removed from JSON, set values to null
  dynamic "backend_request" {
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendRequest) ? [] : ["false"]
    content {
      headers_to_log = null
      body_bytes     = null
    }
  }

  ## Backend response
  dynamic "backend_response" {
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse) ? ["true"] : []
    content {
      headers_to_log = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse.headersToLog
      body_bytes     = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse.bodyBytes
      dynamic "data_masking" {
        for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse.dataMasking) ? ["true"] : []
        content {
          dynamic "headers" {
            for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse.dataMasking.headers) ? ["true"] : []
            content {
              mode  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse.dataMasking.headers.mode
              value = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse.dataMasking.headers.value
            }
          }
          dynamic "query_params" {
            for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse.dataMasking.queryParams) ? ["true"] : []
            content {
              mode  = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse.dataMasking.queryParams.mode
              value = jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse.dataMasking.queryParams.value
            }
          }
        }
      }
    }
  }

  ### If removed from JSON, set values to null
  dynamic "backend_request" {
    for_each = can(jsondecode(file("${local.apis_path}/${each.key}/${local.api_information_file}")).properties.diagnosticLogs.backendResponse) ? [] : ["false"]
    content {
      headers_to_log = null
      body_bytes     = null
    }
  }
}
