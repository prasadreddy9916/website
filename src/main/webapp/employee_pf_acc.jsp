<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PF Account Details</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/employee_pf_acc_styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
</head>
<body>
    <%
        String email = (String) session.getAttribute("email");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String employeeId = "", employeeName = "", pfNumber = "", uanNumber = "", bankName = "", bankAccountNo = "";
        boolean hasPfDetails = false;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam", "root", "hacker#Tag1");

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

            String sql2 = "SELECT employee_name, pf_number, uan_number, bank_name, bank_account_no " +
                         "FROM ctc_employees WHERE employee_id = ?";
            pstmt = conn.prepareStatement(sql2);
            pstmt.setString(1, employeeId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                hasPfDetails = true;
                employeeName = rs.getString("employee_name") != null ? rs.getString("employee_name") : "N/A";
                pfNumber = rs.getString("pf_number") != null ? rs.getString("pf_number") : "N/A";
                uanNumber = rs.getString("uan_number") != null ? rs.getString("uan_number") : "N/A";
                bankName = rs.getString("bank_name") != null ? rs.getString("bank_name") : "XXXX";
                bankAccountNo = rs.getString("bank_account_no") != null ? rs.getString("bank_account_no") : "XXXX";
            }
        } catch (Exception e) {
            out.println("<p>Error fetching PF details: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    %>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-wallet"></i> Account Details</h1>
        </div>
        <div class="content">
            <% if (hasPfDetails) { %>
                <div class="employee-info">
                    <h2>Employee Information</h2>
                    <div class="card">
                        <div class="card-item"><i class="fas fa-id-badge"></i> <span>Employee ID:</span> <%= employeeId %></div>
                        <div class="card-item"><i class="fas fa-user"></i> <span>Name:</span> <%= employeeName %></div>
                    </div>
                </div>
                <div class="pf-details">
                    <h2>PF Details</h2>
                    <table>
                        <thead>
                            <tr>
                                <th>Field</th>
                                <th>Value</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>PF Number</td>
                                <td><%= pfNumber %></td>
                            </tr>
                            <tr>
                                <td>UAN Number</td>
                                <td><%= uanNumber %></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="account-info">
                    <h2>Bank Account Information</h2>
                    <div class="info-grid">
                        <div class="grid-item"><span>Bank Name:</span> <%= bankName %></div>
                        <div class="grid-item"><span>Account Number:</span> <%= bankAccountNo %></div>
                    </div>
                </div>
            <% } else { %>
                <div class="no-pf-message">
                    <i class="fas fa-clock"></i>
                    <p>PF account details will be updated shortly. Please wait for a while.</p>
                </div>
            <% } %>
        </div>
    </div>
    <script src="<%= request.getContextPath() %>/js/employee_pf_acc_scripts.js"></script>
</body>
</html>