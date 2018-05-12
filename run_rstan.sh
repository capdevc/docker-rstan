#!/usr/bin/env bash

set -e

if [[ $# -ge 2 ]]; then
    echo "Usage: $0 [version]"
    echo "    [version] is the image version, and defaults to latest"
    exit 1
fi

VERSION=${1:-latest}

if [[ -n $DOCKER_MACHINE_NAME ]]; then

    HOST_IP=$(docker-machine ip ${DOCKER_MACHINE_NAME})

    # set up port forwarding. Kitchen sinking here since different images use different ports
    echo "Setting up ip port forwarding..."
    autossh -M 5998:7 -nNT -q -o "StrictHostKeyChecking no" \
            -i ~/prognos/ssh/datascience-key.pem \
            -L localhost:8787:localhost:8787 \
            -L localhost:3838:localhost:3838 \
            ubuntu@${HOST_IP} &

    TUNNEL_PID=$!
    echo "Autossh PID: ${TUNNEL_PID}"
fi

# launch the notebook
echo "Launching docker image capdevc/rstan:latest ...."
docker run --name=rstan \
           --rm -it \
           -p 8787:8787 \
           -p 3838:3838 \
           --privileged \
           -e ROOT=TRUE \
           -e USERID=1000 \
           -e AWS_ACCESS_KEY_ID \
           -e AWS_SECRET_ACCESS_KEY \
           -e NOTEBOOK_PATH='mdv-notebooks:/cristian/notebooks' \
           capdevc/rstan:${VERSION}

# If we opened a tunnel, kill it.
if [[ -n ${TUNNEL_PID} ]]; then
    echo "Killing ssh tunnel..."
    kill -9 ${TUNNEL_PID}
fi

echo "Done"
