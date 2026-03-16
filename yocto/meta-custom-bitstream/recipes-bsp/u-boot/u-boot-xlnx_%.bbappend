# Ensure external per-run DTB is available during U-Boot deploy.
do_deploy[depends] += "hermes-external-dtb:do_deploy"

do_deploy:append() {
    if [ ! -f "${DEPLOY_DIR_IMAGE}/${HERMES_EXTERNAL_DTB}" ]; then
        bbfatal "External DTB missing in deploy dir: ${DEPLOY_DIR_IMAGE}/${HERMES_EXTERNAL_DTB}"
    fi

    bbnote "External DTB ready for boot flow: ${DEPLOY_DIR_IMAGE}/${HERMES_EXTERNAL_DTB}"
}