# TechnicalMarkdown
### A [markdown setup for technical documents](https://gabyx.github.io/TechnicalMarkdown), reports, theses & papers.

![](https://img.shields.io/badge/dependencies-pandoc%20%7C%20python3%20%7C%20gradle%20%7C%20vscode-green)

## Quick Intro

**This is a markdown setup demonstrating the power and use of markdown for technical documents:**

- **fully automated conversion sequence** using [`gradle`](https://gradle.org) + [`pandoc`](https://github.com/jgm/pandoc) such that exporting ([Content.md](https://raw.githubusercontent.com/gabyx/TechnicalMarkdown/master/Content.md)) is done in the background:

  - **export to PDF** with `pandoc` to `xelatex` using `latexmk` [See Output](Content.pdf)
  - **export to HTML** with `pandoc` to `html` [See Output](https://gabyx.github.io/TechnicalMarkdown/Content.html)
  - [todo] **export to PDF** with `pandoc` to `html` then to `chrome` with `pupeteer`

- **[pandoc filters](https://pandoc.org/filters.html)** for different AST (abstract syntax tree) conversions:

  - [own filters](https://github.com/gabyx/TechnicalMarkdown/tree/master/convert/pandoc/filters) with [panflute](https://github.com/sergiocorreia/panflute) [[doc](http://scorreia.com/software/panflute)]
  - [--crosscite](https://github.com/jgm/pandoc-citeproc) [[doc](https://github.com/jgm/pandoc-citeproc/blob/master/man/pandoc-citeproc.1.md)] for citing
  - [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref) [[doc](http://lierdakil.github.io/pandoc-crossref)] for cross referencing
  - [pandoc-include-files](https://github.com/pandoc/lua-filters/tree/master/include-files) [[doc](https://github.com/pandoc/lua-filters/tree/master/include-files/README.md)] for file transclusion

- Full-fledged [VS Code](https://code.visualstudio.com/) setup to write and style your document in one of the best IDEs.

## Quick-Start

Execute the following in a shell:

```shell
./gradlew -t build-html
```

This will build the HTML output from its [markdown main file](Content.md).

## Rational

[Pandoc](https://github.com/jgm/pandoc) is awesome and the founder John MacFarlane develops pandoc in a meticulous and principled style.
The documentation is pretty flawless and the community (including him) is really helpful. That is why we rely heavily on pandoc.

1. We target the output formats `html5` and `latex`, because

    - HTML can be viewed in all browsers and web standards such as CSS3 etc.
        have become a major advantage and enables ridiculuous dynamic, interactive styling.
        Collapsable table of contents is just the beginning.
    - LaTeX enables to produce high quality output PDF (`xelatex`).
        Every proper book and distributed PDF is written and set in LaTeX.

2. The orchestration around calling `pandoc` is basically only a file watcher [`gradle`](https://gradle.org)
  which calls `pandoc` on file changes. We want as little as possible different tools to achieve the above output formats.
  That also means we *do not want* to have lots of pre- and post-processing tasks aside from running `pandoc`.
  The main goal is, that users can write `markdown` as a **first-party solution** with some enhanced features enabled by `pandoc` itself.
  **Writting technical documents should become a breeze.**

3. The common agreement in the industry about using M$ Office for writting technical
   documentations as demonstrated here, is considered the most
   complete and utter bullshit you can adhere to.
   Certainly employees mostly must obey. The common argument is "people need to exchange
   documents and work on it".
   Because people need to focus on the utter shitty formatting and WYSIWYG workaround
   experiences, a lot of time and money is spent which gets never debated.

   **It's about high time** to turn into a direction which will likely become the standard.
   **Technical writters should really focus on the content they write and not focus on styling quirks and tricks.**

4. Every technical document writter probably knows about source code management (`git`).
   There you go with proper team work.

## Dependencies

### Gradle

For the Gradle build tool you need a working [Java runtime](https://java.com). On Linux and macOS you can do:

```shell
brew install java
```

You should not need to install Gradle, since everything is setup by the checked-in `gradlew` Gradle wrapper.

### Yarn

You should not need to install ``yarn`` since everything is handled by the dependent Gradle task `installFrontend`. If you experience problems with having the node modules not correctly setup, use

```
cd tools
../build/yarn/bin/yarn install --modules-path build/node_modules
```

### Pandoc

Install [pandoc](https://pandoc.org/installing.html) (>= 2.9.2.1, tested with 2.11.0.4)

For **Linux** and **macOs**:

```shell
brew install pandoc pandoc-crossref
```

For **Windows**:

```shell
choco install pandoc
```

### Python

Install a recent `python3` (>= 3.6) and the following packages:

```shell
pip3 install -r tools/.requirements
```

The best way is to setup a python environment `python venv` since `pandoc`. The VS Code config `python.pythonPath` path needs to be set.

The VS Code tasks get the `${config:python.pythonPath}`
directly as an argument and modify the environement and `pandoc` will use the right python when launching the filters.

You can also start VS Code like this to have the proper `python` enabled:

```bash
# Activate your python env.
source ~/.env/myPython3.8Env/activate
# Start code
cd TechnicalMarkdown && code -n .
```

You can also use the ignored [.envrc](.envrc) file with [direnv](https://github.com/direnv/direnv).

## Building and Viewing

Run the following tasks defined in [tasks.json](.vscode/tasks.json) from VS Code or use the following shell commands:

- **Show HTML Output**: Serves the HTML for preview in a browser with autoreload:

    ```shell
    ./gradlew -t view-html
    ```

- **Convert Markdown -> HTML**: Runs the markdown conversion with Pandoc
  (`html`) continuously:

    ```shell
    ./gradlew -t build-html
    ```

    - The conversion with pandoc applies the following filters in
      [defaults](convert/pandoc/defaults/pandoc-filters.yaml).
    - The HTML output can be inspected in `Content.html`.

- **Convert Markdown -> PDF**: Runs the markdown conversion with Pandoc
  (`latexmk` and `xelatex`) continuously:

    ```shell
    ./gradlew -t build-pdf-tex
    ```

    - The conversion with pandoc applies the following filters in
      [defaults](convert/pandoc/defaults/pandoc-filters.yaml).
    - The PDF output can be inspected in `Content.pdf`.
    - The LaTeX output can be inspected in `build/output-tex/input.tex`.

- **Convert Markdown -> Jira**: Runs the markdown conversion to Jira (experimental) with Pandoc
  continuously:

    ```shell
    ./gradlew -t build-jira
    ```

    - The conversion with pandoc applies the following filters in
      [defaults](convert/pandoc/defaults/pandoc-filters.yaml).
    - The Jira output can be inspected in `Content.jira`.

## Editing Styles

### HTML
You can edit the [main.less](convert/css/src/main.less) file to change the look of the markdown.
Edit the [main.less](convert/css/src/main.less) file to see changes in the conversion from [Content.md](Content.md).

### LaTeX

The following templates are responsible for the LaTeX output:

- [Template.tex](convert/pandoc/includes/Template.tex) : The main template.
- [Header.tex](convert/pandoc/includes/Header.tex)  : The class, packages and styles defining the document, included by the main template with `include-in-header` in [pandoc-latex.yaml](convert/pandoc/defaults/pandoc-latex.yaml)

## Debugging

There is a debug configuration in [launch.json](.vscode/launch.json) for both the HTML and the PDF export.

### Pandoc Filters

Pandoc filters are harder to debug. There is an included unix-like [tee.py](convert/pandoc/filters/tee.py) filter
which can be put anywhere into the filter chain as needed, to see the AST JSON output in the folder `build/pandoc-filter-out`
(see [dev.py](convert/pandoc/filters/module/dev.py) for adjustments). The filter [teeStart.py](convert/pandoc/filters/teeStart.py)
first clears all output before doing the same as [tee.py](convert/pandoc/filters/tee.py).
Uncomment the `tee.py` filters in [pandoc-filters.yaml](convert/pandoc/defaults/pandoc-filters.yaml).

## Issues

### Panflute [done]

Using pandoc `>=2.10` we have more types and AST changes in

- [jgm/pandoc#1024](https://github.com/jgm/pandoc/issues/1024),
- [jgm/pandoc#6277](https://github.com/jgm/pandoc/pull/6277),
- [2.10](https://github.com/jgm/pandoc/releases/tag/2.10)

meaning that also the python library `panflute` needs to be supporting this:

- [Issue](https://github.com/sergiocorreia/panflute/issues/142) : ![](https://img.shields.io/badge/dynamic/json?color=%23FF0000&label=Status&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fsergiocorreia%2Fpanflute%2Fissues%2F142)

### Transclude: Relative file paths

So far *relative* paths are not yet supported in `pandoc-indluce-files.lua` filter.

- [Issue](https://github.com/pandoc/lua-filters/issues/102) : ![Status](https://img.shields.io/badge/dynamic/json?color=%23FF0000&label=Status&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fpandoc%2Flua-filters%2Fissues%2F102)

### Table Issues

- Wrong format for `latex`: [Issue](https://github.com/jgm/pandoc/issues/6883) : ![Status](https://img.shields.io/badge/dynamic/json?color=%23FF0000&label=Status&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fjgm%2Fpandoc%2Fissues%2F6883) -> Update to next version.

## Todo

- Add CI.
- Add tests.
- Add prince conversion to PDF.

## Support & Donation

When you use Githooks and you would like to say thank you for its development and its future maintenance:
I am happy to receive any donation:

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6S6BJL4GSMSG4)

