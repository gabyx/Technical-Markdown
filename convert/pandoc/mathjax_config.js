module.exports = {
    extensions: ["tex2jax.js"],
    jax: ["input/TeX", "output/HTML-CSS"],
    messageStyle: "none",
    tex2jax: {
        processEnvironments: false,
        processEscapes: true
    },
    TeX: {
        extensions: ["AMSmath.js", "AMSsymbols.js", "noErrors.js", "noUndefined.js", "colors.js", "extpfeil.js"],
        equationNumbers: { autoNumber: "AMS" }
    },
    "HTML-CSS": { availableFonts: ["TeX"] }
};
