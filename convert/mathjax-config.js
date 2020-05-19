MathJax.Hub.Config({
    "extensions": ["tex2jax.js"],
    "jax": ["input/TeX", "output/HTML-CSS"],
    "messageStyle": "none",
    "tex2jax": {
        "processEnvironments": false,
        "processEscapes": true,
        "inlineMath": [
            ["\\f$", "\\f$"],
            ["$", "$"]
        ],
        "displayMath": [
            ["\\f[", "\\f]"],
            ["$$", "$$"]
        ]
    },
    "TeX": {
        "extensions": [
            "AMSmath.js",
            "AMSsymbols.js",
            "noErrors.js",
            "noUndefined.js"
        ],
        "equationNumbers": { "autoNumber": "AMS" }
    },
    "HTML-CSS": { "availableFonts": ["TeX"] }
});
