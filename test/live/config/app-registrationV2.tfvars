# config/app-registrationV2.tfvars
# Tracked, ready-to-run fixture for the test/live harness - one representative
# real-usage instance, not a two-code-path engineered fixture and not a
# dormant "_" template.
#
# No owners: the live-test job authenticates as a service principal (via
# OIDC), not an interactive user, so there's no UPN available to resolve
# through the module's `data "azuread_user" "owners"` lookup.

env     = "livetest"
group   = "opr"
project = "eslz"

app_registrations = {
  description = "module-live-test harness app registration"
  owners      = []

  azuread_application = {
    prevent_duplicate_names = true
    sign_in_audience        = "AzureADMyOrg"
  }

  azuread_service_principal = {
    account_enabled = true
  }
}
