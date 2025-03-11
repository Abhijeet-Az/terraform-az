output "caf_kubernetes" {
  value = azurerm_kubernetes_cluster.aks
}
output "caf_kubernetes_id" {
  value = azurerm_kubernetes_cluster.aks.id
}