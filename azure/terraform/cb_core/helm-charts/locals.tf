locals {
  helm_charts_v3 = {
    ingress-nginx = {
      chart_url     = "https://kubernetes.github.io/ingress-nginx"
      chart_version = "4.10.0"
      namespace     = "ingress-basic"
      chart_name    = "ingress-nginx"
    },
    reloader = {
      chart_url     = "https://stakater.github.io/stakater-charts"
      chart_version = "1.0.116"
      namespace     = "default"
      chart_name    = "reloader"
    },
    external-dns = {
      chart_url     = "https://kubernetes-sigs.github.io/external-dns/"
      chart_version = "1.15.0"
      namespace     = "external-dns"
      chart_name    = "external-dns"
    },
    public-ingress = {
      chart_url     = "https://kubernetes.github.io/ingress-nginx"
      chart_version = "4.10.0"
      namespace     = "ingress-basic"
      chart_name    = "ingress-nginx"
    }
  }
}