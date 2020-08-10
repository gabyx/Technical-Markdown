const fs = require("fs");
const os = require("os");
const which = require("which");
const yargs = require("yargs");
const env = require("gulp-env");
const path = require("path");
const gulp = require("gulp");
const less = require("gulp-less");
const rename = require("gulp-rename");
const replace = require("gulp-replace");
const browserSync = require("browser-sync").create();
const reload = browserSync.reload;
const { spawn } = require("child_process");

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
            console.log(p, typeof p);
            if (!fs.existsSync(p)) {
                m = `Python path does not exists: ${p}`;
                console.error(m);
                throw m;
            }
            return path.normalize(p);
        })
        .option("e", {
            alias: "pandocPath",
            type: "string",
            describe: "The path to your pandoc executable.",
            demandOption: false
        })
        .coerce("pandocPath", function (p) {
            p.strip;
            if (!fs.existsSync(p)) {
                m = `Pandoc path does not exists: ${p}`;
                console.error(m);
                throw m;
            }
            return path.normalize(p);
        }).argv;

    // Add python dir to path
    paths = [];

    var pythonDir = null;
    var pythonExe = os.platform() == "win32" ? "python.exe" : "python";
    if (args.pythonPath) {
        pythonDir = path.dirname(args.pythonPath);
        pythonExe = path.basename(args.pythonPath);
        console.log(`Setting python path ${pythonDir}`);
        paths.push(pythonDir);
    }

    var pandocDir = null;
    var pandocExe = os.platform() == "win32" ? "pandoc.exe" : "pandoc";
    if (args.pandocPath) {
        pandocDir = path.dirname(args.pandocPath);
        pandocExe = path.basename(args.pandocPath);
        console.log(`Setting pandoc path ${pandocDir}`);
        paths.push(pythonDir);
    }

    paths.push(process.env.PATH);
    env.set({
        PATH: paths.join(path.delimiter)
    });

    // Check if the needed executables are found
    [
        ["python", pythonExe, pythonDir],
        ["pandoc", pandocExe, pandocDir]
    ].forEach((el) => {
        let key = el[0];
        let exe = el[1];
        let dir = el[2];
        const p = which.sync(exe, { nothrow: true });
        if (p) {
            if (dir && !p.includes(dir)) {
                throw `Executable '${exe}' not found in path '${dir}'`;
            }
            args[`${key}` + "Path"] = p;
            console.log(`Found '${key}' : '${p}'`);
        } else {
            console.error(`You need '${key}' in your path!`);
            console.errer(process.env.PATH);
            process.exit(1);
        }
    });

    // Set as parsed
    parsedArgs = args;
}

function getFileSizeMb(path) {
    const stats = fs.statSync(path);
    return stats["size"] / 1000000.0;
}

async function runPandoc(args) {
    if (!parsedArgs || !parsedArgs["pandocPath"]) {
        throw Error("Arguments not parsed!");
    }

    return new Promise((resolve, reject) => {
        try {
            const program = spawn(parsedArgs["pandocPath"], args, {
                cwd: process.cwd(),
                stdio: ["ignore", "ignore", "inherit"]
            });

            program.on("close", (code) => {
                if (code > 0) {
                    return reject(new Error(`Pandoc failed: ${code}`));
                } else {
                    console.log(
                        " ======================== \n" + " =  Pandoc successful!  = \n" + " ======================== "
                    );
                    return resolve();
                }
            });
        } catch (error) {
            return reject(
                new Error(`Executable '${parsedArgs["pandocPath"]}' could not be started: '${error.toString()}'`)
            );
        }
    });
}

async function htmlExport(markdownFile, outFile) {
    await runPandoc([
        "--fail-if-warnings",
        "--verbose",
        "--toc",
        "--data-dir=convert/pandoc",
        "--defaults=pandoc-dirs.yaml",
        "--defaults=pandoc-html.yaml",
        "--defaults=pandoc-filters.yaml",
        "-o",
        outFile,
        markdownFile
    ]);
    console.log(`Outfile: '${outFile}' :: ${getFileSizeMb(outFile)} mb`);
}

async function latexExport(markdownFile, outFile) {
    await runPandoc([
        "--fail-if-warnings",
        "--data-dir=convert/pandoc",
        "--defaults=pandoc-dirs.yaml",
        "--defaults=pandoc-latex.yaml",
        "--defaults=pandoc-filters.yaml",
        "-o",
        outFile,
        markdownFile
    ]);
    console.log(`Outfile: '${outFile}' :: ${getFileSizeMb(outFile)} mb`);
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
        .src(["includes/Math.html"])
        .pipe(rename("includes/generated/Math.tex"))
        .pipe(replace(re, "$1"))
        .pipe(gulp.dest("./"));
});

const exportTriggerFiles = ["**/*.md", "literature/**/*", "files/**/*", "includes/*", "**/*.yaml", "convert/**/*"];
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
    gulp.watch(["**/*.html", "**/*.css"]).on("change", reload);
});
