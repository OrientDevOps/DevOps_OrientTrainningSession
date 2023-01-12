# Get the resource backend from the Private Storage backend
terraform {
  backend "azurerm" {
      resource_group_name = "DevOpsIntern"
      storage_account_name = "orientdevopsintern"
      container_name = "tfstate"
      key = "terraform.tfstate"
  }
}

provider "azurerm" {
  features{}
}
