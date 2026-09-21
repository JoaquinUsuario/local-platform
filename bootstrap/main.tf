resource "kind_cluster" "default" {
  name           = "gitops-platform"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Port forwarding for ArgoCD and Demo App
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        listen_address = "0.0.0.0"
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        listen_address = "0.0.0.0"
      }
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [kind_cluster.default]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.11" # Specify a stable version
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  timeout    = 600

  # Example values, normally you could load from a file, but keeping it simple here
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "server.insecure"
    value = "true"
  }

  depends_on = [kubernetes_namespace.argocd]
}
