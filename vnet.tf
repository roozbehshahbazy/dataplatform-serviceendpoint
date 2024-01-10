# Get Current Virtual Network id
data "azurerm_virtual_network" "vnet" {
  name                = local.vnet[var.environment].name
  resource_group_name = local.vnet[var.environment].resource_group_name
}


# Get Storage Subnet id
data "azurerm_subnet" "storage_account_subnet" {
  name                 = local.vnet[var.environment].storage_account_subnet
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

# Get Engineering Subnet id
data "azurerm_subnet" "engineering_subnet" {
  name                 = local.vnet[var.environment].engineering_subnet
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

# Get Function app Subnet id
data "azurerm_subnet" "functionapp_subnet" {
  name                 = local.vnet[var.environment].functionapp_subnet
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}


# Get Databricks Public Subnet id
data "azurerm_subnet" "databricks_public_subnet" {
  name                 = local.vnet[var.environment].databricks_public_subnet
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}


# Get Databricks Private Subnet id
data "azurerm_subnet" "databricks_private_subnet" {
  name                 = local.vnet[var.environment].databricks_private_subnet
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}


