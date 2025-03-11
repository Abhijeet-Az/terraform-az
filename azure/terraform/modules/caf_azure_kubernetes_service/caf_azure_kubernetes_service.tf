// Sets up an instance of Azure Kubernetes Service
//**********************************************************************************************
resource "tls_private_key" "key" {
  algorithm = "ED25519"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "aks-${var.caf_application}-${var.env_prefix}-${var.suffix}"
  dns_prefix                = "dns-${var.caf_application}-${var.env_prefix}-${var.suffix}"
  resource_group_name       = var.caf_aks_rg
  location                  = var.location
  node_resource_group       = "MC_${var.caf_application}-${var.env_prefix}-${var.suffix}"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  sku_tier                  = var.sku_tier
  identity {
    type = "SystemAssigned"
  }
  #retrieve the latest version of Kubernetes supported by Azure Kubernetes Service if version is not set
  kubernetes_version = var.kubernetes_version
  dynamic "default_node_pool" {
    for_each = var.agent_pools
    content {
      name                        = var.env_prefix == "dev" ? "agentpool" : default_node_pool.value.name
      node_count                  = default_node_pool.value.count
      vm_size                     = default_node_pool.value.vm_size
      os_sku                      = default_node_pool.value.os_type
      os_disk_size_gb             = default_node_pool.value.os_disk_size_gb
      vnet_subnet_id              = var.agent_pool_subnet_id
      type                        = default_node_pool.value.type
      zones                       = default_node_pool.value.availability_zones
      auto_scaling_enabled        = default_node_pool.value.enable_auto_scaling
      min_count                   = default_node_pool.value.min_count
      max_count                   = default_node_pool.value.max_count
      max_pods                    = default_node_pool.value.max_pods
      orchestrator_version        = var.default_nodepool_kubernetes_version
      temporary_name_for_rotation = "tempupdpool"
      upgrade_settings {
        max_surge = "10%"
      }
    }
  }
  network_profile {
    network_plugin    = var.network_profile.network_plugin
    network_policy    = var.network_profile.network_policy
    service_cidr      = var.network_profile.service_cidr
    dns_service_ip    = var.network_profile.dns_service_ip
    load_balancer_sku = lookup(var.network_profile, "load_balancer_sku", "standard")
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = "c09fae9e-0750-4861-a01d-0dd6d9721be7"
  }

  monitor_metrics {
    annotations_allowed = var.metric_annotations_allowlist
    labels_allowed      = var.metric_labels_allowlist
  }
  oms_agent {
    msi_auth_for_monitoring_enabled = true
    log_analytics_workspace_id      = var.oms_workspace_id
  }

  timeouts {}
  lifecycle {
    ignore_changes = [
      dns_prefix, node_resource_group, network_profile, identity, kubelet_identity, maintenance_window_auto_upgrade, maintenance_window_node_os
    ]
    prevent_destroy = true
  }
}
resource "azurerm_role_assignment" "caf_acr_role_assignment" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.azurerm_container_registry_id
  skip_service_principal_aad_check = true
}



#data collection endpoint 
resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = substr("MSProm-${var.caf_application}-${var.env_prefix}-${var.suffix}", 0, min(44, length("MSProm-${var.caf_application}-${var.env_prefix}-${var.suffix}")))
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
  location            = var.location
  kind                = "Linux"
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                        = substr("MSProm-${var.caf_application}-${var.env_prefix}-${var.suffix}", 0, min(64, length("MSProm-${var.caf_application}-${var.env_prefix}-${var.suffix}")))
  resource_group_name         = azurerm_kubernetes_cluster.aks.resource_group_name
  location                    = var.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id
  kind                        = "Linux"

  destinations {
    monitor_account {
      monitor_account_id = var.prometheus_am_workspace_id
      name               = "MonitoringAccount1"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount1"]
  }

  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }

  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"
  depends_on = [
    azurerm_monitor_data_collection_endpoint.dce
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "dcra" {
  name                    = "MSProm-${var.caf_application}-${var.env_prefix}-${var.suffix}"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  description             = "Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster."
  depends_on = [
    azurerm_monitor_data_collection_rule.dcr
  ]
}

resource "azurerm_monitor_alert_prometheus_rule_group" "azurerm_prometheus_cluster_alert_rules" {
  name                = "prom-rg-aks-cluster-alert${var.caf_application}-${var.env_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
  cluster_name        = azurerm_kubernetes_cluster.aks.name
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [var.prometheus_am_workspace_id, azurerm_kubernetes_cluster.aks.id]

  dynamic "rule" {
    for_each = var.cluster_level_prometheus_rules
    content {
      alert      = rule.value.alert
      enabled    = true
      expression = rule.value.expression
      for        = rule.value.for
      severity   = rule.value.severity

      action {
        action_group_id = var.action_group_id
      }
    }
  }
}

resource "azurerm_monitor_alert_prometheus_rule_group" "azurerm_prometheus_node_alert_rules" {
  name                = "prom-rg-aks-node-alert${var.caf_application}-${var.env_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
  cluster_name        = azurerm_kubernetes_cluster.aks.name
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [var.prometheus_am_workspace_id, azurerm_kubernetes_cluster.aks.id]

  dynamic "rule" {
    for_each = var.node_level_prometheus_rules
    content {
      alert      = rule.value.alert
      enabled    = true
      expression = rule.value.expression
      for        = rule.value.for
      severity   = rule.value.severity

      action {
        action_group_id = var.action_group_id
      }
    }
  }
}

resource "azurerm_monitor_alert_prometheus_rule_group" "azurerm_prometheus_pod_alert_rules" {
  name                = "prom-rg-aks-pod-alert${var.caf_application}-${var.env_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
  cluster_name        = azurerm_kubernetes_cluster.aks.name
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [var.prometheus_am_workspace_id, azurerm_kubernetes_cluster.aks.id]

  dynamic "rule" {
    for_each = var.pod_level_prometheus_rules
    content {
      alert      = rule.value.alert
      enabled    = true
      expression = rule.value.expression
      for        = rule.value.for
      severity   = rule.value.severity

      action {
        action_group_id = var.action_group_id
      }
    }
  }
}
##Prometheus Recording Rules

resource "azurerm_monitor_alert_prometheus_rule_group" "node_recording_rules_rule_group" {
  name                = "prom-rg-node-${var.caf_application}-${var.env_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
  cluster_name        = azurerm_kubernetes_cluster.aks.name
  description         = "Node Recording Rules Rule Group"
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [var.prometheus_am_workspace_id, azurerm_kubernetes_cluster.aks.id]

  rule {
    enabled    = true
    record     = "instance:node_num_cpu:sum"
    expression = <<EOF
count without (cpu, mode) (  node_cpu_seconds_total{job="node",mode="idle"})
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_cpu_utilisation:rate5m"
    expression = <<EOF
1 - avg without (cpu) (  sum without (mode) (rate(node_cpu_seconds_total{job="node", mode=~"idle|iowait|steal"}[5m])))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_load1_per_cpu:ratio"
    expression = <<EOF
(  node_load1{job="node"}/  instance:node_num_cpu:sum{job="node"})
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_memory_utilisation:ratio"
    expression = <<EOF
1 - (  (    node_memory_MemAvailable_bytes{job="node"}    or    (      node_memory_Buffers_bytes{job="node"}      +      node_memory_Cached_bytes{job="node"}      +      node_memory_MemFree_bytes{job="node"}      +      node_memory_Slab_bytes{job="node"}    )  )/  node_memory_MemTotal_bytes{job="node"})
EOF
  }
  rule {
    enabled = true

    record     = "instance:node_vmstat_pgmajfault:rate5m"
    expression = <<EOF
rate(node_vmstat_pgmajfault{job="node"}[5m])
EOF
  }
  rule {
    enabled    = true
    record     = "instance_device:node_disk_io_time_seconds:rate5m"
    expression = <<EOF
rate(node_disk_io_time_seconds_total{job="node", device!=""}[5m])
EOF
  }
  rule {
    enabled    = true
    record     = "instance_device:node_disk_io_time_weighted_seconds:rate5m"
    expression = <<EOF
rate(node_disk_io_time_weighted_seconds_total{job="node", device!=""}[5m])
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_receive_bytes_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_receive_bytes_total{job="node", device!="lo"}[5m]))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_transmit_bytes_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_transmit_bytes_total{job="node", device!="lo"}[5m]))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_receive_drop_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_receive_drop_total{job="node", device!="lo"}[5m]))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_transmit_drop_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_transmit_drop_total{job="node", device!="lo"}[5m]))
EOF
  }
}

resource "azurerm_monitor_alert_prometheus_rule_group" "kubernetes_recording_rules_rule_group" {
  name                = "prom-rg-aks-node-${var.caf_application}-${var.env_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
  cluster_name        = azurerm_kubernetes_cluster.aks.name
  description         = "Kubernetes Recording Rules Rule Group"
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [var.prometheus_am_workspace_id, azurerm_kubernetes_cluster.aks.id]

  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate"
    expression = <<EOF
sum by (cluster, namespace, pod, container) (  irate(container_cpu_usage_seconds_total{job="cadvisor", image!=""}[5m])) * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (  1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_working_set_bytes"
    expression = <<EOF
container_memory_working_set_bytes{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_rss"
    expression = <<EOF
container_memory_rss{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_cache"
    expression = <<EOF
container_memory_cache{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_swap"
    expression = <<EOF
container_memory_swap{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_memory:active:kube_pod_container_resource_requests"
    expression = <<EOF
kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~"Pending|Running"} == 1))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_memory:kube_pod_container_resource_requests:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests"
    expression = <<EOF
kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~"Pending|Running"} == 1))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_cpu:kube_pod_container_resource_requests:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_memory:active:kube_pod_container_resource_limits"
    expression = <<EOF
kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~"Pending|Running"} == 1))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_memory:kube_pod_container_resource_limits:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits"
    expression = <<EOF
kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) ( (kube_pod_status_phase{phase=~"Pending|Running"} == 1) )
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_cpu:kube_pod_container_resource_limits:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    label_replace(      kube_pod_owner{job="kube-state-metrics", owner_kind="ReplicaSet"},      "replicaset", "$1", "owner_name", "(.*)"    ) * on(replicaset, namespace) group_left(owner_name) topk by(replicaset, namespace) (      1, max by (replicaset, namespace, owner_name) (        kube_replicaset_owner{job="kube-state-metrics"}      )    ),    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "deployment"
    }
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job="kube-state-metrics", owner_kind="DaemonSet"},    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "daemonset"
    }
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job="kube-state-metrics", owner_kind="StatefulSet"},    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "statefulset"
    }
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job="kube-state-metrics", owner_kind="Job"},    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "job"
    }
  }
  rule {
    enabled    = true
    record     = ":node_memory_MemAvailable_bytes:sum"
    expression = <<EOF
sum(  node_memory_MemAvailable_bytes{job="node"} or  (    node_memory_Buffers_bytes{job="node"} +    node_memory_Cached_bytes{job="node"} +    node_memory_MemFree_bytes{job="node"} +    node_memory_Slab_bytes{job="node"}  )) by (cluster)
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:node_cpu:ratio_rate5m"
    expression = <<EOF
sum(rate(node_cpu_seconds_total{job="node",mode!="idle",mode!="iowait",mode!="steal"}[5m])) by (cluster) /count(sum(node_cpu_seconds_total{job="node"}) by (cluster, instance, cpu)) by (cluster)
EOF
  }
}
