output "raw_kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config
}

output "node_resource_group" {
    value = azurerm_kubernetes_cluster.aks.node_resource_group
}