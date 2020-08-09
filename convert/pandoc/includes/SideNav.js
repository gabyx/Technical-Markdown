<script>
    function openSideNav() {
        expandWidth = 300;
        var sidnav = document.getElementById("side-nav");
        var m = document.getElementById("main-markdown");

        sidnav.style.width = `${expandWidth}px`;
        if (m.offsetLeft - expandWidth < 0) {
            m.style.marginLeft = `${expandWidth + 40}px`
        }
    }

    function closeSideNav() {
        document.getElementById("side-nav").style.width = "0";
        document.getElementById("main-markdown").style.marginLeft = null;
    }

    var EXPAND_ALL = "⊞";
    var COLLAPSE_ALL = "⊟";

    var toggleExpandCollapse = function () {
        var botton = document.getElementById("expand");
        if (botton.innerHTML === EXPAND_ALL) {
            expandAll();
            botton.innerHTML = COLLAPSE_ALL;
        } else {
            collapseAll();
            botton.innerHTML = EXPAND_ALL;
        }
    };

    var expandAll = function () {
        var allListItems = document.querySelectorAll('nav ul li');
        for (var k = 0; k < allListItems.length; k++) {
            allListItems[k].classList.add("open");
        }
    };

    var collapseAll = function () {
        var allListItems = document.querySelectorAll('nav ul li');
        for (var k = 0; k < allListItems.length; k++) {
            allListItems[k].classList.remove("open");
        }
    };

    var onLoad = function () {
        var treeListItems = document.querySelectorAll('nav ul a');
        for (var i = 0; i < treeListItems.length; i++) {
            // click handler
            treeListItems[i].addEventListener('click', function (e) {
                var parent = e.target.parentElement;
                var classList = parent.classList;
                if (classList.contains("open")) { // close the element and its children
                    classList.remove('open');
                    var openChildrenList = parent.querySelectorAll(':scope .open');
                    for (var j = 0; j < openChildrenList.length; j++) {
                        openChildrenList[j].classList.remove('open');
                    }
                } else { // open the element
                    classList.add('open');
                }
            });
        }
    }

    window.addEventListener('load', onLoad);
</script>