#!/bin/bash
rootDir=$(git rev-parse --show-toplevel)
latexmk -pvc -r "$rootDir/.latexmkrc" -xelatex -gg -outdir="$rootDir/output-tex" "$rootDir/output-tex/input.tex"