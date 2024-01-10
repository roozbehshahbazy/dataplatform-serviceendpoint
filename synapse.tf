resource "azurerm_synapse_workspace" "synapse" {
    depends_on = [
        azurerm_storage_account.asa,
        azurerm_storage_container.lake_container
        ]
  name                                 = join("-",["syn",local.name_component,"synapseeng01"])
  resource_group_name                  = data.azurerm_resource_group.engineering_rg.name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = "https://${azurerm_storage_account.asa.name}.dfs.core.windows.net/${azurerm_storage_container.lake_container.name}" 
  sql_administrator_login              = "synapseadmin${var.environment}"
  sql_administrator_login_password     = "H@Sh1CoR3!" # We need to change this to environmental variable or keyvault
  sql_identity_control_enabled  = true
  public_network_access_enabled = true
  managed_virtual_network_enabled      = true
  managed_resource_group_name = join("-",["rg",local.name_component,"synapsemanagedresourcegroup01"])
  
  identity {
    type = "SystemAssigned"
  }


    aad_admin {
    login     = "Roozbeh.Shahbazirad@z.co.nz"
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id
  }


  tags = local.tags
}


resource "azurerm_synapse_firewall_rule" "synapse_firewall_rule" {
  depends_on = [azurerm_synapse_workspace.synapse]
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}



