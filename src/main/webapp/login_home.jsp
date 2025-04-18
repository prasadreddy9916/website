<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Home</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/auth_styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>
<body>
    <!-- Top Navbar -->
    <div class="navbar">
        <div class="logo">
            <img src="<%= request.getContextPath() %>/images/company_logo.png" alt="Company Logo">
        </div>
        <!-- Marquee with orange text -->
        <marquee class="marquee-text" behavior="scroll" direction="left" scrollamount="5">
            Prasad Technologies PVT LTD
        </marquee>
        <button class="toggle-btn"><i class="fas fa-bars"></i></button>
        <div class="toggle-menu">
            <a href="<%= request.getContextPath() %>/login.jsp">Employee Login</a>
            <a href="<%= request.getContextPath() %>/adminlogin.jsp">Admin Login</a>
        </div>
    </div>

    <!-- Banner Container (Below Navbar) -->
    <div class="banner-container">
        <div class="banner" style="background-image: url('<%= request.getContextPath() %>/images/banner1.jpg');">
            <div class="banner-text">
                Building the Future<br>
                Empowering Our Team<br>
                Software Excellence
            </div>
        </div>
        <div class="banner" style="background-image: url('<%= request.getContextPath() %>/images/banner2.jpg');">
            <div class="banner-text" style="color:black;">
                AI-Powered Innovation<br>
                Smart Solutions<br>
                Transforming Technology
            </div>
        </div>
        <div class="banner" style="background-image: url('<%= request.getContextPath() %>/images/banner3.jpg');">
            <div class="banner-text" >
                Green Technology<br>
                Sustainable Software<br>
                Eco-Friendly Future
            </div>
        </div>
    </div>

    <!-- Banner Indicators -->
    <div class="banner-indicators">
        <div class="dot"></div>
        <div class="dot"></div>
        <div class="dot"></div>
    </div>

    <script src="<%= request.getContextPath() %>/js/auth_scripts.js"></script>
</body>
</html>