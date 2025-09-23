## Installation

Install this with the `hctl` CLI, you should replace the `CHANGEME` in the provider mapping with your real provider type and alias for Kubernetes; and replace the CHANGEME in module_inputs with the real source secret.

```shell
hctl create module \
    --set=resource_type=env \
    --set=module_source=git::https://github.com/humanitec/module-definition-library//env/kubernetes-secret \
    --set=provider_mapping='{"kubernetes": "CHANGEME"}' \
    --set=module_inputs='{"namespace": "default", "secret_name": "CHANGEME"}'
```