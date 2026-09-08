#!/bin/bash

# REPO=irslrepo/
REPO=repo.irsl.eiiris.tut.ac.jp/
UBUNTU_VER=24.04

iname=${DOCKER_IMAGE:-"${REPO}browser_vnc:${UBUNTU_VER}"} ##
cname=${DOCKER_CONTAINER:-"browser_vnc"} ## name of container (should be same as in exec.sh)

trap "echo SIGINT was trapped; docker container stop ${cname}; exit 0" SIGINT

xhost +si:localuser:root

docker rm ${cname}

docker run \
    --privileged \
    --sig-proxy=true \
    --gpus 'all,"capabilities=compute,graphics,utility,display"' \
    --net=host \
    --env="NOVNC_WEB_PORT=6080" \
    --env="WEBSOCKIFY_AUTH=__user__:__passwd__" \
    --env="DISPLAY=:1" \
    --env="VGL_DISPLAY=:0" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --name=${cname} \
    ${iname} supervisord -c /app/supervisord.auth.conf &

wait $!
exit_docker="$?"
echo "!!!!! docker exited: ${exit_docker} !!!!!"
exit ${exit_docker}

##xhost -local:root

## capabilities
# compute	CUDA / OpenCL アプリケーション
# compat32	32 ビットアプリケーション
# graphics	OpenGL / Vulkan アプリケーション
# utility	nvidia-smi コマンドおよび NVML
# video		Video Codec SDK
# display	X11 ディスプレイに出力
# all
