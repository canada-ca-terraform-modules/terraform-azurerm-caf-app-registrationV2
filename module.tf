data "azurerm_client_config" "current" {}

data "azuread_user" "owners" {
  for_each = toset(try(var.app_registrations.owners, []))

  user_principal_name = each.value
}

resource "azuread_application" "aad_app" {
  display_name            = "${var.env}_${var.group}_${var.project}_${var.userDefinedString}_sp"
  owners                  = try(var.app_registrations.owners, []) == [] ? [data.azurerm_client_config.current.object_id] : distinct(flatten([data.azurerm_client_config.current.object_id, data.azuread_user.owners[*].object_id]))
  description             = "${var.env}-${var.group}-${var.project} ${var.app_registrations.description}"
  prevent_duplicate_names = try(var.app_registrations.prevent_duplicate_names, true)

  lifecycle {
    ignore_changes = [owners]
  }
}

resource "azuread_service_principal" "aad_sp" {
  client_id                    = azuread_application.aad_app.client_id
  app_role_assignment_required = try(var.app_registrations.app_role_assignment_required, false)
  owners                       = try(var.app_registrations.owners, []) == [] ? [data.azurerm_client_config.current.object_id] : distinct(flatten([data.azurerm_client_config.current.object_id, data.azuread_user.owners[*].object_id]))
  description                  = "${var.env}-${var.group}-${var.project} ${var.app_registrations.description}"
  tags = try(var.app_registrations.tags, [])

  lifecycle {
    ignore_changes = [owners]
  }
}
