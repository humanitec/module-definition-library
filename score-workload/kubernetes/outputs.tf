output "humanitec_metadata" {
  description = "Metadata for Humanitec."
  value = merge(
    {
      "Kubernetes-Namespace" = var.namespace
    },
    local.create_service ? { "Kubernetes-Service" = kubernetes_service_v1.default[0].metadata[0].name } : {},
    local.workload_type == "Deployment" ? { "Kubernetes-Deployment" = kubernetes_deployment_v1.default[0].metadata[0].name } : {},
    local.workload_type == "StatefulSet" ? { "Kubernetes-StatefulSet" = kubernetes_stateful_set_v1.default[0].metadata[0].name } : {},
  )
}

output "endpoint" {
  value = "${var.metadata.name}.${var.namespace}.svc.cluster.local"
}
