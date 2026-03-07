# Makefile settings
# SHELL := bash 
.ONESHELL:

DOCKER_IMAGE_VIVADO_NAME = vivado
DOCKER_IMAGE_VIVADO_TAG  = 2025.2

DOCKER_IMAGE = ${DOCKER_IMAGE_VIVADO_NAME}:${DOCKER_IMAGE_VIVADO_TAG}
PROJECT_PATH=$(realpath ../)

build:
	docker run --network bridge \
		--rm \
		-e LOCAL_UID=$$(id -u) \
		-e LOCAL_GID=$$(id -g) \
		-v ${PROJECT_PATH}:/workspace:rw \
		-w /workspace \
		$(DOCKER_IMAGE) \
		vivado -mode batch -notrace -source ./scripts/create_project_and_gen_bitstream.tcl
		