// 이벤트 클릭 시 읽기 전용 모드로 전환
function eventClicked(){
    document.getElementById("form-event").classList.add("view-event"), // 폼을 'view-event' 모드로
    document.getElementById("event-title").classList.replace("d-block","d-none"), // 제목 입력 필드 숨김
    document.getElementById("event-type").classList.replace("d-block","d-none"), // 카테고리 입력 필드 숨김
    document.getElementById("btn-save-event").setAttribute("hidden",!0) // 저장 버튼 숨김
}

// 이벤트 편집 상태로 전환
function editEvent(e){
    var t = e.getAttribute("data-id"); // 버튼의 data-id 속성 확인
    if("new-event" == t){
        // 새 이벤트 추가 모드
        document.getElementById("modal-title").innerHTML = "",
        document.getElementById("modal-title").innerHTML = "Add Event", // 모달 제목 변경
        document.getElementById("btn-save-event").innerHTML = "Add Event", // 저장 버튼 문구 변경
        eventTyped(); // 입력 가능 상태로 전환
    } else if("edit-event" == t){
        // 편집 모드
        e.innerHTML = "Cancel", // 버튼 문구 변경
        document.getElementById("btn-save-event").innerHTML = "Update Event", // 저장 버튼 문구 변경
        e.removeAttribute("hidden"), // 버튼 표시
        eventTyped(); // 입력 가능 상태로 전환
    } else {
        // 편집 종료 후 읽기 모드
        e.innerHTML = "Edit",
        eventClicked();
    }
}

// 입력 가능한 상태로 전환
function eventTyped(){
    document.getElementById("form-event").classList.remove("view-event"), // 읽기 모드 해제
    document.getElementById("event-title").classList.replace("d-none","d-block"), // 제목 입력 필드 표시
    document.getElementById("event-type").classList.replace("d-block","d-none"), // 카테고리 입력 필드 표시
    document.getElementById("btn-save-event").removeAttribute("hidden") // 저장 버튼 표시
}

// DOM 로드 완료 후 실행
document.addEventListener("DOMContentLoaded", function(){
    // Bootstrap Modal 객체 생성
    var i = new bootstrap.Modal(document.getElementById("event-modal"), { keyboard: !1 });
    document.getElementById("event-modal");

    var t = document.getElementById("modal-title"), // 모달 제목
        n = document.getElementById("form-event"),  // 이벤트 폼
        o = null, // 현재 선택된 이벤트
        e = (document.getElementsByClassName("needs-validation"), new Date), // 현재 날짜
        d = e.getDate(),
        a = e.getMonth(),
        l = e.getFullYear(),
        r = FullCalendar.Draggable, // 외부 이벤트 드래그 기능
        c = document.getElementById("external-events"); // 외부 이벤트 컨테이너

    // 초기 이벤트 목록
    var s = window.calendarEvents || [
		/*
        { title: "All Day Event", start: new Date(l,a,1) },
        { title: "Long Event", start: new Date(l,a,d-5), end: new Date(l,a,d-2), className: "bg-warning" },
        { id: 999, title: "Repeating Event", start: new Date(l,a,d-3,16,0), allDay: !1, className: "bg-info" },
        { id: 999, title: "Repeating Event", start: new Date(l,a,d+4,16,0), allDay: !1, className: "bg-primary" },
        { title: "Meeting", start: new Date(l,a,d,10,30), allDay: !1, className: "bg-success" },
        { title: "Lunch", start: new Date(l,a,d,12,0), end: new Date(l,a,d,14,0), allDay: !1, className: "bg-danger" },
        { title: "Birthday Party", start: new Date(l,a,d+1,19,0), end: new Date(l,a,d+1,22,30), allDay: !1, className: "bg-success" },
        { title: "Click for Google", start: new Date(l,a,28), end: new Date(l,a,29), url: "http://google.com/", className: "bg-dark" }
		*/
    ];

    // 외부 이벤트 드래그 가능하게 설정
    new r(c, {
        itemSelector: ".external-event",
        eventData: function(e){
            return {
                id: Math.floor(11e3 * Math.random()), // 랜덤 ID
                title: e.innerText, // 이벤트 제목
                allDay: !0,
                start: new Date,
                className: e.getAttribute("data-class") // 색상 클래스
            }
        }
    });

    var m = document.getElementById("calendar");

    // 새 이벤트 생성 모달 열기
    function v(e){
        document.getElementById("form-event").reset(),
        i.show(), // 모달 표시
        n.classList.remove("was-validated"),
        n.reset(),
        o = null,
        t.innerText = "일정생성", // 모달 제목 변경
        newEventData = e;
    }

    // 화면 크기에 따른 초기 뷰 설정
    function u(){
        return 768 <= window.innerWidth && window.innerWidth < 1200 ? "timeGridWeek"
             : window.innerWidth <= 768 ? "listMonth"
             : "dayGridMonth";
    }

    // FullCalendar 초기화
    var g = new FullCalendar.Calendar(m, {
        timeZone: "local",
        editable: !0,
        droppable: !0,
        selectable: !0,
        navLinks: !0,
        initialView: u(),
		aspectRatio: 1.6, // 캘린더 세로길이 조절 높아질수록 줄어듬
        themeSystem: "bootstrap",
        headerToolbar: {
            left: "prev,next today",
            center: "title",
            right: "dayGridMonth,timeGridWeek,timeGridDay,listMonth"
        },
		locale: "ko",
		buttonText: {
		  today: '오늘',
		  month: '월',
		  week: '주',
		  day: '일'
		},
        windowResize: function(e){
            var t = u();
            g.changeView(t);
        },
        eventResize: function(t){
            var e = s.findIndex(function(e){ return e.id == t.event.id });
            s[e] && (s[e].title = t.event.title, s[e].location=t.event.location, s[e].start=t.event.start, 
				s[e].end=t.event.end, s[e].type = t.event.type, s[e].memo=t.event.memo);
        },
        eventClick: function(e){
            document.getElementById("edit-event-btn").removeAttribute("hidden"),
            document.getElementById("btn-save-event").setAttribute("hidden", !0),
            document.getElementById("edit-event-btn").setAttribute("data-id", "edit-event"),
            document.getElementById("edit-event-btn").innerHTML = "수정",
            eventClicked(),
            i.show(),
            n.reset(),
            o = e.event,
            document.getElementById("modal-title").innerHTML = "일정상세",
            console.log("selectedEvent", o),
            document.getElementById("event-title").value = o.title,
			document.getElementById("event-location").value = o.extendedProps.location,
            document.getElementById("event-type").value = o.extendedProps.type,
			document.getElementById("event-start-time").value = moment(o.start).format("YYYY-MM-DDTHH:mm"),
			document.getElementById("event-end-time").value = moment(o.end).format("YYYY-MM-DDTHH:mm"),
			document.getElementById("event-memo").value = o.extendedProps.memo || "",
            document.getElementById("btn-delete-event").removeAttribute("hidden");
        },
        dateClick: function(e){
            document.getElementById("edit-event-btn").setAttribute("hidden", !0),
            document.getElementById("btn-save-event").removeAttribute("hidden"),
            v(e);
        },
        events: s,
        eventReceive: function(e){
            var t = {
                id: parseInt(e.event.id),
                title: e.event.title,
				location:e.event.location,
				start: e.event.start,
				end: e.event.end,
                type: e.event.type,
				memo: e.event.location
            };
            s.push(t);
        },
        eventDrop: function(t){
            var e = s.findIndex(function(e){ return e.id == t.event.id });
            s[e] && (s[e].title = t.event.title, s[e].location=t.event.location, s[e].start=t.event.start, 
				s[e].end=t.event.end, s[e].type = t.event.type, s[e].memo=t.event.memo);
        }
    });

    g.render();

    // 이벤트 저장
    n.addEventListener("submit", function(e){
        e.preventDefault();
        var t, n, d,
            a = document.getElementById("event-title").value,
            tp = document.getElementById("event-type").value;
			sd = document.getElementById("event-start-time").value;
			ed = document.getElementById("event-end-time").value;
			lc = document.getElementById("event-location").value;
			m = document.getElementById("event-memo").value;
        if(o){
            // 기존 이벤트 수정
			t = parseInt(document.getElementById("eventid").value);
            
			fetch("/updateCalendar", {
		        method: "PATCH",
		        headers: {"Content-Type":"application/json"},
		        body: JSON.stringify({calendarId:t,calendarTitle:a,calendarLocation:lc,
					calendarMemo:m,calendarStartTime:sd,calendarEndTime:ed
				})
		    }).then((res) => {
				if(res.ok){
		            g.render();
				}else{
					alert('수정실패');
				}
			});
            
        } else {
            // 새 이벤트 추가
            d = {
                title: a,
                location: lc,
				start: sd,
				end: ed,
                type: tp,
				memo: m
            },
			fetch("/insertCalendar", {
			        method: "POST",
			        headers: {"Content-Type":"application/json"},
			        body: JSON.stringify({userId:53,calendarTitle:a,calendarLocation:lc,calendarType:tp,
						calendarMemo:m,calendarStartTime:sd,calendarEndTime:ed
					})
		    }).then((res) => {
				if(res.ok){
					g.addEvent(d),
		            s.push(d);
				}else{
					alert('등록실패');
				}
			});
            
        }
        i.hide();
    });

    // 이벤트 삭제
    document.getElementById("btn-delete-event").addEventListener("click", function(e){
        if(o){
            for(var t = 0; t < s.length; t++)
                s[t].id == o.id && (s.splice(t, 1), t--);
            o.remove(),
            o = null,
            i.hide();
        }
    });

    // 새 이벤트 버튼 클릭 시
    document.getElementById("btn-new-event").addEventListener("click", function(e){
        v(),
        document.getElementById("edit-event-btn").click();
    });
});
