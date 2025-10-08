# score-workload/aws-lambda

This is a Terraform / OpenTofu compatible module to be used to provision `score-workload` resources ontop of AWS Lambda container functions.

## Requirements

1. There must be a module provider setup for `aws` (`hashicorp/aws`).
2. There must be a resource type setup for `score-workload`, see [README](../README.md).

## Installation

Install this with the `hctl` CLI, you should replace the `CHANGEME` in the provider mapping with your real provider type and alias for AWS; and replace the CHANGEME in module_inputs with the real target namespace.

```shell
hctl create module \
    --set=resource_type=score-workload \
    --set=module_source=git::https://github.com/humanitec/module-definition-library//score-workload/aws-lambda \
    --set=provider_mapping='{"aws": "CHANGEME"}' \
    --set=module_params='{"metadata": {"type": "map"},"containers": {"type": "map"}, "service": {"type": "map", "is_optional": true}}' \
    --set=module_inputs='{"namespace": "CHANGEME"}'
```

## Resource Outputs

The following outputs are exposed

| Name           | Description                                                            | Type     |
| -------------- | ---------------------------------------------------------------------- | -------- |
| `endpoint`     | The dns name of the function invoke url if service ports was not empty | `string` |
| `function_arn` | The lambda function ARN                                                | `string` |
| `iam_role_arn` | The ARN of the IAM role associated with the Function.                  | `string` |

## Module Inputs

The following input variables can be set in the `module_inputs` of the `hctl create module` command.

| Name                    | Description                                                                        | Type           | Default | Required |
| ----------------------- | ---------------------------------------------------------------------------------- | -------------- | ------- | -------- |
| `iam_role_arn`          | An existing IAM role to use for the Function, one will be created if not provided. | `string`       |         | no       |
| `architectures`         | The Lambda architecture (x86_64 or arm64). Defaults to x86_64.                     | `list(string)` |         | no       |
| `aws_region`            | The AWS region to deploy the function to. Defaults to the region of the provider.  | `string`       |         | no       |
| `timeout_in_seconds`    | Timeout of the function.                                                           | `integer`      | `3`     | no       |
| `is_ecr_policy_enabled` | Whether to create the IAM policy for pulling images from ECR.                      | `bool`         | `true`  | no       |
| `additional_tags`       | Additional AWS tags to add to AWS resources                                        | `map(string)`  | `{}`    | no       |
