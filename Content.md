---
title: "Technical Documents"
titlepage-logo: "files/Logo.svg"
subtitle: "Demonstrating the Power of Markdown with Pandoc"
author:
    - "Gabriel Nützi"
    - "The Community"
date: 2. Dezember 2020
location: Zürich, Switzerland
bibliography: ["literature/bibliography.bib"]
csl: "literature/ieee-with-url.csl"
crossrefYaml: "includes/pandoc-crossref.yaml"
link-citations: true

fontsize: 12pt
lang: en-GB

toc: true
toc-depth: 2
top-level-division: chapter
secnumdepth: 3
---

:::{include-if-format=}
Reasonable applied defaults before the above yaml meta block are found in:
- `convert/pandoc/defaults/pandoc-general.yaml` for all output formats
- `convert/pandoc/defaults/pandoc-html.yaml` for HTML
- `convert/pandoc/defaults/pandoc-latex.yaml` for LaTex output
Note: This is a Div block which get discarded because of the `{include-if-format=}`
:::

```{.include format=html include-if-format=html;html5}
includes/Math.html
```

:::{.abstract}
This is a setup demonstrating the power and use of markdown for technical documents by using
a fully automated conversion sequence with `yarn`, `gulp` and of course [`pandoc`](www.pandoc.org).
:::

# Intro

Read the [Readme.md](https://github.com/gabyx/TechnicalMarkdown/blob/master/Readme.md)
for futher information.

# Samples

```{.include}
chapters/KonvexeProbleme.md
chapters/MarkdownSamples.md
chapters/TableSamples.md
```

# References
