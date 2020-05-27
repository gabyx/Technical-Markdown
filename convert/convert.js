const path = require("path");
const mume = require("@shd101wyy/mume");

function getConfigPathHtml() {
    return path.resolve("./convert/html"); // use here your own config folder, default is "~/.mume"
}

function getConfigPathPandoc() {
    return path.resolve("./convert/pandoc"); // use here your own config folder, default is "~/.mume"
}

async function createEngine(configPath, file) {
    await mume.init(configPath); // default uses "~/.mume"

    const config = {
        configPath: configPath,

        // Enable this option will render markdown by pandoc instead of markdown-it.
        usePandocParser: false,

        // In Markdown, a single newline character doesn't cause a line break in the generated HTML. In GitHub Flavored Markdown, that is not true. Enable this config option to insert line breaks in rendered HTML for single newlines in Markdown source.
        breakOnSingleNewLine: false,

        // Enable smartypants and other sweet transforms.
        enableTypographer: false,

        // Enable conversion of URL-like text to links in the markdown preview.
        enableLinkify: true,

        // Math
        mathRenderingOption: "MathJax", // "KaTeX" | "MathJax" | "None"
        mathInlineDelimiters: [
            ["\\(", "\\)"],
            ["$", "$"]
        ],
        mathBlockDelimiters: [
            ["\\[", "\\]"],
            ["$$", "$$"]
        ],
        mathRenderingOnLineService: "https://latex.codecogs.com/gif.latex", // "https://latex.codecogs.com/svg.latex", "https://latex.codecogs.com/png.latex"

        // Enable Wiki Link syntax support. More information can be found a  https://help.github.com/articles/adding-links-to-wikis/
        enableWikiLinkSyntax: true,
        // By default, the extension for wikilink is `.md`. For example: [[test]] will direct to file path `test.md`.
        wikiLinkFileExtension: ".md",

        // Enable emoji & font-awesome plugin. This only works for markdown-it parser, but not pandoc parser.
        enableEmojiSyntax: true,

        // Enable extended table syntax to support merging table cells.
        enableExtendedTableSyntax: false,

        // Enable CriticMarkup syntax. Only works with markdown-it parser.
        // Please check http://criticmarkup.com/users-guide.php for more information.
        enableCriticMarkupSyntax: false,

        // Front matter rendering option
        frontMatterRenderingOption: "none", // 'none' | 'table' | 'code block'

        // Mermaid theme
        mermaidTheme: "mermaid.css", // 'mermaid.css' | 'mermaid.dark.css' | 'mermaid.forest.css'

        // Code Block theme
        // If `auto.css` is chosen, then the code block theme that best matches the current preview theme will be picked.
        codeBlockTheme: "dark.css",

        // Preview theme
        previewTheme: "none.css",

        // Revealjs presentation theme
        revealjsTheme: "none.css",
 
        // Accepted protocols for links.
        protocolsWhiteList:
            "http://, https://, atom://, file://, mailto:, tel:",

        // When using Image Helper to copy images, by default images will be copied to root image folder path '/assets'
        imageFolderPath: "/files",

        // Whether to print background for file export or not. If set to `false`, then `github-light` preview theme will b  used. You can also set `print_background` in front-matter for individual files.
        printBackground: false,

        // Chrome executable path, which is used for Puppeteer export. Leaving it empty means the path will be found automatically.
        chromePath: "",

        // ImageMagick command line path. Should be either `magick` or `convert`. Leaving it empty means the path will be found automatically.
        imageMagickPath: "",

        // Pandoc executable path
        pandocPath: "pandoc",

        // Pandoc markdown flavor
        pandocMarkdownFlavor: "markdown-raw_tex+tex_math_dollar",

        // Pandoc arguments e.g. ['--smart', '--filter=/bin/exe']. Please use long argument names.
        pandocArguments: [],

        // Default latex engine for Pandoc export and latex code chunk.
        latexEngine: "pdflatex",

        // Enables executing code chunks and importing javascript files.
        // ⚠ ️ Please use this feature with caution because it may put your security at risk!
        //    Your machine can get hacked if someone makes you open a markdown with malicious code while script execution is enabled.
        enableScriptExecution: true,

        // Enables transform audio video link to to html5 embed audio video tags.
        // Internally it enables markdown-it-html5-embed plugins.
        enableHTML5Embed: true,

        // Enables video/audio embed with ![]() syntax (default).
        HTML5EmbedUseImageSyntax: true,

        // Enables video/audio embed with []() syntax.
        HTML5EmbedUseLinkSyntax: false,

        // When true embed media with http:// schema in URLs. When false ignore and don't embed them.
        HTML5EmbedIsAllowedHttp: false,

        // HTML attributes to pass to audio tags.
        HTML5EmbedAudioAttributes: 'controls preload="metadata" width="320"',

        // HTML attributes to pass to video tags.
        HTML5EmbedVideoAttributes:
            'controls preload="metadata" width="320" height="240"',

        // Puppeteer waits for a certain timeout in milliseconds before the document export.
        puppeteerWaitForTimeout: 3000,

        // If set to true, then locally installed puppeteer-core will be required. Otherwise, the puppeteer globally installed by `npm install -g puppeteer` will be required.
        usePuppeteerCore: true
    };

    // Init Engine
    return new mume.MarkdownEngine({
        filePath: file,
        projectDirectoryPath: ".",
        config: config
    });
}

async function htmlExport(file) {
    console.log(`Export ${file} to HTML ...`);
    const configPath = getConfigPathHtml();
    console.log(`Using config dir: ${configPath}`);

    const engine = await createEngine(configPath, file);
    return engine.htmlExport({ offline: false, runAllCodeChunks: true });
}

async function pandocExport(file) {
    console.log(`Export ${file} with Pandoc ...`);
    const configPath = getConfigPathPandoc();
    console.log(`Using config dir: ${configPath}`);

    const engine = await createEngine(configPath, file);
    return engine.pandocExport({ offline: false, runAllCodeChunks: true });
}

async function chromeExport(file) {
    console.log(`Export ${file} with Chrome ...`);
    const configPath = getConfigPathHtml();
    console.log(`Using config dir: ${configPath}`);

    const engine = await createEngine(configPath, file);
    return engine.chromeExport({ offline: false, runAllCodeChunks: true });
}

exports.htmlExport = htmlExport;
exports.pandocExport = pandocExport;
exports.chromeExport = chromeExport;