// 이벤트 클릭 시 읽기 전용 모드로 전환
function eventClicked(){
    document.getElementById("form-event").classList.add("view-event"), // 폼을 'view-event' 모드로
    document.getElementById("event-title").classList.replace("d-block","d-none"), // 제목 입력 필드 숨김
    document.getElementById("event-type").classList.replace("d-block","d-none"), // 카테고리 입력 필드 숨김
    document.getElementById("btn-save-event").setAttribute("hidden",true) // 저장 버튼 숨김
}



// 입력 가능한 상태로 전환
function eventTyped(){
    document.getElementById("form-event").classList.remove("view-event"), // 읽기 모드 해제
    document.getElementById("event-title").classList.replace("d-none","d-block"), // 제목 입력 필드 표시
    document.getElementById("event-type").classList.replace("d-block","d-none"), // 카테고리 입력 필드 표시
    document.getElementById("btn-save-event").removeAttribute("hidden") // 저장 버튼 표시
}


// 관리 모달
document.addEventListener("DOMContentLoaded", function() {
	const modal = document.getElementById("management-modal");
	const btn = document.getElementById("management");
	const closeBtn = modal.querySelectorAll(".close");
	
	const addForm = document.getElementById("addForm");
	const modifyForm = document.getElementById("modifyFrom");
	const issueForm = document.getElementById("issueForm");
	const adminType	= document.getElementById("adminType");
	
	btn.onclick = function() {
		modal.style.display = "flex";
		showForm("등록");
		adminType.value = "등록";

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
})
