!function(o) {
    "use strict";

    function n() {
        var t = document.getElementById("topnav-menu-content").getElementsByTagName("a");
        for (var e = 0, a = t.length; e < a; e++)
            if ("nav-item dropdown active" === t[e].parentElement.getAttribute("class")) {
                t[e].parentElement.classList.remove("active");
                t[e].nextElementSibling.classList.remove("show");
            }
    }

    // 안전하게 수정한 e() 함수
    function e(t) {
        var el = document.getElementById(t);
        if (el) el.checked = true;
    }

    function t() {
        if (!(document.webkitIsFullScreen || document.mozFullScreen || document.msFullscreenElement)) {
            console.log("pressed");
            o("body").removeClass("fullscreen-enable");
        }
    }

    var a, r, d;

    o("#side-menu").metisMenu();
    a = document.body.getAttribute("data-sidebar-size");

    o(window).on("load", function() {
        o(".switch").on("switch-change", function() { toggleWeather() });

        if (1024 <= window.innerWidth && window.innerWidth <= 1366) {
            document.body.setAttribute("data-sidebar-size","sm");
            e("sidebar-size-small"); // 안전하게 호출
        }
    });

    o(".vertical-menu-btn").on("click", function(t) {
        t.preventDefault();
        o("body").toggleClass("sidebar-enable");
        if (992 <= o(window).width()) {
            if (a == null) {
                var bodySize = document.body.getAttribute("data-sidebar-size");
                if (!bodySize || bodySize == "lg") document.body.setAttribute("data-sidebar-size","sm");
                else document.body.setAttribute("data-sidebar-size","lg");
            } else if (a == "md") {
                document.body.getAttribute("data-sidebar-size") == "md" ?
                    document.body.setAttribute("data-sidebar-size","sm") :
                    document.body.setAttribute("data-sidebar-size","md");
            } else if (document.body.getAttribute("data-sidebar-size") == "sm") {
                document.body.setAttribute("data-sidebar-size","lg");
            } else {
                document.body.setAttribute("data-sidebar-size","sm");
            }
        }
    });

    // 사이드바 메뉴 활성화
    o("#sidebar-menu a").each(function() {
        var t = window.location.href.split(/[?#]/)[0];
        if (this.href == t) {
            o(this).addClass("active");
            o(this).parent().addClass("mm-active");
            o(this).parent().parent().addClass("mm-show");
            o(this).parent().parent().prev().addClass("mm-active");
            o(this).parent().parent().parent().addClass("mm-active");
            o(this).parent().parent().parent().parent().addClass("mm-show");
            o(this).parent().parent().parent().parent().parent().addClass("mm-active");
        }
    });

    o(document).ready(function() {
        var t;
        if (0 < o("#sidebar-menu").length && 0 < o("#sidebar-menu .mm-active .active").length) {
            if ((t = o("#sidebar-menu .mm-active .active").offset().top) > 300) t -= 300;
            o(".vertical-menu .simplebar-content-wrapper").animate({scrollTop:t}, "slow");
        }
    });

    // 전체화면 토글
    o('[data-bs-toggle="fullscreen"]').on("click", function(t) {
        t.preventDefault();
        o("body").toggleClass("fullscreen-enable");

        if (document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement) {
            document.cancelFullScreen ? document.cancelFullScreen() :
            document.mozCancelFullScreen ? document.mozCancelFullScreen() :
            document.webkitCancelFullScreen && document.webkitCancelFullScreen();
        } else {
            document.documentElement.requestFullscreen ? document.documentElement.requestFullscreen() :
            document.documentElement.mozRequestFullScreen ? document.documentElement.mozRequestFullScreen() :
            document.documentElement.webkitRequestFullscreen && document.documentElement.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
        }
    });

    document.addEventListener("fullscreenchange", t);
    document.addEventListener("webkitfullscreenchange", t);
    document.addEventListener("mozfullscreenchange", t);

    // 내비게이션 활성화
    o(".navbar-nav a").each(function() {
        var t = window.location.href.split(/[?#]/)[0];
        if (this.href == t) {
            o(this).addClass("active");
            o(this).parent().addClass("active");
            o(this).parent().parent().addClass("active");
            o(this).parent().parent().parent().addClass("active");
            o(this).parent().parent().parent().parent().addClass("active");
            o(this).parent().parent().parent().parent().parent().addClass("active");
        }
    });

    // 오른쪽 사이드바 토글
    o(".right-bar-toggle").on("click", function() { o("body").toggleClass("right-bar-enabled") });
    o(document).on("click", "body", function(t) {
        0 < o(t.target).closest(".right-bar-toggle, .right-bar").length || o("body").removeClass("right-bar-enabled");
    });

    // topnav 메뉴 토글
    (function() {
        if (document.getElementById("topnav-menu-content")) {
            var t = document.getElementById("topnav-menu-content").getElementsByTagName("a");
            for (var i = 0; i < t.length; i++) {
                t[i].onclick = function(t) {
                    if ("#" === t.target.getAttribute("href")) {
                        t.target.parentElement.classList.toggle("active");
                        t.target.nextElementSibling.classList.toggle("show");
                    }
                }
            }
            window.addEventListener("resize", n);
        }
    })();

    // 툴팁/팝오버/카운터 초기화
    (function() {
        [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]')).map(function(t) { return new bootstrap.Tooltip(t); });
        [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]')).map(function(t) { return new bootstrap.Popover(t); });
        var delay = o(this).attr("data-delay") ? o(this).attr("data-delay") : 100;
        var time = o(this).attr("data-time") ? o(this).attr("data-time") : 1200;
        o('[data-plugin="counterup"]').each(function() { o(this).counterUp({delay:delay,time:time}); });
    })();

    // 세션 기반 체크박스
    if (window.sessionStorage) {
        r = sessionStorage.getItem("is_visited");
        if (r) {
            var el = document.getElementById(r);
            if (el) el.checked = true;
        } else {
            sessionStorage.setItem("is_visited", "layout-ltr");
        }
    }

    o(window).on("load", function() {
        o("#status").fadeOut();
        o("#preloader").delay(350).fadeOut("slow");
    });

    d = document.getElementsByTagName("body")[0];

    // 모드 설정 버튼
    o("#mode-setting-btn").on("click", function() {
        if (d.hasAttribute("data-bs-theme") && d.getAttribute("data-bs-theme") == "dark") {
            document.body.setAttribute("data-bs-theme","light");
            document.body.setAttribute("data-topbar","light");
            document.body.setAttribute("data-sidebar","light");
            if (!d.hasAttribute("data-layout") || d.getAttribute("data-layout") != "horizontal") {
                document.body.setAttribute("data-sidebar","light");
            }
            e("topbar-color-light");
            e("sidebar-color-light");
        } else {
            document.body.setAttribute("data-bs-theme","dark");
            document.body.setAttribute("data-topbar","dark");
            document.body.setAttribute("data-sidebar","dark");
            if (!d.hasAttribute("data-layout") || d.getAttribute("data-layout") != "horizontal") {
                document.body.setAttribute("data-sidebar","dark");
            }
            e("layout-mode-dark");
            e("sidebar-color-dark");
            e("topbar-color-dark");
        }
    });

    // 레이아웃 초기화
    if (d.hasAttribute("data-layout") && d.getAttribute("data-layout") == "horizontal") e("layout-horizontal");
    else e("layout-vertical");

    if (d.hasAttribute("data-bs-theme") && d.getAttribute("data-bs-theme") == "dark") e("layout-mode-dark");
    else e("layout-mode-light");

    if (d.hasAttribute("data-layout-size") && d.getAttribute("data-layout-size") == "boxed") e("layout-width-boxed");
    else e("layout-width-fuild");

    if (d.hasAttribute("data-topbar") && d.getAttribute("data-topbar") == "dark") e("topbar-color-dark");
    else e("topbar-color-light");

    if (d.hasAttribute("data-sidebar-size") && d.getAttribute("data-sidebar-size") == "sm") e("sidebar-size-small");
    else if (d.hasAttribute("data-sidebar-size") && d.getAttribute("data-sidebar-size") == "md") e("sidebar-size-compact");
    else e("sidebar-size-default");

    if (d.hasAttribute("data-sidebar") && d.getAttribute("data-sidebar") == "colored") e("sidebar-color-colored");
    else if (d.hasAttribute("data-sidebar") && d.getAttribute("data-sidebar") == "dark") e("sidebar-color-dark");
    else e("sidebar-color-light");

    if (document.getElementsByTagName("html")[0].hasAttribute("dir") && document.getElementsByTagName("html")[0].getAttribute("dir") == "rtl") e("layout-direction-rtl");
    else e("layout-direction-ltr");

    // 레이아웃 변경 이벤트
    o("input[name='layout']").on("change", function() { 
        window.location.href = o(this).val() == "vertical" ? "index.html" : "layouts-horizontal.html"; 
    });

    o("input[name='layout-mode']").on("change", function() {
        if (o(this).val() == "light") {
            document.body.setAttribute("data-bs-theme","light");
            document.body.setAttribute("data-topbar","light");
            document.body.setAttribute("data-sidebar","light");
            if (!d.hasAttribute("data-layout") || d.getAttribute("data-layout") != "horizontal") document.body.setAttribute("data-sidebar","light");
            e("topbar-color-light");
            e("sidebar-color-light");
        } else {
            document.body.setAttribute("data-bs-theme","dark");
            document.body.setAttribute("data-topbar","dark");
            document.body.setAttribute("data-sidebar","dark");
            if (!d.hasAttribute("data-layout") || d.getAttribute("data-layout") != "horizontal") document.body.setAttribute("data-sidebar","dark");
            e("topbar-color-dark");
            e("sidebar-color-dark");
        }
    });

    o("input[name='layout-direction']").on("change", function() {
        if (o(this).val() == "ltr") {
            document.getElementsByTagName("html")[0].removeAttribute("dir");
            document.getElementById("bootstrap-style").setAttribute("href","assets/css/bootstrap.min.css");
            document.getElementById("app-style").setAttribute("href","assets/css/app.min.css");
        } else {
            document.getElementById("bootstrap-style").setAttribute("href","assets/css/bootstrap-rtl.min.css");
            document.getElementById("app-style").setAttribute("href","assets/css/app-rtl.min.css");
            document.getElementsByTagName("html")[0].setAttribute("dir","rtl");
        }
    });

    Waves.init();
}(jQuery);
