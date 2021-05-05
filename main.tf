terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}


# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "resourceGroup" {
  name     = var.rsgroup
  location = "eastus"

  tags = {
    environment = var.tag
  }
}

# Create virtual network
resource "azurerm_virtual_network" "devopsNetwork" {
  name                = "vnetdevops"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.resourceGroup.name

  tags = {
    environment = var.tag
  }
}

# Create subnet
resource "azurerm_subnet" "devopssubnet" {
  name                 = "subnetdevops"
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.devopsNetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "Linuxippublica" {
  name                = "linuxippublica"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  allocation_method   = "Dynamic"

  tags = {
    environment = var.tag
  }
}

resource "azurerm_public_ip" "winpublicip" {
  name                = "winPublicIP"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  allocation_method   = "Dynamic"

  tags = {
    environment = var.tag
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "devopsmnsg" {
  name                = "devopsNetworkSecurityGroup"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.resourceGroup.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.tag
  }
}

# Create network interface
resource "azurerm_network_interface" "linuxnic" {
  name                = "linuxNic"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "Linuxos"
    subnet_id                     = azurerm_subnet.devopssubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Linuxippublica.id
  }

  tags = {
    environment = var.tag
  }
}

resource "azurerm_network_interface" "winnic" {
  name                = "Winnic"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "winos"
    subnet_id                     = azurerm_subnet.devopssubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.winpublicip.id
  }

  tags = {
    environment = var.tag
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.linuxnic.id
  network_security_group_id = azurerm_network_security_group.devopsmnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.resourceGroup.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.resourceGroup.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.tag
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "tls_private_key" { value = nonsensitive(tls_private_key.example_ssh.private_key_pem) }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "linuxvm01" {
  name                  = "linuxvm01"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.linuxnic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "linuxvm01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
    //public_key = file("~/.ssh/id_rsa.pub")

  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }

  tags = {
    environment = var.tag
  }
}
resource "azurerm_windows_virtual_machine" "windowsVM" {
  name                  = "windowsvm01"
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  location              = azurerm_resource_group.resourceGroup.location
  size                  = "Standard_B2s"
  admin_username        = "adminuser"
  admin_password        = "P@$$w0rdXqty@@.DXC.2021"
  network_interface_ids = [azurerm_network_interface.winnic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = var.tag
  }
}

output "azurerm_linux_virtual_machine" { value = azurerm_linux_virtual_machine.linuxvm01.public_ip_addresses }
