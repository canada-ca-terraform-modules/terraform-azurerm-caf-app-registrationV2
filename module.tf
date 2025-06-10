data "azurerm_client_config" "current" {}

data "azuread_user" "owners" {
  for_each = toset(try(var.app_registrations.owners, []))

  user_principal_name = each.value
}

locals {
  # owners_list = data.azuread_user.owners[*].object_id
  owners_list = [for owner in data.azuread_user.owners : owner.object_id]
}

resource "azuread_application" "aad_app" {
  display_name                   = try(var.app_registrations.azuread_application.custom_display_name, "") == "" ? "${var.env}_${var.group}_${var.project}_${var.userDefinedString}_sp" : var.app_registrations.azuread_application.custom_display_name
  owners                         = local.owners_list
  description                    = "${var.env}-${var.group}-${var.project} ${var.app_registrations.description}"
  prevent_duplicate_names        = try(var.app_registrations.azuread_application.prevent_duplicate_names, true)
  device_only_auth_enabled       = try(var.app_registrations.azuread_application.device_only_auth_enabled, false)
  fallback_public_client_enabled = try(var.app_registrations.azuread_application.fallback_public_client_enabled, false)
  group_membership_claims        = try(var.app_registrations.azuread_application.group_membership_claims, [])
  identifier_uris                = try(var.app_registrations.azuread_application.identifier_uris, [])
  logo_image                     = try(var.app_registrations.azuread_application.logo_image, null)
  marketing_url                  = try(var.app_registrations.azuread_application.marketing_url, null)
  notes                          = try(var.app_registrations.azuread_application.notes, null)
  oauth2_post_response_required  = try(var.app_registrations.azuread_application.oauth2_post_response_required, false)
  privacy_statement_url          = try(var.app_registrations.azuread_application.privacy_statement_url, null)
  service_management_reference   = try(var.app_registrations.azuread_application.service_management_reference, null)
  sign_in_audience               = try(var.app_registrations.azuread_application.sign_in_audience, "AzureADMyOrg")
  support_url                    = try(var.app_registrations.azuread_application.support_url, null)
  tags                           = try(var.app_registrations.azuread_application.tags, null)
  template_id                    = try(var.app_registrations.azuread_application.template_id, null)
  terms_of_service_url           = try(var.app_registrations.azuread_application.terms_of_service_url, null)

  dynamic "api" {
    for_each = try(var.app_registrations.azuread_application.api, {})
    content {
      mapped_claims_enabled          = try(api.value.mapped_claims_enabled, false)
      known_client_applications      = try(api.value.known_client_applications, [])
      requested_access_token_version = try(api.value.requested_access_token_version, 1)

      dynamic "oauth2_permission_scope" {
        for_each = try(api.value.oauth2_permission_scope, {})
        content {
          admin_consent_description  = oauth2_permission_scope.value.admin_consent_description
          admin_consent_display_name = oauth2_permission_scope.value.admin_consent_display_name
          enabled                    = try(oauth2_permission_scope.value.enabled, true)
          id                         = oauth2_permission_scope.value.id
          type                       = try(oauth2_permission_scope.value.type, "User")
          user_consent_description   = try(oauth2_permission_scope.value.user_consent_description, "")
          user_consent_display_name  = try(oauth2_permission_scope.value.user_consent_display_name, "")
          value                      = try(oauth2_permission_scope.value.value, "")
        }
      }
    }
  }

  # Application roles
  dynamic "app_role" {
    for_each = try(var.app_registrations.azuread_application.app_role, {})
    content {
      allowed_member_types = app_role.value.allowed_member_types
      description          = app_role.value.description
      display_name         = app_role.value.display_name
      enabled              = try(app_role.value.enabled, true)
      id                   = app_role.value.id
      value                = try(app_role.value.value, "")
    }
  }

  # Use feature_tags instead of tags if provided (they’re mutually exclusive)
  dynamic "feature_tags" {
    for_each = try(var.app_registrations.azuread_application.feature_tags, {})
    content {
      custom_single_sign_on = try(feature_tags.value.custom_single_sign_on, false)
      enterprise            = try(feature_tags.value.enterprise, false)
      gallery               = try(feature_tags.value.gallery, false)
      hide                  = try(feature_tags.value.hide, false)
    }
  }

  # Optional claims (with nested dynamic blocks)
  dynamic "optional_claims" {
    for_each = try(var.app_registrations.azuread_application.optional_claims, {})
    content {
      dynamic "access_token" {
        for_each = try(optional_claims.value.access_token, {})
        content {
          additional_properties = access_token.value.additional_properties
          essential             = try(access_token.value.essential, false)
          name                  = access_token.value.name
          source                = try(access_token.value.source, null)
        }
      }
      dynamic "id_token" {
        for_each = try(optional_claims.value.id_token, {})
        content {
          additional_properties = id_token.value.additional_properties
          essential             = try(id_token.value.essential, false)
          name                  = id_token.value.name
          source                = try(id_token.value.source, null)
        }
      }
      dynamic "saml2_token" {
        for_each = try(optional_claims.value.saml2_token, {})
        content {
          additional_properties = saml2_token.value.additional_properties
          essential             = try(saml2_token.value.essential, false)
          name                  = saml2_token.value.name
          source                = try(saml2_token.value.source, null)
        }
      }
    }
  }

  # Password block (only one password is allowed; using dynamic so it’s optional)
  dynamic "password" {
    for_each = try(var.app_registrations.azuread_application.password, {})
    content {
      display_name = password.value.display_name
      end_date     = try(password.value.end_date, null)
      start_date   = try(password.value.start_date, null)
    }
  }

  # Public client settings
  dynamic "public_client" {
    for_each = try(var.app_registrations.azuread_application.public_client, {})
    content {
      redirect_uris = try(public_client.value.redirect_uris, [])
    }
  }


  dynamic "required_resource_access" {
    for_each = try(var.app_registrations.azuread_application.required_resource_access, {})
    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_access
        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }

  # Single page application settings
  dynamic "single_page_application" {
    for_each = try(var.app_registrations.azuread_application.single_page_application, {})
    content {
      redirect_uris = try(single_page_application.value.redirect_uris, [])
    }
  }

  # Web settings, including an implicit_grant block
  dynamic "web" {
    for_each = try(var.app_registrations.azuread_application.web, {})
    content {
      homepage_url  = try(web.value.homepage_url, null)
      logout_url    = try(web.value.logout_url, null)
      redirect_uris = try(web.value.redirect_uris, [])
      dynamic "implicit_grant" {
        for_each = try(web.value.implicit_grant, {})
        content {
          access_token_issuance_enabled = try(implicit_grant.value.access_token_issuance_enabled, false)
          id_token_issuance_enabled     = try(implicit_grant.value.id_token_issuance_enabled, false)
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [owners]
  }
}

resource "azuread_service_principal" "aad_sp" {
  client_id = azuread_application.aad_app.client_id

  account_enabled               = try(var.app_registrations.azuread_service_principal.account_enabled, true)
  alternative_names             = try(var.app_registrations.azuread_service_principal.alternative_names, [])
  app_role_assignment_required  = try(var.app_registrations.azuread_service_principal.app_role_assignment_required, false)
  description                   = "${var.env}-${var.group}-${var.project} ${var.app_registrations.description}"
  login_url                     = try(var.app_registrations.azuread_service_principal.login_url, null)
  notes                         = try(var.app_registrations.azuread_service_principal.notes, null)
  notification_email_addresses  = try(var.app_registrations.azuread_service_principal.notification_email_addresses, [])
  owners                        = local.owners_list
  preferred_single_sign_on_mode = try(var.app_registrations.azuread_service_principal.preferred_single_sign_on_mode, "")
  tags                          = try(var.app_registrations.azuread_service_principal.tags, null)
  use_existing                  = try(var.app_registrations.azuread_service_principal.use_existing, false)

  # Feature tags (mutually exclusive with tags)
  dynamic "feature_tags" {
    for_each = try(var.app_registrations.azuread_service_principal.feature_tags, {})
    content {
      custom_single_sign_on = try(feature_tags.value.custom_single_sign_on, false)
      enterprise            = try(feature_tags.value.enterprise, false)
      gallery               = try(feature_tags.value.gallery, false)
      hide                  = try(feature_tags.value.hide, false)
    }
  }

  # SAML Single Sign-On configuration (optional block)
  dynamic "saml_single_sign_on" {
    for_each = try(var.app_registrations.azuread_service_principal.saml_single_sign_on, {})
    content {
      relay_state = try(saml_single_sign_on.value.relay_state, null)
    }
  }

  lifecycle {
    ignore_changes = [owners]
  }
}

data "azuread_application_published_app_ids" "well_known" {}  

data "azuread_service_principal" "delegated_apps" {
  for_each = try(var.app_registrations.azuread_application.delegated_permission, {})
  client_id = data.azuread_application_published_app_ids.well_known.result[each.key]
}

data "azuread_service_principal" "service_principals" {
  for_each = toset([for required_resource in try(var.app_registrations.azuread_application.required_resource_access, {}) : required_resource.resource_app_id])

  client_id = each.value
}

resource "azuread_app_role_assignment" "assignment" {
  for_each = local.app_perm
  app_role_id = each.value.id
  principal_object_id = azuread_service_principal.aad_sp.object_id
  resource_object_id = each.value.resource_app_id
  depends_on = [ azuread_application.aad_app, azuread_service_principal.aad_sp ]
}

resource "azuread_service_principal_delegated_permission_grant" "test" {
  for_each = local.delegated_perm
  service_principal_object_id = azuread_service_principal.aad_sp.object_id
  resource_service_principal_object_id = each.value.resource_sp
  claim_values = each.value.permission
}
