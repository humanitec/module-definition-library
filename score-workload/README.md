# score-workload resource type

The implementations of this resource type can be found in the child directories.

The recommended resource type is:

```hcl
resource "platform-orchestrator_resource_type" "score-workload" {
  id          = "score-workload"
  description = "A Score Workload based application deployment"
  output_schema = jsonencode({
    type = "object"
    properties = {
      endpoint = {
        type        = "string"
        description = "An optional endpoint uri that the workload's service ports will be exposed on if any are defined"
      }
    }
  })
  is_developer_accessible = true
}
```
