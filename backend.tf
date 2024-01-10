terraform {
  backend "azurerm" {
    resource_group_name  = "Terraform"
    storage_account_name = "configterraform"
    container_name       = "tfstate-dataplatform-serviceendpoint"
    key                  = "z.terraform.tfstate"
  }
}