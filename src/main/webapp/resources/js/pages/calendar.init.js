// 이벤트 클릭 시 읽기 전용 모드로 전환
function eventClicked(){
    document.getElementById("form-event").classList.add("view-event"), // 폼을 'view-event' 모드로
    document.getElementById("event-title").classList.replace("d-block","d-none"), // 제목 입력 필드 숨김
    document.getElementById("event-type").classList.replace("d-block","d-none"), // 카테고리 입력 필드 숨김
    document.getElementById("btn-save-event").setAttribute("hidden",true) // 저장 버튼 숨김
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

    var m = document.getElementById("calendar");

    // 새 이벤트 생성 모달 열기
    function v(e){
        document.getElementById("form-event").reset(),
		// 일정을 생성할때는 input을 hidden으로 바꾸고 select를 다시 보이도록 변경
		document.getElementById("event-type").style.display ='block';
		document.getElementById("event-type-read").type='hidden';
        i.show(), // 모달 표시
        n.classList.remove("was-validated"),
        n.reset(),
        o = null,
        t.innerText = "일정등록", // 모달 제목 변경
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
        editable: true,
        droppable: true,
        selectable: true,
        navLinks: true,
        initialView: u(),
		displayEventTime: false,
		aspectRatio: 1.6, // 캘린더 세로길이 조절 높아질수록 줄어듬
        themeSystem: "bootstrap",
        headerToolbar: {
            left: "prev,next today",
            center: "title",
            right: "dayGridMonth,dayGridWeek,timeGridDay,listMonth"
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
			// 캘린더에서 공휴일은 클릭해도 모달창이 나오지 않는다
			if(e.event.extendedProps.type === '공휴일'){
				return;
			}
            document.getElementById("edit-event-btn").removeAttribute("hidden"),
            document.getElementById("btn-save-event").setAttribute("hidden", true),
            document.getElementById("edit-event-btn").setAttribute("data-id", "edit-event"),
            document.getElementById("edit-event-btn").innerHTML = "수정",
            eventClicked(),
            i.show(),
            n.reset(),
            o = e.event,
            document.getElementById("modal-title").innerHTML = "일정상세",
            console.log("selectedEvent", o),
			document.getElementById("eventid").value = o.id; 
			console.log("id:",o.id);
			document.getElementById("event-user-id").value = o.extendedProps.userId,
			// 작성자 userId
			console.log("userId:",o.extendedProps.userId);
			// 로그인한 직원 userId
			console.log("loginUser:",document.getElementById("event-login-user").value);
            document.getElementById("event-title").value = o.title,
			document.getElementById("event-location").value = o.extendedProps.location,
            document.getElementById("event-type").value = o.extendedProps.type,
			// 상세보기일때는 select가 안보이게하고, input에 값이 보이며 수정불가하도록 설정
			document.getElementById("event-type").style.display ='none';
			document.getElementById("event-type-read").type='text';
			document.getElementById("event-type-read").value = o.extendedProps.type,
			document.getElementById("event-type-read").readOnly = true;
			document.getElementById("event-start-time").value = moment(o.start).format("YYYY-MM-DDTHH:mm"),
			// fullCalendar에서는 시작시간과 종료시간이 같으면 종료시간이 null이되기때문에 시간이 같으면 종료시간에도 시작시간 입력
			document.getElementById("event-end-time").value = o.end 
			    ? moment(o.end).format("YYYY-MM-DDTHH:mm") 
			    : moment(o.start).format("YYYY-MM-DDTHH:mm"),
			document.getElementById("event-memo").value = o.extendedProps.memo || "",
            document.getElementById("btn-delete-event").removeAttribute("hidden");
			// 일정 작성자가 본인이면 삭제,수정버튼이 보이고, 아닐경우 닫기버튼만 보인다
			if(Number(o.extendedProps.userId) === Number(document.getElementById("event-login-user").value)){
				document.getElementById("edit-event-btn").removeAttribute("hidden");
				document.getElementById("btn-delete-event").removeAttribute("hidden");
			}else{
				document.getElementById("edit-event-btn").setAttribute("hidden", true);
				document.getElementById("btn-delete-event").setAttribute("hidden", true);
			}
			
        },
        dateClick: function(e){
			// 수정,삭제버튼 숨기고 저장버튼을 보이게
            document.getElementById("edit-event-btn").setAttribute("hidden", true),
            document.getElementById("btn-save-event").removeAttribute("hidden"),
			document.getElementById("btn-delete-event").setAttribute("hidden", true),
            v(e);
			// 캘린더에서 날짜를 클릭하면 시작일과 종료일이 해당날짜의 00시00분으로 설정
			document.getElementById("event-start-time").value =moment(e.dateStr).format("YYYY-MM-DDTHH:mm");
			document.getElementById("event-end-time").value =moment(e.dateStr).format("YYYY-MM-DDTHH:mm");
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
            s[e] && (s[e].id=t.event.id,s[e].title = t.event.title, s[e].location=t.event.location, s[e].start=t.event.start, 
				s[e].end=t.event.end, s[e].type = t.event.type, s[e].memo=t.event.memo);
        }
    });

    g.render();
	
	// 체크박스로 타입별 일정 조회
	const userId = document.getElementById("event-login-user").value;
	const checkboxes = document.querySelectorAll("#personal, #team, #total");

	// 초기에는 모두 체크된상태
	document.getElementById("personal").checked = true;
	document.getElementById("team").checked = true;
	document.getElementById("total").checked = true;

	// 체크박스 상태에 따라 함수실행
	function calendarLoad(checkbox) {
	    let url = "";
	    if (checkbox.id === "personal") url = "/selectPersonalCalendar?userId=" + userId;
	    if (checkbox.id === "team") url = "/selectTeamCalendar?userId=" + userId;
	    if (checkbox.id === "total") url = "/selectTotalCalendar?userId=" + userId;

		// 체크박스가 체크되면 해당하는 정보가 나오고 체크해제되면 해당하는 정보가 지워진다
	    if (checkbox.checked) {
	        fetch(url)
	            .then(res => res.json())
	            .then(data => {
	                const events = data.map(event => ({
	                    id: event.calendarId,
	                    userId: event.userId,
	                    title: event.calendarTitle,
	                    location: event.calendarLocation,
	                    start: event.calendarStartTime,
	                    end: event.calendarEndTime,
	                    type: event.calendarType,
	                    className:
	                        event.calendarType === "개인" ? "bg-info" :
	                        event.calendarType === "팀" ? "bg-success" :
	                        event.calendarType === "전체" ? "bg-warning" :
	                        "bg-danger",
	                    memo: event.calendarMemo
	                }));
	                g.addEventSource({ id: checkbox.id, events });
	            });
	    } else {
	        g.getEventSources().forEach(event => {
	            if (event.id === checkbox.id) event.remove();
	        });
	    }
	}

	// 체크박스 변경 시 calendarLoad실행
	checkboxes.forEach(cb => cb.addEventListener("change", () => calendarLoad(cb)));

	// 페이지 접속시 체크된 모든 체크박스에대한 일정들을 보여준다
	checkboxes.forEach(cb => {
	    if (cb.checked) calendarLoad(cb);
	});

    // 이벤트 저장
    n.addEventListener("submit", function(e){
        e.preventDefault();
		if (!n.checkValidity()) {
		        e.stopPropagation();
		        n.classList.add("was-validated"); // Bootstrap 시각적 효과
		        return; // 저장 로직 중단
		    }
        var t, d,
            a = document.getElementById("event-title").value,
            tp = document.getElementById("event-type").value;
			sd = document.getElementById("event-start-time").value;
			ed = document.getElementById("event-end-time").value;
			lc = document.getElementById("event-location").value;
			m = document.getElementById("event-memo").value;
			lu = document.getElementById("event-login-user").value;
        if(o){
            // 기존 이벤트 수정
			t = document.getElementById("eventid").value;
            
			fetch("/updateCalendar", {
		        method: "PATCH",
		        headers: {"Content-Type":"application/json"},
		        body: JSON.stringify({calendarId:t,calendarTitle:a,calendarLocation:lc,
					calendarMemo:m,calendarStartTime:sd,calendarEndTime:ed
				})
		    }).then((res) => {
				if(res.ok){
					Swal.fire({
				        title: "수정되었습니다",
				        icon: "success",
						confirmButtonText: "확인",
				        confirmButtonColor: "#34c38f"
				    });
					// 캘린더 수정후 화면에도 바로 수정
					let eventObj = g.getEventById(t);
			        if(eventObj){
			            eventObj.setProp('title', a);
			            eventObj.setStart(sd);
			            eventObj.setEnd(ed);
			            eventObj.setExtendedProp('location', lc);
			            eventObj.setExtendedProp('memo', m);
			        }
				}else{
					Swal.fire({
	                    title: "수정을 실패했습니다.",
	                    icon: "error",
						confirmButtonText: "확인",
						confirmButtonColor: "#34c38f"
	                });
				}
			});
            
        } else {
            // 새 이벤트 추가
            d = {
				userId: lu,
                title: a,
                location: lc,
				start: sd,
				end: ed,
                type: tp,
				memo: m,
				className:
					tp === "개인" ? "bg-info" :
					tp === "팀" ? "bg-success" :
					tp === "전체" ? "bg-warning" :
					"bg-danger"
            },
			fetch("/insertCalendar", {
			        method: "POST",
			        headers: {"Content-Type":"application/json"},
			        body: JSON.stringify({userId:lu,calendarTitle:a,calendarLocation:lc,calendarType:tp,
						calendarMemo:m,calendarStartTime:sd,calendarEndTime:ed
					})
		    }).then((res) => {
				if(res.ok){
					Swal.fire({
				        title: "등록되었습니다.",
				        icon: "success",
						confirmButtonText: "확인",
				        confirmButtonColor: "#34c38f"
			    	}).then((result)=>{ // 확인 누르면 페이지 새로고침
        		    	if(result.isConfirmed){
        		    		location.reload();
        		    	}
        		    });
					g.addEvent(d),
		            s.push(d);
				}else{
					Swal.fire({
	                    title: "등록을 실패했습니다.",
	                    icon: "error",
						confirmButtonText: "확인",
						confirmButtonColor: "#34c38f"
	                });
				}
			});
            
        }
        i.hide();
		g.render();
    });

    // 이벤트 삭제
    document.getElementById("btn-delete-event").addEventListener("click", function(e){
		// Object로 받아온 calendarId값 숫자로 변환
		var t = Number(document.getElementById("eventid").value);
		console.log("deleteCalendarId:",t);
        if(o){
			Swal.fire({
	            title: "삭제하시겠습니까?",
	            icon: "warning",
	            showCancelButton: !0,
	            confirmButtonColor: "#34c38f",
	            cancelButtonColor: "#f46a6a",
	            confirmButtonText: "예",
				cancelButtonText: "아니요"
	        }).then(function(result){
				if(result.value){
					fetch("/deleteCalendar", {method:"DELETE",
		              headers:{"Content-Type":"application/json"},
		              body: JSON.stringify({calendarId:t})})
		            .then((res)=>{
		                if(res.ok){
							for(var t = 0; t < s.length; t++)
				                s[t].id == o.id && (s.splice(t, 1), t--);
				            o.remove(),
				            o = null;
		                }else{
							Swal.fire({
			                    title: "삭제를 실패했습니다.",
			                    icon: "error",
								confirmButtonText: "확인",
								confirmButtonColor: "#34c38f"
			                })
		                }
		            })
	                Swal.fire({
	                    title: "삭제되었습니다.",
	                    icon: "success",
						confirmButtonText: "확인",
			        	confirmButtonColor: "#34c38f"
	                })
	            } else if(result.dismiss === Swal.DismissReason.cancel){
	                Swal.fire({
	                    title: "취소되었습니다.",
	                    icon: "error",
						confirmButtonText: "확인",
						confirmButtonColor: "#34c38f"
	                })
	            }
	        })
			
            i.hide();
        }
    });

    // 일정 생성버튼 클릭시
    document.getElementById("btn-new-event").addEventListener("click", function(e){
		// 수정,삭제버튼 숨기고 저장버튼을 보이게
		document.getElementById("edit-event-btn").setAttribute("hidden", true),
        document.getElementById("btn-save-event").removeAttribute("hidden"),
		document.getElementById("btn-delete-event").setAttribute("hidden", true),
        v(e);
    });
});
