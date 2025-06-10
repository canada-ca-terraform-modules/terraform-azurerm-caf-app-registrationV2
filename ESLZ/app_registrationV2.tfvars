app_registrationsV2 = {
  test = {
    description = "Test App Registration" # (Required) Description of the app registration
    # (Optional) List of User UPNs that will be the initial owners of the app registration. Only used on 1st deployment of App Reg du to life_cycle
    owners = [
      "SET OWNER HERE"
    ]

    # (Required)
    azuread_application = {
      # custom_display_name = "myCustomDisplayName" # (Optional) Custom display name for the app registration.
      prevent_duplicate_names = true # (Optional) Prevents duplicate names of the app registration. Default is true

      # device_only_auth_enabled       = false                                                     # (Optional) Supports device auth without a user.
      # fallback_public_client_enabled = false                                                     # (Optional) Specifies if this is a public client.
      # group_membership_claims        = ["None"]                                                  # (Optional) Claims from group membership; e.g., "None", "SecurityGroup", etc.
      # identifier_uris                = ["https://example.com/myapp"]                             # (Optional) Unique identifier URIs.
      # logo_image                     = "base64encodedlogo=="                                     # (Optional) Base64-encoded logo image.
      # marketing_url                  = "https://example.com/marketing"                           # (Optional) URL of the app's marketing page.
      # notes                          = "This is a test app registration used for demonstration." # (Optional) Management notes.
      # oauth2_post_response_required  = false                                                     # (Optional) Whether POST is required for OAuth2 responses.
      # privacy_statement_url          = "https://example.com/privacy"                             # (Optional) URL of the privacy statement.
      # service_management_reference   = "SMR-12345"                                               # (Optional) Reference from a Service/Asset Management DB.
      # sign_in_audience               = "AzureADMyOrg"                                            # (Optional) Supported account types.
      # support_url                    = "https://example.com/support"                             # (Optional) URL of the app’s support page.
      # tags                           = ["CustomTag1", "CustomTag2"]                              # (Optional) Custom tag values. Mutually exclusive with feature_tags.
      # template_id                    = null                                                      # (Optional) Template ID if instantiating from a gallery application.
      # terms_of_service_url           = "https://example.com/terms"                               # (Optional) URL for terms of service.

      # (Optional) An api block as documented below, which configures API related settings for this application.
      # api = [
      #   {
      #     mapped_claims_enabled          = true # (Optional) Allows an application to use claims mapping without specifying a custom signing key. Defaults to false.
      #     known_client_applications      = []   # (Optional) A set of client IDs, used for bundling consent if you have a solution that contains two parts: a client app and a custom web API app.
      #     requested_access_token_version = 1    # (Optional) The access token version expected by this resource. Must be one of 1 or 2, and must be 2 when sign_in_audience is either AzureADandPersonalMicrosoftAccount or PersonalMicrosoftAccount Defaults to 1.
      #     # oauth2_permission_scope = [
      #     #   {
      #     #     admin_consent_description  = "some description"   # (Required) Delegated permission description that appears in all tenant-wide admin consent experiences, intended to be read by an administrator granting the permission on behalf of all users.
      #     #     admin_consent_display_name = "some display name"  # (Required) Display name for the delegated permission, intended to be read by an administrator granting the permission on behalf of all users.
      #     #     enabled                    = true                 # (Optional) Determines if the permission scope is enabled. Defaults to true.
      #     #     id                         = "some UUID"          # (Required) The unique identifier of the delegated permission. Must be a valid UUID.
      #     #     type                       = "User"               # (Optional) Whether this delegated permission should be considered safe for non-admin users to consent to on behalf of themselves, or whether an administrator should be required for consent to the permissions. Defaults to User. Possible values are User or Admin.
      #     #     user_consent_description   = ""                   # (Optional) Delegated permission description that appears in the end user consent experience, intended to be read by a user consenting on their own behalf.
      #     #     user_consent_display_name  = ""                   # (Optional) Display name for the delegated permission that appears in the end user consent experience.
      #     #     value                      = "user_impersonation" # (Optional) The value that is used for the scp claim in OAuth 2.0 access tokens.
      #     #   }
      #     # ]
      #   }
      # ]

      # (Optional) A collection of app_role blocks as documented below. For more information see official documentation on Application Roles.
      # app_role = [
      #   {
      #     allowed_member_types = ["User"]   # (Required) Who can be assigned this role (e.g., "User" or "Application").
      #     description          = "Description for Role 1"  # (Required) Role description.
      #     display_name         = "Role 1"                # (Required) Role display name.
      #     enabled              = true                    # (Optional) Defaults to true.
      #     id                   = "11111111-1111-1111-1111-111111111111"  # (Required) A valid UUID.
      #     value                = "role1_value"           # (Optional) The value used in tokens.
      #   },
      #   {
      #     allowed_member_types = ["Application"]
      #     description          = "Description for Role 2"
      #     display_name         = "Role 2"
      #     enabled              = true
      #     id                   = "22222222-2222-2222-2222-222222222222"
      #     value                = "role2_value"
      #   }
      # ]

      # (Optional) feature_tags (mutually exclusive with tags)
      # feature_tags = [
      #   {
      #     custom_single_sign_on = false # (Optional) Custom SAML SSO flag. Default is false.
      #     enterprise            = false # (Optional) Marks the app as an enterprise app. Default is false.
      #     gallery               = false # (Optional) Marks the app as a gallery application. Default is false.
      #     hide                  = false # (Optional) Hide app from users (assigns HideApp tag). Default is false.
      #   }
      # ]

      # (Optional) An optional_claims block as documented below.
      # optional_claims = [
      #   {
      #     access_token = [
      #       {
      #         additional_properties = ["cloud_displayname"] # (Optional) List of additional properties.
      #         essential             = false                 # (Optional) Whether the claim is essential.
      #         name                  = "claim1"              # (Required) Claim name.
      #         source                = "user"                # (Optional) Source of the claim.
      #       }
      #     ]

      #     id_token = [
      #       {
      #         additional_properties = ["dns_domain_and_sam_account_name"]
      #         essential             = true
      #         name                  = "claim_id"
      #         source                = null
      #       }
      #     ]

      #     saml2_token = [
      #       {
      #         additional_properties = ["emit_as_roles"]
      #         essential             = false
      #         name                  = "saml_claim"
      #         source                = "user"
      #       }
      #     ]
      #   }
      # ]

      # (Optional) A single Password (only one allowed)
      # password = [
      #   {
      #     display_name = "Default Password"     # (Required) Display name for the password.
      #     end_date     = "2030-12-31T23:59:59Z" # (Optional) End date in RFC3339 format.
      #     start_date   = "2025-01-01T00:00:00Z" # (Optional) Start date (defaults to current date if omitted).
      #   }
      # ]

      # (Optional) Public Client settings (for mobile/desktop apps)
      # public_client = [
      #   {
      #     redirect_uris = ["https://example.com/public_client_redirect"] # (Optional) List of redirect URIs.
      #   }
      # ]

      # (Optional) A collection of required_resource_access blocks as documented below.
      # required_resource_access = [
      #   {
      #     # (Required)
      #     resource_access = [
      #       {
      #         id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # (Required) The unique identifier for an app role or OAuth2 permission scope published by the resource application.
      #         type = "Scope"                                # (Required) Specifies whether the id property references an app role or an OAuth2 permission scope. Possible values are Role or Scope.
      #       }
      #     ]
      #     resource_app_id = "00000003-0000-0000-c000-000000000000" # (Required) The unique identifier for the resource that the application requires access to. This should be the Application ID of the target application.
      #   }
      # ]

      # (Optional) A collection of delegated permission to assign to the app registration
      # delegated_permission = {
      #   "MicrosoftGraph" = {
      #     permission = ["User.Read.All", "Group.ReadWrite.All"]
      #     # permission = [ "Group.ReadWrite.All"]
      #   }
      # }


      # (Optional) Single Page Application (SPA) settings
      # single_page_application = [
      #   {
      #     redirect_uris = ["https://example.com/spa_redirect"] # (Optional) List of SPA redirect URIs.
      #   }
      # ]

      # (Optional) Web settings (for web apps and APIs)
      # web = [
      #   {
      #     homepage_url  = "https://example.com/home"       # (Optional) App homepage URL.
      #     logout_url    = "https://example.com/logout"     # (Optional) Logout URL.
      #     redirect_uris = ["https://example.com/redirect"] # (Optional) List of redirect URIs.
      #     implicit_grant = {                               # (Optional) Implicit grant settings.
      #       access_token_issuance_enabled = false          # (Optional) Enable access token issuance.
      #       id_token_issuance_enabled     = false          # (Optional) Enable ID token issuance.
      #     }
      #   }
      # ]
    }

    # (Optional) Azure AD Service Principal block
    azuread_service_principal = {
      # account_enabled               = true                                           # (Optional) Whether the service principal account is enabled. Default is true.
      # alternative_names             = ["alt-name1", "alt-name2"]                     # (Optional) A set of alternative names.
      # app_role_assignment_required  = false                                          # (Optional) Determines if app role assignment is required. Default is false.
      # login_url                     = "https://example.com/login"                    # (Optional) The URL where users are redirected to authenticate.
      # notes                         = "Service principal for Test App Registration." # (Optional) Free text description.
      # notification_email_addresses  = ["admin@example.com"]                          # (Optional) Email addresses for certificate expiration notifications.
      # preferred_single_sign_on_mode = "saml"                                         # (Optional) SSO mode (e.g., "oidc", "password", "saml", or "notSupported").
      # tags                          = ["HideApp"]                                    # (Optional) Custom tag values. Mutually exclusive with feature_tags. Mutially exclusive with feature_tags.
      # use_existing                  = false                                          # (Optional) When true, any existing service principal will be imported.

      # (Optional) A feature_tags block as described below. Cannot be used together with the tags property.
      feature_tags = [
        {
          custom_single_sign_on = false
          enterprise            = false
          gallery               = false
          hide                  = true
        }
      ]

      # (Optional) SAML single sign-on configuration block
      # saml_single_sign_on = [
      #   {
      #     relay_state = "/myapp/relay" # (Optional) The relative URI for redirection after SSO.
      #   }
      # ]
    }
  }
}
