output "aad_app_object" {
  value       = azuread_application.aad_app
  description = "Azure AD Application object"
}

output "aad_sp_object" {
  value       = azuread_service_principal.aad_sp
  description = "Azure AD Service Principal object"
}