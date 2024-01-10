resource "azurerm_function_app" "event_function_app" {
  name                       = join("-",["fa",local.name_component,"functionappeng01"])
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.engineering_rg.name
  app_service_plan_id        = azurerm_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.event_ingestion_function_storage.name
  storage_account_access_key = azurerm_storage_account.event_ingestion_function_storage.primary_access_key
  os_type                    = "linux"
  version                    = local.function_runtime_version
  tags                       = local.tags
  identity {
    type = "SystemAssigned"
  }
  site_config {
    linux_fx_version            = "PYTHON|${local.python_version}"
    scm_type                    = "VSTSRM"
    use_32_bit_worker_process   = "false"
  }
  app_settings = merge(local.app_settings, {
    "FUNCTIONS_WORKER_RUNTIME" : "python"
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE" : "false"
    "APPINSIGHTS_INSTRUMENTATIONKEY" : azurerm_application_insights.app_insights.instrumentation_key
    "WEBSITE_RUN_FROM_PACKAGE" : "1"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" : "true"
  })
  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      site_config["scm_type"],
      tags

    ]
  }
}


# # Create Private DNS Zone
# resource "azurerm_private_dns_zone" "dns-zone-azurewebsites" {
#  depends_on = [
#     azurerm_function_app.event_function_app
#  ]

#   name                = "privatelink.azurewebsites.net"
#   resource_group_name = data.azurerm_resource_group.engineering_rg.name
# }

# # Create Private DNS Zone Network Link
# resource "azurerm_private_dns_zone_virtual_network_link" "network_link_azurewebsites" {
#    depends_on = [
#     azurerm_function_app.event_function_app
#  ]
#   name                  = join("-",["vl",local.name_component,"sitesvirtuallink01"])
#   resource_group_name = data.azurerm_resource_group.engineering_rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.dns-zone-azurewebsites.name
#   virtual_network_id    = data.azurerm_virtual_network.vnet.id
# }


# # Create Private Endpint
# resource "azurerm_private_endpoint" "endpoint-azurewebsites" {
#    depends_on = [
#     azurerm_function_app.event_function_app
#  ]
#   name                = join("",["pep-",local.name_component,"-",replace(replace("${azurerm_function_app.event_function_app.name}",regex("[0-9]+", "${azurerm_function_app.event_function_app.name}"),""),"-",""),"sites01"])
#   resource_group_name = data.azurerm_resource_group.engineering_rg.name
#   location            = "${var.location}"
#   subnet_id           = data.azurerm_subnet.engineering_subnet.id
#   custom_network_interface_name = join("",["nic-",local.name_component,"-",replace(replace("${azurerm_function_app.event_function_app.name}",regex("[0-9]+", "${azurerm_function_app.event_function_app.name}"),""),"-",""),"sites01"])

#   private_service_connection {
#     name                           = join("",["pec-",local.name_component,"-",replace(replace("${azurerm_function_app.event_function_app.name}",regex("[0-9]+", "${azurerm_function_app.event_function_app.name}"),""),"-",""),"sites01"])
#     private_connection_resource_id = azurerm_function_app.event_function_app.id
#     is_manual_connection           = false
#     subresource_names              = ["sites"]
#   }
# }


resource "azurerm_app_service_virtual_network_swift_connection" "function_app_vnet_integration" {
depends_on = [
    azurerm_function_app.event_function_app
 ]
  app_service_id = azurerm_function_app.event_function_app.id
  subnet_id      = data.azurerm_subnet.functionapp_subnet.id
}


# role assignment to function app managed identity

resource "azurerm_role_assignment" "fa_managed_identity_role_assignment" {
      depends_on = [
        azurerm_function_app.event_function_app
        ]
  scope                = "/subscriptions/${local.subscriptions[var.environment].id}/resourceGroups/${data.azurerm_resource_group.storage_rg.name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_function_app.event_function_app.identity[0].principal_id
}