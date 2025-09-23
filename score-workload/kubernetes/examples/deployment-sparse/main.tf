module "score_workload" {
  source = "../../"

  namespace = "default"

  metadata = {
    name = "deployment-sparse"
    annotations = {
      "score.humanitec.dev/workload-type" = "Deployment"
    }
  }

  containers = {
    "main" = {
      image = "nginx:latest"
    }
  }
}
