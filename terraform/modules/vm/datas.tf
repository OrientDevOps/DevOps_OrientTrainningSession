# Get data_resource from RG
data "azurerm_resource_group" "current" {
  name = "DevOpsIntern"
}

# Get data_resource from sshkey
data "azurerm_ssh_public_key" "my_vm_public_key" {
  name = "DevOpsIntern"
  resource_group_name = data.azurerm_resource_group.current.name
}