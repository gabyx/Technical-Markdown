# [Markdown Setup for Technical Documents](https://github.com/gabyx/TechnicalMarkdown)

![](https://img.shields.io/badge/dependencies-pandoc%20%7C%20python3%20%7C%20node%20%7C%20vscode-green)

**This is a markdown setup demonstrating the power and use of markdown for technical documents:**

- **fully automated conversion sequence** using [`yarn`](https://github.com/yarnpkg/yarn) + [`gulp`](https://github.com/gulpjs/gulp) + [`pandoc`](https://github.com/jgm/pandoc) such that exporting ([Content.md](https://raw.githubusercontent.com/gabyx/TechnicalMarkdown/master/Content.md)) is done in the background:

    - **export to PDF** with `pandoc` to `xelatex` using `latexmk` [See Output](Content.pdf)
    - **export to HTML** with `pandoc` to `html` [See Output](https://gabyx.github.io/TechnicalMarkdown/Content.html)
    - [todo] **export to PDF** with `pandoc` to `html` then to `chrome` with `pupeteer`

- **[pandoc filters](https://pandoc.org/filters.html)** for different AST (abstract syntax tree) conversions:

    - [own filters](https://github.com/gabyx/TechnicalMarkdown/tree/master/convert/pandoc/filters) with [panflute](https://github.com/sergiocorreia/panflute) [[doc](http://scorreia.com/software/panflute)]
    - [--crosscite](https://github.com/jgm/pandoc-citeproc) [[doc](https://github.com/jgm/pandoc-citeproc/blob/master/man/pandoc-citeproc.1.md)] for citing
    - [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref) [[doc](http://lierdakil.github.io/pandoc-crossref)] for cross referencing
    - [pandoc-include-files](https://github.com/pandoc/lua-filters/tree/master/include-files) [[doc](https://github.com/pandoc/lua-filters/tree/master/include-files/README.md)] for file transclusion

**Future Warning:**
The `master` branch is a `pandoc`-only solution, because its more reliable.
Markdown Preview Enhanced is nice but sadly a bit a to much cumbersome to control blackbox and also a bit slow.
This old solution is still available at commit `13856d37030483679`.


# Dependencies

## Node

Install all **local** Node.js dependencies with [yarn](https://classic.yarnpkg.com/en/docs/install):

```shell
git clone https://github.com/gabyx/TechnicalMarkdown.git
cd TechnicalMarkdown
yarn install
```

## Pandoc

Install [pandoc](https://pandoc.org/installing.html) (>= 2.9.2.1)

For **Linux** and **macOs**:

```shell
export HOMEBREW_NO_INSTALL_CLEANUP=1
cd Homebrew/Library/Taps/homebrew/homebrew-core &&
    git checkout 36b6c2d8cd71580a4fd3055375f87a8c52cd5846~20 && # installs 2.9.2.1
    HOMEBREW_NO_AUTO_UPDATE=1 brew install pandoc pandoc-citeproc pandoc-crossref &&
    brew install pandoc pandoc-citeproc pandoc-crossref # installs 2.10.1
```

For **Windows**

```shell
choco install pandoc
git clone https://github.com/gabyx/chocolatey-packages.git@patch-1 temp
cd temp && choco install ./pandoc-crossref/pandoc-crossref.nuspec
```

## Python

Install a recent `python3` (>= 3.6) and the following packages

```shell
pip3 install -r .requirements
```

To make the preview tab **work** make sure that you start VS Code with a variable environment
`PATH` which contains the python executable **you want to use**
(the best is to use a seperate `python venv`) since `pandoc`
is called by the [extension](https://github.com/shd101wyy/vscode-markdown-preview-enhanced)
inside the VS Code process. Example:

```bash
# Activate your python env.
source ~/.env/myPython3.8Env/activate
# Start code
cd TechnicalMarkdown && code -n .
```

You can also use the ignored [.envrc](.envrc) file with [direnv](https://github.com/direnv/direnv).

The VS Code tasks **dont have this caveat**, since we inject the `${config:python.pythonPath}`
directly and modify the environement.

# Building and Viewing

Normally the use of the [Markdown Preview Enhanced](https://github.com/shd101wyy/vscode-markdown-preview-enhanced)
is for simple previewing.
However, we use priorily **only** the pandoc pipeline for the conversion as it is the most powerful and most customizable and well testet tool for markdown conversion. All the conversion is done in the background continuously:

Run the following tasks defined in [tasks.json](.vscode/tasks.json) from VS Code or use the following shell commands:

- **Start Markdown Browser Sync**: Serves the HTML for preview in a browser with autoreload.

    ```shell
    yarn show
    ```

- **Start Markdown HTML Conversion**: Runs the markdown conversion with
  [MPE](https://github.com/shd101wyy/mume) continuously while monitoring changes to markdown `.md` files:

    ```shell
    yarn build:html
    ```

- **Start Markdown Chrome Conversion**: Runs the markdown conversion with Chrome continuously while monitoring input files:

    ```shell
    yarn build:pdf-chrome
    ```

- **Start Markdown Pandoc Conversion**: Runs the markdown conversion with Pandoc
  (`latexmk` and `xelatex`) continuously while monitoring input files:

    ```shell
    yarn build:pdf-tex
    ```

    The conversion with pandoc applies the following filters (see [defaults](convert/pandoc/defaults/pandoc-filters.yaml)):

    1. [pandoc-include-files-set-format.lua](convert/pandoc/filters/pandoc-include-files-set-format.lua)
    2. [pandoc-include-files.lua](convert/pandoc/filters/pandoc-include-files.lua)
    3. [transformMath.py](convert/pandoc/filters/transformMath.py)
    4. [pandoc-crossref](convert/pandoc/filters/pandoc-crossref)
    5. [pandoc-citeproc](convert/pandoc/filters/pandoc-citeproc)
    6. [transformImages.py](convert/pandoc/filters/transformImages.py)

    The latex output can be inspected in `output-tex/input.tex`.

# Editing Styles

You can edit the [main.less](css/src/main.less) file to change the look of the markdown.
Edit the [main.less](css/src/main.less) file to see changes in the conversion from [Content.md](Content.md).

# Debugging

There is a debug configuration in [launch.json](.vscode/launch.json) for both the HTML and the PDF export.

## Pandoc Filters

Pandoc filters are harder to debug. There is an included unix-like [tee.py](convert/pandoc/filters/tee.py) filter
which can be put anywhere into the filter chain as needed, to see the output in `pandoc/filter-out`
(see [dev.py](convert/pandoc/filters/module/dev.py) for adjustments). The filter [teeStart.py](convert/pandoc/filters/teeStart.py)
first clears all output before doing the same as [tee.py](convert/pandoc/filters/tee.py).
Uncomment the `tee.py` filters in [pandoc-filters.yaml](convert/pandoc/defaults/pandoc-filters.yaml).

# Issues

### Panflute [done]
Using pandoc `>=2.10` we have more types and AST changes in

- [jgm/pandoc#1024](https://github.com/jgm/pandoc/issues/1024),
- [jgm/pandoc#6277](https://github.com/jgm/pandoc/pull/6277),
- [2.10](https://github.com/jgm/pandoc/releases/tag/2.10)

meaning that also the python library `panflute` needs to be supporting this:

- [Issue](https://github.com/sergiocorreia/panflute/issues/142) : ![](https://img.shields.io/badge/dynamic/json?color=%23FF0000&label=Status&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fsergiocorreia%2Fpanflute%2Fissues%2F142)


## Transclude: Relative file paths
So far *relative* paths are not yet supported in `pandoc-indluce-files.lua` filter.

- [Issue](https://github.com/pandoc/lua-filters/issues/102) : ![Status](https://img.shields.io/badge/dynamic/json?color=%23FF0000&label=Status&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fpandoc%2Flua-filters%2Fissues%2F102)


# Todo

- Add CI
- Add tests
