document.addEventListener('DOMContentLoaded', () => {
    const empIdFilter = document.getElementById('empIdFilter');
    const nameFilter = document.getElementById('nameFilter');
    const emailFilter = document.getElementById('emailFilter');
    const batchFilter = document.getElementById('batchFilter');
    const dateFilter = document.getElementById('dateFilter');
    const regDateFilter = document.getElementById('regDateFilter');
    const rows = document.querySelectorAll('tbody tr');
    const modal = document.getElementById('employeeModal');
    const modalTitle = document.getElementById('modalTitle');
    const modalCloseBtn = document.querySelector('.modal-close-btn');
    const cancelBtn = document.querySelector('.modal-footer .cancel-btn');
    const saveBtn = document.getElementById('saveBtn');
    const editForm = document.getElementById('editForm');
    const successPopup = document.getElementById('successPopup');
    const errorPopup = document.getElementById('errorPopup');

    function applyFilters() {
        const empIdValue = empIdFilter.value.trim().toLowerCase();
        const nameValue = nameFilter.value.trim().toLowerCase();
        const emailValue = emailFilter.value.trim().toLowerCase();
        const batchValue = batchFilter.value.trim().toLowerCase();
        const dateValue = dateFilter.value.trim();
        const regDateValue = regDateFilter.value.trim();

        rows.forEach(row => {
            const rowEmpId = (row.getAttribute('data-id') || '').toLowerCase();
            const rowName = (row.getAttribute('data-name') || '').toLowerCase();
            const rowEmail = (row.getAttribute('data-email') || '').toLowerCase();
            const rowBatch = (row.getAttribute('data-batch') || '').toLowerCase();
            const rowDate = (row.getAttribute('data-date') || '');
            const rowRegDate = (row.getAttribute('data-regdate') || '');

            const matchesEmpId = empIdValue === '' || rowEmpId.includes(empIdValue);
            const matchesName = nameValue === '' || rowName.includes(nameValue);
            const matchesEmail = emailValue === '' || rowEmail.includes(emailValue);
            const matchesBatch = batchValue === '' || rowBatch.includes(batchValue);
            const matchesDate = dateValue === '' || rowDate === dateValue;
            const matchesRegDate = regDateValue === '' || rowRegDate === regDateValue;

            row.style.display = matchesEmpId && matchesName && matchesEmail && matchesBatch && matchesDate && matchesRegDate ? '' : 'none';
        });
    }

    function openModal(mode, row) {
        modal.style.display = 'flex';
        const cells = row.querySelectorAll('td');
        modalTitle.textContent = mode === 'edit' ? 'Edit Employee Details' : 'View Employee Details';

        document.getElementById('modalPhoto').src = cells[0].querySelector('img').src;
        document.getElementById('modalId').value = cells[1].textContent.trim();
        document.getElementById('modalEmpId').value = cells[1].textContent.trim();
        document.getElementById('modalName').value = cells[2].textContent;
        document.getElementById('modalEmail').value = cells[3].textContent;
        document.getElementById('modalBatch').value = cells[4].textContent;
        document.getElementById('modalDob').value = cells[5].textContent;
        document.getElementById('modalRegDateTime').value = cells[6].textContent.replace(' ', 'T');
        document.getElementById('modalExam').value = cells[7].textContent;
        document.getElementById('modalMotherName').value = row.getAttribute('data-mother');
        document.getElementById('modalFatherName').value = row.getAttribute('data-father');
        document.getElementById('modalAadhar').value = row.getAttribute('data-aadhar');
        document.getElementById('modalPan').value = row.getAttribute('data-pan');
        document.getElementById('modalMobile').value = row.getAttribute('data-mobile');
        document.getElementById('modalGender').value = row.getAttribute('data-gender');
        document.getElementById('modalMaritalStatus').value = row.getAttribute('data-marital');
        document.getElementById('modalHasClicked').value = row.getAttribute('data-hasclicked');

        if (mode === 'view') {
            editForm.querySelectorAll('input, select').forEach(el => el.disabled = true);
            saveBtn.style.display = 'none';
            document.getElementById('modalPhotoInput').style.display = 'none';
        } else {
            editForm.querySelectorAll('input, select').forEach(el => el.disabled = false);
            document.getElementById('modalEmpId').disabled = true;
            document.getElementById('modalRegDateTime').disabled = true;
            saveBtn.style.display = 'inline-block';
            document.getElementById('modalPhotoInput').style.display = 'block';
        }
    }

    function closeModal() {
        modal.style.display = 'none';
    }

    function showSuccessPopup() {
        successPopup.style.display = 'block';
        setTimeout(() => {
            successPopup.style.display = 'none';
            window.location.href = window.location.pathname;
        }, 3000);
    }

    function showErrorPopup() {
        errorPopup.style.display = 'block';
        setTimeout(() => {
            errorPopup.style.display = 'none';
            window.location.href = window.location.pathname;
        }, 3000);
    }

    document.querySelectorAll('.edit-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const row = btn.closest('tr');
            openModal('edit', row);
        });
    });

    document.querySelectorAll('.view-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const row = btn.closest('tr');
            openModal('view', row);
        });
    });

    modalCloseBtn.addEventListener('click', closeModal);
    cancelBtn.addEventListener('click', closeModal);

    empIdFilter.addEventListener('input', applyFilters);
    nameFilter.addEventListener('input', applyFilters);
    emailFilter.addEventListener('input', applyFilters);
    batchFilter.addEventListener('input', applyFilters);
    dateFilter.addEventListener('change', applyFilters);
    regDateFilter.addEventListener('change', applyFilters);

    rows.forEach((row, index) => {
        row.style.opacity = '0';
        row.style.transform = 'translateY(20px)';
        setTimeout(() => {
            row.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            row.style.opacity = '1';
            row.style.transform = 'translateY(0)';
        }, index * 100);
    });

    applyFilters();

    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('success') === 'true') {
        if (!sessionStorage.getItem('successHandled')) {
            showSuccessPopup();
            sessionStorage.setItem('successHandled', 'true');
        }
    } else if (urlParams.get('error') === 'DataTooLong') {
        if (!sessionStorage.getItem('errorHandled')) {
            showErrorPopup();
            sessionStorage.setItem('errorHandled', 'true');
        }
    } else {
        sessionStorage.removeItem('successHandled');
        sessionStorage.removeItem('errorHandled');
    }
});