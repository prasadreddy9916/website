// payslip_scripts.js
function openGenerateModal() {
    document.getElementById('generateModal').style.display = 'flex';
}

function closeGenerateModal() {
    document.getElementById('generateModal').style.display = 'none';
}

function openViewModal(empId, empName, month, year) {
    const payslipDataElement = document.getElementById('payslipData');
    let payslipData = payslipDataElement ? JSON.parse(payslipDataElement.value) : {};

    const key = `${empId}-${month}-${year}`;
    if (!payslipData[key]) {
        console.warn('Payslip data not found for ' + empId + ' ' + month + ' ' + year);
        return;
    }

    const data = payslipData[key];
    const content = document.getElementById('payslipContent');
    content.innerHTML = `
        <div class="payslip-header">
            <h3>Company Information</h3>
            <p><strong>Company Name:</strong> <span>${data.company_name}</span></p>
            <p><strong>Address:</strong> <span>${data.company_address}</span></p>
            <p><strong>Payslip Period:</strong> <span>${month} ${year}</span></p>
        </div>
        <div class="payslip-section">
            <h3>Employee Details</h3>
            <p><strong>Employee ID:</strong> <span>${empId}</span></p>
            <p><strong>Employee Name:</strong> <span>${empName}</span></p>
            <p><strong>Designation:</strong> <span>${data.designation}</span></p>
            <p><strong>Department:</strong> <span>${data.department}</span></p>
            <p><strong>Date of Joining:</strong> <span>${data.date_of_joining}</span></p>
            <p><strong>Location:</strong> <span>${data.work_location}</span></p>
        </div>
        <div class="payslip-section">
            <h3>Attendance Details</h3>
            <p><strong>Total Working Days:</strong> <span>${data.total_working_days}</span></p>
            <p><strong>LOP Days:</strong> <span>${data.lop_days}</span></p>
            <p><strong>Paid Days:</strong> <span>${data.paid_days}</span></p>
        </div>
        <div class="payslip-section">
            <h3>Bank & PF Details</h3>
            <p><strong>Bank Name:</strong> <span>${data.bank_name}</span></p>
            <p><strong>Bank Account No:</strong> <span>${data.bank_account_no}</span></p>
            <p><strong>UAN Number:</strong> <span>${data.uan_number}</span></p>
            <p><strong>PF Number:</strong> <span>${data.pf_number}</span></p>
        </div>
        <div class="payslip-section">
            <h3>Salary Components</h3>
            <table>
                <thead>
                    <tr>
                        <th>Earnings</th>
                        <th>Amount (Rs.)</th>
                        <th>Deductions</th>
                        <th>Amount (Rs.)</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Basic Salary</td>
                        <td>${data.basic_salary.toFixed(2)}</td>
                        <td>EPF</td>
                        <td>${data.epf.toFixed(2)}</td>
                    </tr>
                    <tr>
                        <td>House Rent Allowance</td>
                        <td>${data.hra.toFixed(2)}</td>
                        <td>Professional Tax</td>
                        <td>${data.professional_tax.toFixed(2)}</td>
                    </tr>
                    <tr>
                        <td>Flexible Plan</td>
                        <td>${data.flexible_plan.toFixed(2)}</td>
                        <td>ESI</td>
                        <td>${data.esi.toFixed(2)}</td>
                    </tr>
                    <tr>
                        <td>Other Earnings</td>
                        <td>${data.other_earnings.toFixed(2)}</td>
                        <td>TDS</td>
                        <td>${data.tds.toFixed(2)}</td>
                    </tr>
                    <tr>
                        <td></td>
                        <td></td>
                        <td>Other Deductions (LOP)</td>
                        <td>${data.other_deductions.toFixed(2)}</td>
                    </tr>
                    <tr>
                        <td>Gross Salary</td>
                        <td>${data.gross_salary.toFixed(2)}</td>
                        <td>Total Deductions</td>
                        <td>${data.total_deductions.toFixed(2)}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="payslip-section">
            <h3>Net Salary</h3>
            <p><strong>Net Pay:</strong> <span>Rs. ${data.net_salary.toFixed(2)}</span></p>
            <p><strong>Amount in Words:</strong> <span>${numberToWords(Math.round(data.net_salary))} rupees only</span></p>
        </div>
    `;
    document.getElementById('viewModal').style.display = 'flex';
}

function closeViewModal() {
    document.getElementById('viewModal').style.display = 'none';
}

function generatePayslip(empId, empName, month, year) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = 'payslip_generation.jsp';
    form.style.display = 'none';
    form.innerHTML = `
        <input type="hidden" name="action" value="generate">
        <input type="hidden" name="empId" value="${empId}">
        <input type="hidden" name="empName" value="${empName}">
        <input type="hidden" name="month" value="${month}">
        <input type="hidden" name="year" value="${year}">
    `;
    document.body.appendChild(form);
    form.submit();
}

function downloadPayslip(empId, empName, month, year) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = 'payslip_generation.jsp';
    form.style.display = 'none';
    form.innerHTML = `
        <input type="hidden" name="action" value="download">
        <input type="hidden" name="empId" value="${empId}">
        <input type="hidden" name="empName" value="${empName}">
        <input type="hidden" name="month" value="${month}">
        <input type="hidden" name="year" value="${year}">
    `;
    document.body.appendChild(form);
    form.submit();
}

function filterTable() {
    const empIdFilter = document.getElementById('filterEmpId').value.toLowerCase();
    const nameFilter = document.getElementById('filterName').value.toLowerCase();
    const monthFilter = document.getElementById('filterMonth').value;
    const yearFilter = document.getElementById('filterYear').value;

    const rows = document.getElementById('payslipTable').getElementsByTagName('tr');

    for (let i = 0; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName('td');
        if (cells.length > 0) {
            const empId = cells[0].textContent.toLowerCase();
            const name = cells[1].textContent.toLowerCase();
            const monthYear = cells[2].textContent.split('/');
            const month = monthYear[0];
            const year = monthYear[1];

            const empIdMatch = empId.includes(empIdFilter);
            const nameMatch = name.includes(nameFilter);
            const monthMatch = !monthFilter || month === monthFilter;
            const yearMatch = !yearFilter || year === yearFilter;

            rows[i].style.display = (empIdMatch && nameMatch && monthMatch && yearMatch) ? '' : 'none';
        }
    }
}

document.getElementById('filterEmpId').addEventListener('input', filterTable);
document.getElementById('filterName').addEventListener('input', filterTable);
document.getElementById('filterMonth').addEventListener('change', filterTable);
document.getElementById('filterYear').addEventListener('input', filterTable);

document.addEventListener('click', function(event) {
    const generateModal = document.getElementById('generateModal');
    const viewModal = document.getElementById('viewModal');
    const generateModalContent = generateModal.querySelector('.modal-content');
    const viewModalContent = viewModal.querySelector('.modal-content');

    if (generateModal.style.display === 'flex' && !generateModalContent.contains(event.target) && !event.target.classList.contains('generate-btn')) {
        closeGenerateModal();
    }
    if (viewModal.style.display === 'flex' && !viewModalContent.contains(event.target) && !event.target.classList.contains('view-btn')) {
        closeViewModal();
    }
});

setTimeout(() => {
    const popup = document.getElementById('popup');
    if (popup) popup.style.display = 'none';
}, 3000);

window.onload = function() {
    document.getElementById('generateModal').style.display = 'none';
    document.getElementById('viewModal').style.display = 'none';
    filterTable();
};

function numberToWords(num) {
    const units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
    const teens = ['Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    const thousands = ['', 'Thousand', 'Million', 'Billion'];

    if (num === 0) return 'Zero';
    let words = '';
    let chunkCount = 0;

    while (num > 0) {
        let chunk = num % 1000;
        if (chunk) {
            let chunkWords = '';
            if (chunk >= 100) {
                chunkWords += units[Math.floor(chunk / 100)] + ' Hundred ';
                chunk %= 100;
            }
            if (chunk >= 20) {
                chunkWords += tens[Math.floor(chunk / 10)] + ' ';
                chunk %= 10;
            }
            if (chunk >= 10 && chunk < 20) {
                chunkWords += teens[chunk - 10] + ' ';
                chunk = 0;
            }
            if (chunk > 0) {
                chunkWords += units[chunk] + ' ';
            }
            words = chunkWords + thousands[chunkCount] + ' ' + words;
        }
        num = Math.floor(num / 1000);
        chunkCount++;
    }
    return words.trim();
}