document.addEventListener('DOMContentLoaded', () => {
    const examFilter = document.getElementById('examFilter');
    const batchFilter = document.getElementById('batchFilter');
    const empIdSearch = document.getElementById('empIdSearch');
    const empNameSearch = document.getElementById('empNameSearch');
    const rows = document.querySelectorAll('tbody tr');

    function applyFilters() {
        const examValue = examFilter.value.trim().toLowerCase();
        const batchValue = batchFilter.value.trim().toLowerCase();
        const empIdValue = empIdSearch.value.trim().toLowerCase();
        const empNameValue = empNameSearch.value.trim().toLowerCase();

        rows.forEach((row) => {
            const rowExam = row.getAttribute('data-exam') || '';
            const rowBatch = row.getAttribute('data-batch') || '';
            const rowEmpId = row.getAttribute('data-empid') || '';
            const rowEmpName = row.getAttribute('data-empname') || '';

            const matchesExam = examValue === 'all' || rowExam === examValue;
            const matchesBatch = batchValue === 'all' || rowBatch === batchValue;
            const matchesEmpId = empIdValue === '' || rowEmpId.includes(empIdValue);
            const matchesEmpName = empNameValue === '' || rowEmpName.includes(empNameValue);

            row.style.display = matchesExam && matchesBatch && matchesEmpId && matchesEmpName ? '' : 'none';
        });
    }

    examFilter.addEventListener('change', applyFilters);
    batchFilter.addEventListener('change', applyFilters);
    empIdSearch.addEventListener('input', applyFilters);
    empNameSearch.addEventListener('input', applyFilters);

    applyFilters(); // Apply filters on page load
});