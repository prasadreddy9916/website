// employee_pf_acc_scripts.js
document.addEventListener("DOMContentLoaded", function() {
    // Animate no-PF message
    const noPfMessage = document.querySelector('.no-pf-message');
    if (noPfMessage) {
        noPfMessage.style.opacity = '0';
        noPfMessage.style.transform = 'translateY(20px)';
        setTimeout(() => {
            noPfMessage.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            noPfMessage.style.opacity = '1';
            noPfMessage.style.transform = 'translateY(0)';
        }, 100);
    }

    // Animate Employee Info Card
    const card = document.querySelector('.card');
    if (card) {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        setTimeout(() => {
            card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, 200);
    }

    // Animate PF Details Table Rows
    const tableRows = document.querySelectorAll('.pf-details tr');
    tableRows.forEach((row, index) => {
        row.style.opacity = '0';
        row.style.transform = 'translateY(10px)';
        setTimeout(() => {
            row.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            row.style.opacity = '1';
            row.style.transform = 'translateY(0)';
        }, 300 + index * 100);
    });

    // Animate Account Info Grid Items
    const gridItems = document.querySelectorAll('.grid-item');
    gridItems.forEach((item, index) => {
        item.style.opacity = '0';
        item.style.transform = 'scale(0.9)';
        setTimeout(() => {
            item.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            item.style.opacity = '1';
            item.style.transform = 'scale(1)';
        }, 400 + index * 100);
    });
});