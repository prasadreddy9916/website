<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    String url = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    String username = "root";
    String password = "hacker#Tag1";
    String errorMessage = null;

    List<String> uniqueExams = new ArrayList<>();
    List<String> uniqueBatches = new ArrayList<>();
    List<Map<String, String>> results = new ArrayList<>();

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);
        stmt = conn.createStatement();

        // Fetch unique Exams
        rs = stmt.executeQuery("SELECT DISTINCT Exam FROM employee_registrations WHERE Exam IS NOT NULL");
        while (rs.next()) {
            uniqueExams.add(rs.getString("Exam"));
        }
        Collections.sort(uniqueExams);

        // Fetch unique Batches
        rs = stmt.executeQuery("SELECT DISTINCT Batch FROM employee_registrations WHERE Batch IS NOT NULL");
        while (rs.next()) {
            uniqueBatches.add(rs.getString("Batch"));
        }
        Collections.sort(uniqueBatches);

        // Fetch results with unique Employee_IDs (highest correct answers from score) and coding marks
        String query = "SELECT er.ID AS Employee_ID, er.Name AS Employee_Name, er.Exam, er.Batch, er.score AS Multiple_Score, er.Status, " +
                      "COALESCE(eca.Exam_Name, 'N/A') AS Exam_Category, " +
                      "CAST(SUBSTRING_INDEX(er.score, '/', 1) AS UNSIGNED) AS Correct_Answers, " +
                      "sr.marks AS Coding_Score " +
                      "FROM employee_registrations er " +
                      "LEFT JOIN exam_creation_assignment eca ON er.Batch = eca.Assign_To " +
                      "LEFT JOIN submission_results sr ON er.ID = sr.user_id " +
                      "WHERE CAST(SUBSTRING_INDEX(er.score, '/', 1) AS UNSIGNED) = (" +
                      "    SELECT MAX(CAST(SUBSTRING_INDEX(er2.score, '/', 1) AS UNSIGNED)) " +
                      "    FROM employee_registrations er2 " +
                      "    WHERE er2.ID = er.ID" +
                      ") " +
                      "GROUP BY er.ID, er.Name, er.Exam, er.Batch, er.score, er.Status, eca.Exam_Name, sr.marks";
        rs = stmt.executeQuery(query);

        while (rs.next()) {
            Map<String, String> result = new HashMap<>();
            result.put("Employee_ID", rs.getString("Employee_ID") != null ? rs.getString("Employee_ID") : "N/A");
            result.put("Employee_Name", rs.getString("Employee_Name") != null ? rs.getString("Employee_Name") : "N/A");
            result.put("Exam", rs.getString("Exam") != null ? rs.getString("Exam") : "N/A");
            result.put("Batch", rs.getString("Batch") != null ? rs.getString("Batch") : "N/A");
            result.put("Multiple_Score", rs.getString("Multiple_Score") != null ? rs.getString("Multiple_Score") : "0/0");
            result.put("Status", rs.getString("Status") != null ? rs.getString("Status") : "-");
            result.put("Exam_Category", rs.getString("Exam_Category") != null ? rs.getString("Exam_Category") : "N/A");
            result.put("Coding_Score", rs.getString("Coding_Score") != null ? rs.getString("Coding_Score") : "N/A");
            results.add(result);
        }
    } catch (Exception e) {
        errorMessage = "Error fetching data: " + e.getMessage();
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Results Summary - Exam Management</title>
    <link rel="stylesheet" href="css/ResultSummary.css">
</head>
<body>
    <div class="results-summary">
        <header><h1>Results Summary</h1></header>
        <div class="filters">
            <div class="filter-group">
                <label>Exam Filter</label>
                <select id="examFilter">
                    <option value="all">All Exams</option>
                    <% for (String exam : uniqueExams) { %>
                    <option value="<%= exam.toLowerCase() %>"><%= exam %></option>
                    <% } %>
                </select>
            </div>
            <div class="filter-group">
                <label>Batch Filter</label>
                <select id="batchFilter">
                    <option value="all">All Batches</option>
                    <% for (String batch : uniqueBatches) { %>
                    <option value="<%= batch.toLowerCase() %>"><%= batch %></option>
                    <% } %>
                </select>
            </div>
            <div class="filter-group">
                <label>Employee ID Search</label>
                <input type="text" id="empIdSearch" placeholder="Search by Employee ID">
            </div>
            <div class="filter-group">
                <label>Employee Name Search</label>
                <input type="text" id="empNameSearch" placeholder="Search by Employee Name">
            </div>
        </div>
        <div class="table-container">
            <table>
                <thead class="sticky-header">
                    <tr>
                        <th>Exam</th>
                        <th>Batch</th>
                        <th>Employee ID</th>
                        <th>Employee Name</th>
                        <th>Multiple Score</th>
                        <th>Coding Score</th>
                        <th>Status</th>
                        <th>Exam Category</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, String> result : results) { %>
                    <tr data-exam="<%= result.get("Exam").toLowerCase() %>"
                        data-batch="<%= result.get("Batch").toLowerCase() %>"
                        data-empid="<%= result.get("Employee_ID").toLowerCase() %>"
                        data-empname="<%= result.get("Employee_Name").toLowerCase() %>">
                        <td><%= result.get("Exam") %></td>
                        <td><%= result.get("Batch") %></td>
                        <td><%= result.get("Employee_ID") %></td>
                        <td><%= result.get("Employee_Name") %></td>
                        <td><%= result.get("Multiple_Score") %></td>
                        <td><%= result.get("Coding_Score") %></td>
                        <td><%= result.get("Status") %></td>
                        <td><%= result.get("Exam_Category") %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% if (errorMessage != null) { %>
        <div class="error-message"><%= errorMessage %></div>
        <% } %>
    </div>
    <script src="js/ResultSummary.js"></script>
</body>
</html>