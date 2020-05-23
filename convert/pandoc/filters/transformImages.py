#!/usr/bin/env python
"""
Pandoc filter to convert 
    - ```math``` code blocks to raw inline latex.
    - remove `<div class="latex-math-define" />`
"""

import os
import json
from io import StringIO, BytesIO
from lxml import etree as ET
from cssutils import parseStyle
import pypandoc as pyp
from pandocfilters import toJSONFilter, Para, RawInline

htmlParser = ET.HTMLParser()


def latexblock(code):
    """LaTeX block"""
    return Para([RawInline('tex', code)])


def transformImgToLatex(image, caption=None, style=None):

    src = image.attrib["src"]
    label = None

    # Set `/fig.png` to `./fig.png`
    if os.path.isabs(src):
        src = "." + os.path.splitdrive(src)[1]

    baseCommand = r"imageWithCaption"
    if os.path.splitext(src)[1] == ".svg":
        baseCommand = r"svgWithCaption"

    # Default values
    width = "100%"
    height = None

    width = style.getProperty("width")
    if width:
        width = width.value

    height = style.getProperty("height")
    if height:
        height = height.value

    def toScaling(size: str, proportionalTo: str):
        s = float(size.replace("%", "")) / 100.0
        return "{0}{1}".format(s, proportionalTo)

    if "%" in width:
        width = toScaling(width, r"\textwidth")
    if height and "%" in height:
        height = toScaling(height, r"\textheight")

    # Caption
    if caption is not None:
        caption = caption.text

    # Latex command options
    lGraphicsOpts = "width={0}".format(width)
    if height:
        lGraphicsOpts += ", height={0}".format(height)

    args = [src, caption if caption else "", lGraphicsOpts, label]
    lArgs = "".join(["{" + a + "}" for a in args if a is not None])

    return latexblock(r"\{0}{1}".format(baseCommand, lArgs))


def convert(contents):
    out = pyp.convert_text(
        contents,
        to="json",
        format=
        "markdown-markdown_in_html_blocks+raw_html-raw_tex+tex_math_dollars")
    return json.load(out)


def transformImageWithCaption(format, kvs, contents):
    t = contents.get("t")
    if t == "CodeBlock":
        [[_ident, _classes, _kvs], contents] = contents['c']

        dom = ET.parse(StringIO(contents), htmlParser).getroot()

        img = dom.find(".//img")
        if img is not None:
            caption = dom.find(".//div[@class='caption']")

            if "style" in img.attrib:
                style = parseStyle(img.attrib["style"])

            if format in ["latex", "native", "json"]:
                return transformImgToLatex(img, caption, style)


def transformImages(key, value, format, meta):
    if key == 'Div':
        [[_ident, classes, kvs], contents] = value
        if "img-with-caption" in classes:
            if contents:
                return transformImageWithCaption(format, kvs, contents[0])


if __name__ == "__main__":
    toJSONFilter(transformImages)
