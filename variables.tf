# ---------
# VARIABLES
# ---------

# Basics
variable "artifacts_path" {
  description = "(Required) Artifacts folder path. Path should be relative to your root module path."
  type        = string
  default     = "artifacts"
}

variable "allow_api_without_path" {
  description = "(Optional) Set to 'true' if you want it to be possible to publish API without path / API URL suffix."
  type        = bool
  default     = false
}

# API Management
variable "api_management_name" {
  description = "(Required) The name of the API Management Service."
  type        = string
}

variable "api_management_resource_group_name" {
  description = "(Required) The name of the Resource Group in which the API Management Service exists."
  type        = string
}

# Application Insights
## Only needed if diagnostic logs are configured on an API
variable "application_insights_name" {
  description = "(Optional) The name of the Application Insights component used for diagnostic logs."
  type        = string
  default     = null
}

variable "application_insights_resource_group_name" {
  description = "(Optional) The name of the Resource Group in which the pplication Insights component exists."
  type        = string
  default     = null
}
