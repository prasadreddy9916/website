<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    String URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    String USERNAME = "root";
    String PASSWORD = "hacker#Tag1";

    // Handle form submission for updating PF, UAN, and Bank details
    if ("POST".equalsIgnoreCase(request.getMethod()) && "update".equals(request.getParameter("action"))) {
        String empId = request.getParameter("empId");
        String pfNumber = request.getParameter("pfNumber");
        String uanNumber = request.getParameter("uanNumber");
        String bankName = request.getParameter("bankName");
        String bankAccountNo = request.getParameter("bankAccountNo");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
                 PreparedStatement pstmt = conn.prepareStatement(
                     "UPDATE ctc_employees SET pf_number = ?, uan_number = ?, bank_name = ?, bank_account_no = ? WHERE employee_id = ?")) {
                pstmt.setString(1, pfNumber);
                pstmt.setString(2, uanNumber);
                pstmt.setString(3, bankName);
                pstmt.setString(4, bankAccountNo);
                pstmt.setString(5, empId);
                int rows = pstmt.executeUpdate();
                if (rows > 0) {
                    request.setAttribute("message", "Details updated successfully for " + empId);
                } else {
                    request.setAttribute("error", "Failed to update details for " + empId);
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error updating details: " + e.getMessage());
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Details</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/pf_styles.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Employee PF and Bank Details</h1>
        </div>
        <div class="content">
            <div class="filter-section">
                <div class="form-group">
                    <label for="empIdFilter">Search by Employee ID:</label>
                    <input type="text" id="empIdFilter" onkeyup="filterTable()" placeholder="Enter Employee ID">
                </div>
                <div class="form-group">
                    <label for="empNameFilter">Search by Employee Name:</label>
                    <input type="text" id="empNameFilter" onkeyup="filterTable()" placeholder="Enter Employee Name">
                </div>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Employee ID</th>
                            <th>Name</th>
                            <th>PF Number</th>
                            <th>UAN Number</th>
                            <th>Bank Name</th>
                            <th>Bank Account No</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="employeeTable">
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
                                 PreparedStatement pstmt = conn.prepareStatement(
                                     "SELECT employee_id, employee_name, pf_number, uan_number, bank_name, bank_account_no FROM ctc_employees");
                                 ResultSet rs = pstmt.executeQuery()) {
                                while (rs.next()) {
                    %>
                        <tr>
                            <td><%= rs.getString("employee_id") %></td>
                            <td><%= rs.getString("employee_name") %></td>
                            <td><%= rs.getString("pf_number") != null ? rs.getString("pf_number") : "Not Set" %></td>
                            <td><%= rs.getString("uan_number") != null ? rs.getString("uan_number") : "Not Set" %></td>
                            <td><%= rs.getString("bank_name") != null && !rs.getString("bank_name").equals("XXXX") ? rs.getString("bank_name") : "Not Set" %></td>
                            <td><%= rs.getString("bank_account_no") != null && !rs.getString("bank_account_no").equals("XXXX") ? rs.getString("bank_account_no") : "Not Set" %></td>
                            <td>
                                <button class="edit-btn" onclick="openEditModal('<%= rs.getString("employee_id") %>', '<%= rs.getString("employee_name") %>', '<%= rs.getString("pf_number") != null ? rs.getString("pf_number") : "" %>', '<%= rs.getString("uan_number") != null ? rs.getString("uan_number") : "" %>', '<%= rs.getString("bank_name") != null && !rs.getString("bank_name").equals("XXXX") ? rs.getString("bank_name") : "" %>', '<%= rs.getString("bank_account_no") != null && !rs.getString("bank_account_no").equals("XXXX") ? rs.getString("bank_account_no") : "" %>')">Edit</button>
                            </td>
                        </tr>
                    <%
                                }
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='7'>Error loading data: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Edit Modal -->
        <div id="editModal" class="modal">
            <div class="modal-content">
                <h2>Edit Employee Details</h2>
                <form method="post" action="pf_details.jsp">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" id="editEmpId" name="empId">
                    <div class="form-group">
                        <label>Employee ID</label>
                        <input type="text" id="displayEmpId" readonly>
                    </div>
                    <div class="form-group">
                        <label>Employee Name</label>
                        <input type="text" id="displayEmpName" readonly>
                    </div>
                    <div class="form-group">
                        <label>PF Number<span class="required">*</span></label>
                        <input type="text" id="editPfNumber" name="pfNumber" required>
                    </div>
                    <div class="form-group">
                        <label>UAN Number<span class="required">*</span></label>
                        <input type="text" id="editUanNumber" name="uanNumber" required>
                    </div>
                    <div class="form-group">
                        <label>Bank Name<span class="required">*</span></label>
                        <input type="text" id="editBankName" name="bankName" required>
                    </div>
                    <div class="form-group">
                        <label>Bank Account Number<span class="required">*</span></label>
                        <input type="text" id="editBankAccountNo" name="bankAccountNo" required>
                    </div>
                    <div class="form-actions">
                        <button type="submit">Save</button>
                        <button type="button" onclick="closeEditModal()">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <% if (request.getAttribute("message") != null) { %>
            <div id="popup" class="popup success" style="display: block;"><%= request.getAttribute("message") %></div>
        <% } else if (request.getAttribute("error") != null) { %>
            <div id="popup" class="popup error" style="display: block;"><%= request.getAttribute("error") %></div>
        <% } %>
    </div>

    <script src="<%= request.getContextPath() %>/js/pf_scripts.js"></script>
</body>
</html>