SUMMARY = "Deploy external per-run DTB into Yocto deploy artifacts"
LICENSE = "CLOSED"
SRC_URI = ""

inherit deploy allarch

do_compile() {
    bbnote "Importing external DTB from /dt/${HERMES_EXTERNAL_DTB}"
    if [ ! -f "/dt/${HERMES_EXTERNAL_DTB}" ]; then
        bbfatal "Required DTB not found: /dt/${HERMES_EXTERNAL_DTB}"
    fi

    install -d ${B}
    install -m 0644 "/dt/${HERMES_EXTERNAL_DTB}" "${B}/${HERMES_EXTERNAL_DTB}"
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 "${B}/${HERMES_EXTERNAL_DTB}" "${DEPLOYDIR}/${HERMES_EXTERNAL_DTB}"
    bbnote "Deployed external DTB to ${DEPLOYDIR}/${HERMES_EXTERNAL_DTB}"
}

addtask deploy after do_compile before do_build