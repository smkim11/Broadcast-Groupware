	// 예약 리스트
	document.addEventListener("DOMContentLoaded", function() {
	var carTable = document.getElementById("carTable");
	var pagination = document.getElementById("pagination");
	var page = 1;
	var size = 10;
	var pageGroupSize = 5;

	function loadCarList(currentPage) {
		page = currentPage;
		carTable.innerHTML = "";

		fetch("/api/user/car?page=" + page + "&size=" + size)
			.then(function(res) {
				return res.json();
			})
			.then(function(data) {
				var carReservationList = data.carReservationList;

				if (data.role === 'admin') {
		            document.getElementById('addCar').style.display = 'inline-block';
		        }

				for (var i = 0; i < carReservationList.length; i++) {
					var c = carReservationList[i];
					var tr = document.createElement("tr");

					// 차량 정보 td
					var tdInfo = document.createElement("td");
					tdInfo.innerHTML = '<div class="vehicleNo">' + c.vehicleNo + '</div>' +
									   '<div class="vehicleName">' + c.vehicleName + '</div>' +
									   '<div class="vehicleType">' + c.vehicleType + '</div>';
					tr.appendChild(tdInfo);

					// 예약 현황 td
					var tdChart = document.createElement("td");
					tdChart.innerHTML = '<div class="chart-container" data-reservations="' + encodeURIComponent(JSON.stringify(c.reservationPeriods)) + '"></div>';
					tr.appendChild(tdChart);

					// 예약 버튼 td
					var tdBtn = document.createElement("td");
					if (c.vehicleStatus === "Y") {
						tdBtn.innerHTML = '<button class="reservationBtn" data-vehicle-id="' + c.vehicleId + '">예약하기</button>';
					} else {
						tdBtn.innerHTML = '<button style="background-color: red; border-color: red;">예약불가</button>';
					}
					tr.appendChild(tdBtn);

					// 숨겨진 input 추가
					var hiddenInput = document.createElement("input");
					hiddenInput.type = "hidden";
					hiddenInput.value = c.vehicleId;
					tr.appendChild(hiddenInput);

					carTable.appendChild(tr);
				}

				drawCharts();

				// ===== 페이징 추가 =====
				renderPagination(data.pageDto.totalPage);
			})
			.catch(function(err) {
				console.error("차량 데이터 로드 실패:", err);
			});
	}

	function renderPagination(totalPage) {
		pagination.innerHTML = ""; // 기존 페이지 번호 초기화

		var currentGroup = Math.floor((page - 1) / pageGroupSize);
		var startPage = currentGroup * pageGroupSize + 1;
		var endPage = Math.min(startPage + pageGroupSize - 1, totalPage);

		// 이전 그룹 이동
		var prevLi = document.createElement("li");
		prevLi.className = "page-item" + (startPage > 1 ? "" : " disabled");
		var prevA = document.createElement("a");
		prevA.className = "page-link";
		prevA.href = "#";
		prevA.innerText = "<";
		prevA.onclick = function(e) {
			e.preventDefault();
			if (startPage > 1) loadCarList(startPage - 1);
		};
		prevLi.appendChild(prevA);
		pagination.appendChild(prevLi);

		// 페이지 번호 반복
		for (var i = startPage; i <= endPage; i++) {
			var li = document.createElement("li");
			li.className = "page-item" + (i === page ? " active" : "");
			var a = document.createElement("a");
			a.className = "page-link";
			a.href = "#";
			a.innerText = i;
			a.onclick = (function(pageNum) {
				return function(e) {
					e.preventDefault();
					loadCarList(pageNum);
				};
			})(i);
			li.appendChild(a);
			pagination.appendChild(li);
		}

		// 다음 그룹 이동
		var nextLi = document.createElement("li");
		nextLi.className = "page-item" + (endPage < totalPage ? "" : " disabled");
		var nextA = document.createElement("a");
		nextA.className = "page-link";
		nextA.href = "#";
		nextA.innerText = ">";
		nextA.onclick = function(e) {
			e.preventDefault();
			if (endPage < totalPage) loadCarList(endPage + 1);
		};
		nextLi.appendChild(nextA);
		pagination.appendChild(nextLi);
	}

	// 초기 데이터 로드
	loadCarList(page);
});


	// 로그인 사용자 ID
	const userId = document.getElementById("loginUser").dataset.userId;

	// 초기 날짜 세팅: 현재시간 ~ 23:59
	let today = new Date();
	selectedStartDate = new Date(today);
	selectedStartDate.setHours(0,0,0,0);
	selectedEndDate = new Date(today);
	selectedEndDate.setHours(23,59,59,999);
	let drawnTimes = new Set(); // 중복 시간 출력 방지

	// 시간 라벨 표시 함수
	function drawTimeLabel(ctx, x, date) {
		const hourStr = date.getHours().toString().padStart(2,'0') + ":00";
		if(hourStr === "00:00") return;
		const key = x + "-" + hourStr;
		if(drawnTimes.has(key)) return;
		ctx.fillStyle = "black";
		ctx.font = "10px Arial";
		ctx.fillText(hourStr, x, 45);
		drawnTimes.add(key);
	}

	// 오늘날짜 체크
	function isToday(date) {
		const now = new Date();
		return date.getFullYear() === now.getFullYear() &&
			   date.getMonth() === now.getMonth() &&
			   date.getDate() === now.getDate();
	}

	// 차트 그리기 함수
	function drawCharts() {
			const charts = document.querySelectorAll(".chart-container");

			charts.forEach(chart => {

				chart.innerHTML = "";

				const localDrawnTimes = new Set();

				let periods = JSON.parse(decodeURIComponent(chart.dataset.reservations || "[]"));

				let canvasStart = new Date(selectedStartDate);
				let canvasEnd = new Date(selectedEndDate);

				const canvas = document.createElement("canvas");
				chart.appendChild(canvas);

				canvas.width = chart.clientWidth;
				canvas.height = chart.clientHeight;

				const ctx = canvas.getContext("2d");

				const totalHours = (canvasEnd - canvasStart) / (1000 * 60 * 60);
				const unitWidth = canvas.width / totalHours;

				const drawTimeLabelLocal = (x, date) => {
					const hourStr = date.getHours().toString().padStart(2, '0') + ":00";
					if (hourStr === "00:00") return;
					const key = x + "-" + hourStr;
					if (localDrawnTimes.has(key)) return;
					ctx.fillStyle = "black";
					ctx.font = "10px Arial";
					ctx.fillText(hourStr, x, 45);
					localDrawnTimes.add(key);
				};

				// 1) 전체 바
				ctx.fillStyle = "#e8e6e6";
				ctx.fillRect(0, 15, canvas.width, 20);
				drawTimeLabelLocal(0, canvasStart);

				// 2) 선택 구간   
				const startTimeValue = document.getElementById("startTime").value;
				const endTimeValue = document.getElementById("endTime").value;

				if (startTimeValue && endTimeValue) {

					const [sh, sm] = startTimeValue.split(":").map(Number);
					const [eh, em] = endTimeValue.split(":").map(Number);

					const selStart = new Date(selectedStartDate); selStart.setHours(sh, sm, 0);
					const selEnd = new Date(selectedEndDate); selEnd.setHours(eh, em, 0);

					const cs = new Date(Math.max(selStart, canvasStart));
					const ce = new Date(Math.min(selEnd, canvasEnd));

					if (ce > cs) {

						const x1 = ((cs - canvasStart) / (1000 * 60 * 60)) * unitWidth;
						const x2 = ((ce - canvasStart) / (1000 * 60 * 60)) * unitWidth;

						ctx.fillStyle = "blue";
						ctx.fillRect(x1, 15, x2 - x1, 20);

						drawTimeLabelLocal(x1, cs);
						drawTimeLabelLocal(x2, ce);
					}
				}

				// 3) 예약 구간 
				periods.forEach((p, index) => {

					const startStr = p.reservationStart || p.start;
					const endStr = p.reservationEnd || p.end;

					if (!startStr || !endStr) return;

					const resStart = new Date(startStr.replace(" ", "T"));
					const resEnd = new Date(endStr.replace(" ", "T"));

					if (isNaN(resStart.getTime()) || isNaN(resEnd.getTime())) {
						console.log("예약 데이터 변환 실패:", p);
						return;
					}

					const displayStart = resStart < canvasStart ? canvasStart : resStart;
					const displayEnd = resEnd > canvasEnd ? canvasEnd : resEnd;

					if (displayEnd <= displayStart) return;

					const xStart = ((displayStart - canvasStart) / (1000 * 60 * 60)) * unitWidth;
					const xEnd = ((displayEnd - canvasStart) / (1000 * 60 * 60)) * unitWidth;


					// console.log("예약", index + 1, "=> xStart:", xStart, "xEnd:", xEnd, "width:", xEnd - xStart);

					ctx.fillStyle = "red";
					ctx.fillRect(xStart, 15, xEnd - xStart, 20);

					drawTimeLabelLocal(xStart, displayStart);
					drawTimeLabelLocal(xEnd, displayEnd);
				});

				// 4) 날짜 표시 (MM-DD)
				const oneDay = 1000 * 60 * 60 * 24;
				ctx.fillStyle = "black";
				ctx.font = "bold 10px Arial";

				for (let d = new Date(canvasStart); d <= canvasEnd; d = new Date(d.getTime() + oneDay)) {
					const offsetX = ((d - canvasStart) / (1000 * 60 * 60)) * unitWidth;
					const month = (d.getMonth() + 1).toString().padStart(2, '0');
					const day = d.getDate().toString().padStart(2, '0');
					ctx.fillText(month + "-" + day, offsetX, 10);
				}

				// 5) 오늘 이전 회색 처리
				const now = new Date();
				const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
				if (now > canvasStart) {
					const pastHours = Math.min((today - canvasStart) / (1000 * 60 * 60), totalHours);
					const pastX = pastHours * unitWidth;
					let grayStartX = 0;
					let grayEndX = pastX;

					periods.forEach(p => {
						const reservationStart = new Date(p.reservationStart);
						if (reservationStart < today) {
							const reservedStartX = ((reservationStart - canvasStart) / (1000 * 60 * 60)) * unitWidth;
							grayEndX = Math.max(0, reservedStartX);
						}
					});

					if (grayEndX > grayStartX) {
						ctx.fillStyle = "#e8e6e6";
						ctx.fillRect(grayStartX, 15, grayEndX - grayStartX, 20);
					}
				}
			});
		}


	// 시간 드롭다운
	function populateTimeOptions(selectId, firstOptionLabel){
	    const select = document.getElementById(selectId);
	    select.innerHTML="";
	    const firstOption = document.createElement("option");
	    firstOption.value="";
	    firstOption.textContent=firstOptionLabel;
	    select.appendChild(firstOption);
	
	    for(let h=0;h<24;h++){
	        const hourStr = h.toString().padStart(2,'0');
	        const option = document.createElement('option');
	        option.value = hourStr+":00";
	        option.textContent = hourStr+":00";
	        select.appendChild(option);
	    }
	}
	
	// 시작시간 유효성
	function validateStartTime(){
	    const timeSelect = document.getElementById("startTime");
	    const selectedTime = timeSelect.value;
	    if(!selectedTime || !selectedStartDate) return;
	
	    const today = new Date();
	    const [hours, minutes] = selectedTime.split(":").map(Number);
	
	    const selectedDateTime = new Date(selectedStartDate.getFullYear(),
	        selectedStartDate.getMonth(),
	        selectedStartDate.getDate(),
	        hours, minutes);
	
	    if(selectedStartDate.toDateString() === today.toDateString()){
	        if(selectedDateTime<today){
	            alert("선택한 시작시간은 현재 시간 이후여야 합니다.");
	            timeSelect.value="";
	        }
	    }
	}
	
	// yyyy-mm-dd 포맷
	function formatLocalDate(date){
	    const yyyy = date.getFullYear();
	    const mm = String(date.getMonth()+1).padStart(2,'0');
	    const dd = String(date.getDate()).padStart(2,'0');
	    return yyyy+"-"+mm+"-"+dd;
	}

		document.addEventListener("DOMContentLoaded", function(){
		    populateTimeOptions("startTime","-- 대여시간 선택 --");
		    populateTimeOptions("endTime","-- 반납시간 선택 --");
		
		    flatpickr("#rentalPeriod",{
		        mode:"range",
		        dateFormat:"Y-m-d",
		        locale:"ko",
		        minDate:"today",
		        allowInput:true,
		        defaultDate:[new Date(), new Date()],
		        onClose:function(selectedDates, dateStr, instance){
		            if(selectedDates.length===1){
		                selectedStartDate = new Date(selectedDates[0]);
		                selectedStartDate.setHours(0,0,0,0); // 당일 선택시 초기값 00:00
		                selectedEndDate = new Date(selectedDates[0]);
		                selectedEndDate.setHours(23,59,59,999); // 당일 선택 초기값 23:59
		                instance.setDate([selectedStartDate, selectedEndDate], true);
		            } else if(selectedDates.length===2){
		                selectedStartDate = new Date(selectedDates[0]);
		                selectedEndDate = new Date(selectedDates[1]);
		                selectedStartDate.setHours(0,0,0,0);
		                selectedEndDate.setHours(23,59,59,999);
		            }
		            
		            drawCharts();
		        }
		    });
	
		
		    document.getElementById("startTime").addEventListener("change",validateStartTime);
		
		    drawCharts();
		
		    document.getElementById("search").addEventListener("click", function(e){
		        e.preventDefault();
		        
		        drawCharts();
		    });
		});
		
		// 날짜 형태 yyyy-mm-dd + hh:mm:ss DB-datetime형식으로
		function formatDateTime(date, time) {
		    if(!date || !time) return "";
		    const yyyy = date.getFullYear();
		    const mm = String(date.getMonth() + 1).padStart(2, '0');
		    const dd = String(date.getDate()).padStart(2, '0');
		    return yyyy + "-" + mm + "-" + dd + " " + time + ":00";
		}
	
		// 조회버튼 이벤트
		document.getElementById("search").addEventListener("click", function() {
		    var vehicleType = document.querySelector("select").value;
		    var startDate = selectedStartDate;
		    var endDate = selectedEndDate;
		    var startTime = document.getElementById("startTime").value;
		    var endTime = document.getElementById("endTime").value;
		    
		    // 대여시간 > 반납시간 방지 - 대여시간 이후 반납시간을 선택
		    var startDateTime = formatDateTime(startDate, startTime);
		    var endDateTime = formatDateTime(endDate, endTime);

		    const startDT = new Date(startDateTime.replace(" ", "T"));
		    const endDT = new Date(endDateTime.replace(" ", "T"));

		    if(vehicleType == '') {
				alert('차량타입을 선택하세요.')
		    } else if(endDate == '') {
				alert('예약 기간을 선택하세여.')
		    } else if(startTime == '') {
				alert('예약시간을 선택하세요.')
		    } else if(startDT  > endDT) {
				alert('예약 시간 이후에 반납시간을 선택하세요')
		    } else if(startDT == endDT) {
				alert('예약시간과 반납시간이 같습니다.')
		    }
		    
		    const rows = document.querySelectorAll("table tr");
		    for(let i=1; i<rows.length; i++){ 
		        const typeCell = rows[i].querySelector(".vehicleType");
		        if(vehicleType === "전체" || vehicleType === "" || typeCell.textContent === vehicleType){
		            rows[i].style.display = "";
		        } else {
		            rows[i].style.display = "none";
		        }
		    }
		    
		    drawCharts();
	
		    //console.log("차량 타입:", vehicleType);
		    //console.log("대여일시:", startDateTime);
		    //console.log("반납일시:", endDateTime);
		});
		
		// 모달
		document.addEventListener("DOMContentLoaded", function() {
	
		    const modal = document.getElementById("carModal");
		    const btn = document.getElementById("addCar");
		    const closeBtn = modal.querySelector(".close");
		    const closeBtns = modal.querySelectorAll(".close1");
		    
		    // 폼 가져오기
		    const addForm = document.getElementById("addForm");
		    const modifyForm = document.getElementById("modifyCar");
		    const toggleForm = document.getElementById("carToggle");
		    const adminTypeSelect = document.getElementById("adminType");
	
		    // 모달 열기
		    btn.onclick = function() {
		        modal.style.display = "flex";
		        showForm("등록");
		    	adminTypeSelect.value = "등록";
		    	
		    	selectAdminCarList();
		    	
		    }
	
		    // 모달 닫기버튼 (x)
		    closeBtn.onclick = function() {
		        modal.style.display = "none";
		    }
		    
		 	// 모달 닫기버튼
		    closeBtns.forEach(function(b) {
				b.onclick = function() {
					modal.style.display = "none";
				}
			});
	
		    // 모달 외부 클릭 닫기
		    window.onclick = function(event) {
		        if(event.target == modal) {
		            modal.style.display = "none";
		        }
		    }
	
		    // 등록
		    addForm.addEventListener("submit", function(e) {
		        e.preventDefault();
		        
		        const vehicleNo = this.vehicleNo.value.trim();
		        const vehicleName = this.vehicleName.value.trim();
		        
		        if(!vehicleNo) {
					alert("차량번호를 입력하세요")
					return;
		        } else if(!vehicleName) {
		        	alert("차종을 입력하세요")
					return;
		        } 
	
		        $.ajax({
		            url: "/api/car/addCar",
		            type: "post",
		            data: $(this).serialize(),
		            success: function(response) {
						Swal.fire({
				            title: "차량 등록 완료",
				            icon: "success",
				            confirmButtonText: "확인",
				            confirmButtonColor: "#34c38f"
				        }).then(() => {
				            modal.style.display = "none";
				            location.reload();
				        });
		            },
		            error: function(xhr, status, error) {
						Swal.fire({
				            title: "등록 실패",
				            text: error,
				            icon: "error",
				            confirmButtonText: "확인",
				            confirmButtonColor: "#34c38f"
				        });
		            }
		        });
		    });
		    
			// 차량정보 수정
			/*
		    modifyCar.addEventListener("submit", function(e) {
				e.preventDefault();
				
				$.ajax({
					url: "/api/car/modifyCar",
					type: "post",
					data: $(this).serialize(),
					success: function(response) {
						Swal.fire({
					        title: "수정되었습니다",
					        icon: "success",
							confirmButtonText: "확인",
					        confirmButtonColor: "#34c38f"
					    }).then(() => {
					            modal.style.display = "none";
					            location.reload();
					        });
					},
					error: function(xhr, status, error) {
						Swal.fire({
		                    title: "수정을 실패했습니다.",
		                    icon: "error",
							confirmButtonText: "확인",
							confirmButtonColor: "#34c38f"
		                });
					}
				});
		    });
			*/
		    
		    // 비활성 or 활성화
		    carToggle.addEventListener("submit", function(e) {
				e.preventDefault();
				//console.log($(this).serialize());
				
				$.ajax({
				    url: "/api/car/carToggle",
				    type: "post",
				    data: {
				        vehicleId: $('#toggleVehicleSelect').val(),
				        vehicleUseReasonContent: $('#toggleReason').val(),
				        vehicleUseReasonStartDate: $('#startDate').val(),
				        vehicleUseReasonEndDate: $('#endDate').val(),
				        vehicleStatus: $('#toggleSwitch').is(':checked') ? "Y" : "N"
				    },
				    success: function(res){
						Swal.fire({
					        title: "수정되었습니다",
					        icon: "success",
							confirmButtonText: "확인",
					        confirmButtonColor: "#34c38f"
					    }).then(() => {
					            modal.style.display = "none";
					            location.reload();
					        });
				    }
				});
		    });
		    
	    
		// 이슈등록에 사용할 차량 리스트
	    $(document).ready(function() {
	        $.ajax({
	            url: '/api/car/adminCarList',
	            method: 'GET',
	            success: function(vehicleList) {
	              
	            	 var selects = [$('#modifyVehicleSelect'), $('#toggleVehicleSelect')];

	            	 selects.forEach(function(select) {
	                     select.empty();
	                     select.append('<option value="">-- 차량 선택 --</option>');
	                     
	                     vehicleList.forEach(function(vehicle) {
	                         
	                         var statusText = vehicle.vehicleStatus === 'Y' ? '활성화' : '비활성화';

	                         // 옵션 추가
	                         select.append(
	                             '<option value="' + vehicle.vehicleId + '">' 
	                             + vehicle.vehicleName + ' ' + vehicle.vehicleNo + ' (' + statusText + ')' 
	                             + '</option>'
	                         );
	                     });
	                 });
	             },
	             
	            error: function(err) {
	                console.error('차량 목록을 불러오는데 실패했습니다.', err);
	            }
	        });
	    });
		
		    // 모달 열 때 호출
		    $('#toggleModalOpenBtn').on('click', function() {
		        $('#carToggle').show();
		    });

		    // 비활성화 폼에서 선택한 차량 가져오기
		    $('#toggleVehicleSelect').change(function() {
		        var selectedId = $(this).val();
		        //console.log('선택한 차량 ID (이슈등록 폼):', selectedId);
		        $('#carToggle input[name="vehicleId"]').val(selectedId); 
		    });

		    // 폼에서 선택한 차량 가져오기
		    $('#modifyVehicleSelect').change(function() {
		        var selectedId = $(this).val();
		        $('input[name="vehicleId"]').val(selectedId);
		    });

		    // 폼 전환
		    function showForm(type) {
		        // 모든 폼 숨기기
		        addForm.style.display = "none";
		        modifyForm.style.display = "none";
		        toggleForm.style.display = "none";

		        // 선택한 폼만 보이기
		        if (type === "등록") {
		            addForm.style.display = "block";
		        } else if (type === "수정") {
		            modifyForm.style.display = "block";
		        } else if (type === "이슈등록") {
		            toggleForm.style.display = "block";
		        }     
		        
		    }

		    // select 값 바뀔 때 폼 전환
		    adminTypeSelect.addEventListener("change", function() {
		        showForm(this.value);
		    });
		});

		
		// 예약확인 모달
		document.addEventListener("DOMContentLoaded", function() {
			const modal = document.getElementById("confirmReservation");
			const btn = document.getElementById("myReservation");       
			const closeBtn = modal.querySelector(".close");             
			const closeBtns = modal.querySelectorAll(".close1");         
			const table = document.getElementById("myReservationList"); 
		
			// 예약 확인 버튼 클릭 시 모달 열기 + 데이터 채우기
			btn.addEventListener("click", async function() {
				// 테이블 기존 내용 초기화 (헤더 제외)
				table.querySelectorAll("tr:not(:first-child)").forEach(tr => tr.remove());
		
				try {
					const res = await fetch("/api/user/myReservationList");
					if (!res.ok) throw new Error("서버 오류");
		
					const data = await res.json();
					const myReservationList = data.myReservationList;
					
					//console.log("예약 리스트 확인:", myReservationList);

		
					// 예약 목록 테이블에 채우기
					myReservationList.forEach(c => {
						const tr = document.createElement("tr");
		
						// 차량번호
						const tdVehicleNo = document.createElement("td");
						tdVehicleNo.textContent = c.vehicleNo;
						tr.appendChild(tdVehicleNo);
		
						// 대여 시간
						const tdRentDate = document.createElement("td");
						tdRentDate.textContent = c.rentDate;
						tr.appendChild(tdRentDate);
		
						// 반납 시간
						const tdReturnDate = document.createElement("td");
						tdReturnDate.textContent = c.returnDate;
						tr.appendChild(tdReturnDate);
						
						// rentDateObj 정의 후 24시간 전 계산
						const rentDateObj = new Date(c.rentDate.replace(/-/g, "/"));
						const twentyFourHoursBefore = new Date(rentDateObj.getTime() - 24*60*60*1000);
						const now = new Date();

						// 24시간 전까지만 변경/취소 가능
						const isChangeable = now < twentyFourHoursBefore && rentDateObj > now;
		
					
						// 예약 취소 버튼
						const tdCancel = document.createElement("td");
						const cancelBtn = document.createElement("button");
						cancelBtn.textContent = "취소";
						cancelBtn.disabled = !isChangeable;
						
						// 예약 취소 이벤트
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
						            const res = await fetch("/api/user/cancelMyReservation?vehicleReservation=" + c.vehicleReservationId, {
						                method: "post"
						            });

						            if(!res.ok) throw new Error("서버 오류");

						            await Swal.fire({
						                title: "예약이 취소되었습니다.",
						                icon: "success",
						                confirmButtonText: "확인",
						                confirmButtonColor: "#34c38f"
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
							            modal.style.display = "none";
							            location.reload();
							        });
						    }
						});

						
						// 버튼생성
						tdCancel.appendChild(cancelBtn);
						tr.appendChild(tdCancel);
		
						table.appendChild(tr);
					});
		
					// 모달 열기
					modal.style.display = "flex";
		
				} catch (err) {
					console.error(err);
					alert("예약 내역을 가져오는 중 오류가 발생했습니다.");
				}
				// 모달 닫기버튼 (x)
			    closeBtn.onclick = function() {
			        modal.style.display = "none";
			    }
			    
			 	// 모달 닫기버튼
			    closeBtns.forEach(function(b) {
					b.onclick = function() {
						modal.style.display = "none";
					}
				});
		
			    // 모달 외부 클릭 닫기
			    window.onclick = function(event) {
			        if(event.target == modal) {
			            modal.style.display = "none";
			        }
			    }
			});
		});
	
		// 날짜 포맷 YYYY-MM-DD
		function formatDate(date) {
		    let y = date.getFullYear();
		    let m = ("0" + (date.getMonth() + 1)).slice(-2);
		    let d = ("0" + date.getDate()).slice(-2);
		    return y + "-" + m + "-" + d;
		}
		
		// Flatpickr 초기화(이슈등록)
		flatpickr("#issueDate", {
		    mode: "range",      // 날짜 범위 선택 가능
		    dateFormat: "Y-m-d",
		    locale:"ko",
		    defaultDate: new Date(), // 오늘 기본값
		    onClose: function(selectedDates) {
		        // 시작일과 종료일을 hidden input에 넣기
		        if (selectedDates.length === 1) {
		            // 당일 선택
		            document.getElementById("startDate").value = formatDate(selectedDates[0]);
		            document.getElementById("endDate").value = formatDate(selectedDates[0]);
		        } else if (selectedDates.length === 2) {
		            // 범위 선택
		            document.getElementById("startDate").value = formatDate(selectedDates[0]);
		            document.getElementById("endDate").value = formatDate(selectedDates[1]);
		        }
		        
		        // console.log('비활성 시작시간 : ', startDate);
		        // console.log('비활성 종료시간 :', endDate);
		    }
		});
		
		// 예약 버튼 이벤트 (모든 버튼에 적용)
		document.getElementById("carTable").addEventListener("click", function(e){
		    if(e.target && e.target.classList.contains("reservationBtn")){
		        var vehicleId = e.target.dataset.vehicleId;
		        var startDateTime = formatDateTime(selectedStartDate, document.getElementById("startTime").value);
		        var endDateTime = formatDateTime(selectedEndDate, document.getElementById("endTime").value);
		
		        if(!userId) {
					alert('로그인이 필요합니다.')
					return;
		        } else if(!vehicleId) {
					alert('차량선택에 에러가 발생했습니다.')
					return;
		        } else if(!startDateTime) {
					alert('대여시간을 선택해주세요.')
					return;
		        } else if(!endDateTime) {
					alert('반납시간을 선택해주세요.')
					return;
		        }
		        
		        //console.log("userId:", userId);
		        //console.log("vehicleId:", vehicleId);
		        //console.log("start:", startDateTime);
		        //console.log("end:", endDateTime);		     
		
		        $.ajax({
		            url: "/api/car/CarReservation",
		            type: "POST",
		            contentType: "application/json",
		            data: JSON.stringify({
		                userId: userId,
		                vehicleId: vehicleId,
		                vehicleReservationStartTime: startDateTime,
		                vehicleReservationEndTime: endDateTime
		            }),
		            success: function(res) {						
						Swal.fire({
					        title: "예약되었습니다.",
					        icon: "success",
							confirmButtonText: "확인",
					        confirmButtonColor: "#34c38f"
					    }).then(() => {
					            modal.style.display = "none";
					            location.reload();
					        });
		              
		            },
		            error: function(err) {
		                console.error("예약 실패", err);
						Swal.fire({
		                    title: "등록을 실패했습니다.",
		                    icon: "error",
							confirmButtonText: "확인",
							confirmButtonColor: "#34c38f"
		                });
		            }
		        });
		    }
		});
