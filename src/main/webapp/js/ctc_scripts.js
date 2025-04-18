// js/ctc_scripts.js
function calculateFromMonthly() {
    const basic = parseFloat(document.getElementById('basic').value) || 0;
    const hra = parseFloat(document.getElementById('hra').value) || 0;
    const special = parseFloat(document.getElementById('special').value) || 0;
    const conveyance = parseFloat(document.getElementById('conveyance').value) || 0;
    const medical = parseFloat(document.getElementById('medical').value) || 0;
    const gratuity = parseFloat(document.getElementById('gratuity').value) || 0;
    const bonus = parseFloat(document.getElementById('bonus').value) || 0;

    const grossMonthly = basic + hra + special + conveyance + medical;
    const grossAnnual = grossMonthly * 12;
    document.getElementById('grossMonthly').value = grossMonthly.toFixed(2);
    document.getElementById('grossAnnual').value = grossAnnual.toFixed(2);

    const pfDefault = basic * 0.12;
    const pf = parseFloat(document.getElementById('pf').value) || pfDefault;
    const pfAnnual = pf * 12;
    document.getElementById('pf').value = pf.toFixed(2);
    document.getElementById('pfAnnual').value = pfAnnual.toFixed(2);

    const pt = parseFloat(document.getElementById('pt').value) || 200;
    const ptAnnual = pt * 12;
    document.getElementById('pt').value = pt.toFixed(2);
    document.getElementById('ptAnnual').value = ptAnnual.toFixed(2);

    let esi = parseFloat(document.getElementById('esi').value) || 0;
    if (grossMonthly <= 21000) {
        esi = grossMonthly * 0.0075;
    }
    const esiAnnual = esi * 12;
    document.getElementById('esi').value = esi.toFixed(2);
    document.getElementById('esiAnnual').value = esiAnnual.toFixed(2);

    const taxableIncome = grossAnnual - 75000;
    let tdsAnnual = 0;
    if (taxableIncome > 400000) {
        if (taxableIncome <= 800000) tdsAnnual = (taxableIncome - 400000) * 0.05;
        else if (taxableIncome <= 1200000) tdsAnnual = 20000 + (taxableIncome - 800000) * 0.10;
        else if (taxableIncome <= 1600000) tdsAnnual = 60000 + (taxableIncome - 1200000) * 0.15;
        else if (taxableIncome <= 2000000) tdsAnnual = 120000 + (taxableIncome - 1600000) * 0.20;
        else if (taxableIncome <= 2400000) tdsAnnual = 200000 + (taxableIncome - 2000000) * 0.25;
        else tdsAnnual = 300000 + (taxableIncome - 2400000) * 0.30;
        if (taxableIncome <= 1200000) tdsAnnual = Math.max(0, tdsAnnual - 60000);
    }
    const tdsMonthly = parseFloat(document.getElementById('tds').value) || (tdsAnnual / 12);
    tdsAnnual = tdsMonthly * 12;
    document.getElementById('tds').value = tdsMonthly.toFixed(2);
    document.getElementById('tdsAnnual').value = tdsAnnual.toFixed(2);

    const totalDeductions = pf + pt + tdsMonthly + esi;
    const totalDeductionsAnnual = totalDeductions * 12;
    document.getElementById('totalDeductions').value = totalDeductions.toFixed(2);
    document.getElementById('totalDeductionsAnnual').value = totalDeductionsAnnual.toFixed(2);

    const netSalary = grossMonthly - totalDeductions;
    const netSalaryAnnual = netSalary * 12;
    document.getElementById('netSalary').value = netSalary.toFixed(2);
    document.getElementById('netSalaryAnnual').value = netSalaryAnnual.toFixed(2);

    const employerPf = pfDefault;
    const employerPfAnnual = employerPf * 12;

    const gratuityAnnual = gratuity * 12;
    const bonusAnnual = bonus * 12;
    document.getElementById('gratuityAnnual').value = gratuityAnnual.toFixed(2);
    document.getElementById('bonusAnnual').value = bonusAnnual.toFixed(2);

    const totalCtc = grossMonthly + employerPf + gratuity + bonus;
    const totalCtcAnnual = totalCtc * 12;
    document.getElementById('totalCtc').value = totalCtc.toFixed(2);
    document.getElementById('totalCtcAnnual').value = totalCtcAnnual.toFixed(2);

    document.getElementById('basicAnnual').value = (basic * 12).toFixed(2);
    document.getElementById('hraAnnual').value = (hra * 12).toFixed(2);
    document.getElementById('specialAnnual').value = (special * 12).toFixed(2);
    document.getElementById('conveyanceAnnual').value = (conveyance * 12).toFixed(2);
    document.getElementById('medicalAnnual').value = (medical * 12).toFixed(2);
}

function calculateFromAnnual() {
    const basicAnnual = parseFloat(document.getElementById('basicAnnual').value) || 0;
    const hraAnnual = parseFloat(document.getElementById('hraAnnual').value) || 0;
    const specialAnnual = parseFloat(document.getElementById('specialAnnual').value) || 0;
    const conveyanceAnnual = parseFloat(document.getElementById('conveyanceAnnual').value) || 0;
    const medicalAnnual = parseFloat(document.getElementById('medicalAnnual').value) || 0;
    const gratuityAnnual = parseFloat(document.getElementById('gratuityAnnual').value) || 0;
    const bonusAnnual = parseFloat(document.getElementById('bonusAnnual').value) || 0;

    const basic = basicAnnual / 12;
    const hra = hraAnnual / 12;
    const special = specialAnnual / 12;
    const conveyance = conveyanceAnnual / 12;
    const medical = medicalAnnual / 12;
    const gratuity = gratuityAnnual / 12;
    const bonus = bonusAnnual / 12;

    document.getElementById('basic').value = basic.toFixed(2);
    document.getElementById('hra').value = hra.toFixed(2);
    document.getElementById('special').value = special.toFixed(2);
    document.getElementById('conveyance').value = conveyance.toFixed(2);
    document.getElementById('medical').value = medical.toFixed(2);
    document.getElementById('gratuity').value = gratuity.toFixed(2);
    document.getElementById('bonus').value = bonus.toFixed(2);

    const grossMonthly = basic + hra + special + conveyance + medical;
    const grossAnnual = grossMonthly * 12;
    document.getElementById('grossMonthly').value = grossMonthly.toFixed(2);
    document.getElementById('grossAnnual').value = grossAnnual.toFixed(2);

    const pfAnnualDefault = basic * 0.12 * 12;
    const pfAnnual = parseFloat(document.getElementById('pfAnnual').value) || pfAnnualDefault;
    const pf = pfAnnual / 12;
    document.getElementById('pf').value = pf.toFixed(2);
    document.getElementById('pfAnnual').value = pfAnnual.toFixed(2);

    const ptAnnual = parseFloat(document.getElementById('ptAnnual').value) || 2400;
    const pt = ptAnnual / 12;
    document.getElementById('pt').value = pt.toFixed(2);
    document.getElementById('ptAnnual').value = ptAnnual.toFixed(2);

    let esiAnnual = parseFloat(document.getElementById('esiAnnual').value) || 0;
    let esi = esiAnnual / 12;
    if (grossMonthly <= 21000) {
        esi = grossMonthly * 0.0075;
        esiAnnual = esi * 12;
    }
    document.getElementById('esi').value = esi.toFixed(2);
    document.getElementById('esiAnnual').value = esiAnnual.toFixed(2);

    const taxableIncome = grossAnnual - 75000;
    let tdsAnnual = 0;
    if (taxableIncome > 400000) {
        if (taxableIncome <= 800000) tdsAnnual = (taxableIncome - 400000) * 0.05;
        else if (taxableIncome <= 1200000) tdsAnnual = 20000 + (taxableIncome - 800000) * 0.10;
        else if (taxableIncome <= 1600000) tdsAnnual = 60000 + (taxableIncome - 1200000) * 0.15;
        else if (taxableIncome <= 2000000) tdsAnnual = 120000 + (taxableIncome - 1600000) * 0.20;
        else if (taxableIncome <= 2400000) tdsAnnual = 200000 + (taxableIncome - 2000000) * 0.25;
        else tdsAnnual = 300000 + (taxableIncome - 2400000) * 0.30;
        if (taxableIncome <= 1200000) tdsAnnual = Math.max(0, tdsAnnual - 60000);
    }
    const tdsMonthly = parseFloat(document.getElementById('tds').value) || (tdsAnnual / 12);
    tdsAnnual = tdsMonthly * 12;
    document.getElementById('tds').value = tdsMonthly.toFixed(2);
    document.getElementById('tdsAnnual').value = tdsAnnual.toFixed(2);

    const totalDeductions = pf + pt + tdsMonthly + esi;
    const totalDeductionsAnnual = totalDeductions * 12;
    document.getElementById('totalDeductions').value = totalDeductions.toFixed(2);
    document.getElementById('totalDeductionsAnnual').value = totalDeductionsAnnual.toFixed(2);

    const netSalary = grossMonthly - totalDeductions;
    const netSalaryAnnual = netSalary * 12;
    document.getElementById('netSalary').value = netSalary.toFixed(2);
    document.getElementById('netSalaryAnnual').value = netSalaryAnnual.toFixed(2);

    const employerPf = pf;
    const employerPfAnnual = employerPf * 12;

    const totalCtc = grossMonthly + employerPf + gratuity + bonus;
    const totalCtcAnnual = totalCtc * 12;
    document.getElementById('totalCtc').value = totalCtc.toFixed(2);
    document.getElementById('totalCtcAnnual').value = totalCtcAnnual.toFixed(2);

    document.getElementById('gratuityAnnual').value = gratuityAnnual.toFixed(2);
    document.getElementById('bonusAnnual').value = bonusAnnual.toFixed(2);
}

function calculateAndSubmit() {
    calculateFromMonthly();
    return true;
}

function filterTable() {
    const empIdFilter = document.getElementById('empIdFilter').value.toLowerCase();
    const empNameFilter = document.getElementById('empNameFilter').value.toLowerCase();
    const designationFilter = document.getElementById('designationFilter').value.toLowerCase();
    const departmentFilter = document.getElementById('departmentFilter').value.toLowerCase();
    const joiningDateFilter = document.getElementById('joiningDateFilter').value.toLowerCase();
    const locationFilter = document.getElementById('locationFilter').value.toLowerCase();

    const table = document.getElementById('employeeTable');
    const rows = table.getElementsByTagName('tr');

    for (let i = 0; i < rows.length; i++) {
        const empId = rows[i].getElementsByTagName('td')[0];
        const empName = rows[i].getElementsByTagName('td')[1];
        const designation = rows[i].getElementsByTagName('td')[2];
        const department = rows[i].getElementsByTagName('td')[3];
        const joiningDate = rows[i].getElementsByTagName('td')[4];
        const location = rows[i].getElementsByTagName('td')[5];

        if (empId && empName && designation && department && joiningDate && location) {
            const empIdText = empId.textContent.toLowerCase();
            const empNameText = empName.textContent.toLowerCase();
            const designationText = designation.textContent.toLowerCase();
            const departmentText = department.textContent.toLowerCase();
            const joiningDateText = joiningDate.textContent.toLowerCase();
            const locationText = location.textContent.toLowerCase();

            const idMatch = empIdText.includes(empIdFilter);
            const nameMatch = empNameText.includes(empNameFilter);
            const designationMatch = designationText.includes(designationFilter);
            const departmentMatch = departmentText.includes(departmentFilter);
            const joiningDateMatch = joiningDateText.includes(joiningDateFilter);
            const locationMatch = locationText.includes(locationFilter);

            rows[i].style.display = (idMatch && nameMatch && designationMatch && departmentMatch && joiningDateMatch && locationMatch) ? '' : 'none';
        }
    }
}

setTimeout(() => {
    const popup = document.getElementById('popup');
    if (popup) popup.style.display = 'none';
}, 3000);