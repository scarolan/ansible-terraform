##############################################################################
# Terraform and Ansible - Better Together

resource "azurerm_resource_group" "terraform_ansible" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${azurerm_resource_group.terraform_ansible.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.terraform_ansible.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.terraform_ansible.name}"
  address_prefix       = "${var.subnet_prefix}"
}

resource "azurerm_network_security_group" "tf-ansible-sg" {
  name                = "${var.prefix}-sg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.terraform_ansible.name}"

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "tf-ansible-nic" {
  name                      = "${var.prefix}tf-ansible-nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.terraform_ansible.name}"
  network_security_group_id = "${azurerm_network_security_group.tf-ansible-sg.id}"

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.tf-ansible-pip.id}"
  }
}

resource "azurerm_public_ip" "tf-ansible-pip" {
  name                         = "${var.prefix}-ip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.terraform_ansible.name}"
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "${var.hostname}"
}

resource "azurerm_virtual_machine" "site" {
  name                = "${var.hostname}-site"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.terraform_ansible.name}"
  vm_size             = "${var.vm_size}"

  network_interface_ids         = ["${azurerm_network_interface.tf-ansible-nic.id}"]
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "${var.hostname}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
      disable_password_authentication = true
      ssh_keys {
          path     = "/home/${var.admin_username}/.ssh/authorized_keys"
          key_data = "${var.ssh_pubkey}"
      }
  }

  # This is to ensure SSH comes up before we run the local exec.
  provisioner "remote-exec" { 
    inline = ["echo 'Hello World'"]

    connection {
      type = "ssh"
      host = "${azurerm_public_ip.tf-ansible-pip.fqdn}"
      user = "${var.admin_username}"
      private_key = "${var.ssh_key}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory.yaml --private-key ${var.ssh_key_path} ../ansible/httpd.yml"
  }

}