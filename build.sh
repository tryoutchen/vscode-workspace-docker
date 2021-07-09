#!/bin/bash

set -eo pipefail; [[ "$TRACE" ]] && set -x

docker build \
    --build-arg username=$(id -un) \
    --build-arg timezone=$(cat /etc/timezone) \
    -t ubuntu-focal .
