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

| Name            | Description                                             | Type     |
| --------------- | ------------------------------------------------------- | -------- |
| `endpoint`      | The dns name of the clusterip service for this workload | `string` |

## Module Inputs

The following input variables can be set in the `module_inputs` of the `hctl create module` command.

| Name                     | Description                                           | Type          | Default | Required |
| ------------------------ | ----------------------------------------------------- | ------------- | ------- | -------- |
| `namespace`              | The namespace to deploy to.                           | `string`      |         | yes      |
| `service_account_name`   | The name of the service account to use for the pods.  | `string`      | `null`  | no       |
| `additional_annotations` | Additional annotations to add to all resources.       | `map(string)` | `{}`    | no       |
| `wait_for_rollout`       | Whether to wait for the workload to be rolled out.    | `bool`        | `true`  | no       |
| `wait_for_timeout`       | Timeout to wait                                       | `string`      | `"1m"`  | no       |
| `replicas`               | Optional number of replicas to deploy.                | `number`      | `null`  | no       |

For example, to set the `service_account_name` and disable `wait_for_rollout`, you would use:

```shell
hctl create module \
    ...
    --set=module_inputs='{"namespace": "my-namespace", "service_account_name": "my-sa", "wait_for_rollout": false}'
```
