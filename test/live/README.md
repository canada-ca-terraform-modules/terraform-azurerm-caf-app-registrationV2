# `test/live/` - live-test harness

A live, real-Azure-resource harness used by the `live-test` PR check (see
the [`live-test-actions`](https://github.com/canada-ca-terraform-modules/live-test-actions)
repo and this module's own `.github/workflows/live-test.yml`) to prove that
an open PR doesn't destroy or replace a resource a real consumer already
has running. It is **not** a substitute for either of the module's other
two test surfaces:

- **`tests/*.tftest.hcl`** - mock-based unit tests (`terraform test`, no
  provider credentials, no live Azure AD resources). Covers naming,
  defaults, and upgrade-compat logic on every PR. Run these first; they're
  fast and free.
- **`ESLZ/`** - a usage example showing the map-based (`for_each`) blueprint
  pattern consumers actually wire this module into. Not exercised by CI at
  all; documentation only.
- **`test/live/`** (this directory) - a single, real instance of the module
  applied against the tenant used by the shared live-test sandbox
  subscription. Used by CI to diff the PR's plan against a live baseline,
  and can be run manually by a maintainer the same way.

## What's here

| File | Purpose |
|---|---|
| `main.tf` | Module block with `source = "../../"` (a relative path, not a pinned `?ref` - "baseline" and "PR" are just two on-disk checkouts of this repo), the `azuread` provider config (no explicit credentials - relies on the Azure CLI session `azure/login` establishes in CI), and an empty `backend "local" {}` block (path supplied at `init` time - see below). |
| `variables.tf` | `env`, `group`, `project` (display_name segments), `pr_number` (defaults to `"manual"`), and `app_registrations` (typed `any`, passed straight through to the module). |
| `config/app-registrationV2.tfvars` | One representative real-usage fixture: no owners (the live-test job authenticates as a service principal, not an interactive user, so there's no UPN to resolve), a minimal `azuread_application`/`azuread_service_principal` block. |

This module owns no `azurerm` resource (it's Azure AD-only via the
`azuread` provider), so there's no `test_dependencies.tf` here - unlike
modules that need a throwaway resource group. Concurrency isolation instead
comes from suffixing `userDefinedString` with `var.pr_number` in `main.tf`,
so two concurrently open PRs generate two distinctly-named app
registrations rather than colliding on the same `display_name`.

No Terragrunt anywhere under this directory - a single harness per repo has
no cross-harness DRY need.

## Running it manually

Requires your own `az login` session with permission to create app
registrations and service principals in the target tenant (CI uses OIDC
instead).

```bash
cd test/live
terraform init
terraform plan  -var-file=config/app-registrationV2.tfvars
terraform apply -var-file=config/app-registrationV2.tfvars
```

Confirm only `module.app_registration`'s app registration and service
principal are planned/applied, then tear it down:

```bash
terraform destroy -var-file=config/app-registrationV2.tfvars
```

No `.tfstate` file is ever committed under `test/live/` - every run is
fully ephemeral, whether run by CI or by hand.

## Two-checkout state isolation (baseline vs. PR)

CI proves a PR isn't a breaking change by applying the target branch as a
live baseline, then plan/apply-ing the PR branch's checkout of this same
harness against that same live state - two on-disk checkouts of this repo,
one shared external state file, no state copying between them:

```bash
# Directory A: PR branch checkout, directory B: target branch checkout.
STATE=$RUNNER_TEMP/live-test-<pr-number>.tfstate

# 1. Baseline apply, from B.
cd B/test/live
terraform init -backend-config="path=$STATE"
terraform apply -var-file=config/app-registrationV2.tfvars -var="pr_number=<pr-number>"

# 2. PR plan (and, in CI, apply), from A, against the same state file.
cd A/test/live
terraform init -backend-config="path=$STATE"
terraform plan -var-file=config/app-registrationV2.tfvars -var="pr_number=<pr-number>"

# 3. Always tear down from A once the run finishes (`if: always()` in CI).
terraform destroy -var-file=config/app-registrationV2.tfvars -var="pr_number=<pr-number>"
```

`pr_number` (`TF_VAR_pr_number` in CI, sourced from `github.event.number`)
suffixes the generated `display_name` (via `userDefinedString` in
`main.tf`), so two concurrently open PRs against this module never collide
on the same tenant-wide app registration name.

To verify this locally without CI: check out this branch into two
directories, run step 1 from one and step 2 from the other against a
shared local state file path, and confirm the plan in step 2 diffs against
the resources step 1 actually created (not an empty/fresh-state plan).
Repeat with two different `pr_number` values and confirm no display_name
collision.

