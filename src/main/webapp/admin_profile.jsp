<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Base64" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.12/cropper.min.css">
    <link rel="stylesheet" href="css/admin_profile.css">
</head>
<body>
    <div class="header">
        <h1><i class="fas fa-user-shield"></i> Admin Profile</h1>
    </div>
    <div class="profile-container">
        <%
            String email = (String) session.getAttribute("email");
            if (email == null) {
                response.sendRedirect("adminlogin.jsp");
                return;
            }

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            String errorMessage = null;
            String adminId = "", adminName = "", adminEmail = "", phoneNumber = "", role = "",
                   lastLogin = "", accountCreated = "", joiningDate = "", department = "", designation = "";
            byte[] profilePhotoBytes = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam", "root", "hacker#Tag1");
                
                String sql = "SELECT Admin_ID, Name, Email, Phone_Number, Role, Joining_Date, " +
                           "Department, Designation, Last_Login, Account_Created, Profile_Photo " +
                           "FROM admin WHERE Email = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, email);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    adminId = rs.getString("Admin_ID");
                    adminName = rs.getString("Name");
                    adminEmail = rs.getString("Email");
                    phoneNumber = rs.getString("Phone_Number") != null ? rs.getString("Phone_Number") : "N/A";
                    role = rs.getString("Role") != null ? rs.getString("Role") : "N/A";
                    Timestamp lastLoginTs = rs.getTimestamp("Last_Login");
                    SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy, hh:mm a");
                    lastLogin = lastLoginTs != null ? sdf.format(lastLoginTs) : "N/A";
                    Date accountCreatedDate = rs.getDate("Account_Created");
                    accountCreated = accountCreatedDate != null ? sdf.format(accountCreatedDate) : "N/A";
                    Date joiningDateDate = rs.getDate("Joining_Date");
                    joiningDate = joiningDateDate != null ? sdf.format(joiningDateDate) : "N/A";
                    department = rs.getString("Department") != null ? rs.getString("Department") : "N/A";
                    designation = rs.getString("Designation") != null ? rs.getString("Designation") : "N/A";
                    Blob profilePhoto = rs.getBlob("Profile_Photo");
                    if (profilePhoto != null) {
                        profilePhotoBytes = profilePhoto.getBytes(1, (int) profilePhoto.length());
                    }
                } else {
                    errorMessage = "Admin profile not found for email: " + email;
                }
            } catch (Exception e) {
                errorMessage = "Error retrieving profile: " + e.getMessage();
                e.printStackTrace();
            } finally {
                try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
                try { if (pstmt != null) pstmt.close(); } catch (SQLException ignored) {}
                try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
            }
        %>
        <div class="profile-photo-section">
            <img src="<%= profilePhotoBytes != null ? "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(profilePhotoBytes) : "images/default_profile.jpg" %>" 
                 alt="Profile Photo" class="profile-img" id="profileImg">
            <div class="photo-actions">
                <button class="btn btn-primary add-photo" onclick="document.getElementById('photoInput').click()">Update</button>
                <% if (profilePhotoBytes != null) { %>
                   
                    <button class="btn btn-danger remove-photo" onclick="showRemoveConfirm('<%= adminId %>')">Remove</button>
                <% } %>
            </div>
            <form id="photoForm" action="UploadPhotoServlet" method="post" enctype="multipart/form-data" style="display: none;">
                <input type="file" id="photoInput" name="photo" accept="image/*" onchange="previewPhoto(event)">
                <input type="hidden" name="adminId" value="<%= adminId %>">
            </form>
            <h2 class="mt-3"><%= adminName %></h2>
        </div>
        <div class="info-grid">
            <div class="info-item">
                <p><i class="fas fa-id-badge"></i><strong>Admin ID:</strong> <%= adminId %></p>
            </div>
            <div class="info-item">
                <p><i class="fas fa-envelope"></i><strong>Email:</strong> <%= adminEmail %></p>
            </div>
            <div class="info-item">
                <p><i class="fas fa-phone"></i><strong>Phone:</strong> <%= phoneNumber %></p>
            </div>
            <div class="info-item">
                <p><i class="fas fa-user-tag"></i><strong>Role:</strong> <%= role %></p>
            </div>
            <div class="info-item">
                <p><i class="fas fa-building"></i><strong>Department:</strong> <%= department %></p>
            </div>
            <div class="info-item">
                <p><i class="fas fa-briefcase"></i><strong>Designation:</strong> <%= designation %></p>
            </div>
            <div class="info-item">
                <p><i class="fas fa-calendar-plus"></i><strong>Joining Date:</strong> <%= joiningDate %></p>
            </div>
            <div class="info-item">
                <p><i class="fas fa-clock"></i><strong>Last Login:</strong> <%= lastLogin %></p>
            </div>
            <div class="info-item">
                <p><i class="fas fa-user-plus"></i><strong>Account Created:</strong> <%= accountCreated %></p>
            </div>
        </div>
       
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger mt-3"><%= errorMessage %></div>
        <% } %>
    </div>

    <!-- Crop Modal -->
    <div id="photoModal" class="modal fade" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Crop Your Photo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="crop-container">
                        <img id="cropImage" src="" alt="Crop Preview">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveCroppedPhoto()">Save</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Remove Confirmation Modal -->
    <div id="removeConfirmModal" class="modal fade" tabindex="-1">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-body">
                    <p>Are you sure you want to remove your profile photo?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">No</button>
                    <button type="button" class="btn btn-primary" id="confirmYes">Yes</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Popup Alerts -->
    <div id="successPopup" class="alert alert-success" style="display: none;">Operation successful!</div>
    <div id="errorPopup" class="alert alert-danger" style="display: none;">Operation failed!</div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.12/cropper.min.js"></script>
    <script>
        let cropper;
        const adminId = '<%= adminId %>';
        const defaultImage = 'images/default_profile.jpg';

        function previewPhoto(event) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const img = document.getElementById('cropImage');
                    img.src = e.target.result;
                    const modal = new bootstrap.Modal(document.getElementById('photoModal'));
                    modal.show();
                    if (cropper) cropper.destroy();
                    cropper = new Cropper(img, {
                        aspectRatio: 1,
                        viewMode: 1,
                        movable: true,
                        scalable: true,
                        zoomable: true,
                        autoCropArea: 0.8,
                        cropBoxResizable: true
                    });
                };
                reader.readAsDataURL(file);
            }
        }

        function editPhoto() {
            document.getElementById('photoInput').click();
        }

        function saveCroppedPhoto() {
            const canvas = cropper.getCroppedCanvas({ width: 200, height: 200 });
            canvas.toBlob(function(blob) {
                const formData = new FormData();
                formData.append('photo', blob, 'profile.jpg');
                formData.append('adminId', adminId);
                fetch('UploadPhotoServlet', {
                    method: 'POST',
                    body: formData
                })
                .then(response => {
                    if (response.ok) {
                        return response.text();
                    } else {
                        throw new Error('Upload failed with status: ' + response.status);
                    }
                })
                .then(text => {
                    document.getElementById('profileImg').src = canvas.toDataURL('image/jpeg', 0.7);
                    updatePhotoActions();
                    showPopup('successPopup', 'Photo uploaded successfully!');
                })
                .catch(error => {
                    showPopup('errorPopup', 'Failed to upload photo: ' + error.message);
                });
            }, 'image/jpeg', 1);
            bootstrap.Modal.getInstance(document.getElementById('photoModal')).hide();
        }

        function showRemoveConfirm(adminId) {
            const modal = new bootstrap.Modal(document.getElementById('removeConfirmModal'));
            const yesBtn = document.getElementById('confirmYes');
            modal.show();
            yesBtn.onclick = function() {
                removePhoto(adminId);
                modal.hide();
            };
        }

        function removePhoto(adminId) {
            fetch('RemovePhotoServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'adminId=' + encodeURIComponent(adminId)
            })
            .then(response => {
                if (response.ok) {
                    return response.text();
                } else {
                    throw new Error('Remove failed with status: ' + response.status);
                }
            })
            .then(text => {
                document.getElementById('profileImg').src = defaultImage;
                updatePhotoActions();
                showPopup('successPopup', 'Photo removed successfully!');
            })
            .catch(error => {
                showPopup('errorPopup', 'Failed to remove photo: ' + error.message);
            });
        }

        function updatePhotoActions() {
            const container = document.querySelector('.photo-actions');
            const imgSrc = document.getElementById('profileImg').src;
            const hasPhoto = !imgSrc.includes('default_profile.jpg');
            let html = '<button class="btn btn-primary add-photo" onclick="document.getElementById(\'photoInput\').click()">Change Photo</button>';
            if (hasPhoto) {
                html += `
                    <button class="btn btn-primary edit-photo" onclick="editPhoto()">Edit</button>
                    <button class="btn btn-danger remove-photo" onclick="showRemoveConfirm('${adminId}')">Remove</button>
                `;
            }
            container.innerHTML = html;
        }

        function showPopup(popupId, message) {
            const popup = document.getElementById(popupId);
            popup.textContent = message;
            popup.style.display = 'block';
            popup.classList.add('show');
            setTimeout(() => {
                popup.classList.remove('show');
                setTimeout(() => popup.style.display = 'none', 500);
            }, 3000);
        }
    </script>
</body>
</html>