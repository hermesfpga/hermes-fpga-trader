# Makefile settings
# SHELL := bash
.ONESHELL:

PROJECT_NAME = kria_zynq
XSA_FILE = $(PROJECT_NAME).xsa
BIT_FILE = $(PROJECT_NAME).bit

# Host path where artifacts are stored
ARTIFACTS_HOST_DIR = /home/buildserver/artifacts

# Path to artifacts inside the container
ARTIFACTS_CONTAINER_DIR = /artifacts

DOCKER_IMAGE_VIVADO_NAME = vivado
DOCKER_IMAGE_VIVADO_TAG  = 2025.2

DOCKER_IMAGE = ${DOCKER_IMAGE_VIVADO_NAME}:${DOCKER_IMAGE_VIVADO_TAG}

PROJECT_PATH = $(realpath ../)

# This path must follow scripts/setup_and_build_project.tcl
VIVADO_EXPORT_DIR = vivado

# Git information
GIT_BRANCH_RAW  := $(shell git -C $(PROJECT_PATH) rev-parse --abbrev-ref HEAD)
GIT_COMMIT      := $(shell git -C $(PROJECT_PATH) rev-parse --short HEAD)

# Sanitize branch name for filesystem safety
# Replace any character that is not [a-zA-Z0-9_-] with '_'
GIT_BRANCH_SAFE := $(shell echo "$(GIT_BRANCH_RAW)" | sed 's/[^a-zA-Z0-9_-]/_/g')

# Timestamp used for artifact directories
BUILD_TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

# Final unique build identifier (now just timestamp)
BUILD_ID := $(BUILD_TIMESTAMP)

# Build directory path
BUILD_DIR := $(ARTIFACTS_HOST_DIR)/$(PROJECT_NAME)/$(GIT_BRANCH_SAFE)/$(BUILD_TIMESTAMP)_$(GIT_COMMIT)

# File storing the most recent successful hardware build folder
LATEST_BUILD_FILE = $(ARTIFACTS_HOST_DIR)/$(PROJECT_NAME)_latest_build.txt

# File storing the most recent successful device tree folder
LATEST_DT_FILE = $(ARTIFACTS_HOST_DIR)/$(PROJECT_NAME)_latest_devicetree.txt


build:
	mkdir -p $(BUILD_DIR)

	# run Vivado inside container and capture output; logs are always written
	# to the artifacts directory so `make report` can consume them later.
	# capture the exit code and write it to status file for later use.
	docker run --network bridge \
		--rm \
		-e LOCAL_UID=$$(id -u) \
		-e LOCAL_GID=$$(id -g) \
		-v ${PROJECT_PATH}:/workspace:rw \
		-v $(ARTIFACTS_HOST_DIR):$(ARTIFACTS_CONTAINER_DIR):rw \
		-w /workspace \
		$(DOCKER_IMAGE) \
		bash -lc ' \
			vivado -mode batch -notrace -source ./scripts/create_project_and_gen_bitstream.tcl \
				2>&1 | tee $(ARTIFACTS_CONTAINER_DIR)/$(PROJECT_NAME)/$(GIT_BRANCH_SAFE)/$(BUILD_TIMESTAMP)_$(GIT_COMMIT)/vivado.log ; \
			cp $(VIVADO_EXPORT_DIR)/$(XSA_FILE) $(ARTIFACTS_CONTAINER_DIR)/$(PROJECT_NAME)/$(GIT_BRANCH_SAFE)/$(BUILD_TIMESTAMP)_$(GIT_COMMIT)/$(XSA_FILE) && \
			cp $(VIVADO_EXPORT_DIR)/$(BIT_FILE) $(ARTIFACTS_CONTAINER_DIR)/$(PROJECT_NAME)/$(GIT_BRANCH_SAFE)/$(BUILD_TIMESTAMP)_$(GIT_COMMIT)/$(BIT_FILE) && \
			ls -l $(ARTIFACTS_CONTAINER_DIR)/$(PROJECT_NAME)/$(GIT_BRANCH_SAFE)/$(BUILD_TIMESTAMP)_$(GIT_COMMIT) \
		' ; \
	echo $$? > $(BUILD_DIR)/vivado-status.txt

	# record the build ID even if Vivado failed
	echo "$(PROJECT_NAME)/$(GIT_BRANCH_SAFE)/$(BUILD_TIMESTAMP)_$(GIT_COMMIT)" > $(LATEST_BUILD_FILE)

	# allow the build to fail but still run report from CI with `make report`


# generate a formatted error/warning report and (optionally) append to
# the GitHub Actions step summary.  Accepts BUILD_ID as an environment
# variable or will read the latest if unspecified.
report:
	@BUILD_PATH=$${BUILD_ID:-$$(cat $(LATEST_BUILD_FILE))}; \
	LOG=$(ARTIFACTS_HOST_DIR)/$$BUILD_PATH/vivado.log; \
	STATUS_FILE=$(ARTIFACTS_HOST_DIR)/$$BUILD_PATH/vivado-status.txt; \
	REP=$(ARTIFACTS_HOST_DIR)/$$BUILD_PATH/vivado-report.txt; \
	if [ -f "$$LOG" ]; then \
		STATUS=$$(cat $$STATUS_FILE 2>/dev/null || echo "1"); \
		{ \
			if [ "$$STATUS" = "0" ]; then \
				echo "Status: ✅ Build successful"; \
			else \
				echo "Status: ❌ Build failed"; \
			fi; \
			echo ""; \
			echo "### Summary"; \
			echo ""; \
			grep "Failing Nets\|Worst Negative Slack" "$$LOG" || echo "(no summary found)"; \
			echo ""; \
			echo "### Errors and Warnings"; \
			echo ""; \
			grep -E "ERROR:|CRITICAL WARNING" "$$LOG" || echo "(no errors or warnings)"; \
		} > "$$REP"; \
		echo "Generated report $$REP"; \
		if [ -n "$$GITHUB_STEP_SUMMARY" ]; then \
			echo "" >> $$GITHUB_STEP_SUMMARY; \
			cat "$$REP" >> $$GITHUB_STEP_SUMMARY; \
		fi; \
	else \
		echo "no log file for build $$BUILD_PATH"; \
		exit 1; \
	fi


devicetree:
	test -f $(LATEST_BUILD_FILE)
	BUILD_PATH="$$(cat $(LATEST_BUILD_FILE))"
	mkdir -p $(ARTIFACTS_HOST_DIR)/$$BUILD_PATH/dt

	docker run --network bridge \
		--rm \
		-e LOCAL_UID=$$(id -u) \
		-e LOCAL_GID=$$(id -g) \
		-v ${PROJECT_PATH}:/workspace:rw \
		-v $(ARTIFACTS_HOST_DIR):$(ARTIFACTS_CONTAINER_DIR):rw \
		-w /workspace \
		$(DOCKER_IMAGE) \
		bash -lc ' \
			BUILD_PATH='"$$BUILD_PATH"' && \
			xsct -eval "sdtgen set_dt_param -xsa $(ARTIFACTS_CONTAINER_DIR)/$$BUILD_PATH/$(XSA_FILE) -dir $(ARTIFACTS_CONTAINER_DIR)/$$BUILD_PATH/dt; sdtgen generate_sdt; exit" && \
			gcc -I $(ARTIFACTS_CONTAINER_DIR)/$$BUILD_PATH/dt -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp \
				-o $(ARTIFACTS_CONTAINER_DIR)/$$BUILD_PATH/dt/system-top.dts.tmp \
				$(ARTIFACTS_CONTAINER_DIR)/$$BUILD_PATH/dt/system-top.dts && \
			dtc -I dts -O dtb \
				-o $(ARTIFACTS_CONTAINER_DIR)/$$BUILD_PATH/dt/system-top.dtb \
				$(ARTIFACTS_CONTAINER_DIR)/$$BUILD_PATH/dt/system-top.dts.tmp && \
			ls $(ARTIFACTS_CONTAINER_DIR)/$$BUILD_PATH/dt \
		' || exit 1

	echo "$$BUILD_PATH" > $(LATEST_DT_FILE)