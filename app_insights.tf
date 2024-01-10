resource "azurerm_application_insights" "app_insights" {
  name                = join("-",["api",local.name_component,"applicationinsightseng01"])
  location            = var.location
  resource_group_name = data.azurerm_resource_group.engineering_rg.name
  application_type    = "other"
  retention_in_days   = "90"
  tags                = local.tags

}