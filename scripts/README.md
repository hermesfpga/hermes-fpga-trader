# Scripts — Vivado Hardware Build

This directory contains Tcl helpers and a Makefile used to manage the Vivado hardware build (bitstream and device tree generation).

**Note:** Yocto/Linux image build scripts have been moved to [`yocto/scripts/`](../yocto/scripts/) to keep hardware and software builds cleanly separated.

## Available Tcl scripts

- **`setup_project.tcl`**  
  Recreate the Vivado project only. Useful for quick iterations when you
  only change constraints or block design settings.

- **`create_project_and_gen_bitstream.tcl`**  
  Full‑build entry point. This script is invoked by the `Makefile` (see
  below) and the one used by CI; it first executes `setup_project.tcl` to
  ensure the project exists, then performs synthesis, implementation, and
  bitstream export. It also copies the resulting `.xsa`/`.bit` files to the
  host artifacts directory as configured by the Makefile.

- **`common.tcl`**  
  Contains shared project setup logic (board definition, IP config, etc.)
  Every other script sources this file; modify it when you change the
  hardware design so that all flows pick up the update.

- **`build_utils.tcl`**  
  Utility procedures used by the other scripts to reduce duplication.

## Makefile

A simple GNU Makefile sits next to the Tcl scripts and provides a
convenient containerized build environment (Vivado 2025.2) for
reproducible outputs. The top-level project `Makefile` in the repo
invokes this file via the `make -C scripts` target, but you can also run
it directly from here:

```sh
cd scripts
make build_bitstream  # full hardware build, copies artifacts to the host
make devicetree       # generate DTB from latest build artifacts
```

The Makefile also defines `PROJECT_NAME`, `ARTIFACTS_HOST_DIR`, and other
variables that control where outputs end up. See the file header for
additional details if you need to customize the build process.

## Logging & error reporting

When Vivado runs in batch mode the text output is printed to stdout. In
CI workflows it's helpful to capture this output and produce a concise
report of any errors or warnings so they're visible on the Actions tab.

The `Makefile` build target wraps Vivado in a container and pipes its
output through `tee` into `vivado.log`. That log (plus generated
`.xsa`/`.bit` files) is placed under a shared build directory:

```
artifacts/
├── kria_zynq/
│   ├── main/
│   │   ├── 20250309_120000_abc123/
│   │   │   ├── vivado/
│   │   │   │   ├── vivado.log
│   │   │   │   ├── vivado-report.txt
│   │   │   │   ├── kria_zynq.xsa
│   │   │   │   └── kria_zynq.bit
│   │   │   ├── dt/
│   │   │   └── yocto/
│   │   └── 20250309_130000_def456/
│   │       └── ...
│   └── feature_xyz/
│       └── ...
```

A new helper target, `report`, inspects the latest log (or a specific
`BUILD_ID`) and writes any `ERROR:`/`CRITICAL WARNING` lines to
`vivado-report.txt`. When run under GitHub Actions the same rule will
also append a short summary of the report to `$GITHUB_STEP_SUMMARY` so
the problems appear directly in the step output.

### Usage examples

```sh
# full build + immediate report (CI can split these into separate steps)
make build_bitstream || true
make report
```

```sh
# inspect a previous build explicitly
make report BUILD_ID=kria_zynq/main/20250309_120000_abc123/vivado
```

No special environment is required; the first command just runs the
standard build, and the second produces the human‑readable report.

*Tip:* upload `vivado-report.txt` as a workflow artifact if you want to
keep the full details around for later troubleshooting.

