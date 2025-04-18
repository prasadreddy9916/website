import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;
import org.mindrot.jbcrypt.BCrypt;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@WebServlet("/AdminRegisterServlet")
public class AdminRegisterServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";
    private static final String EMAIL_FROM = "vasanthcyetechnology@gmail.com";
    private static final String EMAIL_PASSWORD = "grzgetigommdtbat"; // App-specific password for Gmail
    private ExecutorService emailExecutor;

    @Override
    public void init() throws ServletException {
        emailExecutor = Executors.newFixedThreadPool(5);
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("MySQL Driver not found", e);
        }
    }

    @Override
    public void destroy() {
        emailExecutor.shutdown();
        super.destroy();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("sendOtp".equals(action)) {
            handleSendOtp(request, response);
        } else if ("verifyOtp".equals(action)) {
            handleVerifyOtp(request, response);
        } else {
            handleRegistration(request, response);
        }
    }

    private void handleSendOtp(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json");
        JSONObject jsonResponse = new JSONObject();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String email = new JSONObject(sb.toString()).getString("email");

        if (!email.endsWith("@gmail.com")) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Only Gmail addresses are allowed");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            String checkQuery = "SELECT COUNT(*) FROM admin WHERE Email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Email already registered");
            } else {
                String otp = String.format("%06d", new Random().nextInt(999999));
                HttpSession session = request.getSession();
                session.setAttribute("otp_" + email, otp);
                session.setAttribute("otp_expiry_" + email, System.currentTimeMillis() + 5 * 60 * 1000);

                emailExecutor.submit(() -> {
                    try {
                        sendEmail(email, "Cye Technology Pvt Ltd - OTP Verification",
                                "Dear Admin,\n\n" +
                                        "We have received a request to verify your email for registration with Cye Technology Pvt Ltd. Please use the following One-Time Password (OTP) to complete the process:\n\n" +
                                        "OTP: " + otp + "\n\n" +
                                        "This OTP is valid for 5 minutes. For security reasons, do not share this OTP with anyone.\n\n" +
                                        "Best Regards,\n" +
                                        "Cye Technology Pvt Ltd Team\n" +
                                        "www.cyetechnology.in");
                    } catch (MessagingException e) {
                        e.printStackTrace();
                    }
                });

                jsonResponse.put("success", true);
            }
            response.getWriter().write(jsonResponse.toString());
        } catch (SQLException e) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Database error: " + e.getMessage());
            response.getWriter().write(jsonResponse.toString());
        }
    }

    private void handleVerifyOtp(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json");
        JSONObject jsonResponse = new JSONObject();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        JSONObject jsonRequest = new JSONObject(sb.toString());
        String email = jsonRequest.getString("email");
        String otp = jsonRequest.getString("otp");

        HttpSession session = request.getSession();
        String storedOtp = (String) session.getAttribute("otp_" + email);
        Long expiry = (Long) session.getAttribute("otp_expiry_" + email);

        if (storedOtp == null || expiry == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "No OTP sent or session expired");
        } else if (System.currentTimeMillis() > expiry) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "OTP has expired");
            session.removeAttribute("otp_" + email);
            session.removeAttribute("otp_expiry_" + email);
        } else if (storedOtp.equals(otp)) {
            session.setAttribute("email_verified_" + email, true);
            session.removeAttribute("otp_" + email);
            session.removeAttribute("otp_expiry_" + email);
            jsonResponse.put("success", true);
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Invalid OTP");
        }
        response.getWriter().write(jsonResponse.toString());
    }

    private void handleRegistration(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String adminId = request.getParameter("adminId");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");
        String joiningDate = request.getParameter("joiningDate");
        String department = request.getParameter("department");
        String designation = request.getParameter("designation");

        HttpSession session = request.getSession();

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("admin_register.jsp").forward(request, response);
            return;
        }

        if (!Boolean.TRUE.equals(session.getAttribute("email_verified_" + email))) {
            request.setAttribute("errorMessage", "Email not verified!");
            request.getRequestDispatcher("admin_register.jsp").forward(request, response);
            return;
        }

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            // Check if Super Admin already exists
            if ("Super Admin".equals(role)) {
                String superAdminCheck = "SELECT COUNT(*) FROM admin WHERE Role = 'Super Admin'";
                PreparedStatement superAdminStmt = conn.prepareStatement(superAdminCheck);
                ResultSet superAdminRs = superAdminStmt.executeQuery();
                superAdminRs.next();
                if (superAdminRs.getInt(1) > 0) {
                    session.setAttribute("toastMessage", "Access Denied: Only one Super Admin is allowed!");
                    session.setAttribute("toastType", "error");
                    response.sendRedirect("admin_register.jsp");
                    return;
                }
            }

            // Check for duplicate Admin ID or Email
            String checkQuery = "SELECT COUNT(*) FROM admin WHERE Admin_ID = ? OR Email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
            checkStmt.setString(1, adminId);
            checkStmt.setString(2, email);
            ResultSet rs = checkStmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                session.setAttribute("toastMessage", "Admin ID or Email already registered!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("admin_register.jsp");
                return;
            }

            // Insert new admin
            String insertQuery = "INSERT INTO admin (Admin_ID, Name, Email, Phone_Number, Password, Role, Joining_Date, Department, Designation, Last_Login, Account_Created, Profile_Photo) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), CURDATE(), NULL)";
            PreparedStatement insertStmt = conn.prepareStatement(insertQuery);
            insertStmt.setString(1, adminId);
            insertStmt.setString(2, name);
            insertStmt.setString(3, email);
            insertStmt.setString(4, phoneNumber);
            insertStmt.setString(5, hashedPassword);
            insertStmt.setString(6, role);
            insertStmt.setString(7, joiningDate);
            insertStmt.setString(8, department);
            insertStmt.setString(9, designation);

            int rowsAffected = insertStmt.executeUpdate();
            if (rowsAffected > 0) {
                session.removeAttribute("email_verified_" + email);
                session.setAttribute("toastMessage", "Successfully registered!");
                session.setAttribute("toastType", "success");
                response.sendRedirect("admin_register.jsp");
            } else {
                request.setAttribute("errorMessage", "Registration failed!");
                request.getRequestDispatcher("admin_register.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("admin_register.jsp").forward(request, response);
        }
    }

    private void sendEmail(String to, String subject, String body) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(EMAIL_FROM));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        message.setText(body);
        Transport.send(message);
    }
}



/*<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Registration - Cye Technology Pvt Ltd</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/admin_register.css">
    <style>
        .toast-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1050;
        }
        .toast-success {
            background-color: #28a745;
            color: white;
        }
        .toast-error {
            background-color: #dc3545;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="register-container">
            <div class="left-panel">
                <div class="left-panel-content">
                    <img src="images/admin-login.jpg" alt="Admin Login" class="left-panel-img">
                    <p>Sign up for your account <span>Admin</span></p>
                </div>
            </div>
            <div class="right-panel">
                <div class="header">
                    <h2><i class="fas fa-user-shield"></i> Admin Registration</h2>
                </div>
                <form action="AdminRegisterServlet" method="post" id="registerForm" onsubmit="return validateForm()">
                    <div class="mb-3">
                        <label for="adminId" class="form-label"><i class="fas fa-id-card"></i> Admin ID</label>
                        <input type="text" class="form-control" id="adminId" name="adminId" required>
                    </div>
                    <div class="mb-3">
                        <label for="name" class="form-label"><i class="fas fa-user"></i> Full Name</label>
                        <input type="text" class="form-control" id="name" name="name" required>
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label"><i class="fas fa-envelope"></i> Email ID</label>
                        <div class="input-group">
                            <input type="email" class="form-control" id="email" name="email" required>
                            <button type="button" id="verifyEmailBtn" class="btn btn-outline-primary" style="display: none;">Verify</button>
                            <span id="emailVerified" class="input-group-text email-verified" style="display: none;"><i class="fas fa-check-circle"></i></span>
                        </div>
                    </div>
                    <div id="otpContainer" class="mb-3" style="display: none;">
                        <label class="form-label"><i class="fas fa-key"></i> Enter OTP</label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="otp" maxlength="6" pattern="[0-9]{6}">
                            <button type="button" id="submitOtpBtn" class="btn btn-primary">Submit OTP</button>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="phoneNumber" class="form-label"><i class="fas fa-phone"></i> Phone Number</label>
                        <input type="text" class="form-control" id="phoneNumber" name="phoneNumber" pattern="[0-9]{10}" required>
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label"><i class="fas fa-lock"></i> Password</label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="password" name="password" required>
                            <span class="input-group-text password-toggle" onclick="togglePassword('password', this)"><i class="fas fa-eye"></i></span>
                        </div>
                        <small id="password-hint" class="form-text text-muted" style="display: none;">Password must be 6-15 characters, with 1 uppercase, 1 number, and 1 symbol.</small>
                    </div>
                    <div class="mb-3">
                        <label for="confirmPassword" class="form-label"><i class="fas fa-lock"></i> Confirm Password</label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                            <span class="input-group-text password-toggle" onclick="togglePassword('confirmPassword', this)"><i class="fas fa-eye"></i></span>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="role" class="form-label"><i class="fas fa-user-tag"></i> Role</label>
                        <select class="form-select" id="role" name="role" required>
                            <option value="Super Admin">Super Admin</option>
                            <option value="HR Admin">HR Admin</option>
                            <option value="Manager">Manager</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="joiningDate" class="form-label"><i class="fas fa-calendar-plus"></i> Joining Date</label>
                        <input type="date" class="form-control" id="joiningDate" name="joiningDate" required>
                    </div>
                    <div class="mb-3">
                        <label for="department" class="form-label"><i class="fas fa-building"></i> Department</label>
                        <input type="text" class="form-control" id="department" name="department" required>
                    </div>
                    <div class="mb-3">
                        <label for="designation" class="form-label"><i class="fas fa-briefcase"></i> Designation</label>
                        <input type="text" class="form-control" id="designation" name="designation" required>
                    </div>
                    <div class="d-flex justify-content-between flex-wrap">
                        <a href="adminlogin.jsp" style="color: blue; padding-top:10px;"><i class="fas fa-sign-in-alt"></i> Back to Login</a>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-check"></i> Register</button>
                    </div>
                </form>
                <div class="error-message mt-3" id="errorMessage">
                    <%= request.getAttribute("errorMessage") != null ? request.getAttribute("errorMessage") : "" %>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast Container -->
    <div class="toast-container">
        <div id="toast" class="toast" role="alert" aria-live="assertive" aria-atomic="true" data-bs-autohide="true" data-bs-delay="3000">
            <div class="toast-header">
                <strong class="me-auto" id="toast-title">Notification</strong>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body"></div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const emailInput = document.getElementById("email");
        const verifyEmailBtn = document.getElementById("verifyEmailBtn");
        const otpContainer = document.getElementById("otpContainer");
        const otpInput = document.getElementById("otp");
        const submitOtpBtn = document.getElementById("submitOtpBtn");
        const emailVerified = document.getElementById("emailVerified");
        const passwordInput = document.getElementById("password");
        const confirmPasswordInput = document.getElementById("confirmPassword");
        const passwordHint = document.getElementById("password-hint");
        const toast = new bootstrap.Toast(document.getElementById("toast"));

        function showToast(message, type = 'info') {
            const toastEl = document.getElementById("toast");
            const toastBody = toastEl.querySelector(".toast-body");
            const toastTitle = document.getElementById("toast-title");
            const toastInstance = new bootstrap.Toast(toastEl);

            toastBody.textContent = message;
            toastEl.classList.remove('toast-success', 'toast-error');

            if (type === 'success') {
                toastEl.classList.add('toast-success');
                toastTitle.textContent = "Success";
            } else if (type === 'error') {
                toastEl.classList.add('toast-error');
                toastTitle.textContent = "Error";
            } else {
                toastTitle.textContent = "Notification";
            }

            toastInstance.show();
        }

        function updateVerifyEmailButton() {
            const email = emailInput.value.trim();
            const gmailRegex = /@gmail\.com$/i; // Case-insensitive regex
            console.log("Email:", email, "Regex test:", gmailRegex.test(email)); // Debug log
            if (gmailRegex.test(email) && email.length > "@gmail.com".length) {
                verifyEmailBtn.style.display = "inline-block";
            } else {
                verifyEmailBtn.style.display = "none";
            }
            otpContainer.style.display = "none";
            emailVerified.style.display = "none";
        }

        // Add event listener for input and trigger initial check
        emailInput.addEventListener("input", updateVerifyEmailButton);
        // Initial call to check if there's already a value
        updateVerifyEmailButton();

        verifyEmailBtn.addEventListener("click", async function() {
            const email = emailInput.value.trim();
            try {
                const response = await fetch('AdminRegisterServlet?action=sendOtp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email })
                });
                const result = await response.json();
                if (result.success) {
                    showToast("OTP sent to your email");
                    otpContainer.style.display = "block";
                    verifyEmailBtn.style.display = "none";
                } else {
                    showToast(result.message || "Failed to send OTP", 'error');
                }
            } catch (error) {
                showToast("Error sending OTP: " + error.message, 'error');
            }
        });

        submitOtpBtn.addEventListener("click", async function() {
            const email = emailInput.value.trim();
            const otp = otpInput.value.trim();
            if (!/^\d{6}$/.test(otp)) {
                showToast("Enter a valid 6-digit OTP", 'error');
                return;
            }
            try {
                const response = await fetch('AdminRegisterServlet?action=verifyOtp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email, otp })
                });
                const result = await response.json();
                if (result.success) {
                    emailVerified.style.display = "inline-block";
                    otpContainer.style.display = "none";
                    emailInput.setAttribute("readonly", "true");
                    showToast("Email verified successfully", 'success');
                } else {
                    showToast(result.message || "Invalid OTP", 'error');
                    otpInput.value = "";
                }
            } catch (error) {
                showToast("Error verifying OTP: " + error.message, 'error');
            }
        });

        passwordInput.addEventListener("input", function() {
            const password = this.value;
            const isValid = /^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,15}$/.test(password);
            passwordHint.style.display = isValid ? "none" : "block";
        });

        function togglePassword(inputId, toggleElement) {
            const input = document.getElementById(inputId);
            const icon = toggleElement.querySelector("i");
            if (input.type === "password") {
                input.type = "text";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            } else {
                input.type = "password";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            }
        }

        function validateForm() {
            const password = passwordInput.value;
            const confirmPassword = confirmPasswordInput.value;
            const isValidPassword = /^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,15}$/.test(password);

            if (!isValidPassword) {
                passwordHint.style.display = "block";
                showToast("Password must be 6-15 characters with 1 uppercase, 1 number, and 1 symbol", 'error');
                return false;
            }
            if (password !== confirmPassword) {
                showToast("Passwords do not match", 'error');
                return false;
            }
            if (emailVerified.style.display !== "inline-block") {
                showToast("Please verify your email", 'error');
                return false;
            }
            return true;
        }

        window.onload = function() {
            <% 
                String toastMessage = (String) session.getAttribute("toastMessage");
                String toastType = (String) session.getAttribute("toastType");
                if (toastMessage != null && toastType != null) {
            %>
                showToast("<%= toastMessage %>", "<%= toastType %>");
                <% if ("success".equals(toastType)) { %>
                    setTimeout(function() {
                        window.location.href = 'adminlogin.jsp';
                    }, 3000);
                <% } %>
            <% 
                    session.removeAttribute("toastMessage");
                    session.removeAttribute("toastType");
                }
            %>
        };
    </script>
</body>
</html>*/
