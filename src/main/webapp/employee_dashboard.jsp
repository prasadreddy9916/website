<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Base64, java.time.*, java.time.format.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/employee_all.css">
</head>
<body>
    <!-- Loader Overlay -->
    <div class="loader-overlay" id="loader">
        <div class="loader-line"></div>
    </div>

    <%
        String email = (String) session.getAttribute("email");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String profilePhotoSrc = "images/default_profile.jpg";
        String employeeId = "";
        String name = "";
        String designation = "";
        String department = "";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam", "root", "hacker#Tag1");
            String sql = "SELECT ID, Name, email, Designation, Department, Profile_Photo FROM employee_registrations WHERE email = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                employeeId = rs.getString("ID");
                name = rs.getString("Name");
                email = rs.getString("email");
                designation = rs.getString("Designation");
                department = rs.getString("Department");
                Blob profilePhoto = rs.getBlob("Profile_Photo");
                if (profilePhoto != null) {
                    byte[] profilePhotoBytes = profilePhoto.getBytes(1, (int) profilePhoto.length());
                    profilePhotoSrc = "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(profilePhotoBytes);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }

        LocalDateTime now = LocalDateTime.now();
        String formattedDate = now.format(DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy"));
        String wish = (now.getHour() < 12) ? "Good Morning" : (now.getHour() < 17) ? "Good Afternoon" : "Good Evening";
    %>

    <div class="dashboard">
        <!-- Sidebar (Left) -->
        <div class="navbar">
            <div class="navbar-header">
                <img src="<%= profilePhotoSrc %>" alt="Profile">
                <h2>Dashboard</h2>
            </div>
            <div class="nav-container">
                <a href="#" onclick="loadIframe('profile.jsp')"><i class="fas fa-user"></i> Employee Profile</a>
                <a href="#" onclick="loadIframe('assessments.jsp')"><i class="fas fa-tasks"></i> Assessments</a>
                <a href="#" onclick="loadIframe('results.jsp')"><i class="fas fa-poll"></i> Results</a>
                <a href="#" onclick="loadIframe('employee_payroll.jsp')"><i class="fas fa-money-check-alt"></i> My Payroll</a>
                <a href="#" onclick="logoutUser()"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>

        <!-- Main Content (Right) -->
        <div class="main-content" id="mainContent">
            <div class="content-container" id="welcomeBox">
                <marquee class="header-marquee">
                    Welcome to Prasad Technology Pvt Ltd - <%= formattedDate %>
                </marquee>
                <h1 class="greeting"><%= wish %>, <%= name %>!</h1>
                <p class="mission-text">
                    At Prasad Technology Pvt Ltd, we empower our team with cutting-edge tools and innovative IT solutions. 
                    Collaborate seamlessly, enhance your skills, and drive the future of technology with our advanced platforms.
                </p>
                <div class="employee-details">
                    <div class="detail-item">
                        <i class="fas fa-id-badge"></i>
                        <span><%= employeeId %></span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-user"></i>
                        <span><%= name %></span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-envelope"></i>
                        <span><%= email %></span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-briefcase"></i>
                        <span><%= designation %></span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-building"></i>
                        <span><%= department %></span>
                    </div>
                </div>
            </div>
            <iframe id="contentIframe" class="content-iframe" frameborder="0"></iframe>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const loader = document.getElementById('loader');
            const welcomeBox = document.getElementById('welcomeBox');
            const iframe = document.getElementById('contentIframe');

            welcomeBox.classList.remove('active');
            iframe.classList.remove('active');

            setTimeout(() => {
                loader.classList.add('loader-hidden');
                setTimeout(() => {
                    loader.style.display = 'none';
                }, 500);
            }, 2000);
        });

        function loadIframe(page) {
            const iframe = document.getElementById('contentIframe');
            const welcomeBox = document.getElementById('welcomeBox');
            iframe.src = '<%= request.getContextPath() %>/' + page;
            iframe.classList.add('active');
            welcomeBox.style.display = 'none';
        }

        function logoutUser() {
            const form = document.createElement('form');
            form.method = 'post';
            form.action = '<%= request.getContextPath() %>/EmployeeLogoutServlet';
            document.body.appendChild(form);
            form.submit();
        }
    </script>
</body>
</html>