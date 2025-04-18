<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.JSONArray, org.json.JSONObject" %>
<%
String email = (String) session.getAttribute("email");
if (email == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Handle exam submission
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String scoreStr = request.getParameter("score");

    response.setContentType("application/json");
    try {
        if (scoreStr == null || !scoreStr.contains("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Invalid score format\"}");
            return;
        }

        String[] scoreParts = scoreStr.split("/");
        int correctAnswers = Integer.parseInt(scoreParts[0].trim());
        int totalQuestions = Integer.parseInt(scoreParts[1].trim()); // Should always be 50
        double percentage = totalQuestions > 0 ? (correctAnswers / (double) totalQuestions) * 100 : 0.0;
        String status = percentage >= 75 ? "Pass" : "Fail";

        String DB_URL = "jdbc:mysql://localhost:3306/exam";
        String DB_USER = "root";
        String DB_PASS = "hacker#Tag1";
        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            String sql = "UPDATE employee_registrations SET score = ?, percentage = ?, status = ? WHERE email = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, scoreStr);
            stmt.setDouble(2, percentage);
            stmt.setString(3, status);
            stmt.setString(4, email);
            int rowsUpdated = stmt.executeUpdate();
            if (rowsUpdated == 0) {
                String insertSql = "INSERT INTO employee_registrations (email, score, percentage, status) VALUES (?, ?, ?, ?)";
                stmt = conn.prepareStatement(insertSql);
                stmt.setString(1, email);
                stmt.setString(2, scoreStr);
                stmt.setDouble(3, percentage);
                stmt.setString(4, status);
                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }

        session.setAttribute("examScore", scoreStr);
        session.setAttribute("examPercentage", percentage);
        session.setAttribute("examStatus", status);

        response.getWriter().write("{\"status\": \"success\"}");
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        response.getWriter().write("{\"status\": \"error\", \"message\": \"Error: " + e.getMessage() + "\"}");
    }
    return;
}

// Fetch the exam type for the employee
String DB_URL = "jdbc:mysql://localhost:3306/exam";
String DB_USER = "root";
String DB_PASS = "hacker#Tag1";
String examType = "Fullstack"; // Default to Fullstack if not found
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    String sql = "SELECT Exam FROM employee_registrations WHERE email = ?";
    PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setString(1, email);
    ResultSet rs = stmt.executeQuery();
    if (rs.next()) {
        examType = rs.getString("Exam");
    }
    rs.close();
    stmt.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
}

// Fetch 50 random questions for the specified exam type
JSONArray questionsArray = new JSONArray();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    String sql = "SELECT difficulty, question, choices, answer FROM questions WHERE exam = ? ORDER BY RAND() LIMIT 50";
    PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setString(1, examType);
    ResultSet rs = stmt.executeQuery();

    while (rs.next()) {
        JSONObject question = new JSONObject();
        question.put("difficulty", rs.getString("difficulty"));
        question.put("question", rs.getString("question"));
        String choicesStr = rs.getString("choices");
        String[] choices = choicesStr.split(",");
        question.put("choices", new JSONArray(choices));
        question.put("answer", rs.getString("answer"));
        questionsArray.put(question);
    }

    rs.close();
    stmt.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error fetching questions: " + e.getMessage());
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Online Assessment</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/exam.css">
    <script src="<%= request.getContextPath() %>/js/exam.js"></script>
</head>
<body data-email="<%= session.getAttribute("email") %>">
    <!-- Instructions Section -->
    <div id="instructions-container" class="instructions-container">
        <h1>Exam Instructions</h1>
        <p>Please read the following instructions carefully before starting the exam:</p>
        <ul>
            <li>The exam consists of 50 multiple-choice questions.</li>
            <li>You have 60 minutes to complete the exam.</li>
            <li>Once started, the exam must be completed in one sitting.</li>
            <li>Do not refresh the page or switch tabs, as this will submit your exam automatically.</li>
            <li>Click "End Assessment" to submit your exam early.</li>
            <li>Ensure a stable internet connection throughout the exam.</li>
        </ul>
        <button id="start-exam-btn" class="start-exam-btn">Start Exam</button>
    </div>

    <!-- Assessment Section (Hidden Initially) -->
    <div id="assessment-container" class="assessment-container hidden">
        <div id="time-remaining" class="time-remaining">Time Left: 60:00</div>
        <button id="end-assessment" class="end-assessment">End Assessment</button>
        <div id="question-area" class="question-area">
            <div id="progress-bar" class="progress-bar"></div>
            <div id="question-content" class="question-content">
                <h2 id="question-header"></h2>
                <p id="question-body"></p>
                <div id="answer-choices" class="answer-choices"></div>
                <button id="advance-btn" class="advance-btn" disabled>Next</button>
            </div>
        </div>
        <div id="alert-box" class="alert-box hidden">
            <div class="alert-content">
                <p id="alert-text"></p>
                <button id="alert-submit" class="alert-btn">Submit Exam</button>
                <button id="alert-stay" class="alert-btn">Stay</button>
                <button id="alert-force" class="alert-btn hidden">Force Submit</button>
                <button id="alert-cancel" class="alert-btn hidden">Cancel</button>
            </div>
        </div>
    </div> 
    <script>
        // Pass the questions fetched from the database to JavaScript
        const assessmentQuestionsForExam = <%= questionsArray.toString() %>;
        document.addEventListener("DOMContentLoaded", function() {
            if (!document.fullscreenElement) {
                document.documentElement.requestFullscreen().catch(err => {
                    console.error("Fullscreen request failed:", err);
                });
            }

            document.getElementById("start-exam-btn").addEventListener("click", function() {
                document.getElementById("instructions-container").classList.add("hidden");
                document.getElementById("assessment-container").classList.remove("hidden");
                launchAssessment();
            });
        });
    </script>
</body>
</html>