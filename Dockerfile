# base
FROM ubuntu:focal

# set the github runner version
ARG RUNNER_VERSION="2.286.0"

# update the base packages and add a non-sudo user
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    useradd -m ubuntu -d /app && \
    mkdir -p /app

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

RUN curl -sSL https://get.docker.com/ | sh
RUN adduser ubuntu docker

# cd into the user directory, download and unzip the github actions runner
RUN cd /app && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN /app/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh && \
    chown ubuntu:ubuntu -R /app

# # since the config and run script for actions are not allowed to be run by root,
# # set the user to "docker" so all subsequent commands are run as the docker user
USER ubuntu

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
