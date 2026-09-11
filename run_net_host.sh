#!/bin/bash

# REPO=irslrepo/
REPO=repo.irsl.eiiris.tut.ac.jp/
UBUNTU_VER=24.04
_DISPLAY_=:10
_VGL_DISPLAY_=:0
_PORT_=6080
#_GPU_OPTION_="--gpus 'all,capabilities=compute,graphics,utility,display'"
_GPU_OPTION_='--gpus all'

usage() {
    cat <<'EOF'
Usage: run_net_host.sh [--no-gpu] [--port <port_num>] [--display <DISPLAY>] [--vgl-display <VGL_DISPLAY>] [-h | --help]

Options:
  --no-gpu                    Without NVIDIA gpu
  --port <port_num>           Port number
  --dispaly <DISPLAY>         DISPLAY
  --vgl-display <VGL_DISPLAY> VGL_DISPLAY
  -h, --help                  Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --no-gpu)
            _GPU_OPTION_=''
            shift
            ;;
        --port)
            if [ -z "$2" ] || [ "${2#-}" != "$2" ]; then
                echo "error: --port requires a value" >&2
                usage
                exit 2
            fi
            _PORT_="$2"
            shift 2
            ;;
        --display)
            if [ -z "$2" ] || [ "${2#-}" != "$2" ]; then
                echo "error: --display requires a value" >&2
                usage
                exit 2
            fi
            _DISPLAY_="$2"
            shift 2
            ;;
        --vgl-display)
            if [ -z "$2" ] || [ "${2#-}" != "$2" ]; then
                echo "error: --vgl-display requires a value" >&2
                usage
                exit 2
            fi
            _VGL_DISPLAY_="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage
            exit 2
            ;;
    esac
done

iname=${DOCKER_IMAGE:-"${REPO}browser_vnc:${UBUNTU_VER}"} ##
cname=${DOCKER_CONTAINER:-"browser_vnc"} ## name of container (should be same as in exec.sh)

trap "echo SIGINT was trapped; docker container stop ${cname}; exit 0" SIGINT

xhost +si:localuser:root

docker rm ${cname}

docker run \
    --privileged \
    --sig-proxy=true \
    ${_GPU_OPTION_} \
    --net=host \
    --env="NOVNC_WEB_PORT=${_PORT_}" \
    --env="DISPLAY=${_DISPLAY_}" \
    --env="VGL_DISPLAY=${_VGL_DISPLAY_}" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --name=${cname} \
    ${iname} &

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
