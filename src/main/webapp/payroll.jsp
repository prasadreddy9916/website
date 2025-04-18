<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payroll Management</title>
    <link rel="stylesheet" href="css/payroll_styles.css">
</head>
<body>

 <%
        String email = (String) session.getAttribute("email");
        if (email == null) {
            response.sendRedirect("adminlogin.jsp");
            return;
        }
        %>
    <div class="container">
        <div class="header">
            <h1>Payroll</h1>
        </div>
        <div class="content">
            <div class="dashboard-grid">
                <div class="dashboard-box" onclick="loadSection('ctc.jsp')">
                    <h2>CTC</h2>
                    <p>Cost to Company Details</p>
                </div>
                <div class="dashboard-box" onclick="loadSection('pf_details.jsp')">
                    <h2>PF & Bank Details</h2>
                    <p>Provident Fund Information<br>Bank Details</p>
                </div>
                <div class="dashboard-box" onclick="loadSection('attendance.jsp')">
                    <h2>Attendance</h2>
                    <p>Employee Attendance Records</p>
                </div>
                <div class="dashboard-box" onclick="loadSection('payslip_generation.jsp')">
                    <h2>Payslip Generation</h2>
                    <p>Generate Employee Payslips</p>
                </div>
                <div class="dashboard-box" onclick="loadSection('tax_deduction.jsp')">
                    <h2>Tax Deduction</h2>
                    <p>Tax Deduction Management</p>
                </div>
            </div>
        </div>
    </div>
    <script src="js/payroll_scripts.js"></script>
</body>
</html>