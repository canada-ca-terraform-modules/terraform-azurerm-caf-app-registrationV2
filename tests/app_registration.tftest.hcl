# tests/app_registration.tftest.hcl
# Functional (mock_provider) tests — no Azure credentials needed.
mock_provider "azuread" {}

variables {
  env               = "Dev"
  group             = "OPS"
  project           = "CORE"
  userDefinedString = "test"
}

run "naming_convention" {
  command = plan

  variables {
    app_registrations = {
      description = "Test App Registration"
      owners      = []
      azuread_application = {
        prevent_duplicate_names = true
      }
    }
  }

  assert {
    condition     = azuread_application.aad_app.display_name == "Dev_OPS_CORE_test_sp"
    error_message = "Default display_name must follow {env}_{group}_{project}_{userDefinedString}_sp convention"
  }
}

run "custom_display_name_override" {
  command = plan

  variables {
    app_registrations = {
      description = "Test App Registration"
      owners      = []
      azuread_application = {
        custom_display_name     = "myCustomDisplayName"
        prevent_duplicate_names = true
      }
    }
  }

  assert {
    condition     = azuread_application.aad_app.display_name == "myCustomDisplayName"
    error_message = "custom_display_name override must take priority over generated display_name"
  }
}

run "default_values" {
  command = plan

  variables {
    app_registrations = {
      description = "Minimal App Registration"
    }
  }

  assert {
    condition     = azuread_application.aad_app.sign_in_audience == "AzureADMyOrg"
    error_message = "sign_in_audience must default to AzureADMyOrg"
  }
  assert {
    condition     = length(azuread_application.aad_app.owners) == 0
    error_message = "owners must default to an empty set when no owners are configured"
  }
}

run "app_role_and_feature_tags" {
  command = plan

  variables {
    app_registrations = {
      description = "App Registration with roles"
      azuread_application = {
        app_role = [
          {
            allowed_member_types = ["Application"]
            description          = "Role 1"
            display_name         = "Role 1"
            id                   = "11111111-1111-1111-1111-111111111111"
            value                = "role1_value"
          }
        ]
        feature_tags = [
          {
            enterprise = true
          }
        ]
      }
      azuread_service_principal = {
        feature_tags = [
          {
            hide = true
          }
        ]
      }
    }
  }

  assert {
    condition     = length(azuread_application.aad_app.app_role) == 1
    error_message = "app_role block must be rendered when configured"
  }
  assert {
    condition     = length(azuread_application.aad_app.feature_tags) == 1
    error_message = "feature_tags block must be rendered on the application"
  }
  assert {
    condition     = length(azuread_service_principal.aad_sp.feature_tags) == 1
    error_message = "feature_tags block must be rendered on the service principal"
  }
}

run "delegated_permission_default_all_users" {
  command = plan

  override_data {
    target = data.azuread_application_published_app_ids.well_known
    values = {
      result = {
        MicrosoftGraph = "00000003-0000-0000-c000-000000000000"
      }
    }
  }

  override_data {
    target = data.azuread_service_principal.delegated_apps["MicrosoftGraph"]
    values = {
      object_id = "33333333-3333-3333-3333-333333333333"
    }
  }

  variables {
    app_registrations = {
      description = "App Registration with delegated permission"
      azuread_application = {
        delegated_permission = {
          MicrosoftGraph = {
            permission = ["User.Read.All"]
          }
        }
      }
    }
  }

  assert {
    condition     = azuread_service_principal_delegated_permission_grant.delegated_permission_grant["MicrosoftGraph"].user_object_id == null
    error_message = "user_object_id must be null (grant applies to all users) when not supplied"
  }
  assert {
    condition     = azuread_service_principal_delegated_permission_grant.delegated_permission_grant["MicrosoftGraph"].claim_values == toset(["User.Read.All"])
    error_message = "claim_values must match the requested permissions"
  }
}

run "delegated_permission_single_user" {
  command = plan

  override_data {
    target = data.azuread_application_published_app_ids.well_known
    values = {
      result = {
        MicrosoftGraph = "00000003-0000-0000-c000-000000000000"
      }
    }
  }

  override_data {
    target = data.azuread_service_principal.delegated_apps["MicrosoftGraph"]
    values = {
      object_id = "33333333-3333-3333-3333-333333333333"
    }
  }

  variables {
    app_registrations = {
      description = "App Registration with per-user delegated permission"
      azuread_application = {
        delegated_permission = {
          MicrosoftGraph = {
            permission     = ["User.Read.All"]
            user_object_id = "22222222-2222-2222-2222-222222222222"
          }
        }
      }
    }
  }

  assert {
    condition     = azuread_service_principal_delegated_permission_grant.delegated_permission_grant["MicrosoftGraph"].user_object_id == "22222222-2222-2222-2222-222222222222"
    error_message = "user_object_id override must be passed through to the grant"
  }
}
