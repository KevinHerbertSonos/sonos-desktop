#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $DIR

DOCKER_LOCAL=Dockerfile.local
USER_ID="$(id -u)"
GROUP_ID="$(id -g)"

# ARG1: Docker image name
# ARG2: Dockerfile
function docker_build {
    docker build --network="host" \
        --build-arg UID="$USER_ID"\
        --build-arg GID="$GROUP_ID"\
        --build-arg UNAME="$USER"\
        -t "$1" -f "$2" .
}

if [ -f "$DOCKER_LOCAL" ]; then
    BASEIMAGE=sonos/plxbase
    DEVIMAGE=sonos/plxlocal
else
    BASEIMAGE=sonos/plxbase
    DEVIMAGE=sonos/plxbase
fi

docker_build $BASEIMAGE Dockerfile

if [ -f "$DOCKER_LOCAL" ]; then
    docker_build $DEVIMAGE Dockerfile.local
fi

BASHRC_OVERRIDE=
if [ -f "$DOCKER_BASHRC" ]; then
    BASHRC_OVERRIDE="--rcfile $DOCKER_BASHRC"
fi

if [ ! -v DOCKER_CPUS_OVERRIDE ]; then
    DOCKER_CPUS_OVERRIDE=0
fi

docker run -it \
    --cpus=$DOCKER_CPUS_OVERRIDE \
    --privileged \
    --cap-add SYS_ADMIN \
    --security-opt seccomp=unconfined \
    --cgroup-parent=docker.slice --cgroupns private \
    --tmpfs /tmp --tmpfs /run --tmpfs /run/lock \
    -v /home/"$USER":/home/"$USER" \
    -v /srctrees:/srctrees:delegated \
    -p 2222:22 \
    $DEVIMAGE

popd
