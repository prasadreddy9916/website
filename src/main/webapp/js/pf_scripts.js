function openEditModal(empId, empName, pfNumber, uanNumber, bankName, bankAccountNo) {
    document.getElementById('editEmpId').value = empId;
    document.getElementById('displayEmpId').value = empId;
    document.getElementById('displayEmpName').value = empName;
    document.getElementById('editPfNumber').value = pfNumber;
    document.getElementById('editUanNumber').value = uanNumber;
    document.getElementById('editBankName').value = bankName;
    document.getElementById('editBankAccountNo').value = bankAccountNo;
    document.getElementById('editModal').style.display = 'block';
}

function closeEditModal() {
    document.getElementById('editModal').style.display = 'none';
}

function filterTable() {
    const empIdFilter = document.getElementById('empIdFilter').value.toLowerCase();
    const empNameFilter = document.getElementById('empNameFilter').value.toLowerCase();
    const table = document.getElementById('employeeTable');
    const rows = table.getElementsByTagName('tr');

    for (let i = 0; i < rows.length; i++) {
        const empId = rows[i].getElementsByTagName('td')[0];
        const empName = rows[i].getElementsByTagName('td')[1];
        if (empId && empName) {
            const empIdText = empId.textContent.toLowerCase();
            const empNameText = empName.textContent.toLowerCase();
            const idMatch = empIdText.includes(empIdFilter);
            const nameMatch = empNameText.includes(empNameFilter);
            rows[i].style.display = (idMatch && nameMatch) ? '' : 'none';
        }
    }
}

// Auto-hide popup after 3 seconds
setTimeout(() => {
    const popup = document.getElementById('popup');
    if (popup) popup.style.display = 'none';
}, 3000);

// Close modal when clicking outside
document.addEventListener('click', function(event) {
    const modal = document.getElementById('editModal');
    const modalContent = modal.querySelector('.modal-content');
    if (modal.style.display === 'block' && !modalContent.contains(event.target) && !event.target.classList.contains('edit-btn')) {
        closeEditModal();
    }
});

// Ensure modal is hidden on page load
window.onload = function() {
    document.getElementById('editModal').style.display = 'none';
    filterTable();
};