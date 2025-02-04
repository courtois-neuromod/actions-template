# Container image that runs your code
FROM ghcr.io/courtois-neuromod/datalad:main

ADD . /actions
WORKDIR /work
RUN source /opt/venv/bin/activate && python -m pip install --no-cache-dir pytest-order ssh-agent-setup platformdirs

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["pytest", "-s", "--log-cli-level", "WARN", "/actions/tests"]
