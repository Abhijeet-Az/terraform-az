variable "mgmt_group_config" {
  type = map(any)
  default = {
    "Crowdbotics" = {
      name = "crowdbotics"
    }
    "CB Playground" = {
      name = "cb-playground"
    }
    "Customer Applications" = {
      name = "cb-customer-apps"
    }
    "Landing Zones" = {
      name = "cb-landing-zones"
    }
    "Platform" = {
      name = "cb-platform"
    }
  }
}

variable "azure_ad_group_map" {
  default = {
    Developers-ReadOnly = {
      azure_ad_group_name = "Developers-ReadOnly"
      azuread_group_members = [
        "12c0d74a-74f7-43e4-ac94-9342b999115c", #hesbon.kiptoo@crowdbotics.com
        "2747125f-49de-469e-bf6c-b8e856c8ba7e", #greg.domanin@crowdbotics.com
        "39daa708-e175-4fd8-a23a-478492d52cdf", #samuel.m@crowdbotics.com
        "4677f1db-ae11-43b1-a4e4-a97ad8d790da", #santosh.purbey@crowdbotics.com
        "518e82cc-71b0-4375-a9fa-2a5ffbae7a85", #brenley@crowdbotics.com 
        "56810e16-e8c9-4905-82a2-ce63a577f22e", #saurav@crowdbotics.com
        "5996d992-46a2-42fb-847d-b2c903c57da6", #shahraiz.ali@crowdbotics.com 
        "69aa4c5a-79ee-47b3-9a52-d6ecbf3101ef", #kushal@crowdbotics.com
        "a57a1bc1-c6e2-452b-92e3-ad6d326eb8cc", #juan@crowdbotics.com
        "b524d3b2-261d-4f1b-ae07-e36503908ad1", #robert.so@crowdbotics.com
        "c57dbe2e-4b1e-4e79-9611-98f0c3e895c5", #abdelhak@crowdbotics.com
        "c8cfb26c-ee6d-4ee4-a937-0bbc360c8037", #eduardo@crowdbotics.com
        "df20447a-a403-45cb-9d14-14543270a7e6", #abid.abdullah@crowdbotics.com
        "66bf17bb-d24d-4948-bcc4-a6d89b2237c9", #daniel.s@crowdbotics.com
        "5698b06e-3361-4611-bdab-5f505286bf6a", #hugo.seabra@crowdbotics.com
        "1db92730-d47f-48f5-ab87-ebbd1414015c", #aline@crowdbotics.com
        "c62611bc-6d7d-4628-b68a-6a2997011fa3"  #juergen@crowdbotics.com
      ]
    },
    DevAKS-ReadWrite = {
      azure_ad_group_name = "DevAKS-ReadWrite"
      azuread_group_members = [
        "12c0d74a-74f7-43e4-ac94-9342b999115c", #hesbon.kiptoo@crowdbotics.com
        "2101fdc7-e5af-43e0-9b03-ec8c34d3aad6", #andre.machado@crowdbotics.com
        "4677f1db-ae11-43b1-a4e4-a97ad8d790da", #santosh.purbey@crowdbotics.com
        "56810e16-e8c9-4905-82a2-ce63a577f22e", #saurav@crowdbotics.com
        "66bf17bb-d24d-4948-bcc4-a6d89b2237c9", #daniel.s@crowdbotics.com
        "69aa4c5a-79ee-47b3-9a52-d6ecbf3101ef", #kushal@crowdbotics.com
        "a57a1bc1-c6e2-452b-92e3-ad6d326eb8cc", #juan@crowdbotics.com
        "c8cfb26c-ee6d-4ee4-a937-0bbc360c8037", #eduardo@crowdbotics.com
        "df20447a-a403-45cb-9d14-14543270a7e6", #abid.abdullah@crowdbotics.com
        "ca5ba9be-10e4-401b-afed-92e755613ffd", #shashank@crowdbotics.com
        "ed99182d-9d72-439b-9edf-95930c7b7be7", #dan@crowdbotics.com
        "5698b06e-3361-4611-bdab-5f505286bf6a", #hugo.seabra@crowdbotics.com
        "1db92730-d47f-48f5-ab87-ebbd1414015c", #aline@crowdbotics.com
        "c62611bc-6d7d-4628-b68a-6a2997011fa3"  #juergen@crowdbotics.com
      ]
    },
    "Engineering Managers" = {
      azure_ad_group_name = "Engineering Managers"
      azuread_group_members = [
        "1db92730-d47f-48f5-ab87-ebbd1414015c", #aline@crowdbotics.com
        "f331e0a7-3c98-418b-9115-123f6fbd8b0a", #curtis@crowdbotics.com
        "ed99182d-9d72-439b-9edf-95930c7b7be7", #dan@crowdbotics.com
        "c62611bc-6d7d-4628-b68a-6a2997011fa3"  #juergen@crowdbotics.com
      ]
    },
    "Porting Core Team" = {
      azure_ad_group_name = "Porting Core Team"
      azuread_group_members = [
        "041d90ca-8bce-4605-a9c3-28b3fbf43969", #srinivas.indra_hensongroup.com#EXT#@crowdbotics.onmicrosoft.com
        "5733137f-b8e5-47f5-9b48-973489b0ad4e", #karan.sharma_hensongroup.com#EXT#@crowdbotics.onmicrosoft.com
        "66f07586-a9fb-451a-8640-b4c9bac7b7aa", #abhijeet.rastogi_hensongroup.com#EXT#@crowdbotics.onmicrosoft.com
        "ca5ba9be-10e4-401b-afed-92e755613ffd", #shashank@crowdbotics.com
        "df20447a-a403-45cb-9d14-14543270a7e6", #abid.abdullah@crowdbotics.com
        "ed99182d-9d72-439b-9edf-95930c7b7be7"  #dan@crowdbotics.com
      ]
    },
    "Product Managers" = {
      azure_ad_group_name = "Product Managers"
      azuread_group_members = [
        "5205a140-3148-4bef-ac1e-5467767d18da" #prateep.gopalkrishnan@crowdbotics.com
      ]
    },
    "The Henson Group" = {
      azure_ad_group_name = "The Henson Group"
      azuread_group_members = [
        "041d90ca-8bce-4605-a9c3-28b3fbf43969", #srinivas.indra_hensongroup.com#EXT#@crowdbotics.onmicrosoft.com
        "56fdb3de-cb47-4991-8350-8c5389857a91", #chris_hensongroup.com#EXT#@crowdbotics.onmicrosoft.com
        "5733137f-b8e5-47f5-9b48-973489b0ad4e", #karan.sharma_hensongroup.com#EXT#@crowdbotics.onmicrosoft.com
        "66f07586-a9fb-451a-8640-b4c9bac7b7aa"  #abhijeet.rastogi_hensongroup.com#EXT#@crowdbotics.onmicrosoft.com
      ]
    },
    "CB Support" = {
      azure_ad_group_name = "CB Support"
      azuread_group_members = [
        "836a09a4-178b-4adf-b4ad-64fd1fdadef8" #tolu@crowdbotics.com
      ]
    }
  }
}


variable "role_assignment_map" {
  type = map(any)
  default = {
    "Developers-ReadOnly" = {
      role_definition_name = ["Reader", "Grafana Viewer", "Azure Kubernetes Service Cluster User Role", "Azure Kubernetes Service RBAC Reader", "Azure Service Bus Data Receiver", "Monitoring Reader"]
      scope_mgt_key        = "Platform"
    }
    "DevAKS-ReadWrite" = {
      role_definition_name = ["Cosmos DB Operator", "Website Contributor", "Azure Kubernetes Service RBAC Writer", "Storage Blob Data Contributor"]
      scope_mgt_key        = "Platform"
    }
    "CB Support" = {
      role_definition_name = ["Reader", "Grafana Viewer", "Azure Kubernetes Service RBAC Reader", "Monitoring Reader", "Website Contributor"]
      scope_mgt_key        = "Customer Applications"
    }
  }
}