document.addEventListener('DOMContentLoaded', () => {
    const batchSelector = document.getElementById('batchSelector');
    const examSelector = document.getElementById('examSelector');
    const rows = document.querySelectorAll('.dashboard-table tbody tr');
    const publishButtons = document.querySelectorAll('.publish-btn');

    function applyFilters() {
        const batchValue = batchSelector.value.trim();
        const examValue = examSelector.value.trim();

        rows.forEach(row => {
            const rowBatch = row.getAttribute('data-batch');
            const rowExam = row.getAttribute('data-exam');

            const matchesBatch = !batchValue || rowBatch === batchValue;
            const matchesExam = !examValue || rowExam === examValue;

            row.style.display = (matchesBatch && matchesExam) ? '' : 'none';
        });
    }

    batchSelector.addEventListener('change', applyFilters);
    examSelector.addEventListener('change', applyFilters);

    publishButtons.forEach(button => {
        button.addEventListener('click', () => {
            if (button.disabled) return; // Prevent clicking if already disabled

            const id = button.getAttribute('data-id');
            const servletUrl = window.location.pathname.startsWith('/website') 
                ? '/website/ExamAssignmentServlet' 
                : '/ExamAssignmentServlet';

            fetch(servletUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `action=publish&id=${encodeURIComponent(id)}`
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    button.textContent = 'Running';
                    button.disabled = true; // Disable button after success
                    button.classList.add('disabled'); // Add class for grey styling
                } else {
                    alert('Failed to publish: ' + data.error);
                }
            })
            .catch(error => {
                console.error('Publish error:', error);
                alert('Failed to publish: ' + error.message);
            });
        });
    });

    applyFilters();
});