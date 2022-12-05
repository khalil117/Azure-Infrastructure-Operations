provider "azurerm" {
  features {}
}
data "azurerm_image" "main" {
  name                = "ubuntuImage"
  resource_group_name = "Azuredevops"
}

 resource "azurerm_resource_group" "Azuredevops" {
  name     = var.resource_group_name
  location = var.location
}


output "id" {
  value = azurerm_resource_group.Azuredevops.id
}
output "image_id" {
  value = "/subscriptions/9ed10bd5-8420-4fdf-b87f-621a5ee7dd47/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/ubuntuImage"
}

// Main virtual network, subnets, nics and public IPs

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vn"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location
  address_space       = ["10.0.0.0/22"]

tags = var.tags
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.Azuredevops.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location
  allocation_method   = "Static"

 tags = var.tags
}

resource "azurerm_public_ip" "second" {
  name                = "${var.prefix}-public-ip-forLB"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location
  allocation_method   = "Static"

 tags = var.tags
}

resource "azurerm_network_interface" "main" {
  count               = var.vm-count > 5 ? 5 : var.vm-count
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = var.tags
}
// Secutiy Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location

  security_rule {
    name                       = "allow-vms-access"
    protocol                   = "*"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

 tags = var.tags
}

resource "azurerm_network_security_rule" "deny-internet" {
  name                        = "deny-internet-access"
  protocol                    = "*"
  access                      = "Deny"
  priority                    = 4096
  direction                   = "Outbound"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Azuredevops.name
  network_security_group_name = azurerm_network_security_group.main.name
}

// Load balancer
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location

  frontend_ip_configuration {
    name = "${var.prefix}-public-ip-forLB"
    # subnet_id            = azurerm_subnet.internal.id
    public_ip_address_id = azurerm_public_ip.second.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "main" {
  name            = "${var.prefix}-lb-pool"
  loadbalancer_id = azurerm_lb.main.id
}

resource "azurerm_availability_set" "main" {
  name                         = "${var.prefix}-av-set"
  resource_group_name          = azurerm_resource_group.Azuredevops.name
  location                     = azurerm_resource_group.Azuredevops.location
  

 tags = var.tags
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm-count > 5 ? 5 : var.vm-count
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.Azuredevops.name
  location                        = azurerm_resource_group.Azuredevops.location
  network_interface_ids           = [azurerm_network_interface.main[count.index].id]
  size                            = "Standard_D2s_v3"
  admin_username                  = var.vm-admin-username
  admin_password                  = var.vm-admin-password
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.main.id
   availability_set_id             = azurerm_availability_set.main.id
 

  # admin_ssh_key {
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  

 

  os_disk {
    name                 = "${var.prefix}-vm-${count.index}-mdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    # disk_size_gb         = "5"
  }

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

 tags = var.tags
}

resource "azurerm_managed_disk" "main" {
  name                 = "${var.prefix}-mdisk"
  resource_group_name  = azurerm_resource_group.Azuredevops.name
  location             = azurerm_resource_group.Azuredevops.location
  storage_account_type = "Standard_LRS"
  disk_size_gb         = "5"
  create_option        = "Empty"

tags = var.tags
}
