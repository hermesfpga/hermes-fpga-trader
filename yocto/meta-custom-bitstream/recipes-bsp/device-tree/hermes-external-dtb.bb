SUMMARY = "Import external per-run DTS/DTB artifacts for SDT builds"
LICENSE = "CLOSED"
SRC_URI = ""

inherit deploy allarch

do_configure[noexec] = "1"

do_compile() {
    bbnote "Importing external DTS from /dt/${HERMES_EXTERNAL_DTS}"
    if [ ! -f "/dt/${HERMES_EXTERNAL_DTS}" ]; then
        bbfatal "Required DTS not found: /dt/${HERMES_EXTERNAL_DTS}"
    fi

    bbnote "Importing external DTB from /dt/${HERMES_EXTERNAL_DTB}"
    if [ ! -f "/dt/${HERMES_EXTERNAL_DTB}" ]; then
        bbfatal "Required DTB not found: /dt/${HERMES_EXTERNAL_DTB}"
    fi

    install -d ${B}
    install -m 0644 "/dt/${HERMES_EXTERNAL_DTS}" "${B}/system-top.dts"
    install -m 0644 "/dt/${HERMES_EXTERNAL_DTB}" "${B}/${HERMES_EXTERNAL_DTB}"
}

do_install() {
    install -d ${D}${datadir}/sdt/${MACHINE}
    install -m 0644 "${B}/system-top.dts" "${D}${datadir}/sdt/${MACHINE}/system-top.dts"
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 "${B}/${HERMES_EXTERNAL_DTB}" "${DEPLOYDIR}/hermes-external.dtb"
    bbnote "Deployed external DTB to ${DEPLOYDIR}/hermes-external.dtb"
}

addtask deploy after do_compile before do_build

SYSROOT_DIRS += "${datadir}/sdt"
FILES:${PN} += "${datadir}/sdt/${MACHINE}/system-top.dts"