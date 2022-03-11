#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2015,SC1091
# =============================================================================
# TechnicalMarkdown
# 
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/common/log.sh"
. "$DIR/common/general.sh"
. "$DIR/common/platform.sh"
. "$DIR/common/packages.sh"

set -e
set -u
set -o pipefail

function installParallel() {
    printInfo " -> Installing 'parallel' ..."
    installPackages "$os" \
        --ubuntu parallel \
        --alpine parallel

    # Try to silence citation warning.
    echo "will cite" | parallel --citation &>/dev/null || true
}

function installJq() {
    local version="1.6"
    printInfo " -> Installing 'jq' ..."

    [ "$arch" = "amd64" ] && local arch="linux64"

    if haveHomebrew; then
        brew install jq@1.6
    elif [ "$os" = "alpine" ]; then
        sudo apk add jq
    elif [ "$os" = "ubuntu" ]; then

        url="https://github.com/stedolan/jq/releases/download/jq-$version/jq-$arch"
        sudo curl -fsSL "$url" -o /usr/local/bin/jq &&
            sudo chmod +x /usr/local/bin/jq || die "Could not install '$url'."

        assertChecksum /usr/local/bin/jq "1fffde9f3c7944f063265e9a5e67ae4f"

    else
        die "Operating system '$os' not supported."
    fi

    version=$(jq --version | head -1 | sed -E "s|jq-([0-9]+\.[0-9]+.*)|\1|") &&
        printInfo " -> Version 'jq': '$version'"
}

function installYq() {
    version="4.12.1"
    printInfo " -> Installing 'yq' ..."

    if haveHomebrew; then
        brew install yq@$version || return 1
    elif [ "$os" = "ubuntu" ] ||
        [ "$os" = "alpine" ]; then

        url="https://github.com/mikefarah/yq/releases/download/v$version/yq_linux_$arch"
        sudo curl -fsSL "$url" -o /usr/local/bin/yq &&
            sudo chmod +x /usr/local/bin/yq || die "Could not install '$url'."

        # assertChecksum /usr/local/bin/yq "4e359dfe49ea73e0efa93b744165b95e"

    else
        die "Operating system '$os' not supported."
    fi

    version=$(yq --version | head -1 | sed -E "s|.* ([0-9]+\.[0-9]+\.[0-9]+).*|\1|") &&
        printInfo " -> Version 'yq': '$version'"

    return 0
}


os="$1"
# osRelease="$2"
arch=$(getPlatformArch)

printInfo "Installing general build tools ..."

installParallel 
installJq 
installYq
