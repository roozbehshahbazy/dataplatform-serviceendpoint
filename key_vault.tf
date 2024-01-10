resource "azurerm_key_vault" "kv" {
  name                = join("-",["kv",local.name_component,"keyvaulteng01"])
  location            = "${var.location}"
  resource_group_name = data.azurerm_resource_group.engineering_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  network_acls {
    bypass = "None"
    default_action = "Deny"
    ip_rules  = []
    virtual_network_subnet_ids = [data.azurerm_subnet.engineering_subnet.id]
  }
  

  tags = local.tags
}

resource "azurerm_key_vault_access_policy" "kv_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get","List"
  ]

  secret_permissions = [
    "Get","List"
  ]
}

# assign access policy to adf service principal
resource "azurerm_key_vault_access_policy" "adf_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_data_factory.adf.identity[0].principal_id

  key_permissions = [
    "Get","List"
  ]

  secret_permissions = [
    "Get","List"
  ]
}