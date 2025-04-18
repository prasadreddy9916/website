<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.DecimalFormat" %>
<%
    String empId = request.getParameter("empId");
    String month = request.getParameter("month");
    int year = Integer.parseInt(request.getParameter("year"));
    DecimalFormat df = new DecimalFormat("#,##0.00");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam", "root", "hacker#Tag1");
        String sql = "SELECT p.*, c.designation, c.department, c.date_of_joining, c.bank_name, " +
                     "c.bank_account_no, c.uan_number, c.pf_number, c.company_name, c.company_address " +
                     "FROM payslips p JOIN ctc_employees c ON p.employee_id = c.employee_id " +
                     "WHERE p.employee_id = ? AND p.month = ? AND p.year = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, empId);
        pstmt.setString(2, month);
        pstmt.setInt(3, year);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
%>
            <div class="section">
                <h3>Employee Details</h3>
                <div class="info-item"><strong>Employee ID:</strong> <span><%= empId %></span></div>
                <div class="info-item"><strong>Name:</strong> <span><%= rs.getString("employee_name") %></span></div>
                <div class="info-item"><strong>Designation:</strong> <span><%= rs.getString("designation") %></span></div>
                <div class="info-item"><strong>Department:</strong> <span><%= rs.getString("department") %></span></div>
                <div class="info-item"><strong>Date of Joining:</strong> <span><%= rs.getString("date_of_joining") %></span></div>
                <div class="info-item"><strong>Bank Name:</strong> <span><%= rs.getString("bank_name") %></span></div>
                <div class="info-item"><strong>Bank A/c No:</strong> <span><%= rs.getString("bank_account_no") %></span></div>
                <div class="info-item"><strong>UAN Number:</strong> <span><%= rs.getString("uan_number") %></span></div>
                <div class="info-item"><strong>PF Number:</strong> <span><%= rs.getString("pf_number") %></span></div>
                <div class="info-item"><strong>Location:</strong> <span><%= rs.getString("work_location") %></span></div>
            </div>

            <div class="section">
                <h3>Attendance Details</h3>
                <div class="info-item"><strong>Total Working Days:</strong> <span><%= rs.getInt("total_working_days") %></span></div>
                <div class="info-item"><strong>LOP Days:</strong> <span><%= rs.getInt("lop_days") %></span></div>
                <div class="info-item"><strong>Paid Days:</strong> <span><%= rs.getInt("paid_days") %></span></div>
            </div>

            <div class="section">
                <h3>Earnings & Deductions</h3>
                <table>
                    <tr><th>Earnings</th><th>Amount (₹)</th><th>Deductions</th><th>Amount (₹)</th></tr>
                    <tr><td>Basic Salary</td><td><%= df.format(rs.getDouble("basic_salary")) %></td><td>EPF</td><td><%= df.format(rs.getDouble("epf")) %></td></tr>
                    <tr><td>House Rent Allowance</td><td><%= df.format(rs.getDouble("hra")) %></td><td>Professional Tax</td><td><%= df.format(rs.getDouble("professional_tax")) %></td></tr>
                    <tr><td>Flexible Plan</td><td><%= df.format(rs.getDouble("flexible_plan")) %></td><td>ESI</td><td><%= df.format(rs.getDouble("esi")) %></td></tr>
                    <tr><td>Other Earnings</td><td><%= df.format(rs.getDouble("other_earnings")) %></td><td>TDS</td><td><%= df.format(rs.getDouble("tds")) %></td></tr>
                    <tr><td></td><td></td><td>Other Deductions (LOP)</td><td><%= df.format(rs.getDouble("other_deductions")) %></td></tr>
                    <tr><td>Gross Earnings</td><td><%= df.format(rs.getDouble("gross_salary")) %></td><td>Total Deductions</td><td><%= df.format(rs.getDouble("total_deductions")) %></td></tr>
                </table>
            </div>

            <div class="section">
                <h3>Net Salary</h3>
                <div class="info-item"><strong>Net Salary:</strong> <span>₹ <%= df.format(rs.getDouble("net_salary")) %></span></div>
            </div>
<%
        } else {
            out.println("<p>No payslip found for this period.</p>");
        }
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p>Error loading payslip: " + e.getMessage() + "</p>");
    }
%>