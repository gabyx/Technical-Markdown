# Markdown Setup for Technical Documents

This is a markdown setup demonstrating the power and use of markdown for **technical documents**:

- using `yarn`+ `gulp` for a **fully automated conversion** sequence such that exporting is done in the background.
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

Run the following commands in `.vscode/tasks.json` in VS Code or use the following shell commands:
- **Start Markdown Conversion**: Runs the markdown conversion with [MPE](https://github.com/shd101wyy/mume) continuously while monitoring changes to `.less` style files and markdown `.md` files:
    ```shell
    yarv build
    ```

- **Start Markdown Browser Sync**: Serves the HTML for preview in a browser with autoreload.
    ```shell
    yarn show
    ```

# Editing Styles
You can edit the `css/src/main.less` file to change the look of the markdown.
Edit the `main.less` file to see changes in `Content.md`.