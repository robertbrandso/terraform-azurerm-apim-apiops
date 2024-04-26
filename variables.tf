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

# Filenames

## apiVersionSets
variable "api_version_set_information_filename" {
  description = "(Optional) Filename for the API Version Set configuration file."
  type        = string
  default     = "apiVersionSetInformation.json"
}

## apis
variable "api_information_filename" {
  description = "(Optional) Filename for the API configuration file."
  type        = string
  default     = "apiInformation.json"
}

variable "api_specification_filename_json" {
  description = "(Optional) Filename for the API specification JSON file."
  type        = string
  default     = "specification.json"
}

variable "api_specification_filename_yaml" {
  description = "(Optional) Filename for the API specification YAML file."
  type        = string
  default     = "specification.yaml"
}

variable "api_policy_filename" {
  description = "(Optional) Filename for the API policy file."
  type        = string
  default     = "policy.xml"
}

variable "api_policy_fallback_to_default_filename" {
  description = "(Optional) Option to fallback to policy.xml if policy file in var.api_policy_filename doesn't exist."
  type        = bool
  default     = false
}

## backends
variable "backend_information_filename" {
  description = "(Optional) Filename for the backend configuration file."
  type        = string
  default     = "backendInformation.json"
}

## certificates
variable "certificates_information_filename" {
  description = "(Optional) Filename for the certificates configuration file."
  type        = string
  default     = "certificatesInformation.json"
}

## groups
variable "groups_information_filename" {
  description = "(Optional) Filename for the groups configuration file."
  type        = string
  default     = "groupsInformation.json"
}

## named-values
variable "named_value_information_filename" {
  description = "(Optional) Filename for the named value configuration file."
  type        = string
  default     = "namedValueInformation.json"
}

## products
variable "product_information_filename" {
  description = "(Optional) Filename for the product configuration file."
  type        = string
  default     = "productInformation.json"
}

variable "product_policy_filename" {
  description = "(Optional) Filename for the product policy file."
  type        = string
  default     = "policy.xml"
}

variable "product_policy_fallback_to_default_filename" {
  description = "(Optional) Option to fallback to policy.xml if policy file in var.product_policy_filename doesn't exist."
  type        = bool
  default     = false
}

## tags
variable "tags_information_filename" {
  description = "(Optional) Filename for the tags configuration file."
  type        = string
  default     = "tagsInformation.json"
}
