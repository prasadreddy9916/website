<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.time.*, java.time.format.DateTimeFormatter" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    String url = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata"; // IST
    String username = "root";
    String password = "hacker#Tag1";
    String errorMessage = null;
    Connection conn = null;
    Statement stmt = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    LocalDateTime currentDateTime = LocalDateTime.now(ZoneId.of("Asia/Kolkata")); // Current IST time
    java.util.Set<String> batches = new java.util.TreeSet<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);
        stmt = conn.createStatement();

        // Step 1: Update Actions to "Completed" for expired deadlines
        String updateSql = "UPDATE assigned_exams SET Actions = 'Completed' WHERE Deadline < ? AND Actions != 'Completed'";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setTimestamp(1, Timestamp.valueOf(currentDateTime));
        pstmt.executeUpdate();
        pstmt.close();

        // Step 2: Sync with exam_creation_assignment
        String fetchSql = "SELECT Exam_Name, Assign_To, Deadline_Date FROM exam_creation_assignment";
        rs = stmt.executeQuery(fetchSql);

        while (rs.next()) {
            String examName = rs.getString("Exam_Name");
            String batchName = rs.getString("Assign_To");
            LocalDateTime deadline = rs.getTimestamp("Deadline_Date").toLocalDateTime();

            // Check if the deadline is still active
            if (deadline.isAfter(currentDateTime)) {
                // Count employees with "Fail" or "Pending" status in the batch
                String countSql = "SELECT COUNT(*) FROM employee_registrations WHERE Batch = ? AND status IN ('Fail', 'Pending')";
                pstmt = conn.prepareStatement(countSql);
                pstmt.setString(1, batchName);
                ResultSet countRs = pstmt.executeQuery();
                countRs.next();
                int totalNumbers = countRs.getInt(1);
                countRs.close();
                pstmt.close();

                // Only insert into assigned_exams if there are employees with "Fail" or "Pending" status
                if (totalNumbers > 0) {
                    // Check if this exam assignment already exists in assigned_exams
                    String checkSql = "SELECT COUNT(*) FROM assigned_exams WHERE Exam_Name = ? AND Batch_Name = ?";
                    pstmt = conn.prepareStatement(checkSql);
                    pstmt.setString(1, examName);
                    pstmt.setString(2, batchName);
                    ResultSet checkRs = pstmt.executeQuery();
                    checkRs.next();
                    int exists = checkRs.getInt(1);
                    checkRs.close();
                    pstmt.close();

                    if (exists == 0) { // Insert if not exists
                        String status = "Live"; // Default status for active exams
                        String actions = ""; // Default actions for active exams

                        String insertSql = "INSERT INTO assigned_exams (Exam_Name, Total_Numbers, Batch_Name, Status, Deadline, Actions) " +
                                          "VALUES (?, ?, ?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(insertSql);
                        pstmt.setString(1, examName);
                        pstmt.setInt(2, totalNumbers);
                        pstmt.setString(3, batchName);
                        pstmt.setString(4, status);
                        pstmt.setTimestamp(5, Timestamp.valueOf(deadline));
                        pstmt.setString(6, actions);
                        pstmt.executeUpdate();
                        pstmt.close();
                    } else {
                        // Reassign the exam if it already exists and the deadline is active
                        String reassignSql = "UPDATE assigned_exams SET Status = 'Live', Actions = '', Deadline = ? " +
                                             "WHERE Exam_Name = ? AND Batch_Name = ?";
                        pstmt = conn.prepareStatement(reassignSql);
                        pstmt.setTimestamp(1, Timestamp.valueOf(deadline));
                        pstmt.setString(2, examName);
                        pstmt.setString(3, batchName);
                        pstmt.executeUpdate();
                        pstmt.close();
                    }
                }
            }
        }
        rs.close();

        // Fetch unique batches for filter
        rs = stmt.executeQuery("SELECT DISTINCT Batch FROM employee_registrations WHERE Batch IS NOT NULL");
        while (rs.next()) {
            batches.add(rs.getString("Batch"));
        }
    } catch (Exception e) {
        errorMessage = "Error syncing data: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="css/exam_dashboard_styles.css">
</head>
<body>
    <div class="exam-dashboard">
        <div class="dashboard-header">
            <h1>Assigned Exams</h1>
        </div>
        <div class="dashboard-filters">
            <div class="filter-item">
                <label for="batchSelector">Batch</label>
                <select id="batchSelector">
                    <option value="">All Batches</option>
                    <% for (String batch : batches) { %>
                    <option value="<%= batch %>"><%= batch %></option>
                    <% } %>
                </select>
            </div>
            <div class="filter-item">
                <label for="examSelector">Exam Type</label>
                <select id="examSelector">
                    <option value="">All Exams</option>
                    <option value="Training">Training</option>
                   
                </select>
            </div>
        </div>
        <div class="dashboard-table-container">
            <table class="dashboard-table">
                <thead>
                    <tr>
                        <th>Exam ID</th>
                        <th>Exam Category</th>
                        <th>Participants</th>
                        <th>Group</th>
                        <th>Progress</th>
                        <th>Due Date & Time</th>
                        <th>Options</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            conn = DriverManager.getConnection(url, username, password);
                            String query = "SELECT ID, Exam_Name, Total_Numbers, Batch_Name, Status, Deadline, Actions " +
                                           "FROM assigned_exams";
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery(query);

                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='7'>No exams assigned yet.</td></tr>");
                            } else {
                                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                while (rs.next()) {
                                    int id = rs.getInt("ID");
                                    String examName = rs.getString("Exam_Name");
                                    int totalNumbers = rs.getInt("Total_Numbers");
                                    String batchName = rs.getString("Batch_Name");
                                    String status = rs.getString("Status");
                                    LocalDateTime deadline = rs.getTimestamp("Deadline").toLocalDateTime();
                                    String actions = rs.getString("Actions");

                                    if (deadline.isBefore(currentDateTime) && !"Completed".equals(actions)) {
                                        pstmt = conn.prepareStatement(
                                            "UPDATE assigned_exams SET Actions = 'Completed' WHERE ID = ?");
                                        pstmt.setInt(1, id);
                                        pstmt.executeUpdate();
                                        pstmt.close();
                                        actions = "Completed";
                                    }
                    %>
                    <tr data-id="<%= id %>" data-exam="<%= examName %>" data-batch="<%= batchName %>">
                        <td><%= id %></td>
                        <td><%= examName %></td>
                        <td><%= totalNumbers %></td>
                        <td><%= batchName %></td>
                        <td><%= status %></td>
                        <td><%= deadline.format(formatter) %></td>
                        <td class="options">
                            <button class="action-btn publish-btn" data-id="<%= id %>"
                                    <% if ("Running".equals(actions) || "Completed".equals(actions)) { %>disabled<% } %>>
                                <%= actions.isEmpty() ? "Publish" : actions %>
                            </button>
                        </td>
                    </tr>
                    <%
                                }
                            }
                        } catch (Exception e) {
                            errorMessage = "Error loading exams: " + e.getMessage();
                            out.println("<tr><td colspan='7'>" + errorMessage + "</td></tr>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) {}
                            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                            if (conn != null) try { conn.close(); } catch (SQLException e) {}
                        }
                    %>
                </tbody>
            </table>
        </div>
        <% if (errorMessage != null) { %>
        <div class="dashboard-error"><%= errorMessage %></div>
        <% } %>
    </div>
    <script src="js/exam_dashboard_scripts.js"></script>
</body>
</html>