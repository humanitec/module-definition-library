## Installation

Install this with the `canyon` CLI, you should replace the `CHANGEME` in the provider mapping with your real provider type and alias for Kubernetes; and replace the CHANGEME in module_inputs with the real source secret.

```shell
canyon create module-definition \
    --set=resource_type=env \
    --set=module_source=git::https://github.com/humanitec/module-definition-library//env/kubernetes-secret \
    --set=provider_mapping='{"kubernetes": "CHANGEME"}' \
    --set=module_inputs='{"secret_name": "CHANGEME"}'
```