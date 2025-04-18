<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Welcome Page</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="css/login.css">
  <style>
    .error-message { color: red; font-weight: bold; }
  </style>
</head>
<body>
  <div class="container">
    <div class="left-panel">
      <img src="images/login.jpg" class="login_img" alt="Login Image">
      <p>Sign in to your account <span>www.cyetechnology.in</span></p>
    </div>
    <div class="right-panel">
      <h2>Hello! <span>Login Your Account</span></h2>
      <% if (request.getParameter("error") != null) { %>
          <p id="error-message" class="error-message">Invalid email or password</p>
      <% } %>
      <% if (request.getParameter("success") != null) { %>
          <p class="error-message" style="color: #27ae60;">Password changed successfully!</p>
      <% } %>
      <form action="<%=request.getContextPath()%>/login" method="post">
        <input type="email" class="form-control" name="email" placeholder="Email Address" required>
        <input type="password" class="form-control" name="password" placeholder="Password" required>
        <div class="form-footer">
          <a href="forgotpassword.jsp">Forgot Password?</a>
        </div>
        <button type="submit" class="btn btn-custom mt-3">Sign In</button>
        <div class="create-account">
          <a href="register.jsp">Create Account</a>
        </div>
      </form>
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    setTimeout(function() {
      var errorMessage = document.getElementById("error-message");
      if (errorMessage) errorMessage.style.display = "none";
    }, 3000);
  </script>
</body>
</html>