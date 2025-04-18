<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*" %>
<%
	String email = (String) session.getAttribute("email");
	if (email == null) {
	    response.sendRedirect("adminlogin.jsp");
	    return;
	}

    // Database connection parameters
    String url = "jdbc:mysql://localhost:3306/exam";
    String username = "root"; // Replace with your MySQL username
    String password = "anilp"; // Replace with your MySQL password

    // Batch selection
    String selectedBatch = request.getParameter("batch");
    int totalRegistered = 0;
    int examsAssigned = 0;
    int pendingAssessments = 0;
    double completedPercentage = 0.0;
    double passRate = 0.0;
    double avgScore = 0.0;
    String topPerformer = "N/A";
    String deptBreakdown = "N/A";
    String deadlineAlert = "N/A";
    String examStatus = "N/A";

    // Fetch data from database if batch is selected
    if (selectedBatch != null && !selectedBatch.isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, username, password);
            String query = "SELECT * FROM exam_overview WHERE selectedBatch = ?";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, selectedBatch);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                totalRegistered = rs.getInt("totalRegistered");
                examsAssigned = rs.getInt("examsAssigned");
                pendingAssessments = rs.getInt("pendingAssessments");
                completedPercentage = rs.getDouble("completedPercentage");
                passRate = rs.getDouble("passRate");
                avgScore = rs.getDouble("avgScore");
                topPerformer = rs.getString("topPerformer") != null ? rs.getString("topPerformer") : "N/A";
                deptBreakdown = rs.getString("deptBreakdown") != null ? rs.getString("deptBreakdown") : "N/A";
                deadlineAlert = rs.getString("deadlineAlert") != null ? rs.getString("deadlineAlert") : "N/A";
                examStatus = rs.getString("examStatus") != null ? rs.getString("examStatus") : "N/A";
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>Error fetching data: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Overview - Admin Panel</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="css/exam_overview.css">
</head>
<body>
    <div class="exam-overview">
        <header>
            <h1>Exam Overview</h1>
        </header>
        <div class="overview-content">
            <!-- Batch Selection Form -->
            <div class="batch-selection">
                <form action="exam_overview.jsp" method="post">
                    <label for="batch">Select Batch:</label>
                    <select name="batch" id="batch" required>
                        <option value="" <%= selectedBatch == null ? "selected" : "" %>>-- Select Batch --</option>
                        <option value="Batch 2025-A" <%= "Batch 2025-A".equals(selectedBatch) ? "selected" : "" %>>Batch 2025-A</option>
                        <option value="Batch 2025-B" <%= "Batch 2025-B".equals(selectedBatch) ? "selected" : "" %>>Batch 2025-B</option>
                    </select>
                    <button type="submit" class="btn btn-primary">Submit</button>
                </form>
            </div>

            <!-- Display Batch Details if Selected -->
            <% if (selectedBatch != null && !selectedBatch.isEmpty()) { %>
                <div class="metrics">
                    <div class="metric-card">
                        <i class="fas fa-users"></i>
                        <h3>Total Registered</h3>
                        <p><%= totalRegistered %></p>
                    </div>
                    <div class="metric-card">
                        <i class="fas fa-clipboard-check"></i>
                        <h3>Exams Assigned</h3>
                        <p><%= examsAssigned %></p>
                    </div>
                    <div class="metric-card">
                        <i class="fas fa-hourglass-half"></i>
                        <h3>Pending Assessments</h3>
                        <p><%= pendingAssessments %></p>
                    </div>
                    <div class="metric-card">
                        <i class="fas fa-check-circle"></i>
                        <h3>Completed</h3>
                        <p><%= String.format("%.1f%%", completedPercentage) %> (<%= (int)(totalRegistered * completedPercentage / 100) %>/<%= totalRegistered %>)</p>
                    </div>
                    <div class="metric-card">
                        <i class="fas fa-trophy"></i>
                        <h3>Pass Rate</h3>
                        <p><%= String.format("%.1f%%", passRate) %></p>
                    </div>
                    <div class="metric-card">
                        <i class="fas fa-star"></i>
                        <h3>Average Score</h3>
                        <p><%= String.format("%.1f/100", avgScore) %></p>
                    </div>
                </div>

                <div class="insights">
                    <div class="insight-card">
                        <h2>Top Performer</h2>
                        <p><i class="fas fa-user-graduate"></i> <%= topPerformer %></p>
                    </div>
                    <div class="insight-card">
                        <h2>Exams by Department/Batch</h2>
                        <p><%= deptBreakdown %></p>
                    </div>
                    <div class="insight-card">
                        <h2>Deadline Alerts</h2>
                        <p><i class="fas fa-exclamation-triangle"></i> <%= deadlineAlert %></p>
                    </div>
                    <div class="insight-card">
                        <h2>Exam Status Summary</h2>
                        <p><%= examStatus %></p>
                    </div>
                </div>
            <% } else { %>
                <div class="no-selection">
                    <p>Please select a batch to view details.</p>
                </div>
            <% } %>
        </div>
    </div>
    <script src="js/exam_overview.js"></script>
</body>
</html>