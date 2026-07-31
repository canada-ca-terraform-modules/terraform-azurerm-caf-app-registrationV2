terraform {
  required_version = ">= 1.9"
}

variable "app_registrationsV2" {
  description = "List of AAD App Registrations to create"
  type        = any
  default     = {}
}

module "app_registrationsV2" {
  for_each = var.app_registrationsV2
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-app-registrationV2?ref=v1.1.0"

  env               = var.env
  group             = var.group
  project           = var.project
  app_registrations = each.value
  userDefinedString = each.key
}