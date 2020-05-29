#!/usr/bin/env python
"""
Pandoc filter to convert
    - ```math``` code blocks to raw inline latex.
    - remove `<div class="latex-math-define" />`
"""

import sys
import os
from panflute import Doc, Element, Image, RawInline, run_filter
from module.utils import log

assert sys.version_info >= (3, 0)

fName = "tfImg"


def latexblock(code):
    return RawInline(code, format="tex")


def transformImgToLatex(image: Image):

    url = image.url
    label = image.identifier

    log("Transforming image '{0}' to latex ...", fName, url)

    # Set `/fig.png` to `./fig.png`
    if os.path.isabs(url):
        url = "." + os.path.splitdrive(url)[1]

    baseCommand = r"imageWithCaption"
    if os.path.splitext(url)[1] == ".svg":
        baseCommand = r"svgWithCaption"

    # Default values
    width = "100%"
    height = None

    def toScaling(size: str, proportionalTo: str):
        if size and "%" in size:
            s = float(size.strip().replace("%", "")) / 100.0
            return "{0}{1}".format(s, proportionalTo)
        else:
            return size

    width = toScaling(image.attributes.get("width", "100%"), proportionalTo=r"\textwidth")
    height = toScaling(image.attributes.get("height", None), proportionalTo=r"\textwidth")
    # Caption
    caption = image.content

    # Latex command options
    lGraphicsOpts = "width={0}".format(width)
    if height:
        lGraphicsOpts += ", height={0}".format(height)

    latexElements = [
        latexblock(r"\{0}{{{1}}}{{".format(baseCommand, url)),
        *caption,
        latexblock(r"}}{{{0}}}{{{1}}}".format(lGraphicsOpts, label))
    ]

    return latexElements


def transformImages(elem: Element, doc: Doc):
    if doc.format == "latex":
        if isinstance(elem, Image):
            return transformImgToLatex(elem)


def main(doc: Doc = None):
    return run_filter(transformImages, doc=doc)


if __name__ == "__main__":
    main()
