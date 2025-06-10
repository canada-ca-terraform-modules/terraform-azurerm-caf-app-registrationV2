locals {

  # This creates the object for the application API permissions. Formats the object from the required_resource_access block to be able to be iterated through with a for_each loop
  app_perm = {for resource in flatten([
    for required_resource in try(var.app_registrations.azuread_application.required_resource_access, {}): [
      for resource_access in required_resource.resource_access: 
        resource_access.grant_admin_consent ? {
        resource_app_id = data.azuread_service_principal.service_principals[required_resource.resource_app_id].object_id
        id = resource_access.id
        type = resource_access.type
      } : null
    ]
  ]) : "${resource.resource_app_id}.${resource.id}" => resource if resource != null}


  # This creates the object for delegated API permissions. Formats the object so we can iterate through with for_each
  delegated_perm = {for api, val in try(var.app_registrations.azuread_application.delegated_permission, {}): api => {
              permission = val.permission
              resource_sp = data.azuread_service_principal.delegated_apps[api].object_id
          }}
}