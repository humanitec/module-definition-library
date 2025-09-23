module "score_workload" {
  source = "../../"

  namespace = "default"

  metadata = {
    name = "statefulset-sparse"
    annotations = {
      "score.humanitec.dev/workload-type" = "StatefulSet"
    }
  }

  containers = {
    "main" = {
      image = "nginx:latest"
    }
  }
}
