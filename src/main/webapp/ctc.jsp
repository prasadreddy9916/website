<!-- ctc.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    String URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    String USERNAME = "root";
    String PASSWORD = "hacker#Tag1";

    String action = request.getParameter("action");
    if (action == null && request.getAttribute("action") != null) {
        action = (String) request.getAttribute("action");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CTC Details</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/ctc_styles.css">
    <style>
        .popup {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 25px;
            color: white;
            font-weight: bold;
            border-radius: 5px;
            z-index: 2000;
            display: none;
        }
        .popup.success { background-color: #2ecc71; }
        .popup.error { background-color: #e74c3c; }
        .form-group .dual-input { display: flex; gap: 10px; }
        .form-group .dual-input input { width: 48%; }
        th, td { white-space: nowrap; }
        .filter-section {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 20px;
        }
        .filter-section .form-group {
            flex: 1;
            min-width: 150px;
        }
        .filter-section label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .filter-section input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }
        #addForm { z-index: 1000; }
        .input-with-button { display: flex; align-items: center; gap: 10px; }
        .input-with-button input { flex-grow: 1; }
        .input-with-button button { padding: 8px 12px; background: #3498db; color: white; border: none; border-radius: 5px; cursor: pointer; }
        .input-with-button button:hover { background: #2980b9; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>CTC Details of Employee</h1>
            <form method="post" action="<%= request.getContextPath() %>/CtcServlet">
                <input type="hidden" name="action" value="add">
                <button type="submit" class="add-new-btn">Add New</button>
            </form>
        </div>
        <div class="content">
            <div class="filter-section">
                <div class="form-group">
                    <label for="empIdFilter">Employee ID</label>
                    <input type="text" id="empIdFilter" onkeyup="filterTable()" placeholder="Search Employee ID">
                </div>
                <div class="form-group">
                    <label for="empNameFilter">Name</label>
                    <input type="text" id="empNameFilter" onkeyup="filterTable()" placeholder="Search Name">
                </div>
                <div class="form-group">
                    <label for="designationFilter">Designation</label>
                    <input type="text" id="designationFilter" onkeyup="filterTable()" placeholder="Search Designation">
                </div>
                <div class="form-group">
                    <label for="departmentFilter">Department</label>
                    <input type="text" id="departmentFilter" onkeyup="filterTable()" placeholder="Search Department">
                </div>
                <div class="form-group">
                    <label for="joiningDateFilter">Joining Date</label>
                    <input type="text" id="joiningDateFilter" onkeyup="filterTable()" placeholder="Search Joining Date">
                </div>
                <div class="form-group">
                    <label for="locationFilter">Work Location</label>
                    <input type="text" id="locationFilter" onkeyup="filterTable()" placeholder="Search Location">
                </div>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Employee ID</th>
                            <th>Name</th>
                            <th>Designation</th>
                            <th>Department</th>
                            <th>Joining Date</th>
                            <th>Work Location</th>
                            <th>Gross Earnings (Monthly ₹ / Annual ₹)</th>
                            <th>Net Salary (Monthly ₹ / Annual ₹)</th>
                            <th>Total CTC (Monthly ₹ / Annual ₹)</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="employeeTable">
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
                                 PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM ctc_employees");
                                 ResultSet rs = pstmt.executeQuery()) {
                                SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MMM-yyyy");
                                while (rs.next()) {
                                    double grossMonthly = rs.getDouble("basic_salary") + rs.getDouble("hra") +
                                        rs.getDouble("special_allowance") + rs.getDouble("conveyance_allowance") +
                                        rs.getDouble("medical_allowance");
                                    double grossAnnual = grossMonthly * 12;
                                    double netMonthly = grossMonthly - (rs.getDouble("pf") + 
                                        rs.getDouble("professional_tax") + rs.getDouble("tds") + rs.getDouble("esi"));
                                    double netAnnual = netMonthly * 12;
                                    double totalCtcMonthly = grossMonthly + rs.getDouble("pf") + 
                                        rs.getDouble("gratuity") + rs.getDouble("bonus");
                                    double totalCtcAnnual = totalCtcMonthly * 12;
                                    String joiningDate = rs.getDate("date_of_joining") != null ? 
                                        dateFormat.format(rs.getDate("date_of_joining")) : "";
                    %>
                        <tr>
                            <td><%= rs.getString("employee_id") %></td>
                            <td><%= rs.getString("employee_name") %></td>
                            <td><%= rs.getString("designation") %></td>
                            <td><%= rs.getString("department") %></td>
                            <td><%= joiningDate %></td>
                            <td><%= rs.getString("work_location") %></td>
                            <td><%= String.format("%.2f / %.2f", grossMonthly, grossAnnual) %></td>
                            <td><%= String.format("%.2f / %.2f", netMonthly, netAnnual) %></td>
                            <td><%= String.format("%.2f / %.2f", totalCtcMonthly, totalCtcAnnual) %></td>
                            <td>
                                <form method="post" action="<%= request.getContextPath() %>/CtcServlet">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="empId" value="<%= rs.getString("employee_id") %>">
                                    <button type="submit">Edit</button>
                                </form>
                            </td>
                        </tr>
                    <%
                                }
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='10'>Error loading data: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <% if ("add".equals(action) || "edit".equals(action)) { %>
        <div id="addForm" class="modal" style="display: block;">
            <div class="modal-content">
                <div class="modal-header">
                    <h2><%= "edit".equals(action) ? "Edit CTC Details" : "Add New CTC Details" %></h2>
                    <button type="button" class="cancel-btn" onclick="window.location.href='<%= request.getContextPath() %>/ctc.jsp'">Cancel</button>
                </div>
                <form method="post" action="<%= request.getContextPath() %>/CtcServlet" onsubmit="return calculateAndSubmit()">
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="formAction" id="formAction" value="<%= "edit".equals(action) ? "edit" : "add" %>">
                    <input type="hidden" name="employeeId" value="<%= request.getAttribute("editEmpId") != null ? request.getAttribute("editEmpId") : "" %>">

                    <h3>Employee Information</h3>
                    <div class="form-group">
                        <label>Employee ID<span class="required">*</span></label>
                        <div class="input-with-button">
                            <input type="text" name="empId" id="empId" value="<%= request.getAttribute("editEmpId") != null ? request.getAttribute("editEmpId") : (request.getParameter("empId") != null ? request.getParameter("empId") : "") %>" 
                                   <%= "edit".equals(action) ? "readonly" : "required" %>>
                            <% if (!"edit".equals(action)) { %>
                                <button type="button" onclick="fetchEmployeeDetails(document.getElementById('empId').value)">Fill</button>
                            <% } %>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Employee Name<span class="required">*</span></label>
                        <input type="text" name="empName" id="empName" value="<%= request.getAttribute("editEmpName") != null ? request.getAttribute("editEmpName") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label>Designation<span class="required">*</span></label>
                        <input type="text" name="designation" id="designation" value="<%= request.getAttribute("editDesignation") != null ? request.getAttribute("editDesignation") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label>Department<span class="required">*</span></label>
                        <input type="text" name="department" id="department" value="<%= request.getAttribute("editDepartment") != null ? request.getAttribute("editDepartment") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label>Date of Joining<span class="required">*</span></label>
                        <input type="date" name="joiningDate" id="joiningDate" value="<%= request.getAttribute("editJoiningDate") != null ? request.getAttribute("editJoiningDate") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label>End Date</label>
                        <input type="date" name="endDate" value="<%= request.getAttribute("editEndDate") != null ? request.getAttribute("editEndDate") : "" %>">
                    </div>
                    <div class="form-group">
                        <label>Work Location<span class="required">*</span></label>
                        <input type="text" name="location" value="<%= request.getAttribute("editLocation") != null ? request.getAttribute("editLocation") : "" %>" required>
                    </div>

                    <h3>Earnings (Monthly / Annual)</h3>
                    <div class="form-group">
                        <label>Basic Salary<span class="required">*</span></label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="basic" id="basic" 
                                   value="<%= request.getAttribute("editBasic") != null ? request.getAttribute("editBasic") : "0" %>" required oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="basicAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>HRA<span class="required">*</span></label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="hra" id="hra" 
                                   value="<%= request.getAttribute("editHra") != null ? request.getAttribute("editHra") : "0" %>" required oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="hraAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Special Allowance<span class="required">*</span></label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="special" id="special" 
                                   value="<%= request.getAttribute("editSpecial") != null ? request.getAttribute("editSpecial") : "0" %>" required oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="specialAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Conveyance Allowance<span class="required">*</span></label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="conveyance" id="conveyance" 
                                   value="<%= request.getAttribute("editConveyance") != null ? request.getAttribute("editConveyance") : "0" %>" required oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="conveyanceAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Medical Allowance<span class="required">*</span></label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="medical" id="medical" 
                                   value="<%= request.getAttribute("editMedical") != null ? request.getAttribute("editMedical") : "0" %>" required oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="medicalAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Gross Earnings</label>
                        <div class="dual-input">
                            <input type="text" id="grossMonthly" readonly>
                            <input type="text" id="grossAnnual" readonly>
                        </div>
                    </div>

                    <h3>Deductions (Monthly / Annual)</h3>
                    <div class="form-group">
                        <label>Provident Fund (12% of Basic)<span class="required">*</span></label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="pf" id="pf" 
                                   value="<%= request.getAttribute("editPf") != null ? request.getAttribute("editPf") : "0" %>" required oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="pfAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Professional Tax<span class="required">*</span></label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="pt" id="pt" 
                                   value="<%= request.getAttribute("editPt") != null ? request.getAttribute("editPt") : "200" %>" required oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="ptAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Income Tax (TDS)<span class="required">*</span></label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="tds" id="tds" 
                                   value="<%= request.getAttribute("editTds") != null ? request.getAttribute("editTds") : "0" %>" required oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="tdsAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>ESI<span class="required">*</span></label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="esi" id="esi" 
                                   value="<%= request.getAttribute("editEsi") != null ? request.getAttribute("editEsi") : "0" %>" required oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="esiAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Total Deductions</label>
                        <div class="dual-input">
                            <input type="number" step="0.01" id="totalDeductions" readonly>
                            <input type="number" step="0.01" id="totalDeductionsAnnual" readonly>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Net Salary (Take Home)</label>
                        <div class="dual-input">
                            <input type="number" step="0.01" id="netSalary" readonly>
                            <input type="number" step="0.01" id="netSalaryAnnual" readonly>
                        </div>
                    </div>

                    <h3>Employer Contributions (Monthly / Annual)</h3>
                    <div class="form-group">
                        <label>Gratuity</label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="gratuity" id="gratuity" 
                                   value="<%= request.getAttribute("editGratuity") != null ? request.getAttribute("editGratuity") : "0" %>" oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="gratuityAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Bonus</label>
                        <div class="dual-input">
                            <input type="number" step="0.01" name="bonus" id="bonus" 
                                   value="<%= request.getAttribute("editBonus") != null ? request.getAttribute("editBonus") : "0" %>" oninput="calculateFromMonthly()">
                            <input type="number" step="0.01" id="bonusAnnual" oninput="calculateFromAnnual()">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Total CTC</label>
                        <div class="dual-input">
                            <input type="text" id="totalCtc" readonly>
                            <input type="text" id="totalCtcAnnual" readonly>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit">Save</button>
                        <button type="button" onclick="window.location.href='<%= request.getContextPath() %>/ctc.jsp'">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
        <% } %>

        <% if (request.getAttribute("message") != null) { %>
            <div id="popup" class="popup success" style="display: block;"><%= request.getAttribute("message") %></div>
        <% } else if (request.getAttribute("error") != null) { %>
            <div id="popup" class="popup error" style="display: block;"><%= request.getAttribute("error") %></div>
        <% } %>
    </div>

    <script src="<%= request.getContextPath() %>/js/ctc_scripts.js"></script>
    <script>
        function fetchEmployeeDetails(empId) {
            if (!empId || document.getElementById('formAction').value !== 'add') return;

            fetch('<%= request.getContextPath() %>/CtcServlet?action=fetchEmployee&empId=' + encodeURIComponent(empId), {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    alert(data.error);
                } else {
                    document.getElementById('empName').value = data.Name || '';
                    document.getElementById('designation').value = data.Designation || '';
                    document.getElementById('department').value = data.Department || '';
                    document.getElementById('joiningDate').value = data.Registration_DateTime ? 
                        data.Registration_DateTime.substring(0, 10) : '';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Failed to fetch employee details');
            });
        }

        <% if ("edit".equals(action) || "add".equals(action)) { %>
            window.onload = function() {
                calculateFromMonthly();
            };
        <% } %>
    </script>
</body>
</html>