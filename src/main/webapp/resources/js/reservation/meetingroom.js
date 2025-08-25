document.addEventListener("DOMContentLoaded", function() {

    const modal = document.getElementById("management-modal");
    const btnOpenModal = document.getElementById("management");
    const closeBtns = modal.querySelectorAll(".close");
    const adminTypeSelect = modal.querySelector("#adminType");

    const forms = {
        "등록": modal.querySelector("#addForm"),
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
    if(addForm) {
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
    }

    // 관리자용 회의실 리스트 불러오기
    $.ajax({
        url: '/api/meetingroom/adminList',
        method: 'GET',
        success: function(meetingroomList) {
            const select = $('#modifyIssueSelect');
            select.empty();
            select.append('<option value="">-- 회의실 선택 --</option>');

            meetingroomList.forEach(function(room) {
                const statusText = room.roomStatus === 'Y' ? '활성화' : '비활성화';
                select.append(
                    '<option value="' + room.roomId + '">'
                    + room.roomName + ' ' + room.roomLocation + '(' + statusText + ')'
                    + '</option>'
                );
            });
        },
        error: function(err) {
            console.error('회의실 목록을 불러오는데 실패했습니다.', err);
        }
    });

    // yyyy-mm-dd 포맷 함수
    function formatLocalDate(date){
        const yyyy = date.getFullYear();
        const mm = String(date.getMonth()+1).padStart(2,'0');
        const dd = String(date.getDate()).padStart(2,'0');
        return yyyy+"-"+mm+"-"+dd;
    }

    // 시간 select 옵션 생성 (2시간 단위)
    function populateTimeOptions(selectId, placeholder) {
        const select = document.getElementById(selectId);
        if(!select) return;
        select.innerHTML = `<option value="">${placeholder}</option>`;
        for(let h = 0; h < 24; h += 2){
            const hh = String(h).padStart(2,'0');
            select.innerHTML += `<option value="${hh}:00:00">${hh}:00</option>`;
        }
    }

    populateTimeOptions("startTime", "-- 시작시간 선택 --");
    populateTimeOptions("endTime", "-- 종료시간 선택 --");

    // flatpickr 적용 (기간 선택)
    flatpickr("#rentalPeriod", {
        mode: "range",
        dateFormat: "Y-m-d",
        locale: "ko",
        minDate: "today",
        allowInput: true,
        defaultDate: [new Date(), new Date()],
        onClose: function(selectedDates, dateStr, instance) {
            if(selectedDates.length === 0) return;

            let start = new Date(selectedDates[0]);
            let end = selectedDates.length === 1 ? new Date(selectedDates[0]) : new Date(selectedDates[1]);

            const startTime = document.getElementById("startTime").value || "08:00:00";
            const endTime = document.getElementById("endTime").value || "10:00:00";

            start.setHours(...startTime.split(":").map(Number));
            end.setHours(...endTime.split(":").map(Number));

            const issueForm = document.getElementById("issueForm");
            if(issueForm){
                let startInput = issueForm.querySelector('input[name="roomUseReasonStartDate"]');
                let endInput = issueForm.querySelector('input[name="roomUseReasonEndDate"]');
                startInput.value = formatLocalDate(start) + " " + startTime;
                endInput.value = formatLocalDate(end) + " " + endTime;
            }

            instance.input.value = formatLocalDate(start) + " ~ " + formatLocalDate(end);
        }
    });

    // 관리자 - 회의실 이슈등록
    const issueForm = forms["이슈관리"];
    if(issueForm) {
        issueForm.addEventListener("submit", function(e){
            e.preventDefault();

            // 회의실 선택
            const roomSelect = document.getElementById("modifyIssueSelect");
            const roomIdInput = issueForm.querySelector('input[name="roomId"]');
            if(roomSelect && roomIdInput) roomIdInput.value = roomSelect.value;

            // toggle 값
			const toggleSwitch = document.getElementById("toggleSwitch");
			    let roomStatusInput = issueForm.querySelector('input[name="roomStatus"]');
			    if(!roomStatusInput) {
			        roomStatusInput = document.createElement("input");
			        roomStatusInput.type = "hidden";
			        roomStatusInput.name = "roomStatus";
			        issueForm.appendChild(roomStatusInput);
			    }
			    roomStatusInput.value = toggleSwitch.checked ? 'Y' : 'N';
				console.log("roomStatus 값:", roomStatusInput.value);

            // 날짜 + 시간 합쳐서 hidden input에 세팅
			const dateRange = document.getElementById("rentalPeriod").value.split(" ~ ");
			    const startTimeVal = document.getElementById("startTime").value;
			    const endTimeVal = document.getElementById("endTime").value;

			    const startInput = issueForm.querySelector('input[name="roomUseReasonStartDate"]');
			    const endInput = issueForm.querySelector('input[name="roomUseReasonEndDate"]');
			    if(startInput && endInput && dateRange.length === 2) {
					startInput.value = dateRange[0] + " " + (startTimeVal || "08:00:00");
			        endInput.value = dateRange[1] + " " + (endTimeVal || "10:00:00");
			    }

            console.log("Ajax로 전송될 데이터:", $(this).serialize());

            $.ajax({
                url: "/api/meetingroom/adminIssue",
                type: "POST",
                data: $(this).serialize(),
                success: function(response){
                    alert("이슈등록 완료");
                    modal.style.display = "none";
                    location.reload();
                },
                error: function(xhr, status, error){
                    alert("이슈등록 실패: " + error);
                }
            });
        });
    }

    // 캘린더
    const calendarEl = document.getElementById("calendar");
    if(calendarEl){
        const calendar = new FullCalendar.Calendar(calendarEl, {
            locale: "ko",
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
            eventClick: function(info){
                console.log("선택된 이벤트:", info.event);
            },
            dateClick: function(info){
                console.log("선택된 날짜:", info.dateStr);
            }
        });
        calendar.render();
    }

});
