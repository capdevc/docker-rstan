#!/usr/bin/env bash

set -e

if [[ $# -ge 2 ]]; then
    echo "Usage: $0 [version]"
    echo "    [version] is the image version, and defaults to latest"
    exit 1
fi

VERSION=${1:-latest}
USER=rstudio

if [[ -n $DOCKER_MACHINE_NAME ]]; then

    HOST_IP=$(docker-machine ip ${DOCKER_MACHINE_NAME})
    USERID=1000

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
           -v /tmp \
           -e DISABLE_AUTH=true \
           -e USER=${USER} \
           --privileged \
           -e ROOT=TRUE \
           -e PASSWORD=prog \
           -e AWS_ACCESS_KEY_ID \
           -e AWS_SECRET_ACCESS_KEY \
           -e NOTEBOOK_PATH='mdv-notebooks:/cristian/notebooks' \
           capdevc/rstan:${VERSION}

# If we opened a tunnel, kill it.
if [[ -n "${TUNNEL_PID}" ]]; then
    echo "Killing autossh process ${TUNNEL_PID}..."
    kill -9 ${TUNNEL_PID}
    echo "Killing ssh processes"
    pkill -9 -f "ssh -L .*$HOST_IP"
fi

echo "Done"
