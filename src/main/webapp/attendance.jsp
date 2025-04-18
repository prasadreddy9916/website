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

    // Handle attendance save (add or update)
    if ("POST".equalsIgnoreCase(request.getMethod()) && "save".equals(request.getParameter("action"))) {
        String empId = request.getParameter("empId");
        String attendanceStr = request.getParameter("attendance");
        String month = request.getParameter("month");
        int year = Integer.parseInt(request.getParameter("year"));
        String empName = request.getParameter("empName");
        String source = request.getParameter("source"); // "add" or "edit"

        int attendance;
        try {
            attendance = Integer.parseInt(attendanceStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid attendance value!");
            return;
        }

        // Validate attendance based on month
        int maxDays;
        boolean isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        switch (month) {
            case "February": maxDays = isLeapYear ? 29 : 28; break;
            case "April": case "June": case "September": case "November": maxDays = 30; break;
            default: maxDays = 31; // January, March, May, July, August, October, December
        }

        if (attendance < 0 || attendance > maxDays) {
            request.setAttribute("error", "Attendance must be between 0 and " + maxDays + " for " + month + "!");
        } else {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD)) {
                    // Check if month-year already exists for this employee
                    PreparedStatement checkStmt = conn.prepareStatement(
                        "SELECT COUNT(*) FROM check_old_attendance WHERE employee_id = ? AND month = ? AND year = ?");
                    checkStmt.setString(1, empId);
                    checkStmt.setString(2, month);
                    checkStmt.setInt(3, year);
                    ResultSet rs = checkStmt.executeQuery();
                    rs.next();

                    if (rs.getInt(1) > 0) {
                        if ("add".equals(source)) {
                            // From "Add Attendance" - show error and do nothing
                            request.setAttribute("error", "Attendance for " + empName + " for " + month + "/" + year + " already exists!");
                        } else if ("edit".equals(source)) {
                            // From "Edit" - update existing record
                            PreparedStatement updateStmt = conn.prepareStatement(
                                "UPDATE check_old_attendance SET attendance = ?, employee_name = ? WHERE employee_id = ? AND month = ? AND year = ?");
                            updateStmt.setInt(1, attendance);
                            updateStmt.setString(2, empName);
                            updateStmt.setString(3, empId);
                            updateStmt.setString(4, month);
                            updateStmt.setInt(5, year);
                            updateStmt.executeUpdate();

                            request.setAttribute("message", "Attendance updated successfully for " + empName);
                        }
                    } else {
                        // No record exists - insert new record
                        PreparedStatement insertStmt = conn.prepareStatement(
                            "INSERT INTO check_old_attendance (employee_id, employee_name, attendance, month, year) VALUES (?, ?, ?, ?, ?)");
                        insertStmt.setString(1, empId);
                        insertStmt.setString(2, empName);
                        insertStmt.setInt(3, attendance);
                        insertStmt.setString(4, month);
                        insertStmt.setInt(5, year);
                        insertStmt.executeUpdate();

                        request.setAttribute("message", "Attendance added successfully for " + empName);
                    }
                }
            } catch (Exception e) {
                request.setAttribute("error", "Error processing attendance: " + e.getMessage());
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/attendance_styles.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Employee Attendance Management</h1>
            <button class="add-btn" onclick="openAddModal()">Add Attendance</button>
        </div>
        <div class="filters">
            <div class="filter-group">
                <label>Employee ID</label>
                <input type="text" id="filterEmpId" placeholder="Enter Employee ID">
            </div>
            <div class="filter-group">
                <label>Name</label>
                <input type="text" id="filterName" placeholder="Enter Name">
            </div>
            <div class="filter-group">
                <label>Attendance</label>
                <input type="number" id="filterAttendance" placeholder="Enter Attendance">
            </div>
            <div class="filter-group">
                <label>Month</label>
                <select id="filterMonth">
                    <option value="">All Months</option>
                    <option value="January">January</option>
                    <option value="February">February</option>
                    <option value="March">March</option>
                    <option value="April">April</option>
                    <option value="May">May</option>
                    <option value="June">June</option>
                    <option value="July">July</option>
                    <option value="August">August</option>
                    <option value="September">September</option>
                    <option value="October">October</option>
                    <option value="November">November</option>
                    <option value="December">December</option>
                </select>
            </div>
            <div class="filter-group">
                <label>Year</label>
                <input type="number" id="filterYear" placeholder="Enter Year">
            </div>
        </div>
        <div class="content">
            <h2>Check Old Attendance</h2>
            <div class="table-container scrollable">
                <table>
                    <thead>
                        <tr>
                            <th>Employee ID</th>
                            <th>Name</th>
                            <th>Attendance</th>
                            <th>Month/Year</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="oldAttendanceTable">
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
                                 PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM check_old_attendance");
                                 ResultSet rs = pstmt.executeQuery()) {
                                while (rs.next()) {
                    %>
                        <tr>
                            <td><%= rs.getString("employee_id") %></td>
                            <td><%= rs.getString("employee_name") %></td>
                            <td><%= rs.getInt("attendance") %></td>
                            <td><%= rs.getString("month") + "/" + rs.getInt("year") %></td>
                            <td>
                                <button class="edit-btn" onclick="openEditModal('<%= rs.getString("employee_id") %>', '<%= rs.getString("employee_name") %>', <%= rs.getInt("attendance") %>, '<%= rs.getString("month") %>', <%= rs.getInt("year") %>, true)">Edit</button>
                            </td>
                        </tr>
                    <%
                                }
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5'>Error loading data: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Add Attendance Modal -->
        <div id="addModal" class="modal" style="display: none;">
            <div class="modal-content">
                <div class="modal-header sticky-header">
                    <h2>Attendance Adding</h2>
                    <button class="cancel-btn" onclick="closeAddModal()">Cancel</button>
                </div>
                <div class="filters">
                    <div class="filter-group">
                        <label>Employee ID</label>
                        <input type="text" id="addFilterEmpId" placeholder="Enter Employee ID">
                    </div>
                    <div class="filter-group">
                        <label>Name</label>
                        <input type="text" id="addFilterName" placeholder="Enter Name">
                    </div>
                    <div class="filter-group">
                        <label>Attendance</label>
                        <input type="number" id="addFilterAttendance" placeholder="Enter Attendance">
                    </div>
                    <div class="filter-group">
                        <label>Month</label>
                        <select id="addFilterMonth">
                            <option value="">All Months</option>
                            <option value="January">January</option>
                            <option value="February">February</option>
                            <option value="March">March</option>
                            <option value="April">April</option>
                            <option value="May">May</option>
                            <option value="June">June</option>
                            <option value="July">July</option>
                            <option value="August">August</option>
                            <option value="September">September</option>
                            <option value="October">October</option>
                            <option value="November">November</option>
                            <option value="December">December</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label>Year</label>
                        <input type="number" id="addFilterYear" placeholder="Enter Year">
                    </div>
                </div>
                <div class="table-container scrollable">
                    <table>
                        <thead>
                            <tr>
                                <th>Employee ID</th>
                                <th>Name</th>
                                <th>Attendance</th>
                                <th>Month/Year</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="attendanceTable">
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
                                     PreparedStatement pstmt = conn.prepareStatement(
                                         "SELECT employee_id, employee_name FROM ctc_employees WHERE end_date IS NULL");
                                     ResultSet rs = pstmt.executeQuery()) {
                                    while (rs.next()) {
                        %>
                            <tr>
                                <td><%= rs.getString("employee_id") %></td>
                                <td><%= rs.getString("employee_name") %></td>
                                <td>0</td>
                                <td>Not Set</td>
                                <td>
                                    <button class="edit-btn" onclick="openEditModal('<%= rs.getString("employee_id") %>', '<%= rs.getString("employee_name") %>', 0, '', 0)">Edit</button>
                                </td>
                            </tr>
                        <%
                                    }
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='5'>Error loading data: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Edit Modal -->
        <div id="editModal" class="modal" style="display: none;">
            <div class="modal-content">
                <h2>Edit Attendance</h2>
                <form method="post" action="attendance.jsp">
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="source" id="editSource">
                    <input type="hidden" id="editEmpId" name="empId">
                    <input type="hidden" id="editEmpName" name="empName">
                    <div class="form-group">
                        <label>Employee ID</label>
                        <input type="text" id="displayEmpId" readonly>
                    </div>
                    <div class="form-group">
                        <label>Employee Name</label>
                        <input type="text" id="displayEmpName" readonly>
                    </div>
                    <div class="form-group">
                        <label>Attendance<span class="required">*</span></label>
                        <input type="number" id="editAttendance" name="attendance" required>
                    </div>
                    <div class="form-group">
                        <label>Month<span class="required">*</span></label>
                        <select id="editMonth" name="month" required>
                            <option value="">Select Month</option>
                            <option value="January">January</option>
                            <option value="February">February</option>
                            <option value="March">March</option>
                            <option value="April">April</option>
                            <option value="May">May</option>
                            <option value="June">June</option>
                            <option value="July">July</option>
                            <option value="August">August</option>
                            <option value="September">September</option>
                            <option value="October">October</option>
                            <option value="November">November</option>
                            <option value="December">December</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Year<span class="required">*</span></label>
                        <input type="number" id="editYear" name="year" min="2000" max="2100" required>
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

    <script src="<%= request.getContextPath() %>/js/attendance_scripts.js"></script>
</body>
</html>

