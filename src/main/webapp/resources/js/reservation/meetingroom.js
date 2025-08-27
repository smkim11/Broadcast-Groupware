document.addEventListener("DOMContentLoaded", function() {

	// 관리자 모달 관련 변수
	const adminModal = document.getElementById("management-modal");
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
					Swal.fire({
				        title: "등록되었습니다.",
				        icon: "success",
						confirmButtonText: "확인",
				        confirmButtonColor: "#34c38f"
				    }).then(() => {
						if(adminModal) adminModal.style.display = "none"; 
											location.reload();
				        });
				},
				error: function(err) {
	                console.error("등록 실패", err);
					Swal.fire({
	                    title: "등록을 실패했습니다.",
	                    icon: "error",
						confirmButtonText: "확인",
						confirmButtonColor: "#34c38f"
	                });
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
					Swal.fire({
				        title: "등록되었습니다.",
				        icon: "success",
						confirmButtonText: "확인",
				        confirmButtonColor: "#34c38f"
				    }).then(() => {
						if(adminModal) {adminModal.style.display = "none";
							}
							location.reload();
				        });
				},
				error: function(err) {
	                console.error("등록 실패", err);
					Swal.fire({
	                    title: "등록을 실패했습니다.",
	                    icon: "error",
						confirmButtonText: "확인",
						confirmButtonColor: "#34c38f"
	                });
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
		    var endHour = hour + 1;
		    var end = endHour.toString().padStart(2,'0') + ":50";
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
				if(!reasonText || !reasonText.value.trim()) {
				    alert("회의 주제를 입력해주세요.");
				    return;
				}

				// 선택 회의실
				var roomListSelect = document.getElementById("roomList");
				roomIdInput.value = roomListSelect ? roomListSelect.value : "";

				// 사유
				reasonInput.value = reasonText ? reasonText.value.trim() : "";
				
				// 현재시간
				var now = new Date();

				// 날짜 + 시간
				var reservations = [];
				for(var i=0; i<selectedTimes.length; i++){
				            var times = selectedTimes[i].split("-"); 

				            var startTimeStr = selectedDate + " " + times[0] + ":00";
				            var endDate = new Date(selectedDate + "T" + times[1] + ":00"); 
				            endDate.setMinutes(endDate.getMinutes() - 10); 
				            var hh = String(endDate.getHours()).padStart(2,'0');
				            var mm = String(endDate.getMinutes()).padStart(2,'0');
				            var endTimeStr = selectedDate + " " + hh + ":" + mm;

				            // startTime을 Date 객체로 생성
				            var startTime = new Date(selectedDate + "T" + times[0] + ":00");

				            // 현재 시간보다 이전이면 경고 후 종료
				            if(startTime < now){
				                alert("현재 시간 이전은 예약할 수 없습니다: ");
				                return; 
				            }

				            reservations.push({
				                roomId: roomListSelect.value,
				                roomReservationReason: reasonText.value.trim(),
				                roomReservationStartTime: startTimeStr,
				                roomReservationEndTime: endTimeStr
				            });
				        }

				//console.log("선택된 날짜:", selectedDate);
				//console.log("선택된 시간:", selectedTimes);
				//console.log("Ajax로 전송될 데이터:", $(this).serialize());

				$.ajax({
					url: '/api/meetingroom/reservation',
					type: 'post',
					contentType: 'application/json',
					data: JSON.stringify(reservations),
					success: function() {
						Swal.fire({
					        title: "등록되었습니다.",
					        icon: "success",
							confirmButtonText: "확인",
					        confirmButtonColor: "#34c38f"
					    }).then(() => {
							if(adminModal) {adminModal.style.display = "none";
								}
								location.reload();
					        });
					},
					error: function(err) {
		                console.error("등록 실패", err);
						Swal.fire({
		                    title: "등록을 실패했습니다.",
		                    icon: "error",
							confirmButtonText: "확인",
							confirmButtonColor: "#34c38f"
		                });
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

				// 문자열 비교 대신 날짜를 생성하여 yyyy-mm-dd을 직접 비교하는 방식으로 변경
				const reservationsForDay = currentRoomReservations.filter(reservation => {
					// 서버에서 받은 예약 시작 시간 문자열로 날짜 객체를 생성
					const reservationDate = new Date(reservation.roomReservationStartTime);
					// 캘린더에서 클릭한 날짜 문자열로 날짜 객체를 생성
					// 'T00:00:00'을 추가하여 시간대(timezone)에 따른 날짜 변경 오류를 방지
					const clickedDate = new Date(selectedDate + 'T00:00:00');

					// 두 날짜 객체의 yyyy-mm-dd 모두 일치하는 경우에만 true를 반환
					return reservationDate.getFullYear() === clickedDate.getFullYear() &&
						   reservationDate.getMonth() === clickedDate.getMonth() &&
						   reservationDate.getDate() === clickedDate.getDate();
				});

				const timeSlotsContainer = document.getElementById('timeSlots');
				const labels = timeSlotsContainer.querySelectorAll('label');

				labels.forEach(function(label) {
					const checkbox = label.querySelector('input[type="checkbox"]');
					const span = label.querySelector('span');
					const timeValue = checkbox.value;
					const parts = timeValue.split('-');
					
					const slotStart = new Date(selectedDate + 'T' + parts[0] + ':00');
					const tempEnd = new Date(selectedDate + 'T' + parts[1] + ':00');
					
					tempEnd.setMinutes(tempEnd.getMinutes() - 10);
					
					const slotEnd = tempEnd;

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
			
			
			// 예약 클릭시 상세보기 모달
			eventClick: function(info){
				var reservationId = info.event.id;
				//console.log("선택된 예약 ID:", reservationId);

				reservationDetail(reservationId, function(reservation) {
					if(!reservation) return;
	
					var detailModal = document.getElementById("detailReservation-modal");
					if(detailModal) detailModal.style.display = "flex";
	
					var tbody = document.getElementById("detailList");
					if(tbody){
					    tbody.innerHTML = "";
					    var tr = document.createElement("tr");

					    // 날짜
					    var useDate = reservation.roomReservationStartTime.split(" ")[0];

					    // 시간
					    var startTime = reservation.roomReservationStartTime.split(" ")[1].split(":").slice(0,2).join(":");
					    var endTime = reservation.roomReservationEndTime.split(" ")[1].split(":").slice(0,2).join(":");
					    var useTime = startTime + " ~ " + endTime;

					    tr.innerHTML = "<td>" + useDate + "</td>" +
					                   "<td>" + useTime + "</td>" +
					                   "<td>" + reservation.roomReservationReason + "</td>" +
					                   "<td>" + reservation.userName + '(' + reservation.userRank + ')' + "</td>";

					    tbody.appendChild(tr);
					}

					var cancelBtn = detailModal.querySelector(".cancel");
					if(cancelBtn) {
						cancelBtn.addEventListener("click", async function(){
						    // 예약 취소 여부 확인
						    const result = await Swal.fire({
						        title: "예약을 취소하시겠습니까?",
						        icon: "warning",
						        showCancelButton: true,
						        confirmButtonText: "예",
						        cancelButtonText: "아니요",
						        confirmButtonColor: "#34c38f",
						        cancelButtonColor: "#f46a6a"
						    });
		
						    if(result.isConfirmed){
						        try {
						            const res = await fetch("/api/room/cancel?reservationId=" + reservationId, {
						                method: "post"
						            });
		
						            if(!res.ok) throw new Error("서버 오류");
		
						            await Swal.fire({
						                title: "예약이 취소되었습니다.",
						                icon: "success",
						                confirmButtonText: "확인",
						                confirmButtonColor: "#34c38f",
						            })
										tr.remove();
	
						        } catch (err) {
						            Swal.fire({
						                title: "예약 취소 중 오류가 발생했습니다.",
						                text: err.message,
						                icon: "error",
						                confirmButtonText: "확인",
						                confirmButtonColor: "#34c38f"
						            });
						        }
						    } else if(result.dismiss === Swal.DismissReason.cancel){
						        Swal.fire({
						            title: "취소되었습니다.",
						            icon: "info",
						            confirmButtonText: "확인",
						            confirmButtonColor: "#34c38f"
						        }).then(() => {
							            detailModal.style.display = "none";
							            location.reload();
							        });
						    }
						});
					}
	
					// 닫기 버튼
					var closeBtns = detailModal.querySelectorAll(".close");
					closeBtns.forEach(function(btn){
					    btn.onclick = function(){ 
					        detailModal.style.display = "none"; 
							location.reload();
					    };
					});

					// 외부 클릭 시 닫기
					window.onclick = function(e){
					    if(e.target === detailModal) detailModal.style.display = "none";
					};
				});
			},
			
			events: currentRoomReservations.map(function(r){
				return {
					id: r.roomReservationId,            
					title: r.roomReservationReason,
					start: r.roomReservationStartTime,
					end: r.roomReservationEndTime
				};
				
			})
			
			
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
				//console.log("캘린더에 추가할 이벤트:", r);
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
	
	// 상세페이지 호출
	function reservationDetail(reservationId, callback) {
		$.ajax({
			url: "/api/room/detail",
			method: "GET",
			data: { roomReservationId: reservationId},
			success: function(res) {
				callback(res);
			},
			error: function(err) {
				currentRoomReservations = [];
				console.error("예약내역 불러오기 실패:", err);
			}
		});
	}
	
	// 내 예약 내역
	var myReservation = document.getElementById("myReservationBtn"); // 버튼 id
	var myReservationModal = document.getElementById("myReservation-modal");
	//var reservationId = info.event.id;
	//console.log("내 예약에서 삭제시 예약 번호: ", reservationId);

	if(myReservation && myReservationModal){
	    myReservation.addEventListener("click", function(){
	        
	        $.ajax({
	            url: '/api/room/myReservation',
	            method: 'GET',
	            success: function(reservations){
	                if(!reservations || reservations.length === 0){
	                    alert("예약 내역이 없습니다.");
	                    return;
	                }

	                var tbody = document.getElementById("myReservationList");
	                if(tbody){
	                    tbody.innerHTML = "";

	                    reservations.forEach(function(reservation){
	                        var tr = document.createElement("tr");

	                        var useDate = reservation.roomReservationStartTime.split(" ")[0];
	                        var startTime = reservation.roomReservationStartTime.split(" ")[1].slice(0,5);
	                        var endTime = reservation.roomReservationEndTime.split(" ")[1].slice(0,5);
	                        var useTime = startTime + " ~ " + endTime;
							
							//console.log("roomReservationId 확인:", reservation.roomReservationId);

							tr.dataset.reservationId = reservation.roomReservationId;
						    //console.log("dataset에 넣은 ID:", tr.dataset.reservationId);
							
	                        tr.innerHTML = "<td>" + reservation.roomName + "</td>" +
	                                       "<td>" + reservation.roomLocation + "</td>" +
	                                       "<td>" + useDate + "</td>" +
	                                       "<td>" + useTime + "</td>" +
	                                       "<td>" + reservation.roomReservationReason + "</td>" +
	                                       "<td><button class='cancelBtn' data-id='" + reservation.roomReservationId + "' style='background:red;color:white;'>취소</button></td>";

	                        tbody.appendChild(tr);
	                    });

	                    // 예약 취소 버튼 이벤트
						var cancelBtns = tbody.querySelectorAll(".cancelBtn");
						cancelBtns.forEach(function(btn){
						    btn.addEventListener("click", async function(e){
						        var tr = e.target.closest("tr"); 
						        const reservationId = tr ? tr.dataset.reservationId : null;

						        if(!reservationId){
						            console.error("reservationId가 비어있습니다.", e.target, tr);
						            alert("예약 ID를 가져올 수 없습니다.");
						            return;
						        }

						        const result = await Swal.fire({
						            title: "예약을 취소하시겠습니까?",
						            icon: "warning",
						            showCancelButton: true,
						            confirmButtonText: "예",
						            cancelButtonText: "아니요",
						            confirmButtonColor: "#34c38f",
						            cancelButtonColor: "#f46a6a"
						        });

						        if(result.isConfirmed){
						            try {
						                const res = await fetch("/api/room/cancel?reservationId=" + reservationId, {
						                    method: "post"
						                });

						                if(!res.ok) throw new Error("서버 오류");

						                await Swal.fire({
						                    title: "예약이 취소되었습니다.",
						                    icon: "success",
						                    confirmButtonText: "확인",
						                    confirmButtonColor: "#34c38f",
						                });
						                tr.remove();

						            } catch (err) {
						                Swal.fire({
						                    title: "예약 취소 중 오류가 발생했습니다.",
						                    text: err.message,
						                    icon: "error",
						                    confirmButtonText: "확인",
						                    confirmButtonColor: "#34c38f"
						                });
						            }
						        } else if(result.dismiss === Swal.DismissReason.cancel){
						            Swal.fire({
						                title: "취소되었습니다.",
						                icon: "info",
						                confirmButtonText: "확인",
						                confirmButtonColor: "#34c38f"
						            }).then(() => {
						                myReservationModal.style.display = "none";
						                location.reload();
						            });
						        }
						    });
						});

	                }

	                // 모달 열기
	                myReservationModal.style.display = "flex";

	                // 닫기 버튼
	                var closeBtns = myReservationModal.querySelectorAll(".close");
	                closeBtns.forEach(function(btn){
	                    btn.onclick = function(){ 
	                        myReservationModal.style.display = "none"; 
							location.reload();
	                    };
	                });

	                // 외부 클릭 시 닫기
	                window.onclick = function(e){
	                    if(e.target === myReservationModal) myReservationModal.style.display = "none";
	                };
	            },
	            error: function(err){
	                console.error("예약 내역 불러오기 실패", err);
	                alert("예약 내역을 가져오는 중 오류가 발생했습니다.");
	            }
	        });
	    });
	}

});