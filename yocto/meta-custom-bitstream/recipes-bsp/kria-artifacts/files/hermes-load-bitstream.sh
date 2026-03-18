#!/bin/sh
set -eu

FW_FILE="/etc/hermes/bitstream-firmware"
FPGA_FLAGS="/sys/class/fpga_manager/fpga0/flags"
FPGA_FW="/sys/class/fpga_manager/fpga0/firmware"
FPGA_STATE="/sys/class/fpga_manager/fpga0/state"

if [ ! -f "$FW_FILE" ]; then
    echo "hermes-load-bitstream: missing $FW_FILE" >&2
    exit 1
fi

BIT_NAME="$(cat "$FW_FILE")"
BIT_NAME="${BIT_NAME%%[[:space:]]*}"

if [ -z "$BIT_NAME" ]; then
    echo "hermes-load-bitstream: empty bitstream name in $FW_FILE" >&2
    exit 1
fi

if [ ! -f "/lib/firmware/$BIT_NAME" ]; then
    echo "hermes-load-bitstream: /lib/firmware/$BIT_NAME not found" >&2
    exit 1
fi

if [ ! -w "$FPGA_FW" ]; then
    echo "hermes-load-bitstream: fpga manager firmware node not writable" >&2
    exit 1
fi

# Full configuration load mode.
echo 0 > "$FPGA_FLAGS"
echo "$BIT_NAME" > "$FPGA_FW"

if [ -r "$FPGA_STATE" ]; then
    STATE="$(cat "$FPGA_STATE")"
    echo "hermes-load-bitstream: fpga0 state=$STATE"
    case "$STATE" in
        operating)
            exit 0
            ;;
        *)
            echo "hermes-load-bitstream: unexpected fpga0 state '$STATE'" >&2
            exit 1
            ;;
    esac
fi

exit 0
