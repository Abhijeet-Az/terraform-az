locals {
  azure_ad_default_group_owner = ["fd892370-2cae-40e3-b110-d286e9b00825"] #engineering@crowdbotics.com
  default_scope_mgt_key        = "Platform"
  githubmanager_object_id      = "10e741b9-9ef6-49fb-9e3d-72d903ad8e90"
  role_assignments = flatten([
    for group_name, role_map in var.role_assignment_map : [
      for role in role_map.role_definition_name : {
        group_name    = group_name
        role_name     = role
        scope_mgt_key = role_map.scope_mgt_key
      }
    ]
  ])
}
