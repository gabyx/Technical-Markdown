#!/bin/bash
rootDir=$(git rev-parse --show-toplevel)
latexmk -pvc -r "$rootDir/.latexmkrc" -xelatex -gg -outdir="$rootDir/build/output-tex" "$rootDir/build/output-tex/input.tex"