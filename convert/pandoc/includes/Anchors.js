<script src="https://cdn.jsdelivr.net/npm/anchor-js/anchor.min.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function (event) {
        var P = "#main-markdown > header"
        var noAnchorHeaders = document.querySelectorAll(`${P} h1, ${P} h2, ${P} h3, ${P} h4, ${P} h5, ${P} h6`)
        for (var k = 0; k < noAnchorHeaders.length; k++) {
            noAnchorHeaders[k].classList.add("no-anchor")
        }

        anchors.options = {
            placement: 'right',
            visible: 'never',
            icon: '§'
        };
        var P = "#main-markdown"
        anchors.add(`${P} h1:not(.no-anchor),${P} h2:not(.no-anchor),${P} h3:not(.no-anchor),${P} h4:not(.no-anchor),${P} h5:not(.no-anchor),${P} h6:not(.no-anchor)`);
    });
</script>
