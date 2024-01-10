resource "azurerm_network_security_group" "dbr_nsg" {
  name                = join("-",["nsg",local.name_component,"networksecuritygroup02"])
  location            = var.location
  resource_group_name = data.azurerm_resource_group.engineering_rg.name
  tags                = local.tags
}



resource "azurerm_network_security_rule" "aad" {
  name                        = "AllowAAD"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureActiveDirectory"
  resource_group_name         = data.azurerm_resource_group.engineering_rg.name
  network_security_group_name = azurerm_network_security_group.dbr_nsg.name
}

resource "azurerm_network_security_rule" "azfrontdoor" {
  name                        = "AllowAzureFrontDoor"
  priority                    = 201
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureFrontDoor.Frontend"
  resource_group_name         = data.azurerm_resource_group.engineering_rg.name
  network_security_group_name = azurerm_network_security_group.dbr_nsg.name
}


resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = data.azurerm_subnet.databricks_public_subnet.id
  network_security_group_id = azurerm_network_security_group.dbr_nsg.id
}


resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = data.azurerm_subnet.databricks_private_subnet.id
  network_security_group_id = azurerm_network_security_group.dbr_nsg.id
}



resource "azurerm_databricks_workspace" "databricks" {

  depends_on = [
    azurerm_subnet_network_security_group_association.public,
    azurerm_subnet_network_security_group_association.private
  ]
  name                = join("-",["dbr",local.name_component,"databrickseng01"])
  resource_group_name = data.azurerm_resource_group.engineering_rg.name
  location            = var.location
  sku                 = "premium"
  managed_resource_group_name = join("-",["rg",local.name_component,"databricksmanagedresourcegroup01"])
  public_network_access_enabled = true
  network_security_group_rules_required = "AllRules"
custom_parameters {
    no_public_ip                                         = false
    virtual_network_id                                   = data.azurerm_virtual_network.vnet.id
    private_subnet_name                                  = data.azurerm_subnet.databricks_public_subnet.name
    public_subnet_name                                   = data.azurerm_subnet.databricks_private_subnet.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
 
}

tags = local.tags

}
