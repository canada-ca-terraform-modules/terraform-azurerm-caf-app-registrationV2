app_registrationsV2 = {
  test = {
    description             = "Test App Registration" # (Required) Description of the app registration
    owners                  = []                      # (Optional) List of User UPNs that will be the initial owners of the app registration. Only used on 1st deployment of App Reg du to life_cycle
    prevent_duplicate_names = true                    # (Optional) Prevents duplicate names of the app registration. Default is true

    app_role_assignment_required = false # (Optional) Determines if app role assignment is required. Default is false
    
    # Azure Active Directory uses special tag values to configure the behavior of service principals. These can be specified
    # using either the tags property or with the feature_tags block. If you need to set any custom tag values not supported by
    # the feature_tags block, it's recommended to use the tags property. Tag values set for the linked application will also
    # propagate to this service principal.
    tags = [
      "HideApp",
    ]
  }
}
