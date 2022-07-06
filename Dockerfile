# Container image that runs your code
FROM ghcr.io/templateflow/datalad:main

RUN pip install --upgrade pytest datalad ssh_agent_setup

ADD . /actions
WORKDIR /actions

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["pytest", "/actions/tests"]
