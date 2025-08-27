document.addEventListener("DOMContentLoaded", function() {
    var m = document.getElementById("calendar");
	var e = window.attendaceEvents || [];
    var g = new FullCalendar.Calendar(m, {
        timeZone: "local",
        editable: false,
		displayEventTime: false,
        initialView: "dayGridMonth",
		aspectRatio: 1.8,
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
        events: e
    });

    g.render();
});
