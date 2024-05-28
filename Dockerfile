# Container image that runs your code
FROM ghcr.io/courtois-neuromod/datalad:main

ADD . /actions
WORKDIR /work
RUN python -m pip install --no-cache-dir pytest-order

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["pytest", "-s", "--log-cli-level", "WARN", "/actions/tests"]
