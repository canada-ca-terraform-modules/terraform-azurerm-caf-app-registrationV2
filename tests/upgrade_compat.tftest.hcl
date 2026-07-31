# tests/upgrade_compat.tftest.hcl
# Purpose: catch breaking resource address/behaviour changes before live re-deploy.
# apply creates mock state; the follow-up plan runs against that state.
mock_provider "azuread" {}

variables {
  env               = "Dev"
  group             = "OPS"
  project           = "CORE"
  userDefinedString = "test"
}

# Step 1: simulate the currently-deployed resource (pre-upgrade inputs only)
run "baseline_apply" {
  command = apply

  override_resource {
    target = azuread_application.aad_app
    values = {
      client_id = "11111111-1111-1111-1111-111111111111"
    }
  }

  override_resource {
    target = azuread_service_principal.aad_sp
    values = {
      object_id = "44444444-4444-4444-4444-444444444444"
    }
  }

  variables {
    app_registrations = {
      description = "Baseline App Registration"
      owners      = []
      azuread_application = {
        prevent_duplicate_names = true
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
    condition     = azuread_application.aad_app.display_name == "Dev_OPS_CORE_test_sp"
    error_message = "Baseline apply: unexpected display_name"
  }
  assert {
    condition     = azuread_service_principal_delegated_permission_grant.delegated_permission_grant == {}
    error_message = "Baseline apply: no delegated permission grants expected"
  }
}

# Step 2: plan the upgraded code against that state — same inputs plus the new
# additive user_object_id argument. Must not force replacement of any resource.
run "upgrade_plan_no_replacement" {
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
      description = "Baseline App Registration"
      owners      = []
      azuread_application = {
        prevent_duplicate_names = true
        delegated_permission = {
          MicrosoftGraph = {
            permission     = ["User.Read.All"]
            user_object_id = "22222222-2222-2222-2222-222222222222"
          }
        }
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
    condition     = azuread_application.aad_app.display_name == "Dev_OPS_CORE_test_sp"
    error_message = "Upgrade plan: display_name must be unchanged after upgrade"
  }
  assert {
    condition     = azuread_service_principal_delegated_permission_grant.delegated_permission_grant["MicrosoftGraph"].user_object_id == "22222222-2222-2222-2222-222222222222"
    error_message = "Upgrade plan: new user_object_id argument must be set"
  }
}
