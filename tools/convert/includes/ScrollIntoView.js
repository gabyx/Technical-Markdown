<script>
// If we have a hash we disable history scrolling restoration and
// really scroll into view.
var c = window.location.hash;
if (c.length != 0) {
    history.scrollRestoration = "manual"
}

document.addEventListener('DOMContentLoaded', function(event) {
    var c = window.location.hash;
    var e = document.getElementById(c.replace("#", ""));
    if (e != null) {
        e.scrollIntoView();
    }
});
</script>
