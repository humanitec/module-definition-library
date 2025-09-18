variable "namespace" {
  type    = string
  default = null
}

variable "secret_name" {
  type = string
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

data "kubernetes_secret" "subject" {
  metadata {
    name      = var.secret_name
    namespace = var.namespace
  }
}

output "humanitec_metadata" {
  value = {
    "Kubernetes-Namespace" = data.kubernetes_secret.subject.metadata[0].namespace,
  }
}

output "values" {
  value     = data.kubernetes_secret.subject.data
  sensitive = true
}
