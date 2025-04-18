<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Base64" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Employee Profile</title>
    <link rel="stylesheet" href="css/profile.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.12/cropper.min.css">
</head>
<body>
    <div class="container">
        <%
            String email = (String) session.getAttribute("email");
            if (email == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            String errorMessage = null;
            String employeeId = "", name = "", aadhar = "", mobile = "", pan = "", motherName = "", fatherName = "", 
                   gender = "", maritalStatus = "", batch = "", batchYear = "", typeOfSet = "", registrationDateTime = "", 
                   dob = "", designation = "", department = ""; // Added designation and department
            byte[] profilePhotoBytes = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam", "root", "hacker#Tag1");
                
                String sql = "SELECT ID, Name, Email, Aadhar, Mobile, PAN, Mother_Name, Father_Name, Gender, Marital_Status, " +
                             "Batch, Batch_Year, Type_of_Set, Registration_DateTime, Date_of_Birth, Profile_Photo, " +
                             "Designation, Department " + // Added Designation and Department
                             "FROM employee_registrations WHERE Email = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, email);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    employeeId = rs.getString("ID");
                    name = rs.getString("Name");
                    aadhar = rs.getString("Aadhar");
                    mobile = rs.getString("Mobile");
                    pan = rs.getString("PAN");
                    motherName = rs.getString("Mother_Name");
                    fatherName = rs.getString("Father_Name");
                    gender = rs.getString("Gender");
                    maritalStatus = rs.getString("Marital_Status");
                    batch = rs.getString("Batch");
                    batchYear = rs.getString("Batch_Year");
                    typeOfSet = String.valueOf(rs.getInt("Type_of_Set"));
                    SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy, hh:mm a");
                    registrationDateTime = rs.getTimestamp("Registration_DateTime") != null ? sdf.format(rs.getTimestamp("Registration_DateTime")) : "N/A";
                    dob = rs.getDate("Date_of_Birth") != null ? new SimpleDateFormat("MMM d, yyyy").format(rs.getDate("Date_of_Birth")) : "N/A";
                    designation = rs.getString("Designation"); // Fetch Designation
                    department = rs.getString("Department");   // Fetch Department
                    Blob profilePhoto = rs.getBlob("Profile_Photo");
                    if (profilePhoto != null) {
                        profilePhotoBytes = profilePhoto.getBytes(1, (int) profilePhoto.length());
                    }
                } else {
                    errorMessage = "Profile not found.";
                }
            } catch (Exception e) {
                e.printStackTrace();
                errorMessage = "Error loading profile: " + e.getMessage();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        %>

        <div class="profile-wrapper">
            <div class="profile-card">
                <div class="profile-header">
                    <div class="profile-photo">
                        <img src="<%= profilePhotoBytes != null ? "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(profilePhotoBytes) : "images/default_profile.jpg" %>" 
                             alt="Profile Photo" class="profile-img" id="profileImg">
                        <div class="photo-actions">
                            <button class="btn btn-update" onclick="document.getElementById('photoInput').click()">Update</button>
                            <% if (profilePhotoBytes != null) { %>
                                <button class="btn btn-remove" onclick="showRemoveConfirm('<%= email %>')">Remove</button>
                            <% } %>
                        </div>
                        <form id="photoForm" action="UploadEmployeePhotoServlet" method="post" enctype="multipart/form-data" style="display: none;">
                            <input type="file" id="photoInput" name="photo" accept="image/*" onchange="previewPhoto(event)">
                            <input type="hidden" name="email" value="<%= email %>">
                        </form>
                    </div>
                    <div class="profile-info-header">
                        <h1 class="profile-name"><%= name %></h1>
                        <p class="profile-id"><i class="fas fa-id-card"></i> <%= employeeId %></p>
                    </div>
                </div>

                <div class="profile-content">
                    <div class="info-card">
                        <h2><i class="fas fa-user"></i> Personal Details</h2>
                        <p><strong>Email:</strong> <%= email %></p>
                        <p><strong>Aadhar:</strong> <%= aadhar != null ? aadhar : "N/A" %></p>
                        <p><strong>Mobile:</strong> <%= mobile != null ? mobile : "N/A" %></p>
                        <p><strong>PAN:</strong> <%= pan != null ? pan : "N/A" %></p>
                        <p><strong>Date of Birth:</strong> <%= dob %></p>
                        <p><strong>Gender:</strong> <%= gender != null ? gender : "N/A" %></p>
                        <p><strong>Marital Status:</strong> <%= maritalStatus != null ? maritalStatus : "N/A" %></p>
                    </div>

                    <div class="info-card">
                        <h2><i class="fas fa-home"></i> Family Details</h2>
                        <p><strong>Mother's Name:</strong> <%= motherName != null ? motherName : "N/A" %></p>
                        <p><strong>Father's Name:</strong> <%= fatherName != null ? fatherName : "N/A" %></p>
                    </div>

                    <div class="info-card">
                        <h2><i class="fas fa-briefcase"></i> Work Details</h2>
                        <p><strong>Designation:</strong> <%= designation %></p> <!-- Added Designation -->
                        <p><strong>Department:</strong> <%= department %></p>   <!-- Added Department -->
                        <p><strong>Batch:</strong> <%= batch %></p>
                        <p><strong>Batch Year:</strong> <%= batchYear != null ? batchYear : "N/A" %></p>
                      
                        <p><strong>Joined:</strong> <%= registrationDateTime %></p>
                    </div>
                </div>

                <% if (errorMessage != null) { %>
                    <div class="error-box"><%= errorMessage %></div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Crop Modal -->
    <div id="photoModal" class="modal">
        <div class="modal-content">
            <h3>Crop Your Photo</h3>
            <div class="crop-container">
                <img id="cropImage" src="" alt="Crop Preview">
            </div>
            <div class="modal-actions">
                <button class="btn btn-update" onclick="saveCroppedPhoto()">Save</button>
                <button class="btn btn-cancel" onclick="closeModal()">Cancel</button>
            </div>
        </div>
    </div>

    <!-- Remove Confirmation Modal -->
    <div id="removeConfirmModal" class="modal">
        <div class="modal-content small-modal">
            <p>Remove profile photo?</p>
            <div class="modal-actions">
                <button class="btn btn-update" id="confirmYes">Yes</button>
                <button class="btn btn-cancel" onclick="closeRemoveConfirm()">No</button>
            </div>
        </div>
    </div>

    <!-- Popup Message -->
    <div id="popup" class="popup"></div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.12/cropper.min.js"></script>
    <script>
        let cropper;
        const email = '<%= email %>';
        const defaultImage = 'images/default_profile.jpg';

        function previewPhoto(event) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const img = document.getElementById('cropImage');
                    img.src = e.target.result;
                    document.getElementById('photoModal').style.display = 'flex';
                    cropper = new Cropper(img, { aspectRatio: 1, viewMode: 1, autoCropArea: 0.8 });
                };
                reader.readAsDataURL(file);
            }
        }

        function saveCroppedPhoto() {
            const canvas = cropper.getCroppedCanvas({ width: 200, height: 200 });
            canvas.toBlob(blob => {
                const formData = new FormData();
                formData.append('photo', blob, 'profile.jpg');
                formData.append('email', email);
                fetch('UploadEmployeePhotoServlet', { method: 'POST', body: formData })
                    .then(response => response.ok ? location.reload() : showPopup('Upload failed', false))
                    .catch(() => showPopup('Error uploading', false));
            }, 'image/jpeg', 0.8);
            closeModal();
        }

        function closeModal() {
            document.getElementById('photoModal').style.display = 'none';
            if (cropper) cropper.destroy();
            document.getElementById('photoInput').value = '';
        }

        function showRemoveConfirm(email) {
            const modal = document.getElementById('removeConfirmModal');
            modal.style.display = 'flex';
            document.getElementById('confirmYes').onclick = () => { removePhoto(email); closeRemoveConfirm(); };
        }

        function closeRemoveConfirm() {
            document.getElementById('removeConfirmModal').style.display = 'none';
        }

        function removePhoto(email) {
            fetch('RemoveEmployeePhotoServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'email=' + encodeURIComponent(email)
            })
            .then(response => response.ok ? location.reload() : showPopup('Remove failed', false))
            .catch(() => showPopup('Error removing', false));
        }

        function showPopup(message, isSuccess) {
            const popup = document.getElementById('popup');
            popup.textContent = message;
            popup.className = 'popup ' + (isSuccess ? 'success' : 'error');
            popup.style.display = 'block';
            setTimeout(() => popup.style.display = 'none', 3000);
        }
    </script>
</body>
</html>