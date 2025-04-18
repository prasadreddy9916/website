<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
	String email = (String) session.getAttribute("email");
	if (email == null) {
	    response.sendRedirect("adminlogin.jsp");
	    return;
	}

    String url = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata"; // IST
    String username = "root";
    String password = "hacker#Tag1";
    List<String> batches = new ArrayList<>();
    String errorMessage = (String) request.getAttribute("error");

    try (Connection conn = DriverManager.getConnection(url, username, password);
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery("SELECT DISTINCT Batch FROM employee_registrations WHERE Batch IS NOT NULL")) {
        Class.forName("com.mysql.cj.jdbc.Driver");
        while (rs.next()) {
            batches.add(rs.getString("Batch"));
        }
        Collections.sort(batches);
    } catch (Exception e) {
        errorMessage = "Failed to load batches: " + e.getMessage();
    }

    Boolean success = (Boolean) request.getAttribute("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Assignment</title>
    <link rel="stylesheet" href="css/exam_creation_styles.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Exam Assignment</h1>
        </div>
        <div class="content">
            <% if (success != null && success) { %>
            <div id="successMessage" class="success-message">Assigned Exam Successfully</div>
            <% } %>
            <% if (errorMessage != null) { %>
            <div class="error-message"><%= errorMessage %></div>
            <% } %>
            <form id="assignmentForm" action="CreateExamServlet" method="post">
                <div class="form-group">
                    <label for="examType">Exam Type</label>
                    <select id="examType" name="examType" required>
                        <option value="" disabled selected>Select Exam Type</option>
                        <option value="Training">Training </option>
                       
                    </select>
                </div>
                <div class="form-group">
                    <label for="batchAssignment">Assign to Batch</label>
                    <select id="batchAssignment" name="batchAssignment" required>
                        <option value="" disabled selected>Select Batch</option>
                        <% for (String batch : batches) { %>
                        <option value="<%= batch %>"><%= batch %></option>
                        <% } %>
                        <% if (batches.isEmpty()) { %>
                        <option value="" disabled>No batches available</option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="dueDate">Due Date</label>
                    <input type="date" id="dueDate" name="dueDate" required>
                </div>
                <div class="form-group">
                    <label for="dueTime">Due Time</label>
                    <input type="time" id="dueTime" name="dueTime" required>
                </div>
                <button type="submit" class="btn">Submit</button>
            </form>
        </div>
    </div>
    <script src="js/exam_creation_scripts.js"></script>
</body>
</html>