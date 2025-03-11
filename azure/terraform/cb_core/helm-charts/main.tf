resource "helm_release" "charts_v3_aks" {
  for_each   = local.helm_charts_v3
  name       = each.key
  repository = each.value.chart_url
  chart      = each.value.chart_name
  version    = each.value.chart_version
  namespace  = each.value.namespace
  wait       = true
  values = [
    templatefile("helm-values/${each.key}.yaml", { ilb_ip = "${var.kube_config[var.environment].ilb_ip}" })
  ]
}

