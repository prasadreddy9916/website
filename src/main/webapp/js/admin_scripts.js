function loadSection(sectionId) {
    const contentArea = document.getElementById('contentArea');
    const inlineSections = document.getElementById('inlineSections');
    const sections = inlineSections.querySelectorAll('.section-content');
    const iframe = document.getElementById('contentIframe');

    iframe.classList.remove('active');
    contentArea.classList.add('active');

    sections.forEach(section => {
        section.classList.remove('active');
    });
    const activeSection = document.getElementById(sectionId);
    if (activeSection) {
        activeSection.classList.add('active');
    }
}

function loadIframe(url) {
    const contentArea = document.getElementById('contentArea');
    const iframe = document.getElementById('contentIframe');

    contentArea.classList.remove('active');
    iframe.classList.add('active');
    iframe.src = url;
}

function logoutUser() {
    // Clear session storage
    sessionStorage.clear();
    
    // Create a form to submit a POST request to the logout endpoint
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = contextPath + '/AdminLogout'; // Use contextPath to handle non-root deployments
    document.body.appendChild(form);
    form.submit();
}

function viewEmployees(employeeId) {
    alert(`Viewing details for Employee ID: ${employeeId}`);
}

function publishLink(employeeId) {
    alert(`Publishing link for Employee ID: ${employeeId}`);
}

function removeRegistration(employeeId) {
    if (confirm(`Remove registration for Employee ID: ${employeeId}?`)) {
        alert(`Registration removed for ${employeeId}`);
    }
}

function revokeLink(examId) {
    if (confirm(`Revoke access for Exam ID: ${examId}?`)) {
        alert(`Link revoked for ${examId}`);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const loader = document.getElementById('loader');
    const contentArea = document.getElementById('contentArea');
    const iframe = document.getElementById('contentIframe');

    contentArea.classList.remove('active');
    iframe.classList.remove('active');

    setTimeout(() => {
        loader.classList.add('loader-hidden');
        setTimeout(() => {
            loader.style.display = 'none';
        }, 500);
    }, 2000);
});