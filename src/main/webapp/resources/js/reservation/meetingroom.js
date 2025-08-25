document.addEventListener("DOMContentLoaded", function() {

    const modal = document.getElementById("management-modal");
    const btnOpenModal = document.getElementById("management");
    const closeBtns = modal.querySelectorAll(".close");
    const adminTypeSelect = modal.querySelector("#adminType");

    const forms = {
        "등록": modal.querySelector("#addForm"),
        "수정": modal.querySelector("#modifyForm"),
        "이슈관리": modal.querySelector("#issueForm")
    };

    // 모달 열기
    btnOpenModal.onclick = function() {
        modal.style.display = "flex";
        adminTypeSelect.value = "등록";
        showForm("등록");
    };

    // 닫기 버튼
    closeBtns.forEach(btn => btn.addEventListener("click", () => {
        modal.style.display = "none";
    }));

    // 외부 클릭 닫기
    window.onclick = function(e) {
        if(e.target == modal) modal.style.display = "none";
    };

    // 모드 변경 시 표시
    adminTypeSelect.addEventListener("change", function() {
        showForm(this.value);
    });

    function showForm(mode) {
        Object.values(forms).forEach(f => {
            if(f) f.style.display = "none";
        });
        if(forms[mode]) forms[mode].style.display = "block";
    }

    // 회의실 등록
    const addForm = forms["등록"];
    addForm.addEventListener("submit", function(e) {
        e.preventDefault();

        const roomName = this.roomName.value.trim();
        const roomLocation = this.roomLocation.value.trim();
        const roomCapacity = this.roomCapacity.value.trim();

        if(!roomName) { alert("회의실명을 입력하세요."); return; }
        if(!roomLocation) { alert("회의실 위치를 입력하세요."); return; }
        if(!roomCapacity) { alert("회의실 수용인원을 입력하세요."); return; }

        $.ajax({
            url: "/api/meetingroom/addRoom",
            type: "POST",
            data: $(this).serialize(),
            success: function() {
                alert("회의실 등록 완료");
                modal.style.display = "none";
                location.reload();
            },
            error: function(xhr, status, error) {
                alert("등록 실패: " + error);
            }
        });
    });
	
	// 관리자용 회의실 리스트
	


    const calendarEl = document.getElementById("calendar");
    if(!calendarEl) {
        console.error("calendar 요소를 찾을 수 없습니다.");
        return;
    }

	const calendar = new FullCalendar.Calendar(calendarEl, {
	    locale: "ko",               // 한글 로케일
	    themeSystem: "bootstrap",
	    headerToolbar: {
	        left: "prev,next today",
	        center: "title",
	        right: "dayGridMonth,timeGridWeek,timeGridDay,listMonth"
	    },
	    initialView: "dayGridMonth",
	    editable: true,
	    selectable: true,
	    droppable: true,
	    events: window.calendarEvents || [],
	    buttonText: {
	        today: "오늘",
	        month: "월",
	        week: "주",
	        day: "일",
	        list: "목록"
	    },
	    eventClick: function(info) {
	        console.log("선택된 이벤트:", info.event);
	        // 모달 열기
	    },
	    dateClick: function(info) {
	        console.log("선택된 날짜:", info.dateStr);
	        // 새 이벤트 생성 모달 열기
	    }
	});


    calendar.render();

});
