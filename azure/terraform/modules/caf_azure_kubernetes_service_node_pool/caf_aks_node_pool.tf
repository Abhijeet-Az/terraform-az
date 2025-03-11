// Sets up additional Azure Kubernetes Services cluster node pool
//**********************************************************************************************
//The type of Default Node Pool for the Kubernetes cluster must be VirtualMachineScaleSets to attach multiple node pools.

resource "azurerm_kubernetes_cluster_node_pool" "caf_kubernetes_cluster_node_pools" {
  name                         = var.caf_kubernetes_node_pool_name
  kubernetes_cluster_id        = var.caf_kubernetes_node_pool_kubernetes_cluster_id
  vm_size                      = var.caf_kubernetes_node_pool_vm_size
  zones                        = var.caf_kubernetes_node_pool_availability_zones
  auto_scaling_enabled         = var.caf_kubernetes_node_pool_enable_auto_scaling
  host_encryption_enabled      = var.caf_kubernetes_node_pool_enable_host_encryption
  node_public_ip_enabled       = var.caf_kubernetes_node_pool_enable_node_public_ip
  fips_enabled                 = var.caf_kubernetes_node_pool_fips_enabled
  kubelet_disk_type            = var.caf_kubernetes_node_pool_kubelet_disk_type
  priority                     = var.caf_kubernetes_node_pool_priority
  eviction_policy              = var.caf_kubernetes_node_pool_priority == "Spot" ? var.caf_kubernetes_node_pool_eviction_policy : null
  max_pods                     = var.caf_kubernetes_node_pool_max_pods
  mode                         = var.caf_kubernetes_node_pool_mode
  node_labels                  = var.caf_kubernetes_node_pool_priority == "Spot" ? var.caf_kubernetes_node_pool_node_labels : null
  node_public_ip_prefix_id     = var.caf_kubernetes_node_pool_enable_node_public_ip ? var.caf_kubernetes_node_pool_node_public_ip_prefix_id : null
  node_taints                  = var.caf_kubernetes_node_pool_node_taints
  orchestrator_version         = var.caf_kubernetes_node_pool_orchestrator_version
  os_disk_size_gb              = var.caf_kubernetes_node_pool_os_disk_size_gb
  os_disk_type                 = var.caf_kubernetes_node_pool_os_disk_type
  os_sku                       = var.caf_kubernetes_node_pool_os_type == "Windows" ? null : var.caf_kubernetes_node_pool_os_sku
  os_type                      = var.caf_kubernetes_node_pool_os_type
  proximity_placement_group_id = var.caf_kubernetes_node_pool_proximity_placement_group_id
  spot_max_price               = var.caf_kubernetes_node_pool_priority == "Spot" ? var.caf_kubernetes_node_pool_spot_max_price : null
  ultra_ssd_enabled            = var.caf_kubernetes_node_pool_ultra_ssd_enabled
  vnet_subnet_id               = var.caf_kubernetes_node_pool_vnet_subnet_id
  max_count                    = var.caf_kubernetes_node_pool_enable_auto_scaling ? var.caf_kubernetes_node_pool_max_count : null
  min_count                    = var.caf_kubernetes_node_pool_enable_auto_scaling ? var.caf_kubernetes_node_pool_min_count : null
  node_count                   = var.caf_kubernetes_node_pool_node_count
  tags                         = var.tags

  //Node surges require subscription quota for the requested max surge count for each upgrade operation. For example, a cluster that has 5 node pools, each with a count of 4 nodes, has a total of 20 nodes. If each node pool has a max surge value of 50%, additional compute and IP quota of 10 nodes (2 nodes * 5 pools) is required to complete the upgrade. Surge upgrade behavior is determined by two settings: max-surge-upgrade. The number of additional nodes that can be added to the node pool during an upgrade. Increasing max-surge-upgrade raises the number of nodes that can be upgraded simultaneously.

  dynamic "upgrade_settings" {
    for_each = var.caf_kubernetes_node_pool_upgrade_max_surge == null ? [] : ["upgrade_settings"]
    content {
      max_surge = var.caf_kubernetes_node_pool_upgrade_max_surge
    }
  }
  //Customizing your node configuration allows you to configure or tune your operating system (OS) settings or the kubelet parameters to match the needs of the workloads. When you create an AKS cluster or add a node pool to your cluster, you can customize a subset of commonly used OS and kubelet settings. To configure settings beyond this subset.
  dynamic "kubelet_config" {
    for_each = try(var.caf_kubernetes_node_pool_kubelet_config, {})
    content {
      allowed_unsafe_sysctls    = kubelet_config.value["allowed_unsafe_sysctls"]
      container_log_max_line    = kubelet_config.value["container_log_max_line"]
      container_log_max_size_mb = kubelet_config.value["container_log_max_size_mb"]
      cpu_cfs_quota_enabled     = kubelet_config.value["cpu_cfs_quota_enabled"]
      cpu_cfs_quota_period      = kubelet_config.value["cpu_cfs_quota_period"]
      cpu_manager_policy        = kubelet_config.value["cpu_manager_policy"]
      image_gc_high_threshold   = kubelet_config.value["image_gc_high_threshold"]
      image_gc_low_threshold    = kubelet_config.value["image_gc_low_threshold"]
      pod_max_pid               = kubelet_config.value["pod_max_pid"]
      topology_manager_policy   = kubelet_config.value["topology_manager_policy"]
    }
  }

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
  lifecycle {
    ignore_changes = [
      max_pods, os_disk_type, zones, min_count, upgrade_settings, node_count
    ]
    prevent_destroy = true
  }
}
//**********************************************************************************************