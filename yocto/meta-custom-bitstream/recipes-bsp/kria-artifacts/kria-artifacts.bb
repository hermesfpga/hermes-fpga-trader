SUMMARY = "Custom FPGA bitstream & generated device tree"
LICENSE = "CLOSED"
SRC_URI = ""

inherit allarch

do_install () {
    bbnote "Installing FPGA artifacts from /dt"
    ls -la /dt || bbwarn "No /dt directory found"
    install -d ${D}${nonarch_base_libdir}/firmware
    install -m 0644 /dt/*.bit ${D}${nonarch_base_libdir}/firmware/ 2>/dev/null || bbwarn "No .bit files found in /dt"
    install -d ${D}/boot/dtbs
    install -m 0644 /dt/*.dtb ${D}/boot/dtbs/ 2>/dev/null || bbwarn "No .dtb files found in /dt"
    bbnote "Installed files:"
    find ${D}${nonarch_base_libdir}/firmware -name "*.bit" -exec basename {} \; || true
    find ${D}/boot/dtbs -name "*.dtb" -exec basename {} \; || true
}

FILES:${PN} += "${nonarch_base_libdir}/firmware/* /boot/dtbs/*"
