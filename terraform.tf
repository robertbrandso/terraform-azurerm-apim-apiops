# ----------------------
# TERRAFORM REQUIREMENTS
# ----------------------
terraform {
  # Terraform version
  required_version = ">= 1.4.0" # Not tested on Terraform version below 1.4.0, but will probably work.

  # Provider versions
  required_providers {
    azurerm = {
      version = ">= 3.50" # Not tested on provider version below 3.50, but will probably work.
    }
    azuread = {
      version = ">= 2.36" # Not tested on provider version below 2.36, but will probably work.
    }
  }
}
