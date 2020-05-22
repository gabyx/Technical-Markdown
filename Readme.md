# Markdown Setup for Technical Documents

This is a markdown setup demonstrating the power and use of markdown for **technical documents**:

- using `yarn`+ `gulp` for a **fully automated conversion** sequence such that exporting is done in the background:

    - export with `chrome`
    - export with `pandoc` to `xelatex`
    - to `html`

    with [Markdown Preview Enhanced Engine](https://github.com/shd101wyy/mume).
- previewing in VS Code with [Markdown Preview Enhanced](https://shd101wyy.github.io/markdown-preview-enhanced).


**See live demo here [Content.html](https://gabyx.github.io/TechnicalMarkdown/Content.html)**

# Dependencies
Install all dependencies with [yarn](https://www.yarnjs.com/get-yarn):
```shell
git clone https://github.com/gabyx/TechnicalMarkdown.git
cd TechnicalMarkdown
yarn
```

# Building and Viewing

Normally one would use the [Markdown Preview Enhanced](https://shd101wyy.github.io/markdown-preview-enhanced) extension and just open the preview panel which works and is nice for previewing. However, complex includes do not retrigger an autoreload and complex conversions should take place in the background continuously anyway:

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

- **Start Markdown Pandoc Conversion**: Runs the markdown conversion with Pandoc (`xelatex`) over [MPE](https://github.com/shd101wyy/mume) continuously while monitoring markdown `.md` files:

    ```shell
    yarn build:pandoc
    ```

    The conversion does not yet produce a descent output because the image includes with `<div>` still need to be transformed first.
    Parser adjustments have been made in `convert/pandoc/parser.js` to transform math expressions.
    **Note**: Install the latest [pandoc release](https://github.com/jgm/pandoc/releases).

# Editing Styles
You can edit the `css/src/main.less` file to change the look of the markdown.
Edit the `main.less` file to see changes in `Content.md`.

# Engine Configs
The config path for the [engine](https://github.com/shd101wyy/mume) is adjusted for the different exports. See `convert/convert.js` and the paths:

- `convert/html`
- `convert/pandoc` 