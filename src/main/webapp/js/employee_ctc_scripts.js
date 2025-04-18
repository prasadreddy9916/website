// employee_ctc_scripts.js
document.addEventListener("DOMContentLoaded", function() {
    const noCtcMessage = document.querySelector('.no-ctc-message');
    if (noCtcMessage) {
        noCtcMessage.style.opacity = '0';
        setTimeout(() => {
            noCtcMessage.style.transition = 'opacity 0.5s ease';
            noCtcMessage.style.opacity = '1';
        }, 100);
    }
});