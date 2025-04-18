<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessments</title>
    <link rel="stylesheet" href="css/assessments.css">
    <script>
        function openFullscreen(url, type) {
            fetch('assessments.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: type === 'exam' ? 'takeAssessment=true' : 'viewCoding=true'
            })
            .then(response => {
                if (response.ok) {
                    let newWindow = window.open(url, '_blank', 'toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=no,fullscreen=yes');
                    if (newWindow) {
                        newWindow.focus();
                        setTimeout(() => {
                            window.location.reload();
                        }, 500);
                    }
                } else {
                    throw new Error('Failed to update status');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Failed to start the ' + (type === 'exam' ? 'assessment' : 'coding exam') + '. Please try again.');
            });
            return false;
        }
    </script>
</head>
<body>
    <%
        String email = (String) session.getAttribute("email");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String DB_URL = "jdbc:mysql://localhost:3306/exam";
        String DB_USER = "root";
        String DB_PASS = "hacker#Tag1";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        String examLink = "exam.jsp";
        String codingLink = "coding.jsp";
        boolean showExamLink = false;
        boolean showCodingLink = false;
        String hasClicked = "No";
        String hasViewedCoding = "No";
        LocalDateTime currentDateTime = LocalDateTime.now();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "SELECT status, Batch, Exam, hasClicked, hasViewedInstructions FROM employee_registrations WHERE email = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();

            if (rs.next()) {
                String status = rs.getString("status");
                String batch = rs.getString("Batch");
                String examType = rs.getString("Exam");
                hasClicked = rs.getString("hasClicked") != null ? rs.getString("hasClicked") : "No";
                hasViewedCoding = rs.getString("hasViewedInstructions") != null ? rs.getString("hasViewedInstructions") : "No";

                if ("Fail".equals(status) || "Pending".equals(status)) {
                    String assignedSql = "SELECT Deadline FROM assigned_exams WHERE Batch_Name = ? AND Actions = 'Running'";
                    stmt = conn.prepareStatement(assignedSql);
                    stmt.setString(1, batch);
                    rs = stmt.executeQuery();

                    if (rs.next()) {
                        LocalDateTime deadline = rs.getTimestamp("Deadline").toLocalDateTime();

                        if (currentDateTime.isBefore(deadline)) {
                            if ("No".equals(hasClicked)) {
                                showExamLink = true;
                            }
                            if ("No".equals(hasViewedCoding)) {
                                showCodingLink = true;
                            }
                        } else {
                            String resetSql = "UPDATE employee_registrations SET hasClicked = 'No', hasViewedInstructions = 'No' WHERE email = ?";
                            stmt = conn.prepareStatement(resetSql);
                            stmt.setString(1, email);
                            int rowsAffected = stmt.executeUpdate();
                            if (rowsAffected > 0) {
                                hasClicked = "No";
                                hasViewedCoding = "No";
                            }
                        }
                    } else {
                        String resetSql = "UPDATE employee_registrations SET hasClicked = 'No', hasViewedInstructions = 'No' WHERE email = ?";
                        stmt = conn.prepareStatement(resetSql);
                        stmt.setString(1, email);
                        int rowsAffected = stmt.executeUpdate();
                        if (rowsAffected > 0) {
                            hasClicked = "No";
                            hasViewedCoding = "No";
                        }
                    }
                }
            } else {
                String insertSql = "INSERT INTO employee_registrations (email, status, hasClicked, hasViewedInstructions) VALUES (?, 'Pending', 'No', 'No') ON DUPLICATE KEY UPDATE hasClicked = 'No', hasViewedInstructions = 'No'";
                stmt = conn.prepareStatement(insertSql);
                stmt.setString(1, email);
                stmt.executeUpdate();
                hasClicked = "No";
                hasViewedCoding = "No";
            }

            if ("true".equals(request.getParameter("takeAssessment"))) {
                String updateSql = "UPDATE employee_registrations SET hasClicked = 'Yes' WHERE email = ?";
                stmt = conn.prepareStatement(updateSql);
                stmt.setString(1, email);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    hasClicked = "Yes";
                    showExamLink = false;
                    if ("POST".equals(request.getMethod())) {
                        response.setContentType("text/plain");
                        out.print("success");
                        return;
                    }
                }
            }

            if ("true".equals(request.getParameter("viewCoding"))) {
                String updateSql = "UPDATE employee_registrations SET hasViewedInstructions = 'Yes' WHERE email = ?";
                stmt = conn.prepareStatement(updateSql);
                stmt.setString(1, email);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    hasViewedCoding = "Yes";
                    showCodingLink = false;
                    if ("POST".equals(request.getMethod())) {
                        response.setContentType("text/plain");
                        out.print("success");
                        return;
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    %>

    <div class="assessment-container">
        <div class="assessment-header">
            <h1><i class="fas fa-tasks"></i> Assessments</h1>
        </div>
        <div class="assessment-content">
            <p class="intro-text">Available assessments will be displayed below:</p>

            <div class="assessment-card">
                <% if (showExamLink) { %>
                    <h3>Take Your Assessment</h3>
                    <p>Click below to start your exam.</p>
                    <a href="#" onclick="return openFullscreen('<%= request.getContextPath() %>/<%= examLink %>', 'exam')" class="assessment-btn">Take Assessment</a>
                <% } else { %>
                    <h3>No Assessments Available</h3>
                    <p>Check back later for available assessments.</p>
                <% } %>
            </div>

            <div class="assessment-card">
                <% if (showCodingLink) { %>
                    <h3>Coding Assessment</h3>
                    <p>Click below to start your coding exam.</p>
                    <a href="#" onclick="return openFullscreen('<%= request.getContextPath() %>/<%= codingLink %>', 'coding')" class="assessment-btn">Start Coding Exam</a>
                <% } else { %>
                    <h3>No Coding Exam Available</h3>
                    <p>You have already started the coding exam or no exam is available.</p>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>