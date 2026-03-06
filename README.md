# hermes-fpga-trader

FPGA reference project for high-frequency trading on Xilinx Kria KR260. This repository contains source HDL, block design scripts, and utility Tcl scripts used to recreate and build the Vivado project. The design is a self-study and experimental platform for low-latency market data processing, 10 GbE networking, and Zynq real‑time control.

## Structure

```
/scripts         # Tcl helpers and project setup/build scripts
/src             # HDL, constraints, and block design
/vivado          # generated Vivado project (ignored)
/docs            # any documentation or notes
```

## Usage

- Run `scripts/setup_project.tcl` in Vivado Tcl console to recreate project structure.
- Run `scripts/setup_and_build_project.tcl` to also synthesize, implement, and write bitstream.

Modify `scripts/setup_impl.tcl` for project changes; the two front‑end scripts simply source it. Build helper functions live in `scripts/build_utils.tcl`.

## Goals

- Generate market actions and measure end‑to‑end latency via 10 GbE UDP on the Kria KR260
- Iteratively reduce latency and explore hardware techniques for speed
- Keep project reproducible via scripted flow

## Vivado Licensing

The 10‑GbE core and certain IP in this project require a Vivado license. Xilinx
offers a free WebPACK/Pro trial license that can be generated from the
Xilinx Support website and is valid for 120 days. After obtaining a license, place
it in `~/.Xilinx/Vivado/Licenses` (or use `vivado -license` to add it) before
running the build scripts. No commercial license is needed for evaluation; the
trial covers the cores used here. Always check the Xilinx site for the latest
licensing terms.

---

*This is a personal study/experiment, not intended for production use.*
