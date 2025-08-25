document.addEventListener("DOMContentLoaded", function() {
    var m = document.getElementById("calendar");

    var g = new FullCalendar.Calendar(m, {
        timeZone: "local",
        editable: false,
        initialView: "dayGridMonth",
        themeSystem: "bootstrap",
        headerToolbar: {
            left: "prev,next",
            center: "title",
            right: "today"
        },
		locale: "ko",
		buttonText: {
		  today: '오늘',
		  month: '월',
		  week: '주',
		  day: '일'
		},
        events: [
            { title: "All Day Event", start: new Date() },
            { title: "Meeting", start: new Date(), className: "bg-success" }
        ]
    });

    g.render();
});
