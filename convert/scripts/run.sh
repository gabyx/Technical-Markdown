#!/bin/bash

format="$1"
[ -z "$format" ] && format="json"

repoDir=$(git rev-parse --show-toplevel)

filters="$repoDir/convert/filters"
export LUA_PATH="$filters/?;$filters/?.lua;$LUA_PATH"
export PYTHONPATH="$filters"

pandoc "--fail-if-warnings" \
    "--verbose" \
    "--toc" \
    "--data-dir=convert/pandoc" \
    "--defaults=pandoc-dirs.yaml" \
    "--defaults=pandoc-general.yaml" \
    "--defaults=pandoc-html.yaml" \
    "--defaults=pandoc-filters.yaml" \
    -t "$format" \
    -o test.json \
    Content.md

if [ "$format" = "json" ]; then
    prettier --write test.json &>/dev/null
fi
