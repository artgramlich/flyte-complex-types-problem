# Initial Setup
```
flytectl create project --id "flyte-complextype" --name "flyte-complextype"

./docker_build.sh -v test
docker push localhost:30000/flyte-complextype:test
pyflyte --verbose --pkgs workflows package --image localhost:30000/flyte-complextype:test --force
flytectl register files --project "flyte-complextype" --domain development --archive flyte-package.tgz  --version test
```

# Local (using main)        

```./workflows/example.py```

Works as expected

# Local (using pyflyte run)

```pyflyte run workflows/example.py hello_world_complex_wf --example '{"name":"Ada"}'```

Works as expected

# Remote (using pyflyte run --remote)

```pyflyte run --remote -p flyte-complextype -d development workflows/example.py hello_world_complex_wf --example '{"name":"Ada"}'```

Fails with
```
/Users/agramlic/tmp/flyte-pydantic-minimal/.venv/lib/python3.12/site-packages/flytekitplugins/pydantic/basemodel_transformer.py:51: FutureWarning: If you are using Pydantic version 2.0 or later, please import BaseModel using `from pydantic.v1 import BaseModel`.
  warnings.warn(
Running Execution on Remote.
Failed with Exception Code: USER:BadInputToAPI
Request rejected by the API, due to Invalid input.
        Input Request: {
  "project": "flyte-complextype",
  "domain": "development",
  "name": "f6da5fed0c86c47d8b0f",
  "spec": {
    "launchPlan": {
      "resourceType": "LAUNCH_PLAN",
      "project": "flyte-complextype",
      "domain": "development",
      "name": "workflows.example.hello_world_complex_wf",
      "version": "LMxosEwmTAt54vIiyKpicw"
    },
    "metadata": {
      "principal": "placeholder"
    },
    "disableAll": false,
    "labels": {},
    "annotations": {},
    "authRole": {}
  },
  "inputs": {
    "literals": {
      "example": {
        "map": {
          "literals": {
            "BaseModel JSON": {
              "scalar": {
                "generic": {
                  "name": "Ada"
                }
              }
            },
            "Serialized Flyte Objects": {
              "map": {}
            }
          }
        }
      }
    }
  }
}
RPC Failed, with Status: StatusCode.INVALID_ARGUMENT
        details: invalid example input wrong type. Expected simple:STRUCT, but got map_value_type:{union_type:{variants:{map_value_type:{simple:NONE}}  variants:{simple:STRUCT}}}
        Debug string UNKNOWN:Error received from peer  {created_time:"2024-04-15T10:35:04.72485-07:00", grpc_status:3, grpc_message:"invalid example input wrong type. Expected simple:STRUCT, but got map_value_type:{union_type:{variants:{map_value_type:{simple:NONE}}  variants:{simple:STRUCT}}}"}
USER:BadInputToAPI: error=None, cause=<_InactiveRpcError of RPC that terminated with:
        status = StatusCode.INVALID_ARGUMENT
        details = "invalid example input wrong type. Expected simple:STRUCT, but got map_value_type:{union_type:{variants:{map_value_type:{simple:NONE}}  variants:{simple:STRUCT}}}"
        debug_error_string = "UNKNOWN:Error received from peer  {created_time:"2024-04-15T10:35:04.72485-07:00", grpc_status:3, grpc_message:"invalid example input wrong type. Expected simple:STRUCT, but got map_value_type:{union_type:{variants:{map_value_type:{simple:NONE}}  variants:{simple:STRUCT}}}"}"
>
```

# Remote using the UI

* http://127.0.0.1:30080/console/projects/flyte-complextype/domains/development/workflow/workflows.example.hello_world_complex_wf/version/test
* Launch Workflow
* In inputs example input box: {"name":"Ada"}

Fails with the message in the UI:

```
[3/3] currentAttempt done. Last Error: SYSTEM::Traceback (most recent call last):

      File "/opt/venv/lib/python3.12/site-packages/flytekit/exceptions/scopes.py", line 178, in system_entry_point
        return wrapped(*args, **kwargs)
               ^^^^^^^^^^^^^^^^^^^^^^^^
      File "/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py", line 669, in dispatch_execute
        raise type(exc)(msg) from exc

Message:

    AttributeError: Failed to convert inputs of task 'workflows.example.say_hello_complex':
  'NoneType' object has no attribute 'literals'

SYSTEM ERROR! Contact platform administrators.
```

Using kubectl logs:

```
{"asctime": "2024-04-15 18:37:19,302", "name": "flytekit", "levelname": "ERROR", "message": "Failed to convert inputs of task 'workflows.example.say_hello_complex':\n  'NoneType' object has no attribute 'literals'", "taskName": null}
{"asctime": "2024-04-15 18:37:19,303", "name": "flytekit", "levelname": "ERROR", "message": "!! Begin System Error Captured by Flyte !!", "taskName": null}
{"asctime": "2024-04-15 18:37:19,303", "name": "flytekit", "levelname": "ERROR", "message": "Traceback (most recent call last):\n\n      File \"/opt/venv/lib/python3.12/site-packages/flytekit/exceptions/scopes.py\", line 178, in system_entry_point\n        return wrapped(*args, **kwargs)\n               ^^^^^^^^^^^^^^^^^^^^^^^^\n      File \"/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py\", line 669, in dispatch_execute\n        raise type(exc)(msg) from exc\n\nMessage:\n\n    AttributeError: Failed to convert inputs of task 'workflows.example.say_hello_complex':\n  'NoneType' object has no attribute 'literals'\n\nSYSTEM ERROR! Contact platform administrators.", "taskName": null}
{"asctime": "2024-04-15 18:37:19,303", "name": "flytekit", "levelname": "ERROR", "message": "!! End Error Captured by Flyte !!", "taskName": null}
```




# Notes

## Differences between the workflow called and subworkflows and tasks
If the initial workflow takes a json string and deserialized to a json string, it works as expected when calling subworkflows or tasks


## Adjusting code and container to give more information
The error above masks the actual error. Adding some minor code changes in the library to show the root cause of the error.

```
./docker_build.sh -v debug
docker push localhost:30000/flyte-complextype:debug
pyflyte --verbose --pkgs workflows package --image localhost:30000/flyte-complextype:debug --force
flytectl register files --project "flyte-complextype" --domain development --archive flyte-package.tgz  --version debug
```

* Go to http://127.0.0.1:30080/console/projects/flyte-complextype/domains/development/workflow/workflows.example.hello_world_complex_wf/version/debug
* Launch Workflow
* In inputs example input box: {"name":"Ada"}


```
[3/3] currentAttempt done. Last Error: SYSTEM::Traceback (most recent call last):

      File "/opt/venv/lib/python3.12/site-packages/flytekit/exceptions/scopes.py", line 178, in system_entry_point
        return wrapped(*args, **kwargs)
               ^^^^^^^^^^^^^^^^^^^^^^^^
      File "/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py", line 745, in dispatch_execute
        raise exc
      File "/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py", line 741, in dispatch_execute
        native_inputs = self._literal_map_to_python_input(
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      File "/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py", line 603, in _literal_map_to_python_input
        return TypeEngine.literal_map_to_kwargs(
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      File "/opt/venv/lib/python3.12/site-packages/flytekit/core/utils.py", line 309, in wrapper
        return func(*args, **kwargs)
               ^^^^^^^^^^^^^^^^^^^^^
      File "/opt/venv/lib/python3.12/site-packages/flytekit/core/type_engine.py", line 1195, in literal_map_to_kwargs
        kwargs[k] = TypeEngine.to_python_value(ctx, lm.literals[k], python_interface_inputs[k])
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      File "/opt/venv/lib/python3.12/site-packages/flytekit/core/type_engine.py", line 1140, in to_python_value
        return transformer.to_python_value(ctx, lv, expected_python_type)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      File "/opt/venv/lib/python3.12/site-packages/flytekitplugins/pydantic/basemodel_transformer.py", line 70, in to_python_value
        basemodel_literals: BaseModelLiterals = lv.map.literals
                                                ^^^^^^^^^^^^^^^

Message:

    AttributeError: 'NoneType' object has no attribute 'literals'

SYSTEM ERROR! Contact platform administrators.
```

Using kubectl logs:

```

ERROR:root:lv.map is None
Traceback (most recent call last):
  File "/opt/venv/lib/python3.12/site-packages/flytekitplugins/pydantic/basemodel_transformer.py", line 66, in to_python_value
    raise ValueError(f"lv.map is None")
ValueError: lv.map is None
Stack (most recent call last):
  File "/opt/venv/bin/pyflyte-execute", line 8, in <module>
    sys.exit(execute_task_cmd())
  File "/opt/venv/lib/python3.12/site-packages/click/core.py", line 1157, in __call__
    return self.main(*args, **kwargs)
  File "/opt/venv/lib/python3.12/site-packages/click/core.py", line 1078, in main
    rv = self.invoke(ctx)
  File "/opt/venv/lib/python3.12/site-packages/click/core.py", line 1434, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/opt/venv/lib/python3.12/site-packages/click/core.py", line 783, in invoke
    return __callback(*args, **kwargs)
  File "/opt/venv/lib/python3.12/site-packages/flytekit/bin/entrypoint.py", line 500, in execute_task_cmd
    _execute_task(
  File "/opt/venv/lib/python3.12/site-packages/flytekit/exceptions/scopes.py", line 143, in f
    return outer_f(inner_f, args, kwargs)
  File "/opt/venv/lib/python3.12/site-packages/flytekit/exceptions/scopes.py", line 173, in system_entry_point
    return wrapped(*args, **kwargs)
  File "/opt/venv/lib/python3.12/site-packages/flytekit/bin/entrypoint.py", line 378, in _execute_task
    _handle_annotated_task(ctx, _task_def, inputs, output_prefix)
  File "/opt/venv/lib/python3.12/site-packages/flytekit/bin/entrypoint.py", line 320, in _handle_annotated_task
    _dispatch_execute(ctx, task_def, inputs, output_prefix)
  File "/opt/venv/lib/python3.12/site-packages/flytekit/bin/entrypoint.py", line 100, in _dispatch_execute
    outputs = _scoped_exceptions.system_entry_point(task_def.dispatch_execute)(ctx, idl_input_literals)
  File "/opt/venv/lib/python3.12/site-packages/flytekit/exceptions/scopes.py", line 143, in f
    return outer_f(inner_f, args, kwargs)
  File "/opt/venv/lib/python3.12/site-packages/flytekit/exceptions/scopes.py", line 178, in system_entry_point
    return wrapped(*args, **kwargs)
  File "/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py", line 741, in dispatch_execute
    native_inputs = self._literal_map_to_python_input(
  File "/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py", line 603, in _literal_map_to_python_input
    return TypeEngine.literal_map_to_kwargs(
  File "/opt/venv/lib/python3.12/site-packages/flytekit/core/utils.py", line 309, in wrapper
    return func(*args, **kwargs)
  File "/opt/venv/lib/python3.12/site-packages/flytekit/core/type_engine.py", line 1195, in literal_map_to_kwargs
    kwargs[k] = TypeEngine.to_python_value(ctx, lm.literals[k], python_interface_inputs[k])
  File "/opt/venv/lib/python3.12/site-packages/flytekit/core/type_engine.py", line 1140, in to_python_value
    return transformer.to_python_value(ctx, lv, expected_python_type)
  File "/opt/venv/lib/python3.12/site-packages/flytekitplugins/pydantic/basemodel_transformer.py", line 69, in to_python_value
    logging.error(e, exc_info=True, stack_info=True)
{"asctime": "2024-04-15 18:44:53,703", "name": "flytekit", "levelname": "ERROR", "message": "!! Begin System Error Captured by Flyte !!", "taskName": null}
{"asctime": "2024-04-15 18:44:53,704", "name": "flytekit", "levelname": "ERROR", "message": "Traceback (most recent call last):\n\n      File \"/opt/venv/lib/python3.12/site-packages/flytekit/exceptions/scopes.py\", line 178, in system_entry_point\n        return wrapped(*args, **kwargs)\n               ^^^^^^^^^^^^^^^^^^^^^^^^\n      File \"/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py\", line 745, in dispatch_execute\n        raise exc\n      File \"/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py\", line 741, in dispatch_execute\n        native_inputs = self._literal_map_to_python_input(\n                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n      File \"/opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py\", line 603, in _literal_map_to_python_input\n        return TypeEngine.literal_map_to_kwargs(\n               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n      File \"/opt/venv/lib/python3.12/site-packages/flytekit/core/utils.py\", line 309, in wrapper\n        return func(*args, **kwargs)\n               ^^^^^^^^^^^^^^^^^^^^^\n      File \"/opt/venv/lib/python3.12/site-packages/flytekit/core/type_engine.py\", line 1195, in literal_map_to_kwargs\n        kwargs[k] = TypeEngine.to_python_value(ctx, lm.literals[k], python_interface_inputs[k])\n                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n      File \"/opt/venv/lib/python3.12/site-packages/flytekit/core/type_engine.py\", line 1140, in to_python_value\n        return transformer.to_python_value(ctx, lv, expected_python_type)\n               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n      File \"/opt/venv/lib/python3.12/site-packages/flytekitplugins/pydantic/basemodel_transformer.py\", line 70, in to_python_value\n        basemodel_literals: BaseModelLiterals = lv.map.literals\n                                                ^^^^^^^^^^^^^^^\n\nMessage:\n\n    AttributeError: 'NoneType' object has no attribute 'literals'\n\nSYSTEM ERROR! Contact platform administrators.", "taskName": null}
{"asctime": "2024-04-15 18:44:53,704", "name": "flytekit", "levelname": "ERROR", "message": "!! End Error Captured by Flyte !!", "taskName": null}
```
