#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2015,SC1091
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/common/general.sh"
. "$DIR/common/log.sh"
. "$DIR/common/version.sh"

set -e
set -u
set -o pipefail

os="$1"
osRelease="$2"

pythonEnvDir="$3"
pythonRequirements="$4"

pythonExe=""

function getPythonExe() {

    local pythonExe
    if haveHomebrew; then
        pythonExe="$HOMEBREW_PREFIX/opt/python@3.9/bin/python3"
    elif [ "$os" = "ubuntu" ]; then
        pythonExe=$(command -v python3.9)
    elif [ "$os" = "alpine" ]; then
        pythonExe=$(command -v python3)
    else
        die "Operating system not supported:" "$os"
    fi

    [ -f "$pythonExe" ] || return 1

    echo "$pythonExe"
    return 0
}

function installPythonEnv() {
    local pythonExe="$1"
    local pythonEnvDir="$2"

    # Make virtual env in home folder
    mkdir -p "$pythonEnvDir" &&
        "$pythonExe" -m venv --system-site-packages "$pythonEnvDir" ||
        die "Installing python virtual env in '$pythonEnvDir'."
}

function installPythonImpl() {
    printInfo "Installing python hook environment to '$pythonEnvDir'"

    if haveHomebrew; then
        brew install python@3.9 || die "Could not install 'python@3.9'."

    elif [ "$os" = "ubuntu" ]; then

        if [ "$osRelease" != "hirsute" ]; then
            sudo add-apt-repository -y ppa:deadsnakes/ppa &&
                sudo apt-get update ||
                die "Could not install 'python3.9'."
        fi

        sudo apt-get install -y python3.9 python3.9-venv || return 1

    elif [ "$os" = "alpine" ]; then

        sudo apk add python3 ||
            die "Could not install 'python3.9'."

    else
        die "Operating system not supported:" "$os"
    fi
}

# Check if we already have python installed.
installPythonImpl || die "Failed to install python."

pythonExe=$(getPythonExe) || die "Python executable not found."

# Install python env.
installPythonEnv "$pythonExe" "$pythonEnvDir" ||
    die "Could not install python env into '$pythonEnvDir'."

# Use python executable from environment.
pythonExe="$pythonEnvDir/bin/python"
[ -f "$pythonExe" ] || die "Could not find python in environment '$pythonEnvDir'."

# Install all python requirements
"$pythonExe" -m pip install --upgrade pip || die "Could not upgrade pip."
"$pythonExe" -m pip install wheel || die "Could not install python 'wheel' module."

if [ -f "$pythonRequirements" ]; then
    "$pythonExe" -m pip install -r "$pythonRequirements" ||
        die "Could not install python requirements."

    # For version check. (cannot install 'semver' because package clash)
    "$pythonExe" -m pip install node-semver ||
        die "Could not install python 'node-semver' module."
fi

if ! grep -q "$pythonEnvDir/bin/activate" ~/.zshrc; then
    printInfo "Use python env. at login ..."
    echo ". '$pythonEnvDir/bin/activate'" >>~/.zshrc ||
        die "Could not change '.zshrc'."
fi
