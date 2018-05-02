#!/usr/bin/env bash
set -e

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>"
  exit 1
fi

# Build image and push to dockerhub
docker build -t capdevc/rstan:${1} .
docker tag capdevc/rstan:${1} capdevc/rstan:latest
docker push capdevc/rstan:${1}
docker push capdevc/rstan:latest
