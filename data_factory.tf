resource "azurerm_data_factory" "adf" {
  name                = join("-",["adf",local.name_component,"datafactoryeng01"])
  location            = var.location
  resource_group_name = data.azurerm_resource_group.engineering_rg.name
  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_managed_private_endpoint" "mpe_blob" {
  depends_on = [azurerm_storage_account.asa]
  name               = join("-",["mpe",azurerm_storage_account.asa.name])
  data_factory_id    = azurerm_data_factory.adf.id
  target_resource_id = azurerm_storage_account.asa.id
  subresource_name   = "blob"
}

resource "azurerm_data_factory_managed_private_endpoint" "mpe_keyvault" {
  depends_on = [azurerm_key_vault.kv]
  name               = join("-",["mpe",azurerm_key_vault.kv.name])
  data_factory_id    = azurerm_data_factory.adf.id
  target_resource_id = azurerm_key_vault.kv.id
  subresource_name   = "vault"
}





# role assignment to adf managed identity

resource "azurerm_role_assignment" "adf_managed_identity_role_assignment" {
      depends_on = [
        azurerm_data_factory.adf
        ]
  scope                = "/subscriptions/${local.subscriptions[var.environment].id}/resourceGroups/${data.azurerm_resource_group.storage_rg.name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.adf.identity[0].principal_id
}



resource "azurerm_data_factory_integration_runtime_azure" "adf_integration_runtime" {
  name                    = "ManagedVnetRuntime"
  data_factory_id         = azurerm_data_factory.adf.id
  location                = var.location
  virtual_network_enabled = true
  time_to_live_min        = 60

}


