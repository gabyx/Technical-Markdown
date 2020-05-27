# Markdown Setup for Technical Documents

This is a markdown setup demonstrating the power and use of markdown for **technical documents**:

- using `yarn`+ `gulp` for a **fully automated conversion** sequence such that exporting is done in the background:

    - export with `pandoc` to `html` then to `chrome`
    - export with `pandoc` to `latexmk` using `xelatex`
    - export with `pandoc` to `html`

    with [Markdown Preview Enhanced Engine](https://github.com/shd101wyy/mume).
- previewing in VS Code with [Markdown Preview Enhanced](https://github.com/shd101wyy/vscode-markdown-preview-enhanced).

- Using the following [pandoc filters](https://pandoc.org/filters.html):
    - [panflute](https://github.com/sergiocorreia/panflute) [doc](http://scorreia.com/software/panflute)
    - [pandoc-crosscite](https://github.com/jgm/pandoc-citeproc) [doc](https://github.com/jgm/pandoc-citeproc/blob/master/man/pandoc-citeproc.1.md)
    - [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref) [doc](http://lierdakil.github.io/pandoc-crossref)

**See live demo here [Content.html](https://gabyx.github.io/TechnicalMarkdown/Content.html)**

# Dependencies
Install all dependencies with [yarn](https://www.yarnjs.com/get-yarn):

```shell
git clone https://github.com/gabyx/TechnicalMarkdown.git
cd TechnicalMarkdown
yarn
```

Install [pandoc](https://pandoc.org/installing.html):
For Linux and macOs:
```shell
brew install pandoc pandoc-citeproc pandoc-crossref
```

Install a recent `python` and the following packages 

```shell
pip install -r .requirements
```

# Building and Viewing
Normally the use of the [Markdown Preview Enhanced](https://shd101wyy.github.io/markdown-preview-enhanced) extension with an opened preview panel works well and is nice for previewing. However, complex includes do not retrigger an autoreload and complex conversions should take place in the background continuously anyway:

Run the following tasks defined in `.vscode/tasks.json` from VS Code or use the following shell commands:
- **Start Markdown HTML Conversion**: Runs the markdown conversion with [MPE](https://github.com/shd101wyy/mume) continuously while monitoring changes to markdown `.md` files:
    ```shell
    yarn build:html
    ```
- **Start Markdown Browser Sync**: Serves the HTML for preview in a browser with autoreload.

    ```shell
    yarn show
    ```
- **Start Markdown Chrome Conversion**: Runs the markdown conversion with Chrome over [MPE](https://github.com/shd101wyy/mume) continuously while monitoring changes to markdown `.md` files:

    ```shell
    yarn build:chrome
    ```

- **Start Markdown Pandoc Conversion**: Runs the markdown conversion with Pandoc (`latexmk` and `xelatex`) over [MPE](https://github.com/shd101wyy/mume) continuously while monitoring markdown `.md` files:

    ```shell
    yarn build:pandoc
    ```

    The conversion with pandoc applies two filters:
    - `convert/pandoc/filters/transformMath.py`: Transform all math expressions.
    - `convert/pandoc/filters/transformImages.py`: Transforms all HTML images.

    **Note**: Install the latest [pandoc release](https://github.com/jgm/pandoc/releases).

# Editing Styles
You can edit the `css/src/main.less` file to change the look of the markdown.
Edit the `main.less` file to see changes in the conversion from `Content.md`.

# Engine Configs
The config path for the [engine](https://github.com/shd101wyy/mume) is `convert/pandoc` . See `convert/convert.js`.

# Debugging
There is a debug configuration in `.vscode/launch.json` for both the HTML and the PDF export.

## Pandoc Filters
Pandoc filters are harder to debug. There is an included unix-like `convert/pandoc/filters/tee.py` filter which can be put anywhere into the filter chain as needed, to see the output in `pandoc/filter-out` (see `pandoc/filters/module/dev.py` for adjustments).
The filter `convert/pandoc/filters/teeStart.py` first clears all output before doing the same as `tee.py`. 

# Todo
- Correct scaling of images for latex and html output.