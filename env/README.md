# env resource type

The implementations of this resource type can be found in the child directories.

The recommended resource type is:

```hcl
resource "platform-orchestrator_resource_type" "env" {
  id          = "env"
  description = "A map of variables in this environment"
  output_schema = jsonencode({
    type = "object"
    required = ["values"]
    properties = {
      values = {
        type        = "object"
        description = "A map of output keys and values"
        additionalProperties = {
            type = string
        }
      }
    }
  })
  is_developer_accessible = true
}
```
