# Get data_resource from RG
data "azurerm_resource_group" "current" {
  name = "DevOpsIntern"
}

# Get data_resource from sshkey
data "azurerm_ssh_public_key" "my_vm_public_key" {
  name = "DevOpsIntern"
  resource_group_name = data.azurerm_resource_group.current.name
}

# Create network
resource "azurerm_virtual_network" "my_terraform_network" {
  name = "LinuxVMnet"
  address_space = ["10.0.0.0/16"]
  location = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
}

# Create the subnet
resource "azurerm_subnet" "my_terraform_network_subnet" {
  name = "LinuxVMsubnet"
  resource_group_name = data.azurerm_resource_group.current.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name = "LinuxVMpubIP"
  location = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
  allocation_method = "Dynamic"
}

# Create a SecurityGroup
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name = "LinuxVMNetworkingSecurityGroup"
  location = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name

  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "HTTP"
    priority = 1002
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "HTTPS"
    priority = 1003
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  tags = {
    Owner = "cuong.ngominh@orientsoftware.com"
    Department = "DevOps"
  }
}

# Create NIC
resource "azurerm_network_interface" "my_terraform_nic" {
  name = "LinuxVMNic"
  location = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name

  ip_configuration {
    name = "my_nic_configuration"
    subnet_id = azurerm_subnet.my_terraform_network_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Get the connect between NIC and security group
resource "azurerm_network_interface_security_group_association" "my_terraform_asNicSG" {
  network_interface_id = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Create the virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name = "LinuxVM"
  computer_name = "LinuxVM"
  resource_group_name = data.azurerm_resource_group.current.name
  location = data.azurerm_resource_group.current.location
  size = "Standard_B1s"
  admin_username = "intern"
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  os_disk {
    name = "LinuxVM_disk"
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  admin_ssh_key {
    username = "intern"
    public_key = data.azurerm_ssh_public_key.my_vm_public_key.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  disable_password_authentication = true
  tags = {
    managed_by = "terraform"
    environment = "dev"
  }
}