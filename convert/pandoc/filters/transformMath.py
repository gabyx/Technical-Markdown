#!/usr/bin/env python3
"""
    Pandoc filter to convert to format latex

    - ```math``` code blocks to raw inline latex.
    - remove `<div class="latex-math-define" />`
"""

import sys
from panflute import Para, RawInline, Div, CodeBlock, Element, Doc, Math, run_filter
from module.utils import log

assert sys.version_info >= (3, 0)

fName = "tfMath"


def mathblock(code):
    return Para(RawInline(code, format="tex"))


def transformMath(elem: Element, doc: Doc):

    if doc.format in ["latex"]:
        if isinstance(elem, Div):
            if "latex-math-define" in elem.classes:
                return []  # remove

        elif isinstance(elem, CodeBlock):
            if "math" in elem.classes:
                return Para(RawInline((elem.text), format="tex"))
    else:
        # Wrap to display math
        if isinstance(elem, CodeBlock):
            if "math" in elem.classes:
                return Para(Math(elem.text, format="DisplayMath"))
    return None


def main(doc: Doc = None):
    return run_filter(transformMath, doc=doc)


if __name__ == "__main__":
    main()
