!function(t){"use strict";

// SweetAlert 초기화 생성자
function e(){}

// SweetAlert 초기화 메서드 정의
e.prototype.init = function(){

    // 기본 알림: 확인 버튼만 있는 알림
    t("#sa-basic").on("click", function(){
        Swal.fire({
            title: "Any fool can use a computer",
            confirmButtonColor: "#5b73e8"
        })
    });

    // 제목과 텍스트, 질문 아이콘
    t("#sa-title").click(function(){
        Swal.fire({
            title: "The Internet?",
            text: "That thing is still around?",
            icon: "question",
            confirmButtonColor: "#5b73e8"
        })
    });

    // 성공 알림: 확인 + 취소 버튼
    t("#sa-success").click(function(){
        Swal.fire({
            title: "Good job!",
            text: "You clicked the button!",
            icon: "success",
            showCancelButton: !0,
            confirmButtonColor: "#5b73e8",
            cancelButtonColor: "#f46a6a"
        })
    });

    // 경고 알림: 확인 시 삭제
    t("#sa-warning").click(function(){
        Swal.fire({
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: "warning",
            showCancelButton: !0,
            confirmButtonColor: "#34c38f",
            cancelButtonColor: "#f46a6a",
            confirmButtonText: "Yes, delete it!"
        }).then(function(t){
            if(t.value){
                Swal.fire("Deleted!", "Your file has been deleted.", "success")
            }
        })
    });

    // 경고 알림 + 커스텀 버튼 클래스 + 취소 버튼 처리
    t("#sa-params").click(function(){
        Swal.fire({
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: "warning",
            showCancelButton: !0,
            confirmButtonText: "Yes, delete it!",
            cancelButtonText: "No, cancel!",
            confirmButtonClass: "btn btn-success mt-2",
            cancelButtonClass: "btn btn-danger ms-2 mt-2",
            buttonsStyling: !1
        }).then(function(t){
            if(t.value){
                Swal.fire({
                    title: "Deleted!",
                    text: "Your file has been deleted.",
                    icon: "success",
                    confirmButtonColor: "#34c38f"
                })
            } else if(t.dismiss === Swal.DismissReason.cancel){
                Swal.fire({
                    title: "Cancelled",
                    text: "Your imaginary file is safe :)",
                    icon: "error"
                })
            }
        })
    });

    // 이미지가 포함된 알림
    t("#sa-image").click(function(){
        Swal.fire({
            title: "Sweet!",
            text: "Modal with a custom image.",
            imageUrl: "assets/images/logo-dark.png",
            imageHeight: 20,
            confirmButtonColor: "#5b73e8",
            animation: !1
        })
    });

    // 자동 닫힘 알림
    t("#sa-close").click(function(){
        var t;
        Swal.fire({
            title: "Auto close alert!",
            html: "I will close in <strong></strong> seconds.",
            timer: 2000,
            confirmButtonColor: "#5b73e8",
            onBeforeOpen: function(){
                Swal.showLoading();
                t = setInterval(function(){
                    Swal.getContent().querySelector("strong").textContent = Swal.getTimerLeft()
                }, 100)
            },
            onClose: function(){ clearInterval(t) }
        }).then(function(t){
            if(t.dismiss === Swal.DismissReason.timer) console.log("I was closed by the timer")
        })
    });

    // 커스텀 HTML을 포함한 알림
    t("#custom-html-alert").click(function(){
        Swal.fire({
            title: "<i>HTML</i> <u>example</u>",
            icon: "info",
            html: 'You can use <b>bold text</b>, <a href="//Themesbrand.in/">links</a> and other HTML tags',
            showCloseButton: !0,
            showCancelButton: !0,
            confirmButtonClass: "btn btn-success",
            cancelButtonClass: "btn btn-danger ms-1",
            confirmButtonColor: "#47bd9a",
            cancelButtonColor: "#f46a6a",
            confirmButtonText: '<i class="fas fa-thumbs-up me-1"></i> Great!',
            cancelButtonText: '<i class="fas fa-thumbs-down"></i>'
        })
    });

    // 화면 오른쪽 상단에 위치하는 성공 알림
    t("#sa-position").click(function(){
        Swal.fire({
            position: "top-end",
            icon: "success",
            title: "Your work has been saved",
            showConfirmButton: !1,
            timer: 1500
        })
    });

    // 커스텀 너비, 패딩, 배경 알림
    t("#custom-padding-width-alert").click(function(){
        Swal.fire({
            title: "Custom width, padding, background.",
            width: 600,
            padding: 100,
            confirmButtonColor: "#5b73e8",
            background: "#fff url(//subtlepatterns2015.subtlepatterns.netdna-cdn.com/patterns/geometry.png)"
        })
    });

    // AJAX 요청을 포함한 알림
    t("#ajax-alert").click(function(){
        Swal.fire({
            title: "Submit email to run ajax request",
            input: "email",
            inputPlaceholder: "Enter your email address",
            showCancelButton: !0,
            confirmButtonText: "Submit",
            showLoaderOnConfirm: !0,
            confirmButtonColor: "#5b73e8",
            cancelButtonColor: "#f46a6a",
            preConfirm: function(n){
                return new Promise(function(t,e){
                    setTimeout(function(){
                        if("taken@example.com"===n) e("This email is already taken.");
                        else t();
                    }, 2000)
                })
            },
            allowOutsideClick: !1
        }).then(function(t){
            Swal.fire({
                icon: "success",
                title: "Ajax request finished!",
                confirmButtonColor: "#34c38f",
                html: "Submitted email: " + t
            })
        })
    });

    // 체인형 알림: 여러 단계 질문
    t("#chaining-alert").click(function(){
        Swal.mixin({
            input: "text",
            confirmButtonText: "Next &rarr;",
            inputPlaceholder: "Enter your Question",
            showCancelButton: !0,
            confirmButtonColor: "#5b73e8",
            cancelButtonColor: "#74788d",
            progressSteps: ["1","2","3"]
        }).queue([
            {title: "Question 1", text: "Chaining swal2 modals is easy"},
            "Question 2",
            "Question 3"
        ]).then(function(t){
            if(t.value){
                Swal.fire({
                    title: "All done!",
                    html: "Your answers: <pre><code>"+JSON.stringify(t.value)+"</code></pre>",
                    confirmButtonText: "Lovely!",
                    confirmButtonColor: "#34c38f"
                })
            }
        })
    });

    // 동적 AJAX 알림
    t("#dynamic-alert").click(function(){
        swal.queue([{
            title: "Your public IP",
            confirmButtonColor: "#5b73e8",
            confirmButtonText: "Show my public IP",
            text: "Your public IP will be received via AJAX request",
            showLoaderOnConfirm: !0,
            preConfirm: function(){
                return new Promise(function(e){
                    t.get("https://api.ipify.org?format=json").done(function(t){
                        swal.insertQueueStep(t.ip);
                        e()
                    })
                })
            }
        }]).catch(swal.noop)
    });

};

// SweetAlert 생성자와 초기화 호출
t.SweetAlert = new e;
t.SweetAlert.Constructor = e;

}(window.jQuery),

// DOM 로드 완료 후 SweetAlert 초기화 실행
function(){"use strict";
window.jQuery.SweetAlert.init()
}();
