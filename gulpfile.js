var fs = require("fs");
var gulp = require("gulp");
var less = require("gulp-less");
var replace = require("gulp-replace");
var markdown = require("./convert/markdownToHtml");
var browserSync = require("browser-sync").create();
var reload = browserSync.reload;

/* Task to compile less */
gulp.task("compile-less", async function () {
  await gulp.src("./css/src/main.less").pipe(less()).pipe(gulp.dest("./css"));
});

/* Task to watch less changes */
gulp.task("watch-less", function () {
  gulp.watch(
    ["./css/src/*", "./css/fonts/*"],
    gulp.series(["compile-less", "compile-markdown"])
  );
});

/* Task to compile all markdown files */
gulp.task("compile-markdown", async function () {
  await markdown.exportToHTML("./Content.md");
});

/* Task to compile all markdown files */
gulp.task("compile-markdown", async function (done) {
  file = "./Content.md";
  console.log("Exporting " + file + " to html...");
  await markdown.exportToHTML(file);
});

/* Task to watch all markdown files */
gulp.task("watch-markdown", async function () {
  gulp.watch("./**/*.md", gulp.series(["compile-markdown"]));
});

gulp.task("show-markdown", function () {
  browserSync.init({
    server: {
      baseDir: "./",
      index: "Content.html",
    },
  });
  gulp.watch("./**/*.html").on("change", reload);
});

/* Task when running `gulp` from terminal */
gulp.task("build-markdown", gulp.parallel(["watch-less", "watch-markdown"]));
