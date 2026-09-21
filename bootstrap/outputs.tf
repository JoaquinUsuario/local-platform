output "cluster_endpoint" {
  description = "The endpoint of the kind cluster"
  value       = kind_cluster.default.endpoint
}

output "argocd_namespace" {
  description = "The namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}
