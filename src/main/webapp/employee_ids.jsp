<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CYE Technology Private Limited</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="css/employee_ids_styles.css">
</head>
<body>
    <div class="employee-ids-container">
        <h1 class="sticky-header">Employee Management 
            <form method="post" action="${pageContext.request.contextPath}/AdminEmployeeServlet" style="display: inline;">
                <input type="hidden" name="action" value="add">
                <button type="submit" id="addNewBtn" class="btn-add">Add New</button>
            </form>
            <div id="popup" class="popup"></div>
        </h1>

        <div class="filter-section">
            <div class="filter-row">
                <div class="filter-group">
                    <label for="idFilter">Employee ID</label>
                    <input type="text" id="idFilter" placeholder="Filter by Employee ID">
                </div>
                <div class="filter-group">
                    <label for="nameFilter">Name</label>
                    <input type="text" id="nameFilter" placeholder="Filter by Name">
                </div>
                <div class="filter-group">
                    <label for="emailFilter">Email</label>
                    <input type="text" id="emailFilter" placeholder="Filter by Email">
                </div>
                <div class="filter-group">
                    <label for="yearFilter">Year</label>
                    <input type="text" id="yearFilter" placeholder="Filter by Year">
                </div>
                <div class="filter-group">
                    <label for="batchFilter">Batch</label>
                    <input type="text" id="batchFilter" placeholder="Filter by Batch">
                </div>
                <div class="filter-group">
                    <label for="designationFilter">Designation</label>
                    <input type="text" id="designationFilter" placeholder="Filter by Designation">
                </div>
                <div class="filter-group">
                    <label for="departmentFilter">Department</label>
                    <input type="text" id="departmentFilter" placeholder="Filter by Department">
                </div>
            </div>
        </div>

        <div class="employee-ids-list">
            <h2>Registered Employees</h2>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Employee ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Year</th>
                            <th>Batch</th>
                            <th>Designation</th>
                            <th>Department</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="employeeTableBody">
                        <%
                            List<Map<String, String>> employees = new ArrayList<>();
                            String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
                            String DB_USER = "root";
                            String DB_PASSWORD = "hacker#Tag1";

                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                     Statement stmt = conn.createStatement();
                                     ResultSet rs = stmt.executeQuery("SELECT * FROM employee_ids ORDER BY employee_id")) {
                                    while (rs.next()) {
                                        Map<String, String> employee = new HashMap<>();
                                        employee.put("employee_id", rs.getString("employee_id"));
                                        employee.put("name", rs.getString("Name"));
                                        employee.put("email", rs.getString("Email") != null ? rs.getString("Email") : "N/A");
                                        employee.put("year", rs.getString("Year"));
                                        employee.put("batch", rs.getString("Batch"));
                                        employee.put("designation", rs.getString("Designation"));
                                        employee.put("department", rs.getString("Department"));
                                        employees.add(employee);
                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<!-- Error fetching employees: " + e.getMessage() + " -->");
                            }

                            if (employees != null && !employees.isEmpty()) {
                                for (Map<String, String> employee : employees) {
                        %>
                            <tr data-id="<%= employee.get("employee_id") != null ? employee.get("employee_id") : "" %>"
                                data-name="<%= employee.get("name") != null ? employee.get("name") : "" %>"
                                data-email="<%= employee.get("email") != null ? employee.get("email") : "" %>"
                                data-year="<%= employee.get("year") != null ? employee.get("year") : "" %>"
                                data-batch="<%= employee.get("batch") != null ? employee.get("batch") : "" %>"
                                data-designation="<%= employee.get("designation") != null ? employee.get("designation") : "" %>"
                                data-department="<%= employee.get("department") != null ? employee.get("department") : "" %>">
                                <td><%= employee.get("employee_id") != null ? employee.get("employee_id") : "" %></td>
                                <td><%= employee.get("name") != null ? employee.get("name") : "" %></td>
                                <td><%= employee.get("email") != null ? employee.get("email") : "" %></td>
                                <td><%= employee.get("year") != null ? employee.get("year") : "" %></td>
                                <td><%= employee.get("batch") != null ? employee.get("batch") : "" %></td>
                                <td><%= employee.get("designation") != null ? employee.get("designation") : "" %></td>
                                <td><%= employee.get("department") != null ? employee.get("department") : "" %></td>
                                <td class="action-buttons">
                                    <form method="post" action="${pageContext.request.contextPath}/AdminEmployeeServlet" style="display: inline;">
                                        <input type="hidden" name="action" value="edit">
                                        <input type="hidden" name="employeeId" value="<%= employee.get("employee_id") %>">
                                        <button type="submit" class="btn-edit">Edit</button>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/AdminEmployeeServlet" style="display: inline;" class="delete-form">
                                        <input type="hidden" name="action" value="confirmDelete">
                                        <input type="hidden" name="employeeId" value="<%= employee.get("employee_id") %>">
                                        <button type="submit" class="btn-delete">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr><td colspan="8">No employees found.</td></tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Modal for Adding/Editing Employee -->
    <% 
        String action = request.getParameter("action");
        if ("add".equals(action) || "edit".equals(action)) {
            Map<String, String> employee = (Map<String, String>) request.getAttribute("employeeToEdit");
            boolean isEdit = "edit".equals(action);
    %>
        <div id="employeeModal" class="modal" style="display: block;">
            <div class="modal-content">
                <div class="modal-header">
                    <h2><%= isEdit ? "Edit Employee" : "Add New Employee" %></h2>
                    <button type="button" class="btn-close" onclick="window.location.href='${pageContext.request.contextPath}/AdminEmployeeServlet'">Cancel</button>
                </div>
                <form id="employeeForm" action="${pageContext.request.contextPath}/AdminEmployeeServlet" method="POST">
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="formAction" value="<%= isEdit ? "edit" : "add" %>">
                    <% if (isEdit) { %>
                        <input type="hidden" name="originalEmployeeId" value="<%= employee.get("employee_id") %>">
                    <% } %>
                    <div class="form-group">
                        <label for="employeeId">Employee ID<span class="required">*</span></label>
                        <input type="text" name="employeeId" id="employeeId" value="<%= isEdit ? employee.get("employee_id") : "CT-" %>" pattern="CT-[A-Za-z0-9]+" title="Employee ID must start with 'CT-' followed by letters or numbers" required>
                    </div>
                    <div class="form-group">
                        <label for="name">Name<span class="required">*</span></label>
                        <input type="text" name="name" id="name" value="<%= isEdit && employee.get("name") != null ? employee.get("name") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email<span class="required">*</span></label>
                        <input type="email" name="email" id="email" value="<%= isEdit && employee.get("email") != null ? employee.get("email") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label for="year">Year<span class="required">*</span></label>
                        <input type="text" name="year" id="year" value="<%= isEdit && employee.get("year") != null ? employee.get("year") : "" %>" pattern="[0-9]{4}" title="Year must be a 4-digit number" required>
                    </div>
                    <div class="form-group">
                        <label for="batch">Batch<span class="required">*</span></label>
                        <input type="text" name="batch" id="batch" value="<%= isEdit && employee.get("batch") != null ? employee.get("batch") : "" %>" placeholder="e.g., Batch 2025-A" required>
                    </div>
                    <div class="form-group">
                        <label for="designation">Designation<span class="required">*</span></label>
                        <input type="text" name="designation" id="designation" value="<%= isEdit && employee.get("designation") != null ? employee.get("designation") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label for="department">Department<span class="required">*</span></label>
                        <input type="text" name="department" id="department" value="<%= isEdit && employee.get("department") != null ? employee.get("department") : "" %>" required>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="btn-save">Save</button>
                        <button type="button" class="btn-cancel" onclick="window.location.href='${pageContext.request.contextPath}/AdminEmployeeServlet'">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
    <% } %>

    <!-- Delete Confirmation Modal -->
    <% 
        if ("confirmDelete".equals(action)) {
            String employeeId = request.getParameter("employeeId");
    %>
        <div id="deleteConfirmModal" class="modal" style="display: block;">
            <div class="modal-content small-modal">
                <p>Are you sure you want to delete this employee?</p>
                <form id="deleteForm" action="${pageContext.request.contextPath}/AdminEmployeeServlet" method="POST">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="employeeId" value="<%= employeeId %>">
                    <div class="modal-actions">
                        <button type="button" id="cancelDeleteBtn" class="btn-cancel" onclick="window.location.href='${pageContext.request.contextPath}/AdminEmployeeServlet'">Cancel</button>
                        <button type="submit" class="btn-remove">Delete</button>
                    </div>
                </form>
            </div>
        </div>
    <% } %>

    <!-- Popup Message Handling -->
    <%
        String message = (String) request.getAttribute("message");
        Boolean success = (Boolean) request.getAttribute("success");
        if (message != null) {
    %>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const popup = document.getElementById("popup");
                popup.textContent = "<%= message %>";
                popup.className = "popup <%= success != null && success ? "success" : "error" %>";
                popup.style.display = "block";
                setTimeout(function () {
                    popup.style.display = "none";
                }, 3000);
            });
        </script>
    <%
        }
    %>

    <script>
        window.contextPath = '${pageContext.request.contextPath}';

        document.addEventListener('DOMContentLoaded', () => {
            const idFilter = document.getElementById('idFilter');
            const nameFilter = document.getElementById('nameFilter');
            const emailFilter = document.getElementById('emailFilter');
            const yearFilter = document.getElementById('yearFilter');
            const batchFilter = document.getElementById('batchFilter');
            const designationFilter = document.getElementById('designationFilter');
            const departmentFilter = document.getElementById('departmentFilter');
            const rows = document.querySelectorAll('#employeeTableBody tr');

            function applyFilters() {
                const idValue = idFilter.value.trim().toLowerCase();
                const nameValue = nameFilter.value.trim().toLowerCase();
                const emailValue = emailFilter.value.trim().toLowerCase();
                const yearValue = yearFilter.value.trim().toLowerCase();
                const batchValue = batchFilter.value.trim().toLowerCase();
                const designationValue = designationFilter.value.trim().toLowerCase();
                const departmentValue = departmentFilter.value.trim().toLowerCase();

                rows.forEach(row => {
                    const rowId = (row.getAttribute('data-id') || '').toLowerCase();
                    const rowName = (row.getAttribute('data-name') || '').toLowerCase();
                    const rowEmail = (row.getAttribute('data-email') || '').toLowerCase();
                    const rowYear = (row.getAttribute('data-year') || '').toLowerCase();
                    const rowBatch = (row.getAttribute('data-batch') || '').toLowerCase();
                    const rowDesignation = (row.getAttribute('data-designation') || '').toLowerCase();
                    const rowDepartment = (row.getAttribute('data-department') || '').toLowerCase();

                    const matchesId = idValue === '' || rowId.includes(idValue);
                    const matchesName = nameValue === '' || rowName.includes(nameValue);
                    const matchesEmail = emailValue === '' || rowEmail.includes(emailValue);
                    const matchesYear = yearValue === '' || rowYear.includes(yearValue);
                    const matchesBatch = batchValue === '' || rowBatch.includes(batchValue);
                    const matchesDesignation = designationValue === '' || rowDesignation.includes(designationValue);
                    const matchesDepartment = departmentValue === '' || rowDepartment.includes(departmentValue);

                    row.style.display = matchesId && matchesName && matchesEmail && matchesYear && matchesBatch && matchesDesignation && matchesDepartment ? '' : 'none';
                });
            }

            idFilter.addEventListener('input', applyFilters);
            nameFilter.addEventListener('input', applyFilters);
            emailFilter.addEventListener('input', applyFilters);
            yearFilter.addEventListener('input', applyFilters);
            batchFilter.addEventListener('input', applyFilters);
            designationFilter.addEventListener('input', applyFilters);
            departmentFilter.addEventListener('input', applyFilters);

            applyFilters(); // Initial call to apply filters based on any pre-filled values
        });
    </script>
</body>
</html>