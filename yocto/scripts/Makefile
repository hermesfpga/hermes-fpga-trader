# Makefile for Yocto builds
# SHELL := bash
.ONESHELL:

PROJECT_NAME = kria_zynq

# Host path where artifacts are stored
ARTIFACTS_HOST_DIR = /home/buildserver/artifacts

# Path to artifacts inside the container
ARTIFACTS_CONTAINER_DIR = /artifacts

# Path to the custom bitstream/DT layer
LAYER_PATH = $(realpath ../meta-custom-bitstream)
LAYER_CONTAINER_PATH = /workspace/meta-custom-bitstream

# Path to in-container Yocto build helper script
BUILD_SD_BOOT_SCRIPT_HOST = $(realpath ./build_sd_boot.sh)
BUILD_SD_BOOT_SCRIPT_CONTAINER = /workspace/build_sd_boot.sh

# Yocto build settings
DOCKER_IMAGE_YOCTO_NAME = yocto_builder
DOCKER_IMAGE_YOCTO_TAG  = v1
DOCKER_IMAGE_YOCTO      = $(DOCKER_IMAGE_YOCTO_NAME):$(DOCKER_IMAGE_YOCTO_TAG)

YOCTO_CACHE_HOST_DIR     = /home/buildserver/yocto_cache
YOCTO_DOWNLOADS_HOST_DIR = $(YOCTO_CACHE_HOST_DIR)/downloads
YOCTO_SSTATE_HOST_DIR    = $(YOCTO_CACHE_HOST_DIR)/sstate

YOCTO_DOWNLOADS_DIR = /yocto-downloads
YOCTO_SSTATE_DIR    = /yocto-sstate

YOCTO_MACHINE = k26-smk-kr-sdt
YOCTO_IMAGE   = kria-image-full-cmdline

# File storing the most recent successful device tree folder
LATEST_DT_FILE = $(ARTIFACTS_HOST_DIR)/$(PROJECT_NAME)_latest_devicetree.txt

# File storing the most recent successful hardware build folder
LATEST_BUILD_FILE = $(ARTIFACTS_HOST_DIR)/$(PROJECT_NAME)_latest_build.txt

# File storing the most recent successful Yocto build folder
LATEST_YOCTO_BUILD_FILE = $(ARTIFACTS_HOST_DIR)/$(PROJECT_NAME)_latest_yocto_build.txt

build_yocto:
	test -f $(LATEST_DT_FILE)
	test -f $(LATEST_BUILD_FILE)
	test -f $(BUILD_SD_BOOT_SCRIPT_HOST)
	DT_BUILD_PATH="$$(cat $(LATEST_DT_FILE))"
	BUILD_PATH="$$(cat $(LATEST_BUILD_FILE))"
	# BUILD_PATH points at the vivado subfolder; take its parent to keep the
	# timestamp/commit directory, then add yocto/
	YOCTO_BUILD_PATH=$$(dirname "$$BUILD_PATH")/yocto
	@echo "DEBUG: DT_BUILD_PATH=$$DT_BUILD_PATH"
	@echo "DEBUG: BUILD_PATH=$$BUILD_PATH"
	@echo "DEBUG: YOCTO_BUILD_PATH=$$YOCTO_BUILD_PATH"
	mkdir -p $(ARTIFACTS_HOST_DIR)/$$YOCTO_BUILD_PATH
	touch $(ARTIFACTS_HOST_DIR)/$$YOCTO_BUILD_PATH/yocto.log
	docker run --rm \
		-e LOCAL_UID=$$(id -u) \
		-e LOCAL_GID=$$(id -g) \
		-e YOCTO_IMAGE="$(YOCTO_IMAGE)" \
		-e YOCTO_MACHINE="$(YOCTO_MACHINE)" \
		-e LAYER_CONTAINER_PATH="$(LAYER_CONTAINER_PATH)" \
		-e ARTIFACTS_CONTAINER_DIR="$(ARTIFACTS_CONTAINER_DIR)" \
		-e YOCTO_BUILD_PATH="$$YOCTO_BUILD_PATH" \
		-v $(ARTIFACTS_HOST_DIR):$(ARTIFACTS_CONTAINER_DIR):rw \
		-v $(YOCTO_DOWNLOADS_HOST_DIR):$(YOCTO_DOWNLOADS_DIR) \
		-v $(YOCTO_SSTATE_HOST_DIR):$(YOCTO_SSTATE_DIR) \
		-v "$(ARTIFACTS_HOST_DIR)/$$DT_BUILD_PATH":/dt:rw \
		-v "$(LAYER_PATH)":$(LAYER_CONTAINER_PATH):ro \
		-v "$(BUILD_SD_BOOT_SCRIPT_HOST)":$(BUILD_SD_BOOT_SCRIPT_CONTAINER):ro \
		$(DOCKER_IMAGE_YOCTO) \
		bash $(BUILD_SD_BOOT_SCRIPT_CONTAINER)

	# record the build ID even if bitbake failed
	printf '%s' "$$YOCTO_BUILD_PATH" > $(LATEST_YOCTO_BUILD_FILE)

# generate a formatted error/warning report and (optionally) append to
# the GitHub Actions step summary.  Accepts BUILD_ID as an environment
# variable or will read the latest if unspecified.
report:
	@BUILD_PATH=$${BUILD_ID:-$$(cat $(LATEST_YOCTO_BUILD_FILE))}; \
	LOG=$(ARTIFACTS_HOST_DIR)/$$BUILD_PATH/yocto.log; \
	REP=$(ARTIFACTS_HOST_DIR)/$$BUILD_PATH/yocto-report.txt; \
	if [ -f "$$LOG" ]; then \
		{ \
			echo "### Yocto run summary"; \
			echo ""; \
			grep -E "ERROR:|WARNING:" "$$LOG" | head -20 || echo "(no errors or warnings found)"; \
			echo ""; \
			echo "### Build Status"; \
			echo ""; \
			tail -5 "$$LOG" | grep -E "Tasks Summary|failed|succeeded" || echo "(build status unknown)"; \
		} > "$$REP"; \
		echo "Generated report $$REP"; \
		if [ -n "$$GITHUB_STEP_SUMMARY" ]; then \
			echo "" >> $$GITHUB_STEP_SUMMARY; \
			cat "$$REP" >> $$GITHUB_STEP_SUMMARY; \
		fi; \
	else \
		echo "no log file at $$LOG"; \
		exit 1; \
	fi
