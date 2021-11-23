resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aswinaks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aswinaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
    type       = "VirtualMachineScaleSets"
  }

  linux_profile {
    admin_username = "azureadmin"

    ssh_key {
      # remove any new lines using the replace interpolation function
      key_data = replace(var.public_ssh_key, "\n", "")
    }
  }
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  role_based_access_control {
    enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

