terraform {
  required_version = ">= 1.9"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azuread" {}

# no-op: touches this file so PR B's diff matches live-test.yml's on.pull_request.paths filter
module "app_registration" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  source = "../../"

  env     = var.env
  group   = var.group
  project = var.project
  # pr_number suffix keeps two concurrently open PRs against this module
  # from colliding on the same tenant-wide app registration display_name -
  # this module owns no azurerm resource group to suffix instead.
  userDefinedString = "livetest-${var.pr_number}"
  app_registrations = var.app_registrations
}
