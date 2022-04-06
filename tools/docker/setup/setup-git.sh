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

set -e
set -u
set -o pipefail

function installGit() {
    if [ "$os" = "ubuntu" ]; then
        sudo apt-get install -y git git-lfs || die "Could not install 'git', 'git-lfs'."
    elif [ "$os" = "alpine" ]; then
        sudo apk add git git-lfs || die "Could not install 'git', 'git-lfs'."
    fi

    sudo git lfs install --system || die "Could not install Git LFS."
}

function installGithooks() {
    local githooksVersion="2.1.2"
    if [ "$os" = "ubuntu" ] || [ "$os" = "alpine" ]; then
        local platform="linux"
        local githooksURL="https://github.com/gabyx/Githooks/releases/download"
        githooksURL="$githooksURL/v$githooksVersion/githooks-$githooksVersion-$platform.$arch.tar.gz"

        local temp
        temp="$(mktemp -d)"
        local ghDir="$temp/githooks"
        mkdir -p "$ghDir" &&
            curl -fsSL "$githooksURL" --output "$ghDir/githooks.tar.xz" &&
            tar -C "$ghDir" -xvf "$ghDir/githooks.tar.xz" &>/dev/null ||
            die "Could not download Githooks '$githooksURL'."

        "$ghDir/cli" installer \
            --non-interactive \
            --maintained-hooks "!all, applypatch-msg, pre-applypatch, post-applypatch, pre-commit, pre-merge-commit, prepare-commit-msg, commit-msg, post-commit, pre-rebase, post-checkout, post-merge, pre-push, post-rewrite" \
            2>&1 || die "Githooks install failed"

    else
        die "Platform '$os' not supported."
    fi
}

os="$1"
arch=$(getPlatformArch)

installGit
installGithooks
