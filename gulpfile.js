var fs = require("fs");
var path = require("path");
var gulp = require("gulp");
var less = require("gulp-less");
var rename = require("gulp-rename");
var replace = require("gulp-replace");
var markdown = require("./convert/convert");
var browserSync = require("browser-sync").create();
var reload = browserSync.reload;

/* Task to compile less */

gulp.task("compile-less", async function () {
    await gulp.src("./css/src/main.less").pipe(less()).pipe(gulp.dest("./css"));
});

/* Task to watch less changes */
gulp.task("watch-less", function () {
    gulp.watch(["./css/src/*", "./css/fonts/*"], gulp.series(["compile-less"]));
});

/* Task to compile all markdown files */
gulp.task("compile-markdown-html", async function () {
    await markdown.htmlExport(path.resolve("./Content.md"));
});

/* Task to compile all markdown files */
gulp.task("compile-markdown-latex", async function () {
    await markdown.pandocExport(path.resolve("./Content.md"));
});

/* Task to compile all markdown files */
gulp.task("compile-markdown-chrome", async function () {
    await markdown.chromeExport(path.resolve("./Content.md"));
});

/* Task to compile all markdown files */
gulp.task("transform-math", async function () {
    const re = /.*\$\$\s+(.+)\$\$.*/gms;
    gulp.src(["includes/Math.md"])
        .pipe(rename("includes/Math.tex"))
        .pipe(replace(re, "$1"))
        .pipe(gulp.dest("convert/pandoc"));
});

/* Task to watch all markdown files */
gulp.task("watch-markdown-html", async function () {
    gulp.watch("./**/*.md", gulp.series(["compile-markdown-html"]));
});

/* Task to watch all markdown files */
gulp.task("watch-markdown-pandoc", async function () {
    gulp.watch(
        "./**/*.md",
        gulp.series(["transform-math", "compile-markdown-latex"])
    );
});

/* Task to watch all markdown files */
gulp.task("watch-math-markdown", async function () {
    gulp.watch("./**/Math.md", gulp.series(["transform-math"]));
});

/* Task to watch all markdown files */
gulp.task("watch-markdown-chrome", async function () {
    gulp.watch("./**/*.md", gulp.series(["compile-markdown-chrome"]));
});

gulp.task("show-markdown", function () {
    browserSync.init({
        server: {
            baseDir: "./",
            index: "Content.html"
        }
    });
    gulp.watch("./**/*.html").on("change", reload);
});

/* Task when running `gulp` from terminal */
gulp.task(
    "build-markdown-html",
    gulp.parallel(["watch-less", "watch-markdown-html"])
);

/* Task when running `gulp` from terminal */
gulp.task(
    "build-markdown-pandoc",
    gulp.parallel(["watch-math-markdown", "watch-markdown-pandoc"])
);

/* Task when running `gulp` from terminal */
gulp.task(
    "build-markdown-chrome",
    gulp.parallel(["watch-less", "watch-markdown-chrome"])
);
