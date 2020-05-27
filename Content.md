---
# Markdown Preview Enhanced
class: "main"
id: "main-markdown-numbered"
html:
    embed_local_images: false
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
    ["-f",
     "markdown+markdown_in_html_blocks+tex_math_dollars"]
output:
    pdf_document:
        pandoc_args:
            [
                "--fail-if-warnings",
                "--format=markdown+markdown_in_html_blocks+native_divs+raw_tex+tex_math_dollars",
                "--filter=convert/pandoc/filters/transformMath.py",
                # "-filter=convert/pandoc/filters/teeStart.py" ,
                "--filter=pandoc-crossref",
                # "--filter=convert/pandoc/filters/tee.py",
                "--filter=pandoc-citeproc",
                # "--filter=convert/pandoc/filters/tee.py",
                "--filter=convert/pandoc/filters/transformImages.py",
                # "--filter=convert/pandoc/filters/tee.py",
                "--pdf-engine-opt=-xelatex",
                "--pdf-engine-opt=-r",
                "--pdf-engine-opt=.latexmkrc",
                "--pdf-engine-opt=-g",
                "--pdf-engine-opt=-outdir=pandoc"
            ]
        latex_engine: latexmk
        template: convert/pandoc/includes/Template.tex
        includes:
            in_header: convert/pandoc/includes/Header.tex
        toc: true
        toc_depth: 2
        citation_package: biblatex
        number_sections: true  
# Pandoc
title: "Technical Document"
author: Gabriel Nützi
fontsize: 12pt
mainfont: Latin Modern Roman
sansfont: Latin Modern Sans
monofont: Latin Modern Mono
documentclass: scrreprt
classoption:
    - a4paper
    - twoside
    - titlepage
    - openright
    - numbers=noenddot
    - chapterprefix=true
    - headings=optiontohead
    - svgnames
    - dvipsnames
hyperrefoptions:
    - linktoc=all
    - hidelinks
linkcolor: DarkGray
filecolor: DarkBlue
citecolor: DarkBlue
urlcolor: MediumBlue
toccolor: DarkGreen
---

@import "css/src/main.less"
@import "/includes/Math.md"

<header>
<p><strong>Author:</strong> Gabriel Nützi<br>
<strong>Reviewer:</strong> Michael Baumann<br>
<strong>Date:</strong> 28.04.2020
</p>
</header>

# Technical Document s

This is a setup demonstrating the power and use of markdown for technical documents by using
the VS Code extension [Markdown Preview Enhanced](https://shd101wyy.github.io/markdown-preview-enhanced) and a fully automated conversion sequence with `yarn`, `gulp`.
Read the [Readme.md](https://github.com/gabyx/TechnicalMarkdown/blob/master/Readme.md) for futher information.

@import "chapters/convex-analysis/KonvexeProbleme.md"
