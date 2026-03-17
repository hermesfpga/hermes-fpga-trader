SUMMARY = "Custom FPGA bitstream & generated device tree"
LICENSE = "CLOSED"
SRC_URI = " \
    file://hermes-autoexpand-rootfs.sh \
    file://hermes-autoexpand-rootfs.service \
"

inherit allarch systemd

SYSTEMD_SERVICE:${PN} = "hermes-autoexpand-rootfs.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

RDEPENDS:${PN} += " \
    e2fsprogs-resize2fs \
    parted \
    util-linux \
"

do_install () {
    bbnote "Installing FPGA artifacts from /dt"
    ls -la /dt || bbwarn "No /dt directory found"
    install -d ${D}${nonarch_base_libdir}/firmware
    install -m 0644 /dt/*.bit ${D}${nonarch_base_libdir}/firmware/ 2>/dev/null || bbwarn "No .bit files found in /dt"
    install -d ${D}/boot/dtbs
    install -m 0644 /dt/*.dtb ${D}/boot/dtbs/ 2>/dev/null || bbwarn "No .dtb files found in /dt"
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/hermes-autoexpand-rootfs.sh ${D}${sbindir}/hermes-autoexpand-rootfs
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/hermes-autoexpand-rootfs.service ${D}${systemd_system_unitdir}/
    bbnote "Installed files:"
    find ${D}${nonarch_base_libdir}/firmware -name "*.bit" -exec basename {} \; || true
    find ${D}/boot/dtbs -name "*.dtb" -exec basename {} \; || true
}

FILES:${PN} += " \
    ${nonarch_base_libdir}/firmware/* \
    /boot/dtbs/* \
    ${sbindir}/hermes-autoexpand-rootfs \
    ${systemd_system_unitdir}/hermes-autoexpand-rootfs.service \
"
