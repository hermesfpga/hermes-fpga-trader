# Ensure external per-run DTB is available during U-Boot deploy.
do_deploy[depends] += "hermes-external-dtb:do_deploy"

do_deploy:append() {
    if [ ! -f "${DEPLOY_DIR_IMAGE}/${HERMES_EXTERNAL_DTB}" ]; then
        bbfatal "External DTB missing in deploy dir: ${DEPLOY_DIR_IMAGE}/${HERMES_EXTERNAL_DTB}"
    fi

    install -m 0644 "${DEPLOY_DIR_IMAGE}/${HERMES_EXTERNAL_DTB}" "${DEPLOYDIR}/${HERMES_EXTERNAL_DTB}"
    ln -sf "${HERMES_EXTERNAL_DTB}" "${DEPLOYDIR}/system.dtb"
    bbnote "U-Boot deploy now uses external DTB: ${HERMES_EXTERNAL_DTB}"
}