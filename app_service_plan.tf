resource "azurerm_service_plan" "app_service_plan" {

  name                = join("-",["asp",local.name_component,"appserviceplaneng01"])
  resource_group_name = data.azurerm_resource_group.engineering_rg.name
  location            = var.location
  os_type             = "Linux"
  tags                = local.tags
  sku_name            = local.app_service_plan[var.environment].sku.size
}
