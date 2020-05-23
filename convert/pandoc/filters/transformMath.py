#!/usr/bin/env python
"""
Pandoc filter to convert 
    - ```math``` code blocks to raw inline latex.
    - remove `<div class="latex-math-define" />`
"""

from pandocfilters import toJSONFilter, Null, Para, RawInline
import pypandoc as pyp


def latexblock(code):
    """LaTeX block"""
    return Para([RawInline('tex', code)])


def transformMath(key, value, format, meta):
    if format in ["latex", "native", "json"]:
        if key == 'Div':
            [[_ident, classes, _kvs], contents] = value
            if "latex-math-define" in classes:
                return []  # remove

        elif key == 'CodeBlock':
            [[_ident, classes, _kvs], contents] = value
            if "math" in classes:
                return latexblock(contents)

    return None


if __name__ == "__main__":
    toJSONFilter(transformMath)
