#!/usr/bin/env bash

set -e

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <machine>"
    echo "    <machine> is the docker-machine name of the host machine, or local for local docker"
    exit 1
fi


if [[ ${1} != "local" ]]; then
    INSTANCE_TYPE=$(docker-machine inspect ${1} -f '{{ .Driver.InstanceType }}')
    GPU_HOST=$([[ ${INSTANCE_TYPE:0:1} == "p" ]] && echo true || echo false)
    # Set up the docker-machine environment
    echo "Setting Docker host to ${1}..."
    until DOCKER_ENV=$(docker-machine env ${1}); do
        if [[ count++ -ge 3 ]]; then
            echo "Failed to generate certs for ${1}"
            exit 1
        fi
        echo "Regenerating certificates for ${1}, retry ${count}..."
        docker-machine regenerate-certs -f ${1}
    done

    eval ${DOCKER_ENV}

    NV_HOST="ssh://ubuntu@$(docker-machine ip ${1}):"
    HOST_IP=$(docker-machine ip ${1})
    ssh-add $DOCKER_CERT_PATH/id_rsa

    # set up port forwarding. Kitchen sinking here since different images use different ports
    echo "Setting up ip port forwarding..."
    autossh -M 5998:7 -nNT -q -o "StrictHostKeyChecking no" \
            -i ~/prognos/ssh/datascience-key.pem \
            -L localhost:8787:localhost:8787 \
            -L localhost:3838:localhost:3838 \
            ubuntu@${HOST_IP} &

    TUNNEL_PID=$!
    echo "Autossh PID: ${TUNNEL_PID}"
else
    # Make sure we're operating locally
    unset DOCKER_TLS_VERIFY
    unset DOCKER_CERT_PATH
    unset DOCKER_HOST
    unset DOCKER_MACHINE_NAME
    unset NV_ARGS
    unset NV_HOST
    # Assume we have no GPU locally
    GPU_HOST=false
fi

# launch the notebook
echo "Launching docker image capdevc/rstan:latest ...."
docker run --name=rstan \
           $([[ $GPU_HOST == true ]] && echo "--runtime=nvidia " || echo " ") \
           --rm -it \
           -p 8787:8787 \
           -p 3838:3838 \
           -v /tmp:/tmp$([[ ${1} == "local" ]] && echo ":cached" || echo " ") \
           --privileged \
           -e GRANT_SUDO=yes \
           -e AWS_ACCESS_KEY_ID \
           -e AWS_SECRET_ACCESS_KEY \
           -e NOTEBOOK_PATH='mdv-notebooks:/' \
           capdevc/rstan:latest

# If we opened a tunnel, kill it.
if [[ -n ${TUNNEL_PID} ]]; then
    echo "Killing ssh tunnel..."
    kill -9 ${TUNNEL_PID}
fi

echo "Done"
