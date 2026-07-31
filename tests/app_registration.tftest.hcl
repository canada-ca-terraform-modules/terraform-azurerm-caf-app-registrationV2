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

run "app_role_assignment_created_on_admin_consent" {
  command = plan

  override_data {
    target = data.azuread_service_principal.service_principals["00000003-0000-0000-c000-000000000000"]
    values = {
      object_id = "55555555-5555-5555-5555-555555555555"
    }
  }

  variables {
    app_registrations = {
      description = "App Registration with admin-consented API permission"
      azuread_application = {
        required_resource_access = [
          {
            resource_app_id = "00000003-0000-0000-c000-000000000000"
            resource_access = [
              {
                id                  = "df021288-bdef-4463-88db-98f22de89214"
                type                = "Role"
                grant_admin_consent = true
              }
            ]
          }
        ]
      }
    }
  }

  assert {
    condition     = length(azuread_app_role_assignment.assignment) == 1
    error_message = "azuread_app_role_assignment must be created when grant_admin_consent = true"
  }
  assert {
    condition     = azuread_app_role_assignment.assignment["55555555-5555-5555-5555-555555555555.df021288-bdef-4463-88db-98f22de89214"].resource_object_id == "55555555-5555-5555-5555-555555555555"
    error_message = "resource_object_id must resolve from the filtered service_principals data source"
  }
}

run "no_app_role_assignment_without_admin_consent" {
  command = plan

  variables {
    app_registrations = {
      description = "App Registration with non-admin-consented API permission"
      azuread_application = {
        required_resource_access = [
          {
            resource_app_id = "00000003-0000-0000-c000-000000000000"
            resource_access = [
              {
                id                  = "df021288-bdef-4463-88db-98f22de89214"
                type                = "Role"
                grant_admin_consent = false
              }
            ]
          }
        ]
      }
    }
  }

  assert {
    condition     = length(azuread_app_role_assignment.assignment) == 0
    error_message = "azuread_app_role_assignment must not be created when grant_admin_consent = false"
  }
  assert {
    condition     = length(data.azuread_service_principal.service_principals) == 0
    error_message = "service_principals data source must not resolve any SP when no resource_access entry has grant_admin_consent = true"
  }
}
