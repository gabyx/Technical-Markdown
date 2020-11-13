#!/bin/bash

set -u
set -e

function die() {
    echo -n "$@" >&2
    exit 1
}

repoDir=$(git rev-parse --show-toplevel)

format="${1:-latex}"
ext=".tex"

filters="$repoDir/convert/pandoc/filters"
export LUA_PATH="$filters/?;$filters/?.lua;${LUA_PATH:-}"
export PYTHONPATH="$filters:${PYTHONPATH:-}"

inDir="$repoDir/chapters/tables"
outDir="$repoDir/chapters/tables-tex"

function convertTable() {

    in="$1"
    out="$2"

    echo -e "Converting table '$1'\n-> '$out'"

    pandoc "--fail-if-warnings" \
        "--verbose" \
        "--data-dir=convert/pandoc" \
        "--defaults=pandoc-dirs.yaml" \
        "--defaults=pandoc-latex-table.yaml" \
        "--defaults=pandoc-filters.yaml" \
        -t "$format" \
        -o "$out" \
        "$in"
}

find "$inDir" -name '*.html' -print0 |
    while IFS= read -r -d '' file; do

        base=$(basename "$file")
        out="$outDir/$(echo "$base" | sed -E "s@(.*)(\..+)@\1$ext@")"

        convertTable "$file" "$out" ||
            die "Could not convert table '$base'"
    done
