<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CTC Details</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/employee_ctc_styles.css">
</head>
<body>
    <%
        String email = (String) session.getAttribute("email");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String employeeId = "";
        String employeeName = "", designation = "", department = "", workLocation = "", joiningDate = "";
        double basic = 0, hra = 0, special = 0, conveyance = 0, medical = 0, bonus = 0, gratuity = 0;
        double pf = 0, pt = 0, tds = 0, esi = 0;
        boolean hasCtcDetails = false;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam", "root", "hacker#Tag1");

            // Fetch employee_id from employee_registrations
            String sql1 = "SELECT ID FROM employee_registrations WHERE email = ?";
            pstmt = conn.prepareStatement(sql1);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                employeeId = rs.getString("ID");
            } else {
                out.println("<p>No employee record found for this email.</p>");
                return;
            }
            rs.close();
            pstmt.close();

            // Fetch CTC details from ctc_employees
            String sql2 = "SELECT * FROM ctc_employees WHERE employee_id = ?";
            pstmt = conn.prepareStatement(sql2);
            pstmt.setString(1, employeeId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                hasCtcDetails = true;
                employeeName = rs.getString("employee_name");
                designation = rs.getString("designation");
                department = rs.getString("department");
                workLocation = rs.getString("work_location");
                joiningDate = rs.getDate("date_of_joining") != null ? 
                    new SimpleDateFormat("dd-MMM-yyyy").format(rs.getDate("date_of_joining")) : "";
                basic = rs.getDouble("basic_salary");
                hra = rs.getDouble("hra");
                special = rs.getDouble("special_allowance");
                conveyance = rs.getDouble("conveyance_allowance");
                medical = rs.getDouble("medical_allowance");
                bonus = rs.getDouble("bonus");
                gratuity = rs.getDouble("gratuity");
                pf = rs.getDouble("pf");
                pt = rs.getDouble("professional_tax");
                tds = rs.getDouble("tds");
                esi = rs.getDouble("esi");
            }
        } catch (Exception e) {
            out.println("<p>Error fetching CTC details: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    %>
    <div class="container">
        <div class="header">
            <h1>CTC Details</h1>
        </div>
        <div class="content">
            <% if (hasCtcDetails) { 
                // Calculate totals
                double grossMonthly = basic + hra + special + conveyance + medical;
                double grossAnnual = grossMonthly * 12;
                double totalDeductionsMonthly = pf + pt + tds + esi;
                double totalDeductionsAnnual = totalDeductionsMonthly * 12;
                double netSalaryMonthly = grossMonthly - totalDeductionsMonthly;
                double netSalaryAnnual = netSalaryMonthly * 12;
                double employerPf = pf; // Assuming employer PF matches employee PF
                double totalCtcMonthly = grossMonthly + employerPf + gratuity + bonus;
                double totalCtcAnnual = totalCtcMonthly * 12;
            %>
                <div class="employee-info">
                    <h2>Employee Information</h2>
                    <div class="info-grid">
                        <div class="info-item"><span>Employee ID:</span> <%= employeeId %></div>
                        <div class="info-item"><span>Name:</span> <%= employeeName %></div>
                        <div class="info-item"><span>Designation:</span> <%= designation %></div>
                        <div class="info-item"><span>Department:</span> <%= department %></div>
                        <div class="info-item"><span>Joining Date:</span> <%= joiningDate %></div>
                        <div class="info-item"><span>Work Location:</span> <%= workLocation %></div>
                    </div>
                </div>

                <div class="ctc-details">
                    <h2>Salary Breakdown</h2>
                    <div class="ctc-section">
                        <h3>Earnings</h3>
                        <table>
                            <thead>
                                <tr><th>Component</th><th>Monthly (₹)</th><th>Annual (₹)</th></tr>
                            </thead>
                            <tbody>
                                <tr><td>Basic Salary</td><td><%= String.format("%.2f", basic) %></td><td><%= String.format("%.2f", basic * 12) %></td></tr>
                                <tr><td>HRA</td><td><%= String.format("%.2f", hra) %></td><td><%= String.format("%.2f", hra * 12) %></td></tr>
                                <tr><td>Special Allowance</td><td><%= String.format("%.2f", special) %></td><td><%= String.format("%.2f", special * 12) %></td></tr>
                                <tr><td>Conveyance Allowance</td><td><%= String.format("%.2f", conveyance) %></td><td><%= String.format("%.2f", conveyance * 12) %></td></tr>
                                <tr><td>Medical Allowance</td><td><%= String.format("%.2f", medical) %></td><td><%= String.format("%.2f", medical * 12) %></td></tr>
                                <tr class="total"><td>Gross Earnings</td><td><%= String.format("%.2f", grossMonthly) %></td><td><%= String.format("%.2f", grossAnnual) %></td></tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="ctc-section">
                        <h3>Deductions</h3>
                        <table>
                            <thead>
                                <tr><th>Component</th><th>Monthly (₹)</th><th>Annual (₹)</th></tr>
                            </thead>
                            <tbody>
                                <tr><td>Provident Fund</td><td><%= String.format("%.2f", pf) %></td><td><%= String.format("%.2f", pf * 12) %></td></tr>
                                <tr><td>Professional Tax</td><td><%= String.format("%.2f", pt) %></td><td><%= String.format("%.2f", pt * 12) %></td></tr>
                                <tr><td>Income Tax (TDS)</td><td><%= String.format("%.2f", tds) %></td><td><%= String.format("%.2f", tds * 12) %></td></tr>
                                <tr><td>ESI</td><td><%= String.format("%.2f", esi) %></td><td><%= String.format("%.2f", esi * 12) %></td></tr>
                                <tr class="total"><td>Total Deductions</td><td><%= String.format("%.2f", totalDeductionsMonthly) %></td><td><%= String.format("%.2f", totalDeductionsAnnual) %></td></tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="ctc-section">
                        <h3>Net Salary (Take Home)</h3>
                        <table>
                            <thead>
                                <tr><th>Monthly (₹)</th><th>Annual (₹)</th></tr>
                            </thead>
                            <tbody>
                                <tr><td><%= String.format("%.2f", netSalaryMonthly) %></td><td><%= String.format("%.2f", netSalaryAnnual) %></td></tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="ctc-section">
                        <h3>Employer Contributions</h3>
                        <table>
                            <thead>
                                <tr><th>Component</th><th>Monthly (₹)</th><th>Annual (₹)</th></tr>
                            </thead>
                            <tbody>
                                <tr><td>Employer PF Contribution</td><td><%= String.format("%.2f", employerPf) %></td><td><%= String.format("%.2f", employerPf * 12) %></td></tr>
                                <tr><td>Gratuity</td><td><%= String.format("%.2f", gratuity) %></td><td><%= String.format("%.2f", gratuity * 12) %></td></tr>
                                <tr><td>Bonus</td><td><%= String.format("%.2f", bonus) %></td><td><%= String.format("%.2f", bonus * 12) %></td></tr>
                                <tr class="total"><td>Total CTC</td><td><%= String.format("%.2f", totalCtcMonthly) %></td><td><%= String.format("%.2f", totalCtcAnnual) %></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            <% } else { %>
                <div class="no-ctc-message">
                    <p>CTC details will be updated shortly.<br> Please wait for a while.</p>
                </div>
            <% } %>
        </div>
    </div>
    <script src="<%= request.getContextPath() %>/js/employee_ctc_scripts.js"></script>
</body>
</html>