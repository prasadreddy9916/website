// employee_payslip_scripts.js
document.addEventListener("DOMContentLoaded", function() {
    // Show error popup if exists
    const errorPopup = document.getElementById('errorPopup');
    if (errorPopup) {
        errorPopup.style.display = 'block';
        setTimeout(() => {
            errorPopup.style.opacity = '0';
            setTimeout(() => errorPopup.style.display = 'none', 500);
        }, 3000);
    }

    // Animate table rows
    const rows = document.querySelectorAll('.payslip-table tr');
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

function viewPayslip(empId, month, year) {
    const modal = document.getElementById('viewModal');
    const modalBody = document.getElementById('modalBody');

    fetch(`employee_payslip_data.jsp?empId=${empId}&month=${month}&year=${year}`)
        .then(response => response.text())
        .then(data => {
            modalBody.innerHTML = data;
            modal.style.display = 'flex';
            setTimeout(() => modal.style.opacity = '1', 10);
        })
        .catch(error => {
            modalBody.innerHTML = `<p>Error loading payslip: ${error.message}</p>`;
            modal.style.display = 'flex';
        });
}

function downloadPayslip(empId, month, year) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = 'employee_payslip.jsp';
    form.style.display = 'none';

    const fields = [
        { name: 'action', value: 'download' },
        { name: 'empId', value: empId },
        { name: 'month', value: month },
        { name: 'year', value: year }
    ];

    fields.forEach(field => {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = field.name;
        input.value = field.value;
        form.appendChild(input);
    });

    document.body.appendChild(form);
    form.submit();
    document.body.removeChild(form);
}

function closeModal() {
    const modal = document.getElementById('viewModal');
    modal.style.opacity = '0';
    setTimeout(() => modal.style.display = 'none', 300);
}