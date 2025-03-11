// Outputs Azure Kubernetes Services cluster node pools
//**********************************************************************************************
output "caf_kubernetes_cluster_node_pools" {
  value = azurerm_kubernetes_cluster_node_pool.caf_kubernetes_cluster_node_pools
}
//**********************************************************************************************