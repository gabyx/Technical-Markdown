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
            return resolve(markdown);
        });
    },
    onDidTransformMarkdown: function (markdown) {
        return new Promise((resolve, reject) => {
            return resolve(markdown);
        });
    }
};
