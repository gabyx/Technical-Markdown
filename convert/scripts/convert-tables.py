#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import re
import os
import commentjson as json
import glob
import subprocess
import yaml
from concurrent.futures import ProcessPoolExecutor

# Setting root dir
repoDir = subprocess.check_output(["git", "rev-parse", "--show-toplevel"], encoding="utf-8").strip()

# Settings general defaults
pandocGeneralDefaults = os.path.join(
    repoDir,
    "convert/pandoc/defaults/pandoc-general.yaml",
)
with open(pandocGeneralDefaults, "r") as f:
    pandocGeneralDefaults = yaml.load(f, Loader=yaml.FullLoader)

# Setting important env. variables
filters = os.path.join(repoDir, "convert/pandoc/filters")
s = os.environ.get("LUA_PATH")
os.environ["LUA_PATH"] = "{0}/?;{0}/?.lua;{1}".format(filters, s if s else "")
s = os.environ.get("PYTHONPATH")
os.environ["PYTHONPATH"] = "{0}:{1}".format(filters, s if s else "")


def replaceColumnType(match):
    columns = ""
    for c in match.group(2):
        columns += "S" + c
    return match.group(1) + columns + match.group(3)


defaultTableRegexes = {
    "latex": [
        (  # Remove pandoc inserted struct
            re.compile(r"\\end\{itemize\}\\strut"),
            r"\\end{itemize}",
        ),
        (  # Remove \endfirsthead, its not needed
            re.compile(r"\\endfirsthead.*?\\endhead", re.DOTALL),
            r"\\endhead",
        )
    ]
}


def getStretchRegexes(spacing):
    return [(  # Set spacing for inbetween tabularnewline
        re.compile(r"\\tabularnewline"),
        r"\\tabularnewline\\addlinespace[{0}]".format(spacing),
    )]


def getFormat(file):
    ext = os.path.splitext(file)[1]

    if ext == ".html":
        return "html+tex_math_dollars"
    elif ext == ".tex":
        return "latex"
    elif ext == ".md":
        return pandocGeneralDefaults["from"]
    else:
        raise ValueError("Wrong format {0}".format(ext))


def getExtension(format):

    if "html" in format:
        return ".html"
    elif "latex" in format:
        return ".tex"
    elif "markdown" in format:
        return ".md"
    else:
        raise ValueError("Wrong format {0}".format(format))


def setLatexSpacing(output, spacing):
    startTag = "\\endhead"
    endTag = "\\bottomrule"

    start = output.find(startTag) + len(startTag)
    end = output.find(endTag)

    print("Found cell body between '{0}-{1}'".format(start, end))
    substring = output[start:end]

    for reg, repl in getStretchRegexes(spacing):
        substring = reg.sub(repl, substring)

    return output[0:start] + substring + output[end:]


def getColumnSizes(output, scaleToOne=False, scaleToFullMargin=0, columnRatios=None):
    endTag = "\\endhead"
    end = output.find(endTag)

    widths = []
    formats = []

    if end < 0:
        return widths, formats

    # Extract all widths
    part = output[0:end]
    r = re.compile(r"\\begin\{minipage\}(?:\[.*\])?\{.*\\real\{(\d+(?:\.\d+)?)\}\}(\\.*)")

    for m in r.finditer(part):
        w = float(m.group(1))
        widths.append(w)

        formats.append(m.group(2))

    if len(widths) == 0:
        raise ValueError("Regex failed")

    # Overwrite by new column ratios
    if columnRatios:
        assert len(columnRatios) == len(widths)
        totalWidth = sum(columnRatios)
        widths = [c / float(totalWidth) for c in columnRatios]
        print("Set ratios to '{0}'".format(widths))

    if scaleToOne or columnRatios:
        print("Scale to full width ...")
        totalWidth = sum(widths)
        scale = (1.0 - scaleToFullMargin) / totalWidth
        widths = [w * scale for w in widths]

    print("Found widths [tot: '{0}'] '{1}'".format(sum(widths), widths))
    print("Found formats '{0}'".format(formats))

    return widths, formats


def setColumnFormat(output, widths, formats):
    if not widths:
        return output

    reg = re.compile(r"(\\begin\{longtable\}\[\])\{.*\}")

    nSeps = 2 * (len(widths) - 1)

    def getWidth(w):
        return r"p{" + r"(\columnwidth-{1}\tabcolsep) * \real{{{0:0.3f}}}".format(w, nSeps) + r"}"

    # Build column
    columns = [(r">{" + f + r"}" + getWidth(w)) for f, w in zip(formats, widths)]

    form = r"@{}" + "".join(columns) + "@{}"

    print("Replacing format with:\n'{0}'".format(form))

    def repl(m):
        return m.group(1) + "{" + form + r"}"

    output = reg.sub(repl, output)

    # Remove all minipages
    reg = re.compile(r"\\end\{minipage\}")
    output = reg.sub(r"", output)

    reg = re.compile(r"\\begin\{minipage\}.*")
    return reg.sub(r"", output)


def deleteEmptyLines(output):
    reg = re.compile(r"^\s*\n", re.MULTILINE)
    return reg.sub("", output)


def postProcessLatexTables(config, output):
    r = re.compile(r"\\begin\{longtable\}.*?\\end\{longtable\}", re.DOTALL)

    def postProcessLatexTable(match):
        table = match.group(0)

        # Count column sized
        widths, formats = getColumnSizes(table, config.get("scaleColumnsToFull", False),
                                         config.get("scaleColumnsToFullMargin", 0.0), config.get("columnRatios", None))

        table = setColumnFormat(table, widths, formats)

        # Stetch cell rows in latex output
        spacing = config.get("rowSpacing")
        if spacing:
            print("Apply spacing ...")
            table = setLatexSpacing(table, spacing)

        return deleteEmptyLines(table)

    return r.sub(postProcessLatexTable, output)


def convertTable(file, config):

    fromFormat = config["from"] if "from" in config else getFormat(file)
    toFormat = config["to"]
    toExt = getExtension(toFormat)

    # Make output file
    baseName, ext = os.path.splitext(os.path.split(file)[1])
    outputDir = config["outputDir"].format(repoDir=repoDir, ext=toExt[1:])
    outFile = os.path.join(outputDir, baseName + toExt)

    # Run pandoc
    print("--------------------------------------------------------------")
    print("Converting '{0}' -> '{1}' [{2} -> {3}]".format(file, outFile, fromFormat, toFormat))

    output = subprocess.check_output([
        "pandoc",
        "--fail-if-warnings",
        "--verbose",
        "--data-dir=convert/pandoc",
        "--defaults=pandoc-dirs.yaml",
        "--defaults=pandoc-table.yaml",
        "--defaults=pandoc-filters.yaml",
    ] + config.get("pandocArgs", []) + [
        "-f",
        fromFormat,
        "-t",
        toFormat,
        file,
    ],
                                     encoding="utf-8")
    # Pre save...
    with open(outFile, "w") as o:
        o.write(output)

    # Modify regexes
    if config.get("defaultPostProcessing"):
        regs = defaultTableRegexes.get(toFormat, [])
        for reg, repl in regs:
            print("Apply default output regexes ...")
            output = reg.sub(repl, output)

    if toFormat == "latex":
        output = postProcessLatexTables(config, output)

    with open(outFile, "w") as o:
        o.write(output)


def convertTables(config):

    globs = config["globs"]
    if isinstance(globs, str):
        globs = [globs]

    # Get all files by globbing
    files = []
    for g in globs:

        # Replace 'repoDir'
        g = g.format(repoDir=repoDir)
        # Get files
        files += glob.glob(g, recursive=True)

    for f in files:
        convertTable(f, config)


def run(configs, parallel=False):

    if parallel:
        with ProcessPoolExecutor() as executor:
            executor.map(convertTables, configs)
    else:
        for c in configs:
            convertTables(c)


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--config',
        required=False,
        default=os.path.join(repoDir, "convert/scripts/tables.json"),
        help='Config file with tables',
    )

    parser.add_argument(
        '--parallel',
        action="store_true",
        help='Config file with tables',
    )

    args = parser.parse_args()

    with open(args.config, "r") as f:
        config = json.load(f)

    run(config, parallel=args.parallel)
