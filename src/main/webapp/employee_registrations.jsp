<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.io.*, java.util.Base64" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    String url = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    String username = "root";
    String password = "hacker#Tag1";
    String errorMessage = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String empIdFilter = request.getParameter("empIdFilter") != null ? request.getParameter("empIdFilter").trim().toLowerCase() : "";
    String nameFilter = request.getParameter("nameFilter") != null ? request.getParameter("nameFilter").trim().toLowerCase() : "";
    String emailFilter = request.getParameter("emailFilter") != null ? request.getParameter("emailFilter").trim().toLowerCase() : "";
    String batchFilter = request.getParameter("batchFilter") != null ? request.getParameter("batchFilter").trim().toLowerCase() : "";
    String dateFilter = request.getParameter("dateFilter") != null ? request.getParameter("dateFilter").trim() : "";
    String regDateFilter = request.getParameter("regDateFilter") != null ? request.getParameter("regDateFilter").trim() : "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);
        String query = "SELECT ID, Name, Mother_Name, Father_Name, Aadhar, PAN, Mobile, Gender, Marital_Status, Date_of_Birth, Profile_Photo, Email, Batch, Registration_DateTime, Exam, hasClicked " +
                       "FROM employee_registrations " +
                       "WHERE (? IS NULL OR LOWER(ID) LIKE ?) " +
                       "AND (? IS NULL OR LOWER(Name) LIKE ?) " +
                       "AND (? IS NULL OR LOWER(Email) LIKE ?) " +
                       "AND (? IS NULL OR LOWER(Batch) LIKE ?) " +
                       "AND (? IS NULL OR Date_of_Birth = ?) " +
                       "AND (? IS NULL OR DATE(Registration_DateTime) = ?) " +
                       "ORDER BY Registration_DateTime DESC";
        pstmt = conn.prepareStatement(query);
        pstmt.setString(1, empIdFilter.isEmpty() ? null : empIdFilter);
        pstmt.setString(2, empIdFilter.isEmpty() ? null : "%" + empIdFilter + "%");
        pstmt.setString(3, nameFilter.isEmpty() ? null : nameFilter);
        pstmt.setString(4, nameFilter.isEmpty() ? null : "%" + nameFilter + "%");
        pstmt.setString(5, emailFilter.isEmpty() ? null : emailFilter);
        pstmt.setString(6, emailFilter.isEmpty() ? null : "%" + emailFilter + "%");
        pstmt.setString(7, batchFilter.isEmpty() ? null : batchFilter);
        pstmt.setString(8, batchFilter.isEmpty() ? null : "%" + batchFilter + "%");
        pstmt.setString(9, dateFilter.isEmpty() ? null : dateFilter);
        pstmt.setString(10, dateFilter.isEmpty() ? null : dateFilter);
        pstmt.setString(11, regDateFilter.isEmpty() ? null : regDateFilter);
        pstmt.setString(12, regDateFilter.isEmpty() ? null : regDateFilter);
        rs = pstmt.executeQuery();
    } catch (Exception e) {
        errorMessage = "Error fetching data: " + e.getMessage();
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Details - Exam Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin_employee_details.css">
</head>
<body>
    <div class="details-container">
        <header>
            <h1><i class="fas fa-users"></i> Employee Details</h1>
        </header>
        <div class="filters">
            <div class="filter-group">
                <label for="empIdFilter">Employee ID</label>
                <input type="text" id="empIdFilter" name="empIdFilter" placeholder="Search by ID..." value="<%= empIdFilter %>">
            </div>
            <div class="filter-group">
                <label for="nameFilter">Name</label>
                <input type="text" id="nameFilter" name="nameFilter" placeholder="Search by name..." value="<%= nameFilter %>">
            </div>
            <div class="filter-group">
                <label for="emailFilter">Email</label>
                <input type="text" id="emailFilter" name="emailFilter" placeholder="Search by email..." value="<%= emailFilter %>">
            </div>
            <div class="filter-group">
                <label for="batchFilter">Batch</label>
                <input type="text" id="batchFilter" name="batchFilter" placeholder="Search by batch..." value="<%= batchFilter %>">
            </div>
            <div class="filter-group">
                <label for="dateFilter">Date of Birth</label>
                <input type="date" id="dateFilter" name="dateFilter" value="<%= dateFilter %>">
            </div>
            <div class="filter-group">
                <label for="regDateFilter">Registration Date</label>
                <input type="date" id="regDateFilter" name="regDateFilter" value="<%= regDateFilter %>">
            </div>
        </div>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Profile Photo</th>
                        <th>Employee ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Batch</th>
                        <th>Date of Birth</th>
                        <th>Registration DateTime</th>
                        <th>Exam</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            if (rs != null && rs.isBeforeFirst()) {
                                while (rs.next()) {
                                    String id = rs.getString("ID") != null ? rs.getString("ID") : "N/A";
                                    String name = rs.getString("Name") != null ? rs.getString("Name") : "N/A";
                                    String empEmail = rs.getString("Email") != null ? rs.getString("Email") : "N/A";
                                    String batch = rs.getString("Batch") != null ? rs.getString("Batch") : "N/A";
                                    String dob = rs.getString("Date_of_Birth") != null ? rs.getString("Date_of_Birth") : "N/A";
                                    String regDateTime = rs.getString("Registration_DateTime") != null ? rs.getString("Registration_DateTime") : "N/A";
                                    String exam = rs.getString("Exam") != null ? rs.getString("Exam") : "N/A";
                                    String motherName = rs.getString("Mother_Name") != null ? rs.getString("Mother_Name") : "N/A";
                                    String fatherName = rs.getString("Father_Name") != null ? rs.getString("Father_Name") : "N/A";
                                    String aadhar = rs.getString("Aadhar") != null ? rs.getString("Aadhar") : "N/A";
                                    String pan = rs.getString("PAN") != null ? rs.getString("PAN") : "N/A";
                                    String mobile = rs.getString("Mobile") != null ? rs.getString("Mobile") : "N/A";
                                    String gender = rs.getString("Gender") != null ? rs.getString("Gender") : "N/A";
                                    String maritalStatus = rs.getString("Marital_Status") != null ? rs.getString("Marital_Status") : "N/A";
                                    String hasClicked = rs.getString("hasClicked") != null ? rs.getString("hasClicked") : "No";

                                    String photoBase64 = "data:image/jpeg;base64,/9j/4AAQSkZJRg=="; // Default placeholder
                                    Blob photoBlob = rs.getBlob("Profile_Photo");
                                    if (photoBlob != null) {
                                        byte[] photoBytes = photoBlob.getBytes(1, (int) photoBlob.length());
                                        photoBase64 = "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(photoBytes);
                                    }
                    %>
                    <tr data-id="<%= id.toLowerCase() %>" data-name="<%= name.toLowerCase() %>" data-email="<%= empEmail.toLowerCase() %>"
                        data-batch="<%= batch.toLowerCase() %>" data-date="<%= dob %>" data-regdate="<%= regDateTime.substring(0, 10) %>"
                        data-mother="<%= motherName %>" data-father="<%= fatherName %>" data-aadhar="<%= aadhar %>"
                        data-pan="<%= pan %>" data-mobile="<%= mobile %>" data-gender="<%= gender %>"
                        data-marital="<%= maritalStatus %>" data-hasclicked="<%= hasClicked %>">
                        <td><img src="<%= photoBase64 %>" alt="Profile Photo" class="profile-photo"></td>
                        <td><%= id %></td>
                        <td><%= name %></td>
                        <td><%= empEmail %></td>
                        <td><%= batch %></td>
                        <td><%= dob %></td>
                        <td><%= regDateTime %></td>
                        <td><%= exam %></td>
                        <td>
                            <button class="action-btn edit-btn" data-id="<%= id %>">Edit</button>
                            <button class="action-btn view-btn" data-id="<%= id %>">View</button>
                        </td>
                    </tr>
                    <%
                                }
                            } else {
                                out.println("<tr><td colspan='9' class='no-data'>No employee details found.</td></tr>");
                            }
                        } catch (Exception e) {
                            errorMessage = "Error displaying data: " + e.getMessage();
                            out.println("<tr><td colspan='9' class='error-message'>" + errorMessage + "</td></tr>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) {}
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                            if (conn != null) try { conn.close(); } catch (SQLException e) {}
                        }
                    %>
                </tbody>
            </table>
        </div>
        <% if (errorMessage != null) { %>
        <div class="error-message"><%= errorMessage %></div>
        <% } %>
        <% if (request.getParameter("error") != null && !"DataTooLong".equals(request.getParameter("error"))) { %>
        <div class="error-message">Error: <%= request.getParameter("error") %></div>
        <% } %>
    </div>

    <!-- Modal for Edit/View -->
    <div class="modal" id="employeeModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalTitle">Employee Details</h2>
                <button class="modal-close-btn"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <form id="editForm" action="<%= request.getContextPath() %>/UpdateEmployeeServlet" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="id" id="modalId">
                    <div class="form-group">
                        <label>Profile Photo</label>
                        <img id="modalPhoto" class="modal-photo" src="" alt="Profile Photo">
                        <input type="file" name="profilePhoto" id="modalPhotoInput" accept="image/*">
                    </div>
                    <div class="form-group">
                        <label>Employee ID</label>
                        <input type="text" id="modalEmpId" readonly>
                    </div>
                    <div class="form-group">
                        <label>Name</label>
                        <input type="text" name="name" id="modalName">
                    </div>
                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" id="modalEmail">
                    </div>
                    <div class="form-group">
                        <label>Batch</label>
                        <input type="text" name="batch" id="modalBatch">
                    </div>
                    <div class="form-group">
                        <label>Mother Name</label>
                        <input type="text" name="motherName" id="modalMotherName">
                    </div>
                    <div class="form-group">
                        <label>Father Name</label>
                        <input type="text" name="fatherName" id="modalFatherName">
                    </div>
                    <div class="form-group">
                        <label>Aadhar</label>
                        <input type="text" name="aadhar" id="modalAadhar" maxlength="12" pattern="[0-9]{12}" title="Aadhar must be 12 digits">
                    </div>
                    <div class="form-group">
                        <label>PAN</label>
                        <input type="text" name="pan" id="modalPan" maxlength="10" pattern="[A-Z0-9]{10}" title="PAN must be 10 characters">
                    </div>
                    <div class="form-group">
                        <label>Mobile</label>
                        <input type="text" name="mobile" id="modalMobile">
                    </div>
                    <div class="form-group">
                        <label>Gender</label>
                        <select name="gender" id="modalGender">
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Marital Status</label>
                        <select name="maritalStatus" id="modalMaritalStatus">
                            <option value="Single">Single</option>
                            <option value="Married">Married</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Date of Birth</label>
                        <input type="date" name="dob" id="modalDob">
                    </div>
                    <div class="form-group">
                        <label>Registration DateTime</label>
                        <input type="datetime-local" name="regDateTime" id="modalRegDateTime" readonly>
                    </div>
                    <div class="form-group">
                        <label>Exam</label>
                        <input type="text" name="exam" id="modalExam">
                    </div>
                    <div class="form-group">
                        <label>Has Clicked</label>
                        <select name="hasClicked" id="modalHasClicked">
                            <option value="Yes">Yes</option>
                            <option value="No">No</option>
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="modal-btn cancel-btn">Cancel</button>
                <button class="modal-btn save-btn" id="saveBtn" type="submit" form="editForm">Save</button>
            </div>
        </div>
    </div>

    <!-- Error Popup -->
    <div class="error-popup" id="errorPopup">
        <p>Not added the details, reenter details</p>
    </div>

    <!-- Success Popup -->
    <div class="success-popup" id="successPopup">
        <p>Employee details updated successfully!</p>
    </div>

    <script src="<%= request.getContextPath() %>/js/admin_registration_details.js"></script>
</body>
</html>