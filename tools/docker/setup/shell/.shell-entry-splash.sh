#!/usr/bin/env zsh
# shellcheck disable=SC1090,SC1071
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

. "$CONTAINER_SETUP_DIR/common/version.sh"

containerName="$1"

UPDATE_MESSAGE=""
if [ -n "$TECHMD_BUILD_VERSION_REMOTE" ]; then
    # shellcheck disable=SC2181
    if versionCompare "$TECHMD_BUILD_VERSION_REMOTE" ">" "$TECHMD_VERSION_BUILD"; then
        UPDATE_MESSAGE="[ NEW version '$TECHMD_BUILD_VERSION_REMOTE' available ]"
    fi
fi

TECHMD_SPLASH_TEXT=$(echo "$containerName" | figlet -f slant -w 120 | sed -E "s/^/  /g")
COMMIT_SHA=$(echo "$TECHMD_COMMIT_SHA" | cut -c -7)

echo -e "\e[34m\e[1m
\e[32m$TECHMD_SPLASH_TEXT\e[93m

  Author:   Gabriel Nützi
  Version:  ${TECHMD_BUILD_VERSION:-undefined} @${COMMIT_SHA:-none} \e[31m${UPDATE_MESSAGE:-}\e[93m

  \e[34mReport problems and contributions to \"https://github.com/gabyx/techanicalmarkdown/issues\"
  Enjoy!
\e[0m"
