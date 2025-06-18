variable "prefix" {
    type = string
    default = "namespace-"
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

resource "kubernetes_namespace" "ns" {
  metadata {
    generate_name = var.prefix
  }
}

output "name" {
    value = kubernetes_namespace.ns.metadata[0].name
}

output "humanitec_metadata" {
  description = "Metadata for Humanitec."
  value = {
    "Kubernetes-Namespace" = kubernetes_namespace.ns.metadata[0].name
  }
}
