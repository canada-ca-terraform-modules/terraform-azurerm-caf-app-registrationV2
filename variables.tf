variable "env" {
  description = "(Required) 4 character string defining the environment name prefix for the App Registration"
  type        = string
}

variable "group" {
  description = "(Required) Character string defining the group for the target subscription"
  type        = string
}

variable "project" {
  description = "(Required) Character string defining the project for the target subscription"
  type        = string
}

variable "app_registrations" {
  description = "AAD App Registration to create"
  type        = any
  default     = {}
}

variable "userDefinedString" {
  description = "(Required) User defined portion value for the name of the App Registration."
  type        = string
}
