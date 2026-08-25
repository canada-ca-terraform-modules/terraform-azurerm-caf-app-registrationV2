# Rename from the original (badly named) .test instance to .delegated_permission_grant.
# This block performs a zero-churn state migration for existing deployments.
# Safe to remove once all consumers have applied v1.1.0 or later.
moved {
  from = azuread_service_principal_delegated_permission_grant.test
  to   = azuread_service_principal_delegated_permission_grant.delegated_permission_grant
}
