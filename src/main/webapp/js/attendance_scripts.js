function openAddModal() {
    document.getElementById('addModal').style.display = 'flex';
    // Reset filters when opening modal
    document.getElementById('addFilterEmpId').value = '';
    document.getElementById('addFilterName').value = '';
    document.getElementById('addFilterAttendance').value = '';
    document.getElementById('addFilterMonth').value = '';
    document.getElementById('addFilterYear').value = '';
    filterAddTable(); // Apply filters on open
}

function closeAddModal() {
    document.getElementById('addModal').style.display = 'none';
}

function openEditModal(empId, empName, attendance, month, year, isOld = false) {
    document.getElementById('editEmpId').value = empId;
    document.getElementById('editEmpName').value = empName;
    document.getElementById('displayEmpId').value = empId;
    document.getElementById('displayEmpName').value = empName;
    document.getElementById('editAttendance').value = attendance;
    document.getElementById('editMonth').value = month || '';
    document.getElementById('editYear').value = year || '';
    
    // Set source dynamically
    document.getElementById('editSource').value = isOld ? 'edit' : 'add'; // "edit" for old attendance, "add" for new
    
    document.getElementById('editModal').style.display = 'flex';
}

function closeEditModal() {
    document.getElementById('editModal').style.display = 'none';
}

// Close modals when clicking outside
document.addEventListener('click', function(event) {
    const addModal = document.getElementById('addModal');
    const editModal = document.getElementById('editModal');
    const addModalContent = addModal.querySelector('.modal-content');
    const editModalContent = editModal.querySelector('.modal-content');

    if (addModal.style.display === 'flex' && !addModalContent.contains(event.target) && !event.target.classList.contains('add-btn')) {
        closeAddModal();
    }
    if (editModal.style.display === 'flex' && !editModalContent.contains(event.target) && !event.target.classList.contains('edit-btn')) {
        closeEditModal();
    }
});

// Auto-hide popup after 3 seconds
setTimeout(() => {
    const popup = document.getElementById('popup');
    if (popup) popup.style.display = 'none';
}, 3000);

// Filter table function for old attendance
function filterTable() {
    const empIdFilter = document.getElementById('filterEmpId').value.toLowerCase();
    const nameFilter = document.getElementById('filterName').value.toLowerCase();
    const attendanceFilter = document.getElementById('filterAttendance').value;
    const monthFilter = document.getElementById('filterMonth').value;
    const yearFilter = document.getElementById('filterYear').value;

    const rows = document.getElementById('oldAttendanceTable').getElementsByTagName('tr');

    for (let i = 0; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName('td');
        if (cells.length > 0) {
            const empId = cells[0].textContent.toLowerCase();
            const name = cells[1].textContent.toLowerCase();
            const attendance = cells[2].textContent;
            const monthYear = cells[3].textContent.split('/');
            const month = monthYear[0];
            const year = monthYear[1];

            const empIdMatch = empId.includes(empIdFilter);
            const nameMatch = name.includes(nameFilter);
            const attendanceMatch = !attendanceFilter || attendance === attendanceFilter;
            const monthMatch = !monthFilter || month === monthFilter;
            const yearMatch = !yearFilter || year === yearFilter;

            rows[i].style.display = (empIdMatch && nameMatch && attendanceMatch && monthMatch && yearMatch) ? '' : 'none';
        }
    }
}

// Filter table function for add attendance modal
function filterAddTable() {
    const empIdFilter = document.getElementById('addFilterEmpId').value.toLowerCase();
    const nameFilter = document.getElementById('addFilterName').value.toLowerCase();
    const attendanceFilter = document.getElementById('addFilterAttendance').value;
    const monthFilter = document.getElementById('addFilterMonth').value;
    const yearFilter = document.getElementById('addFilterYear').value;

    const rows = document.getElementById('attendanceTable').getElementsByTagName('tr');

    for (let i = 0; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName('td');
        if (cells.length > 0) {
            const empId = cells[0].textContent.toLowerCase();
            const name = cells[1].textContent.toLowerCase();
            const attendance = cells[2].textContent;
            const monthYear = cells[3].textContent;
            const month = monthYear === 'Not Set' ? '' : monthYear.split('/')[0];
            const year = monthYear === 'Not Set' ? '' : monthYear.split('/')[1];

            const empIdMatch = empId.includes(empIdFilter);
            const nameMatch = name.includes(nameFilter);
            const attendanceMatch = !attendanceFilter || attendance === attendanceFilter;
            const monthMatch = !monthFilter || month === monthFilter;
            const yearMatch = !yearFilter || year === yearFilter || monthYear === 'Not Set';

            rows[i].style.display = (empIdMatch && nameMatch && attendanceMatch && monthMatch && yearMatch) ? '' : 'none';
        }
    }
}

// Add event listeners for filters
document.getElementById('filterEmpId').addEventListener('input', filterTable);
document.getElementById('filterName').addEventListener('input', filterTable);
document.getElementById('filterAttendance').addEventListener('input', filterTable);
document.getElementById('filterMonth').addEventListener('change', filterTable);
document.getElementById('filterYear').addEventListener('input', filterTable);

// Add event listeners for Add Attendance filters
document.getElementById('addFilterEmpId').addEventListener('input', filterAddTable);
document.getElementById('addFilterName').addEventListener('input', filterAddTable);
document.getElementById('addFilterAttendance').addEventListener('input', filterAddTable);
document.getElementById('addFilterMonth').addEventListener('change', filterAddTable);
document.getElementById('addFilterYear').addEventListener('input', filterAddTable);

// Ensure modals are hidden on page load and apply filters
window.onload = function() {
    document.getElementById('addModal').style.display = 'none';
    document.getElementById('editModal').style.display = 'none';
    filterTable(); // Apply old attendance filters
    filterAddTable(); // Apply add attendance filters
};