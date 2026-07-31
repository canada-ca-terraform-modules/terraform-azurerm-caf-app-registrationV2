# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-07-31

### Changed

- Bumped `azuread` provider constraint to `~> 3.0` and confirmed compatibility of all `azuread_*` resources/data sources against the current provider documentation.
- Bumped `ESLZ/app_registrationV2.tf` module `source` ref from `v1.0.2` to `v1.1.0`.
- `azuread_service_principal_delegated_permission_grant.test` renamed to `azuread_service_principal_delegated_permission_grant.delegated_permission_grant` via a `moved` block (no state churn for existing deployments) — see `moved.tf`.
- Outputs `aad_app_object` / `aad_sp_object` marked `sensitive = true` since they expose full resource objects.
- `preferred_single_sign_on_mode` default changed from `""` to `null` to avoid sending an empty string to the Azure AD API when the attribute is not configured.
- Fixed `ESLZ/app_registrationV2.tf` module source URL: corrected typo in repository name (`app_registrationV2` → `app-registrationV2`); the underscore would cause a 404 on `terraform init`.
- Documented module-specific `grant_admin_consent` attribute on `required_resource_access.resource_access` entries in `ESLZ/app_registrationV2.tfvars` — without this flag, `azuread_app_role_assignment` resources are not created even when permissions are declared.

### Removed

- Removed unused `azurerm` provider requirement (`providers.tf`) and `mock_provider "azurerm"` from test files — this module only manages `azuread_*` resources and never referenced `azurerm_*` resources or data sources; the prior README entry for `azurerm_client_config.current` was stale/unused.
- Removed unused `location` and `tags` root input variables — dead placeholders carried over from a copy-pasted VM module template, never referenced by any resource/local in this module and not exposed by the `ESLZ/app_registrationV2.tf` wrapper.
- Removed dead commented-out variable blocks (`vmss`, `resource_groups`, `subnets`, `custom_data`, `user_data`) left over from the same copy-paste.
- Deleted empty `name.tf` (contained no live locals after cleanup).

### Added

- `providers.tf` with pinned `required_providers` (previously implicit/missing).
- `tests/upgrade_compat.tftest.hcl` — state-chaining compatibility test (`apply` baseline, then `plan` against upgraded config) verifying no resource replacement is triggered by this upgrade.
- `.tflint.hcl`, `.gitignore`, `.gitattributes` added/standardized.
- README `Notes` section documenting the `owners` `ignore_changes` lifecycle behaviour on `azuread_application`/`azuread_service_principal`.
- `tests/app_registration.tftest.hcl` — `app_role_assignment_created_on_admin_consent` run exercising the `grant_admin_consent` → `azuread_app_role_assignment` path (previously untested).

### Changed (PR review follow-up)

- `data.azuread_service_principal.service_principals` `for_each` now only resolves resource app IDs that have at least one `resource_access` entry with `grant_admin_consent = true`, instead of every entry in `required_resource_access` — avoids unnecessary API calls and reduces the SP-read permission surface needed by the caller's credentials.
- Clarified the `upgrade_plan_no_replacement` test comment in `tests/upgrade_compat.tftest.hcl`: the Terraform 1.x `test` framework's `assert` blocks can only verify planned attribute values, not planned resource actions (create/update/replace), so the run proves stable attributes rather than a guaranteed no-replace plan.

### Known blockers

- None.
