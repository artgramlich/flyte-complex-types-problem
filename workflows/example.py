#!/usr/bin/env python3
import typing
from flytekit import task, workflow
from pydantic import BaseModel


class ExampleComplexInput(BaseModel):
    name: str


class ExampleComplexOutput(BaseModel):
    greeting: str


@task()
def say_hello_complex(example: ExampleComplexInput) -> ExampleComplexOutput:
    return ExampleComplexOutput(greeting=f"Hello, {example.name}!")


@workflow
def hello_world_complex_wf(example: ExampleComplexInput) -> ExampleComplexOutput:
    res = say_hello_complex(example=example)
    return res


if __name__ == "__main__":
    print(
        f"Running wf() {hello_world_complex_wf(example=ExampleComplexInput(name='passengers'))}"
    )
