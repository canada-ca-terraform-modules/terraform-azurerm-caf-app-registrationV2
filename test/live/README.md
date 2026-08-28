# `test/live/` - manual live-Azure-AD harness

A live, real-Entra-ID-resource harness for `terraform-azurerm-caf-app-registrationV2`.
**This is manual-run only** - there is no `live-test.yml` CI workflow for this
module. Automated per-PR live-testing (the pattern used by other modules in
this org, e.g. `terraform-azurerm-caf-keyvault`) was tried here and decommissioned:
the shared live-test sandbox identity (`id-live-test-sandbox`) has Azure RBAC
on the sandbox subscription but no Entra ID/Graph directory role (e.g.
`Application.ReadWrite.All`), which `azuread_application`/`azuread_service_principal`
management requires. The first automated run failed with
`403 Authorization_RequestDenied: Insufficient privileges` while patching a
just-created application, and left an orphaned `azuread_application` in the
tenant that had to be cleaned up by hand. Granting that Graph role to a
shared, multi-module CI identity was judged too broad a permission grant, so
the workflow automation was removed rather than pursued further.

This harness is **not** a substitute for the module's other test surface:

- **`tests/*.tftest.hcl`** - mock-based unit tests (`terraform test`, no
  provider credentials, no live Azure AD resources). Covers naming,
  defaults, and upgrade-compat logic. Run these first; they're fast and free.
- **`ESLZ/`** - a usage example showing the map-based (`for_each`) blueprint
  pattern consumers actually wire this module into. Documentation only.
- **`test/live/`** (this directory) - a single, real instance of the module
  applied against Entra ID, run by hand with your own credentials.

## What's here

| File | Purpose |
|---|---|
| `main.tf` | Module block with `source = "../../"` (a relative path to this repo checkout), the `azuread` provider config (uses your ambient `az login` session - no explicit credentials), and an empty `backend "local" {}` block. |
| `variables.tf` | `env`, `group`, `project` (display_name segments), `pr_number` (defaults to `"manual"`, only relevant if you want to run two instances side by side without a name collision), and `app_registrations` (typed `any`, passed straight through to the module). |
| `config/app-registrationV2.tfvars` | One representative real-usage fixture: no owners, a minimal `azuread_application`/`azuread_service_principal` block. |

This module owns no `azurerm` resource (it's Azure AD-only via the
`azuread` provider), so there's no `test_dependencies.tf` here - unlike
modules that need a throwaway resource group.

No Terragrunt anywhere under this directory - a single harness per repo has
no cross-harness DRY need.

## Running it manually

Requires your own `az login` session, authenticated as a user or principal
with permission to create app registrations and service principals in the
target tenant (e.g. Application Administrator / Cloud Application
Administrator, or Global Administrator).

```bash
cd test/live
terraform init
terraform plan  -var-file=config/app-registrationV2.tfvars
terraform apply -var-file=config/app-registrationV2.tfvars
```

Confirm only `module.app_registration`'s app registration and service
principal are planned/applied, then tear it down once you're done:

```bash
terraform destroy -var-file=config/app-registrationV2.tfvars
```

No `.tfstate` file is ever committed under `test/live/` - keep every run
ephemeral and destroy it when finished so no orphaned app registration is
left in the tenant.

If you want to run two instances concurrently without a `display_name`
collision (both derive their name from `userDefinedString`, which is
suffixed with `var.pr_number` in `main.tf`), pass a distinct value:

```bash
terraform apply -var-file=config/app-registrationV2.tfvars -var="pr_number=<something-unique>"
```
