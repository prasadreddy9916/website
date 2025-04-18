<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Payroll</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/employee_payroll_styles.css">
</head>
<body>
    <%
        String email = (String) session.getAttribute("email");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    <div class="container">
        <div class="header">
            <h1>My Payroll</h1>
        </div>
        <div class="content">
            <div class="dashboard-grid">
                <div class="dashboard-box" onclick="window.location.href='<%= request.getContextPath() %>/employee_ctc.jsp'">
                    <h2>CTC</h2>
                    <p>Cost to Company Details</p>
                </div>
                <div class="dashboard-box" onclick="window.location.href='<%= request.getContextPath() %>/employee_pf_acc.jsp'">
                    <h2>PF & ACC Details</h2>
                    <p>Provident Fund Information<br> Account Information</p>
                </div>
                <div class="dashboard-box" onclick="window.location.href='<%= request.getContextPath() %>/employee_attendance.jsp'">
                    <h2>Attendance</h2>
                    <p>Employee Attendance Records</p>
                </div>
                <div class="dashboard-box" onclick="window.location.href='<%= request.getContextPath() %>/employee_payslip.jsp'">
                    <h2>Payslip Monthly</h2>
                    <p>Employee Payslips</p>
                </div>
                <div class="dashboard-box" onclick="window.location.href='<%= request.getContextPath() %>/employee_tax_deduction.jsp'">
                    <h2>Tax Deduction</h2>
                    <p>Tax Deduction Management</p>
                </div>
            </div>
        </div>
    </div>
    <!-- Remove script if not needed -->
    <!-- <script src="<%= request.getContextPath() %>/js/employee_payroll_scripts.js"></script> -->
</body>
</html>