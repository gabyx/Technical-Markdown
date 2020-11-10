#!/usr/bin/env python3
"""
    Pandoc filter to convert to format latex

    - ```math``` code blocks to raw inline latex.
    - remove `<div class="latex-math-define" />`

    Does not work with a block `Para` and afterwards a block `Code`
    since the `Code` should be merged into the `Para` to not
    have a newline. If we need this filter this should be fixed.
    So far we use `raw_tex`.

"""

import sys
from panflute import Para, RawBlock, RawInline, Div, CodeBlock, Element, Doc, Math, run_filter
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
                return RawBlock(elem.text, format="tex")
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
