<script>
    function openSideNav() {
        expandWidth = 300;
        var sidnav = document.getElementById("side-nav");
        var m = document.getElementById("main-markdown");

        sidnav.style.width = `${expandWidth}px`;
        if (m.offsetLeft - expandWidth < 0)
        {
            m.style.marginLeft = `${expandWidth}px`
        }
    }

    function closeSideNav() {
        document.getElementById("side-nav").style.width = "0";
        document.getElementById("main-markdown").style.marginLeft = null;
    }
</script>