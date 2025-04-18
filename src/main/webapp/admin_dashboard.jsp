<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.Base64, java.time.*, java.time.format.*" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    String adminName = "";
    String adminEmail = "";
    String adminRole = "";
    byte[] profilePhotoBytes = null;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata", "root", "hacker#Tag1");
        
        String sql = "SELECT Name, Email, Profile_Photo, Role FROM admin WHERE Email = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, email);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            adminName = rs.getString("Name");
            adminEmail = rs.getString("Email");
            adminRole = rs.getString("Role");
            Blob profilePhoto = rs.getBlob("Profile_Photo");
            if (profilePhoto != null) {
                profilePhotoBytes = profilePhoto.getBytes(1, (int) profilePhoto.length());
            }
        } else {
            adminName = "Unknown Admin";
            adminEmail = "N/A";
            adminRole = "N/A";
        }
    } catch (Exception e) {
        e.printStackTrace();
        adminName = "Error";
        adminEmail = "Error fetching data";
        adminRole = "Error";
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }

    // Get current date and time
    LocalDateTime now = LocalDateTime.now();
    String formattedDate = now.format(DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy"));
    String wish;
    int hour = now.getHour();
    if (hour < 12) {
        wish = "Good Morning";
    } else if (hour < 17) {
        wish = "Good Afternoon";
    } else {
        wish = "Good Evening";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Exam Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="css/admin_styles.css">
</head>
<body>
    <!-- Loader -->
    <div class="loader-overlay" id="loader">
        <div class="loader-line"></div>
    </div>

    <div class="dashboard">
        <!-- Sidebar (Left) -->
        <div class="sidebar">
            <div class="sidebar-header">
                <img src="<%= profilePhotoBytes != null ? "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(profilePhotoBytes) : "images/default_profile.jpg" %>" 
                     alt="Profile Photo" class="sidebar-photo">
                <h2 class="sidebar-title">Admin Panel</h2>
            </div>
            <div class="nav-container">
                <ul class="nav-list">
                    <li class="nav-item" onclick="loadIframe('admin_profile.jsp')"><i class="fas fa-user"></i> Admin Profile</li>    
                    <li class="nav-item" onclick="loadIframe('exam_creation.jsp')"><i class="fas fa-edit"></i> Exam Creation & Assignment</li>
                    <li class="nav-item" onclick="loadIframe('assigned_exams.jsp')"><i class="fas fa-tasks"></i> Assigned Exams</li>
                    <li class="nav-item" onclick="loadIframe('employee_registrations.jsp')"><i class="fas fa-users"></i> Employee Registrations</li>
                    <li class="nav-item" onclick="loadIframe('results_summary.jsp')"><i class="fas fa-poll"></i> Results Summary</li>
                    <li class="nav-item" onclick="loadIframe('employee_ids.jsp')"><i class="fas fa-id-card"></i> Enter Employee Details</li>
                    <li class="nav-item" onclick="loadIframe('payroll.jsp')"><i class="fas fa-money-bill-wave"></i> Payroll</li>
                    <li class="nav-item" onclick="loadIframe('admin_login_history.jsp')"><i class="fas fa-history"></i> Admin Login History</li>
                    <li class="nav-item" onclick="logoutUser()"><i class="fas fa-sign-out-alt"></i> Logout</li>
                </ul>
            </div>
        </div>

        <!-- Main Content (Right) -->
        <div class="main-content" id="mainContent">
            <div class="container">
                <marquee class="header-marquee">
                    Welcome to Prasad Technology Pvt Ltd - <%= formattedDate %>
                </marquee>
                <h1 class="greeting"><%= wish %>, <%= adminName %>!</h1>
                <p class="mission-text">
                    At Prasad Technology Pvt Ltd, we pioneer next-generation IT solutions to transform your digital landscape. 
                    Harness innovation, optimize workflows, and propel your software capabilities to new heights with our state-of-the-art platforms.
                </p>
                <div class="admin-details">
                    <div class="detail-item">
                        <i class="fas fa-envelope"></i>
                        <span><%= adminEmail %></span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-user-shield"></i>
                        <span><%= adminRole %></span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-building"></i>
                        <span>CYE Technology Pvt Ltd</span>
                    </div>
                </div>
            </div>

            <div class="content-area" id="contentArea">
                <div id="inlineSections"></div>
            </div>

            <iframe id="contentIframe" class="content-iframe" frameborder="0"></iframe>
        </div>
    </div>

    <!-- Inject context path into JavaScript -->
    <script type="text/javascript">
        const contextPath = '<%= request.getContextPath() %>';
    </script>
    <script src="js/admin_scripts.js"></script>
</body>
</html>