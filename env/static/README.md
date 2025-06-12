```shell
canyon create module-definition \
    --set=resource_type=env \
    --set=module_source=git::https://github.com/humanitec/module-definition-library//env/static \
    --set=module_inputs='{"values": {"KEY": "VALUE"}}'
```