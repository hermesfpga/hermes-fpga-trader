# Makefile settings
# SHELL := bash 
.ONESHELL:

# fix libudev bug with this export:
#(https://adaptivesupport.amd.com/s/article/000034450?language=en_US&utm_source=chatgpt.com)
# 000034450 - Vivado 2022.x - Batch mode execution fails in Linux docker running under Windows/Linux host
#export LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1

# Fix OS release file for Vivado by setting it to a simpler string with same content

PROJECT_PATH=$(realpath ../)

build:
	docker run --network bridge \
		--rm \
		-v ${PROJECT_PATH}:/home/proj:rw \
		vivado:2025.2 \
		/bin/bash -c '\
			cd /home/proj; \
			source /tools/Xilinx/2025.2/Vivado/settings64.sh; \
			export LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1; \
			printf '%s\n' 'NAME="Ubuntu"' 'VERSION="22.04.5"' 'ID=ubuntu' 'ID_LIKE=debian' 'PRETTY_NAME="Ubuntu 22.04.5 LTS"' 'VERSION_ID="22.04"' >/etc/os-release; \
			vivado -mode batch -notrace -source ./scripts/create_project_and_gen_bitstream.tcl; \
			chmod -R 755 ./vivado/; \
		'
		