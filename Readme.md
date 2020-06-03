# Markdown Setup for Technical Documents

![](https://img.shields.io/badge/dependencies-pandoc%20%7C%20python3%20%7C%20node%20%7C%20vscode-green)

This is a markdown setup demonstrating the power and use of markdown for **technical documents**:

- using `yarn`+ `gulp` for a **fully automated conversion** sequence such that exporting ([Content.md](https://raw.githubusercontent.com/gabyx/TechnicalMarkdown/master/Content.md)) is done in the background:

    - export to **PDF** with `pandoc` to `html` then to `chrome`
    - export to **PDF** with `pandoc` to `latexmk` using `xelatex` [See Output](Content.pdf)
    - export to **HTML** with `pandoc` to `html` [See Output](https://gabyx.github.io/TechnicalMarkdown/Content.html)

    with [Markdown Preview Enhanced Engine](https://github.com/shd101wyy/mume).

- previewing in VS Code with [Markdown Preview Enhanced](https://github.com/shd101wyy/vscode-markdown-preview-enhanced).

- Using the following [pandoc filters](https://pandoc.org/filters.html):

    - 2 own filters with [panflute](https://github.com/sergiocorreia/panflute) [[doc](http://scorreia.com/software/panflute)]
    - [pandoc-crosscite](https://github.com/jgm/pandoc-citeproc) [[doc](https://github.com/jgm/pandoc-citeproc/blob/master/man/pandoc-citeproc.1.md)]
    - [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref) [[doc](http://lierdakil.github.io/pandoc-crossref)]

# Dependencies

## Yarn

Install all **local** Node.js dependencies with [yarn](https://classic.yarnpkg.com/en/docs/install):

```shell
git clone https://github.com/gabyx/TechnicalMarkdown.git
cd TechnicalMarkdown
yarn
```

## Pandoc

Install [pandoc](https://pandoc.org/installing.html) [Version >= 2.9.2.1]

For **Linux** and **macOs**:

```shell
brew install pandoc pandoc-citeproc pandoc-crossref
```

For **Windows**

```shell
choco install pandoc
git clone https://github.com/gabyx/chocolatey-packages.git@patch-1 temp
cd temp && choco install ./pandoc-crossref/pandoc-crossref.nuspec
```

## Python

Install a recent `python` [Version >= 3.6] and the following packages

```shell
pip install -r .requirements
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

The VS Code Tasks **dont have this caveat**, since we inject the `${config:python.pythonPath}`
directly and modify the environement.

# Building and Viewing

Normally the use of the [Markdown Preview Enhanced](https://github.com/shd101wyy/vscode-markdown-preview-enhanced)
extension with an opened preview panel works well and is nice for previewing.
However, complex includes do not retrigger an autoreload and complex conversions
should take place in the background continuously anyway:

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

- **Start Markdown Chrome Conversion**: Runs the markdown conversion with Chrome
  over [MPE](https://github.com/shd101wyy/mume) continuously while monitoring changes to markdown `.md` files:

    ```shell
    yarn build:pdf-chrome
    ```

- **Start Markdown Pandoc Conversion**: Runs the markdown conversion with Pandoc
  (`latexmk` and `xelatex`) over [MPE](https://github.com/shd101wyy/mume) continuously while monitoring markdown `.md` files:

    ```shell
    yarn build:pdf-tex
    ```

    The conversion with pandoc applies two filters:

    - [transformMath.py](convert/pandoc/filters/transformMath.py): Transform all math expressions.
    - [transformImages.py](convert/pandoc/filters/transformImages.py): Transforms all HTML images.

    The latex output can be inspected in `output-tex/input.tex`.

# Editing Styles

You can edit the [main.less](css/src/main.less) file to change the look of the markdown.
Edit the [main.less](css/src/main.less) file to see changes in the conversion from [Content.md](Content.md)`.

# Engine Configs

The config path for the [engine](https://github.com/shd101wyy/mume) is [pandoc](convert/pandoc) . See [convert.js](convert/convert.js).

# Debugging

There is a debug configuration in [launch.json](.vscode/launch.json) for both the HTML and the PDF export.

## Pandoc Filters

Pandoc filters are harder to debug. There is an included unix-like [tee.py](convert/pandoc/filters/tee.py) filter
which can be put anywhere into the filter chain as needed, to see the output in `pandoc/filter-out`
(see [dev.py](convert/pandoc/filters/module/dev.py) for adjustments). The filter [teeStart.py](convert/pandoc/filters/teeStart.py)
first clears all output before doing the same as [tee.py](convert/pandoc/filters/tee.py).
Uncomment the `tee.py` filters in [pandoc-filters.yaml](convert/pandoc/defaults/pandoc-filters.yaml).

# Todo

- Customize scaling of images for latex and html output inside the pandoc filter
- Add CI
- Add tests
