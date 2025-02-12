-MAKEFLAGS+=--silent
UID:=$(shell id +-u)
NVIDIA_GPU:=$(shell (docker info | grep Runtimes | grep nvidia 1> /dev/null && command -v nvidia-smi 1>/dev/null 2>/dev/null && nvidia-smi | grep Processes 1>/dev/null 2>/dev/null) && echo '--runtime nvidia --gpus all' || echo '')
FLAVOR ?= test
ROBOT_PANEL_PORT ?= 8008
VS_PORT ?= 31415
WEBOTS_STREAM_PORT ?= 1234
DOCKER_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
#PROJECT_DIR:=$(shell dirname ${DOCKER_DIR})
PROJECT_DIR:=${DOCKER_DIR}
DISPLAY=:0
TEAM_NAME=hzrob
IMAGE=hzrob
USERNAME=developer

.PHONY: all

all: build run

build:
	echo ${NO_CACHE_ARG}
	DOCKER_BUILDKIT=1 docker build ${DOCKER_DIR} -f ${DOCKER_DIR}/Dockerfile -t ${TEAM_NAME} ${DOCKER_ARGS} --build-arg UID=${UID}
 
run: 
	docker run --ipc=host \
		--cap-add SYS_ADMIN \
		--name ${IMAGE}-${FLAVOR} \
		--add-host=host.docker.internal:host-gateway \
		--privileged \
		--restart unless-stopped \
		-p ${ROBOT_PANEL_PORT}:8008 -p ${VS_PORT}:31415 -p ${WEBOTS_STREAM_PORT}:1234 \
		-e NVIDIA_DRIVER_CAPABILITIES=all ${NVIDIA_GPU} \
		-e DISPLAY=${DISPLAY} \
		-v ~/.Xauthority:/${USERNAME}/.host/.Xauthority:ro \
		-e WAYLAND_DISPLAY=${WAYLAND_DISPLAY} \
		--device=/dev/dxg \
		-it --gpus all --device /dev/dri:/dev/dri \
		-e LD_LIBRARY_PATH=/usr/lib/wsl/lib \
		-v /tmp/.X11-unix/:/tmp/.X11-unix:rw \
		-v /dev:/dev:rw \
		-v ${PROJECT_DIR}/projects/devel:/${USERNAME}/repositories:rw \
		-v ${PROJECT_DIR}:/${USERNAME}/container:rw \
		-d -it ${IMAGE} 1>/dev/null

ls:
	echo ${DOCKER_DIR}