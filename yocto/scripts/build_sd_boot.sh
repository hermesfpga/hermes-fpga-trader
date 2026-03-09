#!/usr/bin/env bash
set -u

# Validate required inputs provided by the Makefile/docker run wrapper.
if [ -z "${YOCTO_IMAGE:-}" ] || [ -z "${YOCTO_MACHINE:-}" ] || [ -z "${YOCTO_BUILD_PATH:-}" ] || [ -z "${ARTIFACTS_CONTAINER_DIR:-}" ] || [ -z "${LAYER_CONTAINER_PATH:-}" ]; then
    echo "Missing required environment variables for build_sd_boot.sh" >&2
    exit 2
fi

# Confirm the mounted DT artifacts are visible inside the container.
echo "Mounted device tree files:"
ls /dt

# Ensure the custom layer and required image config are present.
bitbake-layers add-layer "${LAYER_CONTAINER_PATH}" 2>/dev/null || true
grep -q '^IMAGE_INSTALL:append.*kria-artifacts' conf/local.conf || echo 'IMAGE_INSTALL:append = " kria-artifacts"' >> conf/local.conf
grep -Eq '^MACHINE[[:space:]]*=[[:space:]]*"' conf/local.conf || echo "MACHINE = \"${YOCTO_MACHINE}\"" >> conf/local.conf

# Build image and keep the real bitbake exit code even with tee enabled.
set -o pipefail
bitbake "${YOCTO_IMAGE}" 2>&1 | tee -a "${ARTIFACTS_CONTAINER_DIR}/${YOCTO_BUILD_PATH}/yocto.log"
BB_EXIT=${PIPESTATUS[0]}

# Resolve Yocto deploy output and export boot artifacts to persistent host storage.
DEPLOY_DIR=$(bitbake -e "${YOCTO_IMAGE}" | sed -n 's/^DEPLOY_DIR_IMAGE="\(.*\)"/\1/p' | head -1)
OUT_BOOT_DIR="${ARTIFACTS_CONTAINER_DIR}/${YOCTO_BUILD_PATH}/boot"
mkdir -p "${OUT_BOOT_DIR}"

if [ -d "${DEPLOY_DIR}" ]; then
    echo "Exporting Yocto .wic.xz image from ${DEPLOY_DIR} to ${OUT_BOOT_DIR}"
    # DEPLOY_DIR_IMAGE typically resolves to:
    # /workspace/build/tmp/deploy/images/<machine>
    # and contains files like <image>-<machine>-<timestamp>.wic.xz
    MATCHED=$(find "${DEPLOY_DIR}" -maxdepth 1 \( -type f -o -type l \) -name "*.wic.xz" | wc -l)

    if [ "${MATCHED}" -eq 0 ]; then
        echo "WARNING: No .wic.xz file found in ${DEPLOY_DIR}" >&2
        echo "Top-level deploy contents:" >&2
        ls -lah "${DEPLOY_DIR}" >&2 || true
    else
        find "${DEPLOY_DIR}" -maxdepth 1 \( -type f -o -type l \) -name "*.wic.xz" -exec cp -avL {} "${OUT_BOOT_DIR}/" \;
    fi

    ls -lah "${OUT_BOOT_DIR}"
else
    echo "WARNING: DEPLOY_DIR_IMAGE not found: ${DEPLOY_DIR}"
fi

# Return the original build status for CI/reporting.
exit ${BB_EXIT}
