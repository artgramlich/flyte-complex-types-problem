FROM python:3.12-slim-bookworm

WORKDIR /root
ENV VENV /opt/venv
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONPATH /root

RUN apt-get update && apt-get install -y build-essential

ENV VENV /opt/venv
# Virtual environment
RUN python3 -m venv ${VENV}
ENV PATH="${VENV}/bin:$PATH"

# Install Python dependencies
COPY requirements.txt /root
RUN pip install -r /root/requirements.txt

# Copy the actual code
COPY . /root

# Add debugging changes
#RUN cp debugging-files/flytekitplugins/pydantic/basemodel_transformer.py /opt/venv/lib/python3.12/site-packages/flytekitplugins/pydantic/basemodel_transformer.py \
#    && cp debugging-files/flytekit/core/base_task.py /opt/venv/lib/python3.12/site-packages/flytekit/core/base_task.py


# This tag is supplied by the build script and will be used to determine the version
# when registering tasks, workflows, and launch plans
ARG tag
ENV FLYTE_INTERNAL_IMAGE $tag
