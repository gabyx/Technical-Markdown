#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2015
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/common/log.sh"

set -e
set -u
set -o pipefail

os="$1"

if [ "$os" = "ubuntu" ]; then
    sudo apt-get clean ||
        printWarning "Could not clean apt-get cache."
    [ -d /var/lib/apt/lists ] && sudo rm -rf /var/lib/apt/lists/* ||
        printWarning "Could not clean apt-get cache."
elif [ "$os" = "alpine" ]; then
    sudo apk cache clean ||
        printWarning "Could not clean apk cache."
else
    die "Operating system '$os' not supported."
fi

[ -d /tmp ] && sudo rm -rf /tmp/* || printWarning "Could not remove '/tmp/*' ."
[ -d /var/tmp ] && sudo rm -rf /var/tmp/* || printWarning "Could not remove '/var/tmp/*' ."
[ -d ~/.cache ] && sudo rm -rf ~/.cache || printWarning "Could not remove '~/.cache' ."

# We can delete this file too, its Linux, files are ref-counted.
# This shell still has a valid reference.
find "$CONTAINER_SETUP_DIR" -mindepth 1 \
    -not \( -name "setup-time-zone*" \
    -or -name "setup-locales*" \
    -or -name "setup-credentials*" \
    -or -name "setup-runtime*" \
    -or -path "*/common*" \) \
    -exec rm -rf {} \; >/dev/null ||
    printWarning "Could not clean '$CONTAINER_SETUP_DIR'."

exit 0
