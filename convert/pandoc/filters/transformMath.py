#!/usr/bin/env python
"""
    Pandoc filter to convert

    - ```math``` code blocks to raw inline latex.
    - remove `<div class="latex-math-define" />`
"""

import sys
from panflute import Para, Math, Div, CodeBlock, Element, Doc, run_filter

assert sys.version_info >= (3, 0)

fName = "tfMath"


def mathblock(code):
    return Para(Math(code, format="DisplayMath"))


def transformMath(elem: Element, doc: Doc):

    if doc.format in ["latex"]:
        if isinstance(elem, Div):
            if "latex-math-define" in elem.classes:
                return []  # remove

        elif isinstance(elem, CodeBlock):
            if "math" in elem.classes:
                return mathblock(elem.text)

    return None


def main(doc: Doc = None):
    return run_filter(transformMath, doc=doc)


if __name__ == "__main__":
    main()
