variable "env" {
  description = "Environment prefix used in the generated App Registration display_name"
  type        = string
  default     = "livetest"
}

variable "group" {
  description = "Group segment used in the generated App Registration display_name"
  type        = string
  default     = "opr"
}

variable "project" {
  description = "Project segment used in the generated App Registration display_name"
  type        = string
  default     = "eslz"
}

variable "pr_number" {
  description = <<-EOT
    Suffix applied to the generated display_name so concurrent PRs against
    this module never collide on the same tenant-wide app registration name.
    CI sources this from `TF_VAR_pr_number` (`github.event.number`); manual
    runs can leave the default or pass their own value.
  EOT
  type        = string
  default     = "manual"
}

variable "app_registrations" {
  description = "App registration configuration object, passed straight through to the module under test"
  type        = any
}
