locals {
  psql_admin_pwd_secret_name    = "psqladminpwd"
  excluded_namespaces_regex_exp = "^(aks-command|kube-public|kube-system|default|kube-node-lease|tigera-operator)$|pr-app$"
  slack_webhook_kv_secret_name  = "slackwebhookurl"
  default_allowed_methods       = ["GET", "HEAD"]
  default_max_age_in_seconds    = 0
  default_exposed_headers       = ["Content-Length"]
  default_allowed_headers       = ["*"]

  origin_url_map = [for url in var.azure_config[var.environment].cors_allowed_origins : {
    allowed_origins    = [url]
    allowed_methods    = local.default_allowed_methods
    allowed_headers    = local.default_allowed_headers
    exposed_headers    = local.default_exposed_headers
    max_age_in_seconds = local.default_max_age_in_seconds
    }
  ]
  cluster_level_prometheus_rules = [
    {
      alert      = "Cluster Level Alert - CPU Quota Over Committed"
      expression = <<EOF
sum(
  min without(resource) (
    kube_resourcequota{
      job="kube-state-metrics", 
      type="hard", 
      resource=~"(cpu|requests.cpu)",
      namespace!~"${local.excluded_namespaces_regex_exp}"
    }
  )
) 
/ 
sum(
  kube_node_status_allocatable{
    resource="cpu", 
    job="kube-state-metrics"
  }
) > 1.5
EOF
      for        = "PT5M"
      severity   = 3
    },
    {
      alert      = "Cluster Level Alert - Memory Quota Over Committed"
      expression = <<EOF
sum(
  min without(resource) (
    kube_resourcequota{
      job="kube-state-metrics", 
      type="hard", 
      resource=~"(memory|requests.memory)",
      namespace!~"${local.excluded_namespaces_regex_exp}"
    }
  )
) 
/ 
sum(
  kube_node_status_allocatable{
    resource="memory", 
    job="kube-state-metrics"
  }
) > 1.5
EOF
      for        = "PT5M"
      severity   = 3
    },
    {
      alert      = "Cluster Level Alert - OOM Killed Countainer Count"
      expression = <<EOF
sum by (cluster,container,controller,namespace)(
  kube_pod_container_status_last_terminated_reason{reason="OOMKilled", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  * on(cluster,namespace,pod) group_left(controller) 
  label_replace(kube_pod_owner{namespace!~"${local.excluded_namespaces_regex_exp}"}, "controller", "$1", "owner_name", "(.*)")
) > 0
EOF
      for        = "PT5M"
      severity   = 4
    },
    {
      alert      = "Cluster Level Alert - Kube Client Error"
      expression = <<EOF
(
  sum(rate(rest_client_requests_total{code=~"5..", namespace!~"${local.excluded_namespaces_regex_exp}"}[5m])) 
  by (cluster, instance, job, namespace)  
) 
/
(
  sum(rate(rest_client_requests_total{namespace!~"${local.excluded_namespaces_regex_exp}"}[5m])) 
  by (cluster, instance, job, namespace)
) 
> 0.01
EOF
      for        = "PT5M"
      severity   = 4
    },
    {
      alert      = "Cluster Level Alert - Kube Persistent Volume Filling Up within 4 days"
      expression = <<EOF
(
  kubelet_volume_stats_available_bytes{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  / 
  kubelet_volume_stats_capacity_bytes{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  < 0.15
)
and 
(
  kubelet_volume_stats_used_bytes{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  > 0
)
and 
(
  predict_linear(kubelet_volume_stats_available_bytes{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"}[6h], 4 * 24 * 3600) 
  < 0
)
unless 
on(namespace, persistentvolumeclaim) 
(
  kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  == 1
)
unless 
on(namespace, persistentvolumeclaim) 
(
  kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  == 1
)
EOF
      for        = "PT5M"
      severity   = 4
    },
    {
      alert      = "Cluster Level Alert - Kube Persistent Volume iNodes Filling Up"
      expression = <<EOF
kubelet_volume_stats_inodes_free{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"} 
/
kubelet_volume_stats_inodes{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"} 
< 0.03

EOF
      for        = "PT15M"
      severity   = 4
    },
    {
      alert      = "Cluster Level Alert - Kube Persistent Volume Error"
      expression = <<EOF
kube_persistentvolume_status_phase{phase=~"Failed|Pending", job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} > 0
EOF
      for        = "PT15M"
      severity   = 4
    },
    {
      alert      = "Cluster Level Alert - Kube Container in waiting state"
      expression = <<EOF
sum by (namespace, pod, container, cluster) (
  kube_pod_container_status_waiting_reason{
    job="kube-state-metrics",
    namespace!~"${local.excluded_namespaces_regex_exp}"
  }
) > 0
EOF
      for        = "PT5M"
      severity   = 3
    },
    {
      alert      = "Cluster Level Alert - Kube Daemon Set Not Scheduled"
      expression = <<EOF
kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} 
- 
kube_daemonset_status_current_number_scheduled{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} 
> 0
EOF
      for        = "PT15M"
      severity   = 3
    },
    {
      alert      = "Cluster Level Alert - Kube Daemon Set Miss Scheduled"
      expression = <<EOF
kube_daemonset_status_number_misscheduled{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} > 0
EOF
      for        = "PT15M"
      severity   = 3
    },
    {
      alert      = "Cluster Level Alert - Kube Resource Quota Almost Full"
      expression = <<EOF
kube_resourcequota{job="kube-state-metrics", type="used", namespace!~"${local.excluded_namespaces_regex_exp}"} 
/ 
ignoring(instance, job, type) 
(
  kube_resourcequota{job="kube-state-metrics", type="hard", namespace!~"${local.excluded_namespaces_regex_exp}"} > 0
) 
> 0.9 
< 1
EOF
      for        = "PT15M"
      severity   = 3
    }
  ]
  node_level_prometheus_rules = [
    {
      alert      = "Node Level Alert - Kube Node Unreachable"
      expression = <<EOF
(
  kube_node_spec_taint{job="kube-state-metrics", key="node.kubernetes.io/unreachable", effect="NoSchedule", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  unless 
  ignoring(key, value) 
  (
    kube_node_spec_taint{job="kube-state-metrics", key=~"ToBeDeletedByClusterAutoscaler|cloud.google.com/impending-node-termination|aws-node-termination-handler/spot-itn", namespace!~"${local.excluded_namespaces_regex_exp}"}
  )
) == 1

EOF
      for        = "PT15M"
      severity   = 3
    },
    {
      alert      = "Node Level Alert - Node Readiness Flapping"
      expression = <<EOF
sum(
  changes(
    kube_node_status_condition{status="true", condition="Ready", namespace!~"${local.excluded_namespaces_regex_exp}"}[15m]
  )
) by (cluster, node) > 2

EOF
      for        = "PT15M"
      severity   = 3
    }
  ]
  pod_level_prometheus_rules = [
    {
      alert      = "Pod Level Alert - PV Usage High"
      expression = <<EOF
avg by (namespace, controller, container, cluster) (
  (
    (kubelet_volume_stats_used_bytes{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"} 
    / 
    on(namespace, cluster, pod, container) group_left 
    kubelet_volume_stats_capacity_bytes{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"})
    * 
    on(namespace, pod, cluster) group_left(controller) 
    label_replace(kube_pod_owner, "controller", "$1", "owner_name", "(.*)")
  )
) > 0.8
EOF
      for        = "PT15M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - Deployment Replicas Mismatch"
      expression = <<EOF
(
  kube_deployment_spec_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  > 
  kube_deployment_status_replicas_available{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}
)
and
(
  changes(kube_deployment_status_replicas_updated{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}[10m]) 
  == 0
)
EOF
      for        = "PT15M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - StatefulSet Replicas Mismatch"
      expression = <<EOF
(
  kube_statefulset_status_replicas_ready{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  != 
  kube_statefulset_status_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}
)
and
(
  changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}[10m]) 
  == 0
)

EOF
      for        = "PT15M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - Horizontal Pod Autoscaler Replicas Mismatch"
      expression = <<EOF
(
  kube_horizontalpodautoscaler_status_desired_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  != 
  kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}
) 
and 
(
  kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  > 
  kube_horizontalpodautoscaler_spec_min_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}
) 
and 
(
  kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  < 
  kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}
) 
and 
(
  changes(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}[15m]) 
  == 0
)
EOF
      for        = "PT15M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - Horizontal Pod Autoscaler Maxed Out"
      expression = <<EOF
kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} 
== 
kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}
EOF
      for        = "PT15M"
      severity   = 4
    },
    {
      alert      = "Pod Level Alert - Pod Crash Looping"
      expression = <<EOF
max_over_time(
  kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff", job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}[5m]
) 
>= 1
EOF
      for        = "PT15M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - Job State Older than 6 hours"
      expression = <<EOF
sum by(namespace,cluster)(
  kube_job_spec_completions{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}
) 
- 
sum by(namespace,cluster)(
  kube_job_status_succeeded{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}
)  
> 0
 
EOF
      for        = "PT5M"
      severity   = 4
    },
    {
      alert      = "Pod Level Alert - Container Restart"
      expression = <<EOF
sum by (namespace, controller, container, cluster)(
  increase(
    kube_pod_container_status_restarts_total{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}[15m]
  ) 
  * on(namespace, pod, cluster) group_left(controller) 
  label_replace(
    kube_pod_owner, "controller", "$1", "owner_name", "(.*)"
  )
) 
> 2
EOF
      for        = "PT5M"
      severity   = 4
    },
    {
      alert      = "Pod Level Alert - Ready Pods less than 80%"
      expression = <<EOF
(
  sum by (cluster, namespace, deployment)(
    kube_deployment_status_replicas_ready{namespace!~"${local.excluded_namespaces_regex_exp}"}
  ) 
  / 
  sum by (cluster, namespace, deployment)(
    kube_deployment_spec_replicas{namespace!~"${local.excluded_namespaces_regex_exp}"}
  ) 
  < .8 
) 
or 
(
  sum by (cluster, namespace, deployment)(
    kube_daemonset_status_number_ready{namespace!~"${local.excluded_namespaces_regex_exp}"}
  ) 
  / 
  sum by (cluster, namespace, deployment)(
    kube_daemonset_status_desired_number_scheduled{namespace!~"${local.excluded_namespaces_regex_exp}"}
  ) 
  < .8
) 
EOF
      for        = "PT5M"
      severity   = 4
    },
    {
      alert      = "Pod Level Alert - Pods in Failed State"
      expression = <<EOF
sum by (cluster, namespace, controller) (
  kube_pod_status_phase{phase="failed", namespace!~"${local.excluded_namespaces_regex_exp}"} 
  * on(namespace, pod, cluster) group_left(controller) 
  label_replace(kube_pod_owner, "controller", "$1", "owner_name", "(.*)")
) 
> 0 
EOF
      for        = "PT5M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - Pods not ready by controller"
      expression = <<EOF
sum by (namespace, controller, cluster) (
  max by(namespace, pod, cluster) (
    kube_pod_status_phase{job="kube-state-metrics", phase=~"Pending|Unknown", namespace!~"${local.excluded_namespaces_regex_exp}"}
  ) 
  * on(namespace, pod, cluster) group_left(controller) 
  label_replace(kube_pod_owner, "controller", "$1", "owner_name", "(.*)")
) 
> 0
EOF
      for        = "PT5M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - StatefulSet Generation Mismatch"
      expression = <<EOF
kube_statefulset_status_observed_generation{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} 
!= 
kube_statefulset_metadata_generation{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"}
EOF
      for        = "PT5M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - Job in Failed State"
      expression = <<EOF
kube_job_failed{job="kube-state-metrics", namespace!~"${local.excluded_namespaces_regex_exp}"} > 0
EOF
      for        = "PT5M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - Average Container CPU Usage High"
      expression = <<EOF
sum(rate(container_cpu_usage_seconds_total{image!="", container!="POD", namespace!~"${local.excluded_namespaces_regex_exp}"}[5m])) by (pod, cluster, container, namespace) 
/ 
sum(container_spec_cpu_quota{image!="", container!="POD", namespace!~"${local.excluded_namespaces_regex_exp}"} 
/ container_spec_cpu_period{image!="", container!="POD", namespace!~"${local.excluded_namespaces_regex_exp}"}) 
by (pod, cluster, container, namespace) 
> .95
EOF
      for        = "PT5M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - Average Container Memory Usage High"
      expression = <<EOF
avg by (namespace, controller, container, cluster) (
  (
    (container_memory_working_set_bytes{container!="", image!="", container!="POD", namespace!~"${local.excluded_namespaces_regex_exp}"} 
    / on(namespace, cluster, pod, container) group_left kube_pod_container_resource_limits{resource="memory", node!=""})
    * on(namespace, pod, cluster) group_left(controller) 
    label_replace(kube_pod_owner, "controller", "$1", "owner_name", "(.*)")
  )
) > .95
EOF
      for        = "PT5M"
      severity   = 3
    },
    {
      alert      = "Pod Level Alert - Start-up Latency High"
      expression = <<EOF
histogram_quantile(0.99, sum(rate(kubelet_pod_worker_duration_seconds_bucket{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"}[5m])) by (cluster, instance, le)) 
* on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet", namespace!~"${local.excluded_namespaces_regex_exp}"} > 60
EOF
      for        = "PT5M"
      severity   = 3
    }
  ]
}