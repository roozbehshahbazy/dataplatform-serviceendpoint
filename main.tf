terraform {
    required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version =  "=3.62.0"
    }
    }
}

provider "azurerm" {
    features {}
}

data "azurerm_client_config" "current" {}


data "azurerm_resource_group" "engineering_rg" {
  name     = "rg-${local.name_component}-data-eng01"
}


data "azurerm_resource_group" "storage_rg" {
  name     = "rg-${local.name_component}-storage01"

}

