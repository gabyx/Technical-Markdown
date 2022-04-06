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
push="false"
noCacheArg=""
dockerArgs=()
baseName="technical-markdown"
pushBaseName="docker.io/gabyxgabyx"

# Parse all arguments.
function parseArgs() {

    local prev=""
    local count=0
    for p in "$@"; do
        
        if [ "$p" = "--base-name" ]; then
            true
        elif [ "$prev" = "--base-name" ]; then
            baseName="$p"
        elif [ "$p" = "--base-name" ]; then
            true
        elif [ "$prev" = "--push-base-name" ]; then
            pushBaseName="$p"
        elif [ "$p" = "--push" ]; then
            push="true"
        elif [ "$p" = "--no-cache" ]; then
            noCacheArg="--no-cache"
        elif [ "$p" = "-h" ] || [ "$p" = "--help" ]; then
            printInfo "Build a container." \
                "Usage:" \
                "   --base-name <string>  Image base name (default 'technical-markdown')." \
                "   --push-base-name <string>  Image base name (default 'docker.io/gabyxgabyx')."
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

# Define repo version.
printInfo "Define tag and version."
repoCommitSHA="$(git rev-parse HEAD)"

# Get the tag (on CI possibly not there.)
repoVersion="$(git describe --tags --match "v*" \
    --abbrev=0 2>/dev/null | sed -E "s/^v//g")" || repoVersion="not-found"

printInfo "Repository SHA: '$repoCommitSHA'."
printInfo "Repository Version: '$repoVersion'."

for addTag in "-minimal" ""; do

    # Define image name.
    imageName="$baseName:$repoVersion$addTag"
    imageNameLatest="$baseName:latest$addTag"

    printInfo "Building image '$imageName'..."
    cd "$ROOT_DIR" &&
        DOCKER_BUILDKIT=1 \
            docker build \
            "${dockerArgs[@]}" \
            -f tools/docker/Dockerfile \
            -t "$imageName" \
            $noCacheArg \
            --target "technical-markdown$addTag" \
            --build-arg "TECHMD_BUILD_VERSION=$repoVersion" \
            --build-arg "TECHMD_COMMIT_SHA=$repoCommitSHA" \
            .

    docker tag "$imageName" "$imageNameLatest"

    if [ "$push" = "true" ]; then
        docker tag "$imageName" "$pushBaseName/$imageName"
        docker tag "$imageNameLatest" "$pushBaseName/$imageNameLatest"
        docker push "$pushBaseName/$imageName"
        docker push "$pushBaseName/$imageNameLatest"
    fi
done
