<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="css/adminlogin.css">
    <!-- Font Awesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="body-wrapper">
        <div class="login-container">
            <div class="left-panel">
                <img src="images/admin-login.jpg" class="login-img" alt="Admin Login Image">
                <p>Secure Admin Access <span>Admin Portal</span></p>
            </div>
            <div class="right-panel">
                <h2>Admin <span>Login</span></h2>
                
                                <!-- Error message container -->
                <div id="error-container" class="error-message" style="display: none;">
                    <% 
                        String error = request.getParameter("error");
                        if ("1".equals(error)) {
                            out.println("Invalid email or password.");
                        } else if ("2".equals(error)) {
                            out.println("An error occurred. Please try again.");
                        }
                    %>
                </div>
                
                <form action="adminLogin" method="post">
                    <div class="form-group">
                        <input type="email" class="form-input" name="email" placeholder="Email Address" required>
                        <i class="fas fa-envelope input-icon"></i>
                    </div>
                    <div class="form-group">
                        <input type="password" class="form-input" name="password" placeholder="Password" required>
                        <i class="fas fa-lock input-icon"></i>
                    </div>
                    <button type="submit" class="btn-login"><i class="fas fa-sign-in-alt"></i> Login</button>
                </form>

               
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JavaScript -->
    <script type="text/javascript">
        // Show error message for 3 seconds if it exists
        window.onload = function() {
            const errorContainer = document.getElementById("error-container");
            const errorText = errorContainer.textContent.trim();
            
            if (errorText !== "") { // Check if there's any error message
                errorContainer.style.display = "block"; // Show the error message
                setTimeout(() => {
                    errorContainer.style.display = "none"; // Hide after 3 seconds
                }, 3000);
            }
        };
    </script>
</body>
</html>