// employee_attendance_scripts.js
document.addEventListener("DOMContentLoaded", function() {
    const noAttendanceMessage = document.querySelector('.no-attendance-message');
    if (noAttendanceMessage) {
        noAttendanceMessage.style.opacity = '0';
        noAttendanceMessage.style.transform = 'translateY(20px)';
        setTimeout(() => {
            noAttendanceMessage.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            noAttendanceMessage.style.opacity = '1';
            noAttendanceMessage.style.transform = 'translateY(0)';
        }, 100);
    }

    const rows = document.querySelectorAll('.attendance-details tr');
    rows.forEach((row, index) => {
        row.style.opacity = '0';
        row.style.transform = 'translateY(10px)';
        setTimeout(() => {
            row.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            row.style.opacity = '1';
            row.style.transform = 'translateY(0)';
        }, index * 100);
    });
});