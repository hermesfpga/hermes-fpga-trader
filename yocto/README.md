# Yocto Build System

Yocto/Bitbake workflow for building a Linux image that includes your custom FPGA bitstream and device tree.

## Structure

```
yocto/
├── scripts/Makefile                          # build_yocto target
├── scripts/build_sd_boot.sh                  # in-container Yocto build/export logic
└── meta-custom-bitstream/                    # Reusable Yocto layer
    ├── conf/layer.conf
    └── recipes-bsp/kria-artifacts/kria-artifacts.bb
```

## Build

```sh
# Hardware flow first (writes vivado/ and dt/ under one build folder)
cd scripts && make build_bitstream && make devicetree

# Yocto build consumes those artifacts
cd yocto/scripts && make build_yocto
```

Current artifact layout for one build:

```
/home/buildserver/artifacts/kria_zynq/<branch>/<timestamp>_<commit>/
    vivado/
    dt/
    yocto/
```

Path tracker files:
- `/home/buildserver/artifacts/kria_zynq_latest_build.txt` -> `.../vivado`
- `/home/buildserver/artifacts/kria_zynq_latest_devicetree.txt` -> `.../dt`
- `/home/buildserver/artifacts/kria_zynq_latest_yocto_build.txt` -> `.../yocto`

The `build_yocto` target mounts the device tree directory and installs files into the image:
- Bitstream → `/lib/firmware/`
- Device tree → `/boot/dtbs/`

The Yocto `report` target reads `yocto.log` from that `yocto/` folder and generates `yocto-report.txt`.

After `bitbake` completes, the build also exports the boot disk image into:

```
/home/buildserver/artifacts/kria_zynq/<branch>/<timestamp>_<commit>/yocto/boot/
```

Current export policy copies only `*.wic.xz` from `DEPLOY_DIR_IMAGE`.
The bitstream and DTB are still packaged in the Yocto image via the custom layer,
but are not exported as separate files in `yocto/boot/`.

## Reusing the Layer

Copy `meta-custom-bitstream/` into your Yocto workspace and register it:

```sh
bitbake-layers add-layer /path/to/meta-custom-bitstream
# or manually add to bblayers.conf:
# BBLAYERS += "/path/to/meta-custom-bitstream"
```

Include in your image:
```conf
IMAGE_INSTALL:append = " kria-artifacts"
```

## Kernel Integration

```conf
KERNEL_DEVICETREE = "system-top"
```

Load bitstream in U-Boot or init script:
```sh
fpga load /lib/firmware/<your-bitstream.bit>
```

---

https://docs.yoctoproject.org/
