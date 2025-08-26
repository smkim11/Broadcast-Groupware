document.addEventListener("DOMContentLoaded", function() {


	// 관리자 모달 관련 변수
	const adminModal = document.getElementById("management-modal"); // 
	const btnOpenAdminModal = document.getElementById("management");
	const adminTypeSelect = adminModal ? adminModal.querySelector("#adminType") : null;
	const closeBtns = adminModal ? adminModal.querySelectorAll(".close") : [];

	const forms = adminModal ? {
		"등록": adminModal.querySelector("#addForm"),
		"이슈관리": adminModal.querySelector("#issueForm")
	} : {};

	// 관리자 모달 열기
	if(btnOpenAdminModal && adminModal && adminTypeSelect){
		btnOpenAdminModal.onclick = function() {
			adminModal.style.display = "flex";
			adminTypeSelect.value = "등록";
			showForm("등록");
		};
	}

	// 관리자 모달 닫기 버튼
	closeBtns.forEach(btn => {
		if(btn){
			btn.addEventListener("click", () => {
				if(adminModal) adminModal.style.display = "none";
			});
		}
	});

	// 관리자 모달 외부 클릭 닫기
	window.onclick = function(e) {
		if(e.target == adminModal) adminModal.style.display = "none";
	};

	// 관리자 모드 변경
	if(adminTypeSelect){
		adminTypeSelect.addEventListener("change", function() {
			showForm(this.value);
		});
	}

	function showForm(mode) {
		Object.values(forms).forEach(f => {
			if(f) f.style.display = "none";
		});
		if(forms[mode]) forms[mode].style.display = "block";
	}


	// 관리자 회의실 등록
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
					if(adminModal) adminModal.style.display = "none"; 
					location.reload();
				},
				error: function(xhr, status, error) {
					alert("등록 실패: " + error);
				}
			});
		});
	}
	
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
	
	// 관리자 이슈 등록
	const issueForm = forms["이슈관리"];
	if(issueForm) {
		issueForm.addEventListener("submit", function(e){
			e.preventDefault();

			const roomSelect = document.getElementById("modifyIssueSelect");
			const roomIdInput = issueForm.querySelector('input[name="roomId"]');
			if(roomSelect && roomIdInput) roomIdInput.value = roomSelect.value;

			const toggleSwitch = document.getElementById("toggleSwitch");
			let roomStatusInput = issueForm.querySelector('input[name="roomStatus"]');
			if(!roomStatusInput) {
				roomStatusInput = document.createElement("input");
				roomStatusInput.type = "hidden";
				roomStatusInput.name = "roomStatus";
				issueForm.appendChild(roomStatusInput);
			}
			roomStatusInput.value = toggleSwitch.checked ? 'Y' : 'N';

			const dateRange = document.getElementById("rentalPeriod").value.split(" ~ ");
			const startTimeVal = document.getElementById("startTime").value;
			const endTimeVal = document.getElementById("endTime").value;

			const startInput = issueForm.querySelector('input[name="roomUseReasonStartDate"]');
			const endInput = issueForm.querySelector('input[name="roomUseReasonEndDate"]');
			if(startInput && endInput && dateRange.length === 2) {
				startInput.value = dateRange[0] + " " + (startTimeVal || "08:00:00");
				endInput.value = dateRange[1] + " " + (endTimeVal || "10:00:00");
			}

			$.ajax({
				url: "/api/meetingroom/adminIssue",
				type: "POST",
				data: $(this).serialize(),
				success: function(response){
					alert("이슈등록 완료");
					if(adminModal) adminModal.style.display = "none";
					location.reload();
				},
				error: function(xhr, status, error){
					alert("이슈등록 실패: " + error);
				}
			});
		});
	}


	// 사용자 예약 모달
	var reservationModal = document.getElementById('reservationMeetingroom-modal');
	if(reservationModal){
		var timeSlotsContainer = document.getElementById('timeSlots');
		for(var hour=0; hour<24; hour+=2){
			var start = hour.toString().padStart(2,'0') + ":00";
			var end = (hour+2).toString().padStart(2,'0') + ":50";
			var label = document.createElement('label');
			label.innerHTML = '<input type="checkbox" name="selectedTime" value="' + start + '-' + end + '"><span>' + start + ' ~ ' + end + '</span>';
			timeSlotsContainer.appendChild(label);
		}

		// 예약 모달 닫기 버튼
		var closeButtons = reservationModal.querySelectorAll('.close, .closeBtn');
		closeButtons.forEach(function(btn){
			if(btn){
				btn.addEventListener('click', function(){
					reservationModal.style.display = 'none';
				});
			}
		});

		// 예약 폼 제출
		var reservationForm = document.getElementById('reservationMeetingroom');
		if(reservationForm){
			reservationForm.addEventListener('submit', function(e){
				e.preventDefault();
				
				var selectedTimes = Array.from(reservationForm.querySelectorAll('input[name="selectedTime"]:checked'))
					.map(function(i){ return i.value; });

				if(selectedTimes.length === 0){
					alert("시간을 선택해주세요.");
					return;
				}

				// hidden input 세팅
				var roomIdInput = document.getElementById("reservationRoomId");
				var reasonInput = document.getElementById("reservationReasonHidden");
				var startInput = document.getElementById("reservationStartTime");
				var endInput = document.getElementById("reservationEndTime");
				var reasonText = document.getElementById("roomReservationReason");

				if(!roomIdInput || !reasonInput || !startInput || !endInput){
					alert("예약용 hidden input이 없습니다.");
					return;
				}

				// 선택 회의실
				var roomListSelect = document.getElementById("roomList");
				roomIdInput.value = roomListSelect ? roomListSelect.value : "";

				// 사유
				reasonInput.value = reasonText ? reasonText.value.trim() : "";

				// 날짜 + 시간
				var reservations = selectedTimes.map(function(timeRange){
					var times = timeRange.split("-");
					return {
						roomId: roomListSelect.value,
						roomReservationReason: reasonText.value.trim(),
						roomReservationStartTime: selectedDate + " " + times[0] + ":00",
						roomReservationEndTime: selectedDate + " " + times[1] + ":50"
					};
				});

				//console.log("선택된 날짜:", selectedDate);
				//console.log("선택된 시간:", selectedTimes);
				console.log("Ajax로 전송될 데이터:", $(this).serialize());

				$.ajax({
					url: '/api/meetingroom/reservation',
					type: 'post',
					contentType: 'application/json',
					data: JSON.stringify(reservations),
					success: function() {
						alert('예약성공');
						reservationModal.style.display = "none"; 
						location.reload();
					},
					error: function(xhr, status, error){
						alert("예약 실패: " + error);
					}
				});

				reservationForm.reset();
			});
		}
	}

	
	// 캘린더
	var calendarEl = document.getElementById("calendar");
	var calendar;
	var selectedDate = null;
	var currentRoomReservations = []; 

	if(calendarEl){
		calendar = new FullCalendar.Calendar(calendarEl, {
			locale: "ko",
			themeSystem: "bootstrap",
			headerToolbar: {
				left: "prev,next today",
				center: "title",
				right: "dayGridMonth,timeGridWeek,timeGridDay,listMonth"
			},
			buttonText: {
						today: "오늘",
						month: "월",
						week: "주",
						day: "일",
						list: "목록"
			},
			initialView: "dayGridMonth",
			editable: false,
			selectable: true,
			droppable: false,
			dayMaxEvents: false,
			dateClick: function(info){
				selectedDate = info.dateStr;

				var roomId = $("#roomList").val();
				if (!roomId) {
					alert("먼저 회의실을 선택해주세요.");
					return;
				}

				// ########## 수정된 부분 ##########
				// 문자열 비교 대신 Date 객체를 생성하여 년/월/일을 직접 비교하는 방식으로 변경
				const reservationsForDay = currentRoomReservations.filter(reservation => {
					// 서버에서 받은 예약 시작 시간 문자열로 Date 객체를 생성합니다.
					const reservationDate = new Date(reservation.roomReservationStartTime);
					// 캘린더에서 클릭한 날짜 문자열로 Date 객체를 생성합니다.
					// 'T00:00:00'을 추가하여 시간대(timezone)에 따른 날짜 변경 오류를 방지합니다.
					const clickedDate = new Date(selectedDate + 'T00:00:00');

					// 두 Date 객체의 년, 월, 일이 모두 일치하는 경우에만 true를 반환합니다.
					return reservationDate.getFullYear() === clickedDate.getFullYear() &&
						   reservationDate.getMonth() === clickedDate.getMonth() &&
						   reservationDate.getDate() === clickedDate.getDate();
				});
				// ########## 수정 종료 ##########

				const timeSlotsContainer = document.getElementById('timeSlots');
				const labels = timeSlotsContainer.querySelectorAll('label');

				labels.forEach(function(label) {
					const checkbox = label.querySelector('input[type="checkbox"]');
					const span = label.querySelector('span');
					const timeValue = checkbox.value;
					const parts = timeValue.split('-');
					
					const slotStart = new Date(selectedDate + 'T' + parts[0] + ':00');
					const slotEnd = new Date(selectedDate + 'T' + parts[1] + ':50');

					checkbox.disabled = false;
					checkbox.checked = false;
					span.style.textDecoration = 'none';
					span.style.color = 'initial';

					const isBooked = reservationsForDay.some(function(reservation) {
						const reservationStart = new Date(reservation.roomReservationStartTime);
						const reservationEnd = new Date(reservation.roomReservationEndTime);
						
						return reservationStart < slotEnd && reservationEnd > slotStart;
					});

					if (isBooked) {
						checkbox.disabled = true;
						span.style.textDecoration = 'line-through';
						span.style.color = 'gray';
					}
				});

				var reservationModal = document.getElementById('reservationMeetingroom-modal');
				if(reservationModal){
					reservationModal.style.display = 'flex';
					var chooseDateP = reservationModal.querySelector('#chooseDate');
					if(chooseDateP) chooseDateP.textContent = "선택한 날짜: " + selectedDate;
				}
			},
			events: []
			
			
		});
		calendar.render();
	}

	// 뷰 좌측 상단에 회의실 리스트
	$.ajax({
	    url: '/api/meetingroom/roomlist',
	    type: 'GET',
	    success: function(meetingroomList) {
	        var select = $('#roomList');
	        select.empty();
	        select.append('<option value="">-- 회의실 선택 --</option>');

	        meetingroomList.forEach(function(room) {
	            select.append('<option value="' + room.roomId + '">' + room.roomName + ' (' + room.roomLocation + ')</option>');
	        });

	        if(meetingroomList.length > 0){
	            select.val(meetingroomList[0].roomId).trigger("change");
	        }
			
	    },
	    error: function(err) {
	        console.error('회의실 목록 불러오기 실패:', err);
	    }   
	});
	

	// 회의실 변경 시 예약 정보 다시 불러오기
	$("#roomList").on("change", function() {
		var roomId = $(this).val();

		if(!roomId) {
			calendar.removeAllEvents();
			currentRoomReservations = [];
			return;
		}

		$.ajax({
			url: '/api/meetingroom/reservations',
			type: 'GET',
			data: { roomId: roomId },
			success: function(response) { 
				if (response && Array.isArray(response)) {
					currentRoomReservations = response;
				} else if (response && response.data && Array.isArray(response.data)) {
					currentRoomReservations = response.data;
				} else {
					console.error("예상치 못한 예약 데이터 형식입니다.", response);
					currentRoomReservations = [];
				}
				
				calendar.removeAllEvents();
				currentRoomReservations.forEach(function(r){
					calendar.addEvent({
						id: r.roomReservationId,
						title: r.roomReservationReason,
						start: r.roomReservationStartTime,
						end: r.roomReservationEndTime,
						color: r.color || "#007bff"
					});
				});
			},
			error: function(err) {
				currentRoomReservations = [];
				console.error("예약내역 불러오기 실패:", err);
			}
		});
	});
});