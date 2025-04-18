<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Forgot Password</title>
    <link rel="stylesheet" href="css/forgotpassword.css">
</head>
<body>
    <div class="container">
        <h2>Forgot <span>Password?</span></h2>
        <p>Reset your password securely with <span>xAI</span></p>

        <form id="forgotPasswordForm" method="post">
            <input type="email" name="email" id="email" class="form-control" placeholder="Enter your email" required>
            <button type="button" id="sendOtpBtn" class="btn-custom">Send OTP</button>

            <div id="otpSection" style="display: none;">
                <div class="otp-container">
                    <input type="text" name="otp" id="otp" class="form-control otp-input" placeholder="Enter OTP" required>
                    <button type="button" id="resendOtpBtn" class="btn-resend">Resend</button>
                </div>
                <input type="password" name="newPassword" id="newPassword" class="form-control" placeholder="New Password" required>
                <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" placeholder="Confirm Password" required>
                <button type="button" id="resetPasswordBtn" class="btn-custom">Reset Password</button>
            </div>
        </form>

        <div class="create-account">
            <a href="login.jsp">Back to Login</a>
        </div>
    </div>

    <div id="popup" class="popup"></div>

    <script>
        // Preserve form state on page refresh
        window.addEventListener('load', function() {
            const email = localStorage.getItem('forgotEmail');
            if (email) {
                document.getElementById('email').value = email;
                sendOtp(false, true); // Silent resend on page load if email exists
            }
        });

        document.getElementById("sendOtpBtn").addEventListener("click", function() {
            sendOtp();
        });

        document.getElementById("resendOtpBtn").addEventListener("click", function() {
            sendOtp(true); // Resend OTP
        });

        document.getElementById("resetPasswordBtn").addEventListener("click", function() {
            const email = document.getElementById("email").value;
            const otp = document.getElementById("otp").value;
            const newPassword = document.getElementById("newPassword").value;
            const confirmPassword = document.getElementById("confirmPassword").value;

            if (!otp || !newPassword || !confirmPassword) {
                showPopup("All fields are required", true);
                return;
            }

            if (newPassword !== confirmPassword) {
                showPopup("Passwords do not match", true);
                return;
            }

            fetch("ForgotPasswordServlet", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "action=resetPassword&email=" + encodeURIComponent(email) + 
                      "&otp=" + encodeURIComponent(otp) + 
                      "&newPassword=" + encodeURIComponent(newPassword) + 
                      "&confirmPassword=" + encodeURIComponent(confirmPassword)
            })
            .then(response => response.text())
            .then(data => {
                if (data === "success") {
                    showPopup("Password changed successfully", false);
                    localStorage.removeItem('forgotEmail');
                    setTimeout(() => window.location.href = "login.jsp", 2000);
                } else {
                    showPopup(data, true);
                }
            })
            .catch(error => showPopup("An error occurred", true));
        });

        function sendOtp(isResend = false, silent = false) {
            const email = document.getElementById("email").value;
            if (!email) {
                showPopup("Email is required", true);
                return;
            }

            const sendOtpBtn = document.getElementById("sendOtpBtn");
            sendOtpBtn.disabled = true;
            sendOtpBtn.textContent = "Sending OTP...";

            fetch("ForgotPasswordServlet", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "action=sendOtp&email=" + encodeURIComponent(email) + "&resend=" + isResend
            })
            .then(response => response.text())
            .then(data => {
                sendOtpBtn.disabled = false;
                sendOtpBtn.textContent = "Send OTP";
                if (data === "success") {
                    if (!silent) {
                        showPopup(isResend ? "New OTP sent successfully" : "OTP sent successfully", false);
                    }
                    document.getElementById("otpSection").style.display = "block";
                    document.getElementById("sendOtpBtn").style.display = "none";
                    localStorage.setItem('forgotEmail', email);
                    document.getElementById("otp").value = "";
                } else if (!silent) {
                    showPopup(data, true);
                }
            })
            .catch(error => {
                sendOtpBtn.disabled = false;
                sendOtpBtn.textContent = "Send OTP";
                if (!silent) showPopup("An error occurred", true);
            });
        }

        function showPopup(message, isError) {
            const popup = document.getElementById("popup");
            popup.textContent = message;
            popup.className = "popup " + (isError ? "error" : "");
            popup.style.display = "block";
            setTimeout(() => popup.style.display = "none", 3000);
        }
    </script>
</body>
</html>