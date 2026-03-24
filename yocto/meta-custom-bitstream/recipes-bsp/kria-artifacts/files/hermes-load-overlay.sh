#!/bin/sh
set -eu

# Device tree overlay loading helper for runtime FPGA programming
# This allows the kernel's device tree to be updated when a new bitstream is loaded

OVERLAY_NAME="${1:-pl-overlay}"
OVERLAY_DTBO="/lib/firmware/${OVERLAY_NAME}.dtbo"
DTC_FLAGS="-@ -q -O dtb"

if [ ! -f "/lib/firmware/${OVERLAY_NAME}.dts" ]; then
    echo "hermes-load-overlay: source not found: /lib/firmware/${OVERLAY_NAME}.dts" >&2
    exit 1
fi

# Compile overlay if .dtbo doesn't exist or is older than .dts
if [ ! -f "$OVERLAY_DTBO" ] || [ "/lib/firmware/${OVERLAY_NAME}.dts" -nt "$OVERLAY_DTBO" ]; then
    echo "hermes-load-overlay: compiling ${OVERLAY_NAME}..."
    if ! dtc ${DTC_FLAGS} -i "/sys/firmware/devicetree/base" \
        -o "$OVERLAY_DTBO" "/lib/firmware/${OVERLAY_NAME}.dts"; then
        echo "hermes-load-overlay: failed to compile overlay" >&2
        exit 1
    fi
fi

# Load overlay into kernel device tree
DT_OVERLAY_DIR="/sys/kernel/config/device-tree/overlays"
if [ ! -d "$DT_OVERLAY_DIR" ]; then
    echo "hermes-load-overlay: devicetree configfs not mounted" >&2
    echo "  (requires: CONFIG_OF_CONFIGFS in kernel)" >&2
    exit 1
fi

OVERLAY_PATH="${DT_OVERLAY_DIR}/${OVERLAY_NAME}"
if [ -d "$OVERLAY_PATH" ]; then
    echo "hermes-load-overlay: removing previous overlay ${OVERLAY_NAME}..."
    if ! echo -1 > "${OVERLAY_PATH}/status" 2>/dev/null; then
        echo "hermes-load-overlay: warning - could not unload existing overlay" >&2
    fi
    # Give kernel time to clean up
    sleep 0.5
fi

# Create and load new overlay
mkdir -p "$OVERLAY_PATH"
if ! cat "$OVERLAY_DTBO" > "${OVERLAY_PATH}/dtbo"; then
    echo "hermes-load-overlay: failed to load overlay" >&2
    rm -rf "$OVERLAY_PATH"
    exit 1
fi

# Verify overlay loaded
if [ -f "${OVERLAY_PATH}/status" ]; then
    STATUS=$(cat "${OVERLAY_PATH}/status")
    if [ "$STATUS" != "applied" ]; then
        echo "hermes-load-overlay: overlay failed to apply, status=$STATUS" >&2
        exit 1
    fi
    echo "hermes-load-overlay: overlay ${OVERLAY_NAME} loaded successfully"
else
    echo "hermes-load-overlay: warning - could not verify overlay status"
fi

exit 0
