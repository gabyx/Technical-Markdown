module.exports = {
    onWillParseMarkdown: function (markdown) {
        return new Promise((resolve, reject) => {
            return resolve(markdown);
        });
    },
    onDidParseMarkdown: function (html) {
        return new Promise((resolve, reject) => {
            return resolve(html);
        });
    },
    onWillTransformMarkdown: function (markdown) {
        return new Promise((resolve, reject) => {
            console.log("Replace Math.md ...");
            markdown = markdown
                .replace(/@import.*Math.md.*/gm, "")
                .replace(/```math\s+((?:.*\n)*?)```/gm, "$1");
            return resolve(markdown);
        });
    },
    onDidTransformMarkdown: function (markdown) {
        return new Promise((resolve, reject) => {
            return resolve(markdown);
        });
    }
};
