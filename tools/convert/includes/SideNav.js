<script>
    function openSideNav() {
        expandWidth = 300;
        var sidnav = document.getElementById("sidenav");
        var m = document.getElementById("main-markdown");

        sidnav.style.width = `${expandWidth}px`;
        if (m.offsetLeft - expandWidth < 0) {
            m.style.marginLeft = `${expandWidth + 40}px`;
        }

        document.getElementById("nav-content").style.display = "none";

        toc = document.getElementById("TOC");        
        // Append to sidebar.
        toc.parentNode.removeChild(toc);
        document.getElementById("sidenav-content").append(toc);
    }

    function closeSideNav() {
        document.getElementById("sidenav").style.width = "0";
        document.getElementById("main-markdown").style.marginLeft = null;

        navContent = document.getElementById("nav-content");
        navContent.style.display = "initial";
        
        toc = document.getElementById("TOC");        
        // Append to inline.
        toc.parentNode.removeChild(toc);
        document.getElementById("nav-content").append(toc);
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
        var treeListItems = document.querySelectorAll('nav ul li');
        for (var i = 0; i < treeListItems.length; i++) {

            var isLeaf = treeListItems[i].getElementsByTagName('ul').length == 0;
            if (isLeaf) {
                treeListItems[i].classList.add("leaf")
                continue;
            }

            // click handler
            treeListItems[i].addEventListener('click',
                function (e) {
                    var target = e.target;

                    var classList = target.classList;
                    if (classList.contains("open")) { // close the element and its children
                        classList.remove('open');
                        var openChildrenList = target.querySelectorAll(':scope li.open');
                        for (var j = 0; j < openChildrenList.length; j++) {
                            openChildrenList[j].classList.remove('open');
                        }
                    } else { // open the element
                        classList.add('open');
                    }

                    e.stopPropagation();
                }
            );
        }
    }

    window.addEventListener('load', onLoad);
</script>
