# Tables

## HTML Table

Cross refeference do not work here.

<!-- No format attribute needed since we allow HTML in markdown.
     For latex we include another file. -->
```{.include format=html+tex_math_dollars .var-replace include-if-format=latex;html;html5;json;native}
chapters/tables/TableExample.html
```

:::{include-if-format=latex}
Included latex file parsed in as `latex`:
:::
```{.include format=latex include-if-format=latex;json;native}
chapters/tables-tex/TableExample.tex
```

## Multiline Table {#sec:multi-line-table}

Cross reference do work here.
```{.include}
chapters/tables/TableExample.md
```
