const fs = require("fs");
const which = require("which");
const yargs = require("yargs");
const env = require("gulp-env");
const path = require("path");
const gulp = require("gulp");
const less = require("gulp-less");
const rename = require("gulp-rename");
const replace = require("gulp-replace");
const markdown = require("./convert/convert");
const browserSync = require("browser-sync").create();
const { execFile } = require("child_process");
const reload = browserSync.reload;

let parsedArgs = null;

async function parseArguments() {
    if (parsedArgs) {
        // Already parsed
        return;
    }

    let args = yargs
        .option("p", {
            alias: "pythonPath",
            type: "string",
            describe: "The path to your python executable.",
            demandOption: true
        })
        .coerce("pythonPath", function (p) {
            p.strip;
            if (!fs.existsSync(p)) {
                m = `Python path does not exists: ${p}`;
                console.error(m);
                throw m;
            }
            return p;
        })
        .option("e", {
            alias: "pandocPath",
            type: "string",
            describe: "The path to your pandoc executable.",
            demandOption: true
        })
        .coerce("pandocPath", function (p) {
            p.strip;
            if (!fs.existsSync(p)) {
                m = `Pandoc path does not exists: ${p}`;
                console.error(m);
                throw m;
            }
            return p;
        }).argv;

    // Add python dir to path
    paths = [];

    let pythonDir = null;
    if (args.pythonPath) {
        pythonDir = path.dirname(args.pythonPath);
        console.log(`Setting python path ${pythonDir}`);
        paths.push(pythonDir);
    }

    let pandocDir = null;
    if (args.pandocPath) {
        pandocDir = path.dirname(args.pandocPath);
        console.log(`Setting pandoc path ${pandocDir}`);
        paths.push(pythonDir);
    }

    paths.push(process.env.PATH);
    env.set({
        PATH: paths.join(path.delimiter)
    });

    // Check if the needed executables are found
    [
        ["python", pythonDir],
        ["pandoc", pandocDir]
    ].forEach((executable) => {
        const p = which.sync(executable[0], { nothrow: true });
        if (p) {
            if (executable[1] && !p.includes(executable[1])) {
                throw `Executable '${executable[0]}' not found in path '${executable[1]}'`;
            }
            args[`${executable[0]}` + "Path"] = p;
            console.log(`Found '${executable[0]}' : '${p}'`);
        } else {
            console.error("You need '${executable[0]}' in your path!");
            console.errer(process.env.PATH);
            process.exit(1);
        }
    });

    // Set as parsed
    parsedArgs = args;
}

async function runPandoc(args) {
    if (!parsedArgs || !parsedArgs["pandocPath"]) {
        throw Error("Arguments not parsed!");
    }

    return new Promise((resolve, reject) => {
        try {
            const program = execFile(
                parsedArgs["pandocPath"],
                args,
                { cwd: process.cwd() },
                (error, stdout, stderr) => {
                    console.log(stdout);

                    if (error) {
                        return reject(error);
                    } else if (stderr) {
                        return reject(new Error(`Pandoc error: ${stderr}`));
                    } else {
                        return resolve();
                    }
                }
            );
        } catch (error) {
            return reject(`Executable '${parsedArgs["pandocPath"]}' could not be started: '${error.toString()}'`);
        }
    });
}

async function htmlExport(markdownFile, outFile) {
    await runPandoc([
        "--fail-if-warnings",
        "--verbose",
        "--data-dir=convert/pandoc",
        "--defaults=pandoc-dirs.yaml",
        "--defaults=pandoc-html.yaml",
        "--filter",
        "set-include-format.lua"
        "--defaults=pandoc-filters.yaml",
        "-o",
        outFile,
        markdownFile,
    ]);
}

async function latexExport(markdownFile, outFile) {
    await runPandoc([
        "--fail-if-warnings",
        "--verbose",
        "--data-dir=convert/pandoc",
        "--defaults=pandoc-dirs.yaml",
        "--defaults=pandoc-latex.yaml",
        "--defaults=pandoc-filters.yaml",
        "-o",
        outFile,
        markdownFile
    ]);
}

gulp.task("parse-args", async function () {
    await parseArguments();
});

/* Task to compile less */
gulp.task("compile-less", async function () {
    return gulp.src("css/src/main.less").pipe(less()).pipe(gulp.dest("./css"));
});

/* Task to compile all markdown files */
gulp.task("compile-markdown-html", async function () {
    await htmlExport(path.resolve("Content.md"), "Content.html");
});

/* Task to compile all markdown files */
gulp.task("compile-markdown-tex", async function () {
    await latexExport(path.resolve("Content.md"), "Content.pdf");
});

/* Task to compile all markdown files */
gulp.task("transform-math", async function () {
    const re = /.*\$\$\s+(.+)\$\$.*/gms;
    return gulp
        .src(["includes/Math.md"])
        .pipe(rename("includes/Math.tex"))
        .pipe(replace(re, "$1"))
        .pipe(gulp.dest("convert/pandoc"));
});

const exportTriggerFiles = ["**/*.md", "literature/**/*", "files/**/*", "includes/**/*"];
const lessFiles = ["css/src/*", "css/fonts/*"];

/* Task to watch all markdown files */
gulp.task("watch-markdown-html", async function () {
    gulp.watch(
        [...exportTriggerFiles, ...lessFiles],
        gulp.series(["parse-args", "compile-less", "compile-markdown-html"])
    );
});

/* Task to watch all markdown files */
gulp.task("watch-markdown-latex", async function () {
    gulp.watch(exportTriggerFiles, gulp.series(["parse-args", "transform-math", "compile-markdown-tex"]));
});

/* Task when running `gulp` from terminal */
gulp.task("build-html", gulp.parallel(["watch-markdown-html"]));

/* Task when running `gulp` from terminal */
gulp.task("build-pdf-tex", gulp.parallel(["watch-markdown-latex"]));

gulp.task("show-markdown", function () {
    browserSync.init({
        server: {
            baseDir: "./",
            index: "Content.html"
        }
    });
    gulp.watch("**/*.html").on("change", reload);
});
