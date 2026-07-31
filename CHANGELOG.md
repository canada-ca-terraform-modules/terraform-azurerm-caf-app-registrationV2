# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- Bumped `azuread` provider constraint to `~> 3.0` and confirmed compatibility of all `azuread_*` resources/data sources against the current provider documentation.
- Bumped `ESLZ/app_registrationV2.tf` module `source` ref from `v1.0.2` to `v1.1.0`.
- `azuread_service_principal_delegated_permission_grant.test` renamed to `azuread_service_principal_delegated_permission_grant.delegated_permission_grant` via a `moved` block (no state churn for existing deployments) — see `moved.tf`.
- Outputs `aad_app_object` / `aad_sp_object` marked `sensitive = true` since they expose full resource objects.

### Removed

- Removed unused `azurerm` provider requirement (`providers.tf`) and `mock_provider "azurerm"` from test files — this module only manages `azuread_*` resources and never referenced `azurerm_*` resources or data sources; the prior README entry for `azurerm_client_config.current` was stale/unused.
- Removed unused `location` and `tags` root input variables — dead placeholders carried over from a copy-pasted VM module template, never referenced by any resource/local in this module and not exposed by the `ESLZ/app_registrationV2.tf` wrapper.
- Removed dead commented-out variable blocks (`vmss`, `resource_groups`, `subnets`, `custom_data`, `user_data`) left over from the same copy-paste.
- Deleted empty `name.tf` (contained no live locals after cleanup).

### Added

- `providers.tf` with pinned `required_providers` (previously implicit/missing).
- `tests/upgrade_compat.tftest.hcl` — state-chaining compatibility test (`apply` baseline, then `plan` against upgraded config) verifying no resource replacement is triggered by this upgrade.
- `.tflint.hcl`, `.gitignore`, `.gitattributes` added/standardized.

### Known blockers

- None.
