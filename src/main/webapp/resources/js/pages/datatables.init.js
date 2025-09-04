$(document).ready(function () {
	$.fn.DataTable.ext.pager.numbers_length = 5;
    // DataTable 초기화
    var table = $("#datatable-buttons").DataTable({
        lengthChange: false,           // 페이지 길이 선택 숨김
        pageLength: 10,                // 한 페이지에 보여줄 행 수
        dom: "<'row'<'col-md-6'l>>" +
             "<'row'<'col-md-12'tr>>" +
             "<'row'<'col-md-7'f>>" +
             "<'row'<'col-md-7'p>>",
        language: {
            search: "",
            searchPlaceholder: "검색어를 입력하세요.",   // 검색창 placeholder
            zeroRecords: "검색 결과가 없습니다.",       // 검색 결과 없을 때
            paginate: {
                previous: "<",
                next: ">"
            }
        },
        buttons: [
            { extend: "copy", text: "복사" },
            { extend: "excel", text: "Excel 저장" },
            { extend: "pdf", text: "PDF 저장" },
            { extend: "colvis", text: "필터" }
        ],
        pagingType: "simple_numbers", // 연속 숫자 + < > 버튼
        drawCallback: function () {
            // 5개씩 그룹 페이징
            var api = this.api();
            var $paginate = $(this).closest('.dataTables_wrapper').find('.dataTables_paginate');
            var currentPage = api.page();
            var totalPages = api.page.info().pages;
            var pageGroupSize = 5;

            var startGroup = Math.floor(currentPage / pageGroupSize) * pageGroupSize;
            var endGroup = Math.min(startGroup + pageGroupSize, totalPages);

            $paginate.find('span a').each(function (index, el) {
                if (index < startGroup || index >= endGroup) $(el).hide();
                else $(el).show();
            });
        },
        initComplete: function () {
            // 버튼을 특정 위치로 이동
            this.api().buttons().container()
                .appendTo("#datatable-buttons_wrapper .col-md-6:eq(0)");
            // length select box에 Bootstrap 스타일 적용
            $(".dataTables_length select").addClass("form-select form-select-sm");
        }
    });

});
