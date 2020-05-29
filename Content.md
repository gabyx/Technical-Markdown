---
# Markdown Preview Enhanced
class: "main"
id: "main-markdown-numbered"
html:
    embed_local_images: true
    embed_svg: true
    offline: false
    toc: true
puppeteer:
    path: "./Content-Chrome.pdf"
    landscape: false
    format: "A4"
    printBackground: true
    timeout: 3000 # <= Special config, which means waitFor 3000 ms
pandoc_args:
    [
        "--fail-if-warnings",
        "--standalone",
        "--data-dir=convert/pandoc",
        "--resource-path=convert/pandoc",
        "--defaults=pandoc-html.yaml",
        "--defaults=pandoc-filters.yaml"
    ]
output:
    pdf_document:
        pandoc_args: [
                "--fail-if-warnings",
                "--data-dir=convert/pandoc",
                "--resource-path=convert/pandoc",
                "--defaults=pandoc-latex.yaml",
                "--defaults=pandoc-filters.yaml"
            ]
        latex_engine: "latexmk"
# Pandoc
title: "Technical Documents"
fontsize: 12pt
lang: en-US
toc: true
toc-depth: 2
top-level-division: chapter
number-sections: true
---

@import "css/src/main.less"
@import "includes/Math.md"

**Author:** Gabriel Nützi<br>
**Reviewer:** Michael Baumann<br>
**Date:** 28.05.2020

This is a setup demonstrating the power and use of markdown for technical documents by using
the VS Code extension [Markdown Preview Enhanced](https://shd101wyy.github.io/markdown-preview-enhanced) and a fully automated conversion sequence with `yarn`, `gulp`.
Read the [Readme.md](https://github.com/gabyx/TechnicalMarkdown/blob/master/Readme.md) for futher information.

@import "chapters/convex-analysis/KonvexeProbleme.md"
