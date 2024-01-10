# Create a Storage account
resource "azurerm_storage_account" "asa" {
  name                     = join("",["sa",replace(local.name_component,"-",""),"storage01"])
  resource_group_name      = data.azurerm_resource_group.storage_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  tags                     = local.tags

  network_rules {

  default_action             = "Deny"
  virtual_network_subnet_ids = [data.azurerm_subnet.engineering_subnet.id , 
                                  data.azurerm_subnet.functionapp_subnet.id, 
                                  data.azurerm_subnet.databricks_private_subnet.id, 
                                  data.azurerm_subnet.databricks_public_subnet.id]
  bypass                     = ["None"]

  }
}



### function app storage account
resource "azurerm_storage_account" "event_ingestion_function_storage" {
  name                     = join("",["sa",replace(local.name_component,"-",""),"functionappeng01"])
  resource_group_name      = data.azurerm_resource_group.storage_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}


# Adding medallion containers
resource "azurerm_storage_container" "lake_container" {
   depends_on = [
    azurerm_storage_account.asa
    ]
  name                  = "data-hub"
  storage_account_name  = azurerm_storage_account.asa.name
  container_access_type = "private"
}


# role assignment to synapse managed identity

resource "azurerm_role_assignment" "synapse_managed_identity_role_assignment" {
      depends_on = [
        azurerm_synapse_workspace.synapse
        ]
  scope                = "/subscriptions/${local.subscriptions[var.environment].id}/resourceGroups/${data.azurerm_resource_group.storage_rg.name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse.identity[0].principal_id
}

# updating storage account network rules 

# resource "azurerm_storage_account_network_rules" "storage_network_rules" {
#    depends_on = [
#     azurerm_storage_account.asa,
#     azurerm_synapse_workspace.synapse
#     ]

#   storage_account_id = azurerm_storage_account.asa.id
#   default_action             = "Deny"
#   virtual_network_subnet_ids = [data.azurerm_subnet.engineering_subnet.id , 
#                                   data.azurerm_subnet.functionapp_subnet.id, 
#                                   data.azurerm_subnet.databricks_private_subnet.id, 
#                                   data.azurerm_subnet.databricks_public_subnet.id]
#   bypass                     = ["None"]

#   private_link_access {
#     endpoint_resource_id     = azurerm_synapse_workspace.synapse.id
#   }
# }

