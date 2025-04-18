<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Registration</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/register.css">
</head>
<body>
    <div class="body-wrapper">
        <div class="container">
            <!-- Page 1 -->
            <div id="page1" class="form-page">
                <div class="left-panel">
                    <img src="images/login.jpg" class="login_img" alt="Login Image">
                    <p>Sign up for your account <span>www.cyetechnology.in</span></p>
                </div>
                <div class="right-panel">
                    <h2>Sign Up <span>- Step 1</span></h2>
                    <form id="form1">
                        <div class="employee-id-group">
                            <span class="employee-id-prefix">CT-</span>
                            <input type="text" class="underline-input employee-id-input" id="id" name="id" placeholder="Enter 8-digit ID" pattern="[0-9]{8}" required>
                        </div>
                        <input type="text" class="underline-input" id="name" name="name" placeholder="Your Name" readonly>
                        <div class="email-group">
                            <input type="email" class="underline-input" id="email" name="email" placeholder="Email Address" readonly>
                            <button type="button" id="verifyEmailBtn" class="verify-btn" style="display: none;">Verify Email</button>
                            <span id="emailVerified" class="email-verified" style="display: none;"><i class="fas fa-check-circle"></i></span>
                        </div>
                        <div id="otpContainer" class="otp-container">
                            <input type="text" class="underline-input" id="otp" placeholder="Enter OTP" maxlength="6" pattern="[0-9]{6}">
                            <button type="button" id="submitOtpBtn" class="btn btn-custom" style="padding: 5px 10px; font-size: 0.8rem;">Submit OTP</button>
                        </div>
                        <input type="text" class="underline-input" id="batch" name="batch" placeholder="Batch" readonly>
                        <input type="text" class="underline-input" id="designation" name="designation" placeholder="Designation" readonly>
                        <input type="text" class="underline-input" id="department" name="department" placeholder="Department" readonly>
                        <input type="text" class="underline-input" id="batchYear" name="batchYear" placeholder="Year" readonly>
                        <div class="button-group">
                            <button type="button" class="btn signin-text" onclick="window.location.href='login.jsp'"><i class="fas fa-sign-in-alt"></i> Sign In</button>
                            <button type="button" class="btn btn-custom" id="nextBtn"><i class="fas fa-arrow-right"></i> Next</button>
                        </div>
                    </form>
                </div>
            </div>

        <!-- Page 2 -->
<div id="page2" class="form-page">
    <div class="left-panel">
        <img src="images/login.jpg" class="login_img" alt="Login Image">
        <p>Sign up for your account <span>www.cyetechnology.in</span></p>
    </div>
    <div class="right-panel">
        <h2>Sign Up <span>- Step 2</span></h2>
        <form action="register" method="post" id="form2" onsubmit="return validateForm()">
            <input type="hidden" name="id" id="id2">
            <input type="hidden" name="name" id="name2">
            <input type="hidden" name="email" id="email2">
            <input type="hidden" name="batch" id="batch2">
            <input type="hidden" name="designation" id="designation2">
            <input type="hidden" name="department" id="department2">
            <input type="hidden" name="batchYear" id="batchYear2">
            <input type="text" class="underline-input" id="aadhar" name="aadhar" placeholder="Aadhar Number" pattern="[0-9]{12}" required>
            <input type="text" class="underline-input" id="mobile" name="mobile" placeholder="Mobile Number" pattern="[0-9]{10}" required>
            <input type="text" class="underline-input" id="pan" name="pan" placeholder="PAN Number" pattern="[A-Z]{5}[0-9]{4}[A-Z]{1}" required>
            <input type="date" class="underline-input" id="dateOfBirth" name="dateOfBirth" required>
            <input type="text" class="underline-input" id="motherName" name="motherName" placeholder="Mother's Name" required>
            <input type="text" class="underline-input" id="fatherName" name="fatherName" placeholder="Father's Name" required>
            <div class="form-group">
                <select class="underline-input" id="gender" name="gender" required>
                    <option value="">Select Gender</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                    <option value="Other">Other</option>
                </select>
            </div>
            <div class="form-group">
                <select class="underline-input" id="maritalStatus" name="maritalStatus" required>
                    <option value="">Select Marital Status</option>
                    <option value="Single">Single</option>
                    <option value="Married">Married</option>
                    <option value="Divorced">Divorced</option>
                    <option value="Widowed">Widowed</option>
                </select>
            </div>
            <div class="form-group password-field">
                <input type="password" class="underline-input" id="password" name="password" placeholder="Password" required>
                <i class="fas fa-eye password-toggle" id="togglePassword"></i>
            </div>
            <span class="password-hint" id="password-hint" style="display: none;">Password must be 6-15 characters, with at least 1 uppercase, 1 number, and 1 symbol.</span>
            <div class="form-group password-field">
                <input type="password" class="underline-input" id="confirmPassword" name="confirmPassword" placeholder="Confirm Password" required>
                <i class="fas fa-eye password-toggle" id="toggleConfirmPassword"></i>
            </div>
            <div class="form-group">
                <select class="underline-input" id="exam" name="exam" required>
                    <option value="">Select Exam</option>
                    <option value="fullstack">Fullstack</option>
                    <option value="cyber">Cyber</option>
                    <option value="python">Python</option>
                    <option value="aws">AWS</option>
                    <option value="frontend">Frontend</option>
                    <option value="database">Database</option>
                    <option value="java">Java</option>
                    <option value="mern">MERN</option>
                </select>
            </div>
            <div class="button-group">
                <button type="button" class="btn btn-custom" id="backBtn"><i class="fas fa-arrow-left"></i> Back</button>
                <button type="button" class="btn signin-text" onclick="window.location.href='login.jsp'"><i class="fas fa-sign-in-alt"></i> Sign In</button>
                <button type="submit" class="btn btn-custom"><i class="fas fa-check"></i> Register</button>
            </div>
        </form>
        <div class="error-message">
            <%= request.getAttribute("errorMessage") != null ? request.getAttribute("errorMessage") : "" %>
        </div>
    </div>
</div>
        </div>
    </div>
    <div id="popup" class="popup-message"></div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const page1 = document.getElementById("page1");
        const page2 = document.getElementById("page2");
        const nextBtn = document.getElementById("nextBtn");
        const backBtn = document.getElementById("backBtn");
        const employeeIdInput = document.getElementById("id");
        const nameInput = document.getElementById("name");
        const emailInput = document.getElementById("email");
        const batchInput = document.getElementById("batch");
        const designationInput = document.getElementById("designation");
        const departmentInput = document.getElementById("department");
        const batchYearInput = document.getElementById("batchYear");
        const verifyEmailBtn = document.getElementById("verifyEmailBtn");
        const otpContainer = document.getElementById("otpContainer");
        const otpInput = document.getElementById("otp");
        const submitOtpBtn = document.getElementById("submitOtpBtn");
        const emailVerified = document.getElementById("emailVerified");
        const passwordInput = document.getElementById("password");
        const confirmPasswordInput = document.getElementById("confirmPassword");
        const togglePassword = document.getElementById("togglePassword");
        const passwordHint = document.getElementById("password-hint");

        // Fetch employee details
        employeeIdInput.addEventListener("blur", async function() {
            const employeeId = this.value.trim();
            if (employeeId.length === 8 && /^\d{8}$/.test(employeeId)) {
                try {
                    const response = await fetch('<%=request.getContextPath()%>/register?action=fetchEmployee', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'employeeId=' + encodeURIComponent(employeeId)
                    });
                    const result = await response.json();
                    if (result.success) {
                        nameInput.value = result.name;
                        emailInput.value = result.email;
                        batchInput.value = result.batch;
                        designationInput.value = result.designation;
                        departmentInput.value = result.department;
                        batchYearInput.value = result.year;
                        document.getElementById("id2").value = "CT-" + employeeId;
                        document.getElementById("name2").value = result.name;
                        document.getElementById("email2").value = result.email;
                        document.getElementById("batch2").value = result.batch;
                        document.getElementById("designation2").value = result.designation;
                        document.getElementById("department2").value = result.department;
                        document.getElementById("batchYear2").value = result.year;
                        showPopup("Employee details loaded", "success");
                        updateVerifyEmailButton();
                    } else {
                        showPopup(result.message || "Employee not found", "error");
                    }
                } catch (error) {
                    showPopup("Error fetching employee: " + error.message, "error");
                }
            }
        });

        // Email verification
        function updateVerifyEmailButton() {
            const email = emailInput.value.trim();
            const gmailRegex = /@gmail\.com$/;
            verifyEmailBtn.style.display = gmailRegex.test(email) ? "inline-block" : "none";
            otpContainer.style.display = "none"; // Ensure OTP container is hidden initially
            emailVerified.style.display = "none";
        }

        emailInput.addEventListener("input", updateVerifyEmailButton);

        verifyEmailBtn.addEventListener("click", async function() {
            const email = emailInput.value.trim();
            try {
                const response = await fetch('<%=request.getContextPath()%>/register?action=sendOtp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email })
                });
                const result = await response.json();
                if (result.success) {
                    showPopup("OTP sent to your email", "success");
                    otpContainer.style.display = "flex"; // Show OTP container instantly
                    verifyEmailBtn.style.display = "none";
                } else {
                    showPopup(result.message || "Failed to send OTP", "error");
                }
            } catch (error) {
                showPopup("Error sending OTP: " + error.message, "error");
            }
        });

        submitOtpBtn.addEventListener("click", async function() {
            const email = emailInput.value.trim();
            const otp = otpInput.value.trim();
            if (!/^\d{6}$/.test(otp)) {
                showPopup("Enter a valid 6-digit OTP", "error");
                return;
            }
            try {
                const response = await fetch('<%=request.getContextPath()%>/register?action=verifyOtp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email, otp })
                });
                const result = await response.json();
                if (result.success) {
                    emailVerified.style.display = "inline-block";
                    otpContainer.style.display = "none";
                    emailInput.setAttribute("readonly", "true");
                    showPopup("Email verified successfully", "success");
                } else {
                    showPopup(result.message || "Invalid OTP", "error");
                    otpInput.value = "";
                }
            } catch (error) {
                showPopup("Error verifying OTP: " + error.message, "error");
            }
        });

        // Page navigation
        nextBtn.addEventListener("click", function() {
            if (emailVerified.style.display !== "inline-block") {
                showPopup("Please verify your email", "error");
                return;
            }
            page1.style.display = "none"; // Hide page1
            page2.style.display = "flex"; // Show page2
        });

        backBtn.addEventListener("click", function() {
            page2.style.display = "none"; // Hide page2
            page1.style.display = "flex"; // Show page1
        });

        // Password toggle
        togglePassword.addEventListener("click", function() {
            const type = passwordInput.type === "password" ? "text" : "password";
            passwordInput.type = type;
            confirmPasswordInput.type = type;
            this.classList.toggle("fa-eye");
            this.classList.toggle("fa-eye-slash");
        });

        // Form validation
        function validateForm() {
            const password = passwordInput.value;
            const confirmPassword = confirmPasswordInput.value;
            const aadhar = document.getElementById("aadhar").value;
            const pan = document.getElementById("pan").value;
            const dateOfBirth = document.getElementById("dateOfBirth").value;

            const isValidPassword = /^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,15}$/.test(password);
            if (!isValidPassword) {
                passwordHint.style.display = "block";
                showPopup("Password must be 6-15 chars with 1 uppercase, 1 number, 1 symbol", "error");
                return false;
            }
            if (password !== confirmPassword) {
                showPopup("Passwords do not match", "error");
                return false;
            }
            if (!/^\d{12}$/.test(aadhar)) {
                showPopup("Aadhar must be a 12-digit number", "error");
                return false;
            }
            if (!/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/.test(pan)) {
                showPopup("PAN must be in format ABCDE1234F", "error");
                return false;
            }
            const today = new Date();
            const dob = new Date(dateOfBirth);
            if (!(dob instanceof Date && !isNaN(dob) && dob < today)) {
                showPopup("Invalid date of birth (must be in the past)", "error");
                return false;
            }
            document.getElementById("id2").value = "CT-" + employeeIdInput.value;
            return true;
        }

        // Popup message
        function showPopup(message, type) {
            const popup = document.getElementById("popup");
            popup.textContent = message;
            popup.className = "popup-message " + type;
            popup.style.display = "block";
            setTimeout(() => {
                popup.style.display = "none";
                if (type === "success" && message === "Registered successfully") {
                    window.location.href = "login.jsp";
                }
            }, 3000);
        }

        <% if (request.getAttribute("successMessage") != null) { %>
            showPopup("<%= request.getAttribute("successMessage") %>", "success");
        <% } else if (request.getAttribute("errorMessage") != null) { %>
            showPopup("<%= request.getAttribute("errorMessage") %>", "error");
        <% } %>
    </script>
</body>
</html>