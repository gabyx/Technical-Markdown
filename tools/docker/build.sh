#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2015,SC1091
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================
ROOT_DIR=$(git rev-parse --show-toplevel)

set -e
set -u

. "$ROOT_DIR/tools/docker/setup/common/log.sh"

# Arguments
tag="latest"
push="false"
dockerArgs=()

# Parse all arguments.
function parseArgs() {

    local prev=""
    local count=0
    for p in "$@"; do
        if [ "$p" = "--tag" ]; then
            true
        elif [ "$prev" = "--tag" ]; then
            tag="$p"
        elif [ "$p" = "--push" ]; then
            push="true"
        elif [ "$p" = "-h" ] || [ "$p" = "--help" ]; then
            printInfo "Build a container." \
                "Usage:" \
                "   --tag <string>       Container tag."
            exit 0
        elif [ "$p" = "--" ]; then
            break
        else
            printError "Wrong argument '$p' !"
            return 1
        fi

        count=$((count + 1))
        prev="$p"
    done

    shift $count
    dockerArgs=("$@")

    return 0
}

parseArgs "$@"

# Define name.
name="technical-markdown"
if [ "$push" = "true" ]; then
    name="docker.io/gabyxgabyx/$name"
fi
name="$name:$tag"

# Define repo version.
printInfo "Define tag and version."
repoCommitSHA="$(git rev-parse HEAD)"
# Get the tag (on CI possibly not there.)
repoVersion="$(git describe --tags --match "v*" --abbrev=0 2>/dev/null | sed -E "s/^v//g")" || repoVersion="not-found"

printInfo "Repository SHA: '$repoCommitSHA'."
printInfo "Repository Version: '$repoVersion'."

printInfo "Building image '$name'..."
cd "$ROOT_DIR" &&
    docker build \
        "${dockerArgs[@]}" \
        -f tools/docker/Dockerfile \
        -t "$name" \
        --progress=plain \
        --build-arg "TECHMD_BUILD_VERSION=$repoVersion" \
        --build-arg "TECHMD_COMMIT_SHA=$repoCommitSHA" \
        --target "technical-markdown" \
        .

if [ "$push" = "true" ]; then
    docker push "$name"
fi
