terraform {
  backend "local" {
    path = "/home/xeusnguyen/DevOps_OrientTrainningSession/terraform/modules/backend/terraform.tfstate"
  }
}

provider "local" {
    features{}
}

data "azurerm_client_config" "current" {
}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}