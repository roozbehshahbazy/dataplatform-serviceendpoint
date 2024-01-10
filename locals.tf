locals { 
  env     = terraform.workspace

  environments = {
    dev  = { "name" = "Development", "identifier" = "d" },
    test = { "name" = "NonProd", "identifier" = "n" },
    prod = { "name" = "Production", "identifier" = "p" }
  }

subscriptions ={
  dev = {"name" = "Visual Studio Enterprise Subscription" , "id" = "d3272c42-d494-4f22-959e-29239731c465","synapse_admin_group_name" = "SQL_G_DataSolutions_Admin_D"},
  test = {"name" = "Visual Studio Enterprise Subscription" , "id" = "d3272c42-d494-4f22-959e-29239731c465","synapse_admin_group_name" = "SQL_G_DataSolutions_Admin_T"},
  prod = {"name" = "Visual Studio Enterprise Subscription" , "id" = "d3272c42-d494-4f22-959e-29239731c465","synapse_admin_group_name" = "SQL_G_DataSolutions_Admin_P"}
}


vnet = {
  dev = {"name" = "vnt-d-shared-internalnetwork01", resource_group_name = "rg-d-shared-devtestnetwork01", storage_account_subnet = "snt-d-dss-storage01", engineering_subnet = "snt-d-dss-eng01", functionapp_subnet = "snt-d-dss-functionapp01", databricks_public_subnet = "snt-d-dss-dbrpublic01", databricks_private_subnet = "snt-d-dss-dbrprivate01" },
  test = {"name" = "vnt-np-shared-internalnetwork01", resource_group_name = "rg-np-shared-nonprodnetwork01", storage_account_subnet = "", engineering_subnet = "", functionapp_subnet = "", databricks_public_subnet = "", databricks_private_subnet = ""},
  prod = {"name" = "vnt-p-shared-internalnetwork01", resource_group_name = "rg-p-shared-prodnetwork01", storage_account_subnet = "", engineering_subnet = "", functionapp_subnet = "", databricks_public_subnet = "", databricks_private_subnet = ""}
}

business_unit = {
    short_name = "dss"
    long_name  = "data solutions"
  }

name_component = "${local.environments[var.environment].identifier}-${local.business_unit.short_name}"


tags = {
    environment = local.environments[var.environment].name,
    "Product Name" = "Data Platform",
    "Cost Centre" = "1030150",
    "Product Owner" = "Data Solutions Team",
    "Contact Email" = "DataSolutions@zisfornz.onmicrosoft.com"

  }


  app_service_plan = {
    dev  = { sku = {size = "P0v3", tier = "PremiumV3"} },
    test = { sku = {size = "P0v3", tier = "PremiumV3"} },
    prod = { sku = {size = "P2v3", tier = "PremiumV3"}}
  }

  function_runtime_version = "~4"


  python_version = "3.11"


  app_settings = {
    "BlobStorage__serviceUri" : "",
    "InfinityServiceBusConnection__fullyQualifiedNamespace" : ""
    "InfinitySubscription" : ""
  }

}

