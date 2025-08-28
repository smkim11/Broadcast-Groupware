$(document).ready(function () {
    // id="datatable" 테이블에 기본 DataTable 기능 적용 (검색, 페이징, 정렬 등)
    $("#datatable").DataTable();
	$.fn.DataTable.ext.pager.numbers_length = 5;

	$.fn.DataTable.ext.pager.grouped = function(page, pages) {
	    var numbers = [];
	    var groupSize = $.fn.DataTable.ext.pager.numbers_length;
	    var group = Math.floor(page / groupSize); // 현재 그룹
	    var start = group * groupSize;
	    var end = start + groupSize;
	    if (end > pages) end = pages;

	    for (var i = start; i < end; i++) {
	        numbers.push(i);
	    }

	    return numbers;
	};
    // id="datatable-buttons" 테이블에 DataTable 적용 + 버튼 옵션 추가
    $("#datatable-buttons").DataTable({
        lengthChange: !1, // "한 페이지에 몇 개씩 보기" 옵션 숨김 (lengthChange: false 와 동일)
		dom: 
		        "<'row'<'col-md-6'l>>" +           
		        "<'row'<'col-md-12'tr>>" +           // 테이블 본문
		        "<'row'<'col-md-7'p>>"+
				"<'row'<'col-md-7'f>>", // 하단: 왼쪽 info, 오른쪽 pagination
		language: {
		        search: "검색",
				paginate: {
		            previous: "<",
		            next: ">",
		            first: "처음",
		            last: "마지막"
		        }
		    },
	    buttons: [
	        { extend: "copy", text: "복사"},
	        { extend: "excel", text: "Excel 저장"},
	        { extend: "pdf", text: "PDF 저장"},
	        { extend: "colvis", text: "필터"}
	    ]
    })
    // DataTables 버튼들을 특정 위치에 붙이기
    .buttons().container()
    .appendTo("#datatable-buttons_wrapper .col-md-6:eq(0)");
    // 테이블의 'length 선택(select box)' 부분에 Bootstrap 스타일 적용
    $(".dataTables_length select").addClass("form-select form-select-sm");
	
});
