---
title: "Technical Documents"
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

```{.include format=html include-if-format=html;html5}
includes/Math.html
```

**Author:** Gabriel Nützi<br>
**Reviewer:** Michael Baumann<br>
**Date:** 28.05.2020

# Intro

This is a setup demonstrating the power and use of markdown for technical documents by using
a fully automated conversion sequence with `yarn`, `gulp` and of course [`pandoc`](www.pandoc.org).
Read the [Readme.md](https://github.com/gabyx/TechnicalMarkdown/blob/master/Readme.md)
for futher information.

# Samples

```{.include}
chapters/KonvexeProbleme.md
chapters/MarkdownSamples.md
chapters/TableSamples.md
```

# References
