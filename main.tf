locals {
  common_tags = merge(var.common_tags, {    
    "environment" = "Demo"    
  })
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-rg"
  location = var.location
  tags = local.common_tags
}

module "ssh-key" {
  source         = "./modules/ssh-key"
  public_ssh_key = var.public_ssh_key
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  public_ssh_key      = module.ssh-key.public_ssh_key
  tags                = local.common_tags
}

resource "azurerm_public_ip" "ingress_pip" {
  name                = "aswin-aks-pip"
  resource_group_name = module.aks.node_resource_group
  location            = azurerm_resource_group.aks_rg.location
  allocation_method   = "Static"
  domain_name_label   = "aswin-aks-pip"
  sku                 = "Standard"

  tags = local.common_tags
}

resource "random_password" "jenkins_admin_password" {
  length           = 12
  special          = true
  override_special = "_%@"
}

module "kubernetes" {
  source                 = "./modules/kubernetes"
  client_certificate     = base64decode(module.aks.kube_config.0.client_certificate)
  client_key             = base64decode(module.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config.0.cluster_ca_certificate)
  host                   = module.aks.kube_config.0.host
  ingress_ip_address     = azurerm_public_ip.ingress_pip.ip_address
  jenkins_admin_password = random_password.jenkins_admin_password.result
}