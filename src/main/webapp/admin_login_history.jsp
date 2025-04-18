<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");

    if (email == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login History</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="css/admin_login_history_styles.css">
</head>
<body>
    <% 
        if (!"Super Admin".equals(role)) {
    %>
        <div id="accessDeniedPopup" class="access-denied-popup">
            Access Denied: Only Super Admin can view this page!
        </div>
        <script>
            document.getElementById('accessDeniedPopup').style.display = 'block';
            setTimeout(() => {
                window.location.href = 'admin_login_history.jsp';
            }, 3000);
        </script>
    <% 
        } else { 
    %>
    <div class="history-container">
        <div class="sticky-header">
            <h1>Admin Login History</h1>
            <button class="add-btn" onclick="showAddPopup()">Add New Admin</button>
        </div>

        <div class="filter-section">
            <div class="filter-row">
                <div class="filter-group">
                    <label for="idFilter">Admin ID</label>
                    <input type="text" id="idFilter" placeholder="Filter by Admin ID">
                </div>
                <div class="filter-group">
                    <label for="nameFilter">Name</label>
                    <input type="text" id="nameFilter" placeholder="Filter by Name">
                </div>
                <div class="filter-group">
                    <label for="emailFilter">Email</label>
                    <input type="text" id="emailFilter" placeholder="Filter by Email">
                </div>
            </div>
        </div>

        <div class="history-list">
            <h2>Admin History</h2>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Admin ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Joining Date</th>
                            <th>Login History</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="historyTableBody">
                        <%
                            List<Map<String, String>> admins = new ArrayList<>();
                            Connection conn = null;
                            PreparedStatement pstmt = null;
                            ResultSet rs = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata", "root", "hacker#Tag1");
                                String sql = "SELECT Admin_ID, Name, Email, Role, Joining_Date, Phone_Number, Password, Department, Designation FROM admin ORDER BY Joining_Date DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();

                                while (rs.next()) {
                                    Map<String, String> admin = new HashMap<>();
                                    admin.put("admin_id", rs.getString("Admin_ID"));
                                    admin.put("name", rs.getString("Name"));
                                    admin.put("email", rs.getString("Email"));
                                    admin.put("role", rs.getString("Role"));
                                    admin.put("joining_date", rs.getString("Joining_Date"));
                                    admin.put("phone_number", rs.getString("Phone_Number"));
                                    admin.put("password", rs.getString("Password"));
                                    admin.put("department", rs.getString("Department"));
                                    admin.put("designation", rs.getString("Designation"));
                                    admins.add(admin);
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<!-- Error fetching admin data: " + e.getMessage() + " -->");
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                                if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                            }

                            if (admins != null && !admins.isEmpty()) {
                                for (Map<String, String> admin : admins) {
                                    String adminId = admin.get("admin_id");
                        %>
                            <tr data-id="<%= adminId != null ? adminId : "" %>"
                                data-name="<%= admin.get("name") != null ? admin.get("name") : "" %>"
                                data-email="<%= admin.get("email") != null ? admin.get("email") : "" %>">
                                <td><%= adminId != null ? adminId : "" %></td>
                                <td><%= admin.get("name") != null ? admin.get("name") : "" %></td>
                                <td><%= admin.get("email") != null ? admin.get("email") : "" %></td>
                                <td><%= admin.get("role") != null ? admin.get("role") : "" %></td>
                                <td><%= admin.get("joining_date") != null ? admin.get("joining_date") : "" %></td>
                                <td>
                                    <button class="view-btn" onclick="showLoginHistory('<%= adminId %>')">View</button>
                                    <div class="login-history-popup" id="popup-<%= adminId %>">
                                        <div class="popup-content">
                                            <span class="close-btn" onclick="hideLoginHistory('<%= adminId %>')">×</span>
                                            <h3>Login History for <%= admin.get("name") %></h3>
                                            <table class="history-table">
                                                <thead>
                                                    <tr>
                                                        <th>Login Timestamp</th>
                                                        <th>IP Address</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <%
                                                        try {
                                                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata", "root", "hacker#Tag1");
                                                            String historySql = "SELECT Login_Timestamp, IP_Address FROM admin_login_history WHERE Admin_ID = ? ORDER BY Login_Timestamp DESC";
                                                            pstmt = conn.prepareStatement(historySql);
                                                            pstmt.setString(1, adminId);
                                                            rs = pstmt.executeQuery();

                                                            while (rs.next()) {
                                                                String loginTimestamp = rs.getString("Login_Timestamp") != null ? rs.getString("Login_Timestamp") : "N/A";
                                                                String ipAddress = rs.getString("IP_Address") != null ? rs.getString("IP_Address") : "N/A";
                                                    %>
                                                        <tr>
                                                            <td><%= loginTimestamp %></td>
                                                            <td><%= ipAddress %></td>
                                                        </tr>
                                                    <%
                                                            }
                                                        } catch (Exception e) {
                                                            e.printStackTrace();
                                                            out.println("<!-- Error fetching login history: " + e.getMessage() + " -->");
                                                        } finally {
                                                            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                                                            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                                                        }
                                                    %>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <button class="edit-btn" onclick="showEditPopup('<%= adminId %>')">Edit</button>
                                    <button class="delete-btn" onclick="showDeletePopup('<%= adminId %>')">Delete</button>
                                    <!-- Edit Popup -->
                                    <div class="edit-popup" id="edit-popup-<%= adminId %>">
                                        <div class="edit-popup-content">
                                            <h3 class="edit-header">Edit Admin: <%= admin.get("name") %></h3>
                                            <form action="AdminActionServlet" method="post" id="editForm-<%= adminId %>" onsubmit="return validatePassword('<%= adminId %>')">
                                                <input type="hidden" name="action" value="edit">
                                                <input type="hidden" name="adminId" value="<%= adminId %>">
                                                <label>Admin ID:</label>
                                                <input type="text" name="newAdminId" value="<%= adminId %>" readonly><br>
                                                <label>Email:</label>
                                                <input type="email" name="email" value="<%= admin.get("email") %>" readonly><br>
                                                <label>Role:</label>
                                                <input type="text" name="role" value="<%= admin.get("role") %>" readonly><br>
                                                <label>Joining Date:</label>
                                                <input type="date" name="joiningDate" value="<%= admin.get("joining_date") %>" readonly><br>
                                                <label>Name:</label>
                                                <input type="text" name="name" value="<%= admin.get("name") %>" maxlength="100" required><br>
                                                <label>Mobile:</label>
                                                <input type="text" name="phoneNumber" value="<%= admin.get("phone_number") != null ? admin.get("phone_number") : "" %>" maxlength="15"><br>
                                                <label>Department:</label>
                                                <input type="text" name="department" value="<%= admin.get("department") != null ? admin.get("department") : "" %>" maxlength="50"><br>
                                                <label>Designation:</label>
                                                <input type="text" name="designation" value="<%= admin.get("designation") != null ? admin.get("designation") : "" %>" maxlength="50"><br>
                                                <label>Current Password:</label>
                                                <div class="password-container">
                                                    <input type="password" id="currentPassword-<%= adminId %>" name="currentPassword" value="" readonly placeholder="Cannot display hashed password">
                                                    <span class="toggle-password" onclick="togglePassword('currentPassword-<%= adminId %>')">
                                                        <i class="fas fa-eye"></i>
                                                    </span>
                                                </div>
                                                <label>New Password:</label>
                                                <div class="password-container">
                                                    <input type="password" id="newPassword-<%= adminId %>" name="password" maxlength="15">
                                                    <span class="toggle-password" onclick="togglePassword('newPassword-<%= adminId %>')">
                                                        <i class="fas fa-eye"></i>
                                                    </span>
                                                </div>
                                                <small class="password-hint">Password must be 6-15 characters, with 1 uppercase, 1 number, and 1 symbol</small><br>
                                                <button type="submit" class="save-btn">Save</button>
                                                <button type="button" class="cancel-btn" onclick="hideEditPopup('<%= adminId %>')">Cancel</button>
                                            </form>
                                        </div>
                                    </div>
                                    <!-- Delete Popup -->
                                    <div class="delete-popup" id="delete-popup-<%= adminId %>">
                                        <div class="delete-popup-content">
                                            <p>Are you sure you want to delete <%= admin.get("name") %>?</p>
                                            <button class="close-btn" onclick="hideDeletePopup('<%= adminId %>')">Close</button>
                                            <button class="delete-confirm-btn" onclick="deleteAdmin('<%= adminId %>')">Delete</button>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr><td colspan="7">No admin records found.</td></tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Add New Admin Popup -->
    <div class="add-popup" id="addPopup">
        <div class="add-popup-content">
            <h3 class="add-header">Add New Admin</h3>
            <form action="AdminActionServlet" method="post" id="addForm" onsubmit="return validateAddForm()">
                <input type="hidden" name="action" value="add">
                <label class="required">Admin ID:</label>
                <input type="text" id="addAdminId" name="adminId" required>
                <label class="required">Name:</label>
                <input type="text" id="addName" name="name" maxlength="100" required>
                <label class="required">Email:</label>
                <div class="input-group">
                    <input type="email" id="addEmail" name="email" required>
                    <button type="button" class="verify-btn" id="verifyEmailBtn" onclick="sendOtp()">Verify</button>
                    <span class="email-verified" id="emailVerified"><i class="fas fa-check-circle"></i></span>
                </div>
                <div class="otp-group" id="otpGroup">
                    <label>Enter OTP:</label>
                    <input type="text" id="addOtp" maxlength="6">
                    <button type="button" class="verify-btn" onclick="verifyOtp()">Submit OTP</button>
                </div>
                <label class="required">Phone Number:</label>
                <input type="text" id="addPhoneNumber" name="phoneNumber" maxlength="15" required>
                <label class="required">Password:</label>
                <div class="password-container">
                    <input type="password" id="addPassword" name="password" maxlength="15" required>
                    <span class="toggle-password" onclick="togglePassword('addPassword')">
                        <i class="fas fa-eye"></i>
                    </span>
                </div>
                <label class="required">Confirm Password:</label>
                <div class="password-container">
                    <input type="password" id="addConfirmPassword" name="confirmPassword" maxlength="15" required>
                    <span class="toggle-password" onclick="togglePassword('addConfirmPassword')">
                        <i class="fas fa-eye"></i>
                    </span>
                </div>
                <small class="password-hint">Password must be 6-15 characters, with 1 uppercase, 1 number, and 1 symbol</small>
                <label class="required">Role:</label>
                <select id="addRole" name="role" required>
                    <option value="HR">HR</option>
                    <option value="Manager">Manager</option>
                    <option value="Payroll">Payroll</option>
                </select>
                <label class="required">Joining Date:</label>
                <input type="date" id="addJoiningDate" name="joiningDate" required>
                <label>Department:</label>
                <input type="text" id="addDepartment" name="department" maxlength="50">
                <label>Designation:</label>
                <input type="text" id="addDesignation" name="designation" maxlength="50">
                <button type="submit" class="save-btn">Save</button>
                <button type="button" class="cancel-btn" onclick="hideAddPopup()">Cancel</button>
            </form>
        </div>
    </div>

    <!-- Success/Error Popups -->
    <div id="successPopup" class="success-popup"><%= request.getParameter("success") != null ? "Admin Added Successfully!" : "" %></div>
    <div id="errorPopup" class="error-popup"><%= request.getParameter("error") != null ? request.getParameter("error") : "" %></div>

    <!-- Change Warning Popup -->
    <div id="changeWarningPopup" class="access-denied-popup" style="background: #ff9800;">
        Warning: Only Name, Mobile, Department, Designation, and Password can be changed!
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const idFilter = document.getElementById('idFilter');
            const nameFilter = document.getElementById('nameFilter');
            const emailFilter = document.getElementById('emailFilter');
            const rows = document.querySelectorAll('#historyTableBody tr');

            <% if ("nonEditableFieldsChanged".equals(request.getParameter("warning"))) { %>
                document.getElementById('changeWarningPopup').style.display = 'block';
                setTimeout(() => {
                    document.getElementById('changeWarningPopup').style.display = 'none';
                }, 3000);
            <% } %>
            <% if (request.getParameter("success") != null) { %>
                document.getElementById('successPopup').style.display = 'block';
                setTimeout(() => {
                    document.getElementById('successPopup').style.display = 'none';
                }, 3000);
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                document.getElementById('errorPopup').style.display = 'block';
                setTimeout(() => {
                    document.getElementById('errorPopup').style.display = 'none';
                }, 3000);
            <% } %>

            function applyFilters() {
                const idValue = idFilter.value.trim().toLowerCase();
                const nameValue = nameFilter.value.trim().toLowerCase();
                const emailValue = emailFilter.value.trim().toLowerCase();

                rows.forEach(row => {
                    const rowId = (row.getAttribute('data-id') || '').toLowerCase();
                    const rowName = (row.getAttribute('data-name') || '').toLowerCase();
                    const rowEmail = (row.getAttribute('data-email') || '').toLowerCase();

                    const matchesId = idValue === '' || rowId.includes(idValue);
                    const matchesName = nameValue === '' || rowName.includes(nameValue);
                    const matchesEmail = emailValue === '' || rowEmail.includes(emailValue);

                    row.style.display = matchesId && matchesName && matchesEmail ? '' : 'none';
                });
            }

            idFilter.addEventListener('input', applyFilters);
            nameFilter.addEventListener('input', applyFilters);
            emailFilter.addEventListener('input', applyFilters);

            applyFilters();
        });

        function showLoginHistory(adminId) {
            document.getElementById('popup-' + adminId).style.display = 'block';
        }

        function hideLoginHistory(adminId) {
            document.getElementById('popup-' + adminId).style.display = 'none';
        }

        function showEditPopup(adminId) {
            document.getElementById('edit-popup-' + adminId).style.display = 'block';
        }

        function hideEditPopup(adminId) {
            document.getElementById('edit-popup-' + adminId).style.display = 'none';
        }

        function showDeletePopup(adminId) {
            document.getElementById('delete-popup-' + adminId).style.display = 'block';
        }

        function hideDeletePopup(adminId) {
            document.getElementById('delete-popup-' + adminId).style.display = 'none';
        }

        function deleteAdmin(adminId) {
            const form = document.createElement('form');
            form.method = 'post';
            form.action = 'AdminActionServlet';
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'adminId';
            idInput.value = adminId;
            form.appendChild(actionInput);
            form.appendChild(idInput);
            document.body.appendChild(form);
            form.submit();
        }

        function togglePassword(fieldId) {
            const field = document.getElementById(fieldId);
            const icon = field.nextElementSibling.querySelector('i');
            if (field.type === 'password') {
                field.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                field.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        function validatePassword(adminId) {
            const newPassword = document.getElementById('newPassword-' + adminId).value;
            if (newPassword) {
                const passwordRegex = /^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{6,15}$/;
                if (!passwordRegex.test(newPassword)) {
                    alert('Password must be 6-15 characters, with 1 uppercase, 1 number, and 1 symbol!');
                    return false;
                }
            }
            return true;
        }

        function showAddPopup() {
            document.getElementById('addPopup').style.display = 'block';
            document.getElementById('addForm').reset();
            document.getElementById('otpGroup').style.display = 'none';
            document.getElementById('emailVerified').style.display = 'none';
            document.getElementById('verifyEmailBtn').style.display = 'inline-block';
            document.getElementById('addEmail').removeAttribute('readonly');
        }

        function hideAddPopup() {
            document.getElementById('addPopup').style.display = 'none';
        }

        async function sendOtp() {
            const email = document.getElementById('addEmail').value.trim();
            if (!email.endsWith('@gmail.com')) {
                showErrorPopup('Only Gmail addresses are allowed');
                return;
            }
            try {
                const response = await fetch('AdminActionServlet?action=sendOtp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email })
                });
                const result = await response.json();
                if (result.success) {
                    document.getElementById('otpGroup').style.display = 'block';
                    document.getElementById('verifyEmailBtn').style.display = 'none';
                    showSuccessPopup('OTP sent to your email');
                } else {
                    showErrorPopup(result.message || 'Failed to send OTP');
                }
            } catch (error) {
                showErrorPopup('Error sending OTP: ' + error.message);
            }
        }

        async function verifyOtp() {
            const email = document.getElementById('addEmail').value.trim();
            const otp = document.getElementById('addOtp').value.trim();
            if (!/^\d{6}$/.test(otp)) {
                showErrorPopup('Enter a valid 6-digit OTP');
                return;
            }
            try {
                const response = await fetch('AdminActionServlet?action=verifyOtp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email, otp })
                });
                const result = await response.json();
                if (result.success) {
                    document.getElementById('emailVerified').style.display = 'inline-block';
                    document.getElementById('otpGroup').style.display = 'none';
                    document.getElementById('addEmail').setAttribute('readonly', 'true');
                    showSuccessPopup('Email verified successfully');
                } else {
                    showErrorPopup(result.message || 'Invalid OTP');
                    document.getElementById('addOtp').value = '';
                }
            } catch (error) {
                showErrorPopup('Error verifying OTP: ' + error.message);
            }
        }

        function validateAddForm() {
            const password = document.getElementById('addPassword').value;
            const confirmPassword = document.getElementById('addConfirmPassword').value;
            const emailVerified = document.getElementById('emailVerified').style.display === 'inline-block';
            const passwordRegex = /^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{6,15}$/;

            if (!passwordRegex.test(password)) {
                showErrorPopup('Password must be 6-15 characters, with 1 uppercase, 1 number, and 1 symbol');
                return false;
            }
            if (password !== confirmPassword) {
                showErrorPopup('Passwords do not match');
                return false;
            }
            if (!emailVerified) {
                showErrorPopup('Please verify your email');
                return false;
            }
            return true;
        }

        function showSuccessPopup(message) {
            const popup = document.getElementById('successPopup');
            popup.textContent = message || 'Operation Successful!';
            popup.style.display = 'block';
            setTimeout(() => popup.style.display = 'none', 3000);
        }

        function showErrorPopup(message) {
            const popup = document.getElementById('errorPopup');
            popup.textContent = message;
            popup.style.display = 'block';
            setTimeout(() => popup.style.display = 'none', 3000);
        }
    </script>
    <% } %>
</body>
</html>