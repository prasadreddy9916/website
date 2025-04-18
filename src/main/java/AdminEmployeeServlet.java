import java.io.IOException;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AdminEmployeeServlet")
public class AdminEmployeeServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        // Simply forward to JSP, which will fetch data itself
        request.getRequestDispatcher("/employee_ids.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            if ("add".equals(action)) {
                request.getRequestDispatcher("/employee_ids.jsp").forward(request, response);
            } else if ("edit".equals(action)) {
                String employeeId = request.getParameter("employeeId");
                Map<String, String> employee = fetchEmployeeById(employeeId);
                request.setAttribute("employeeToEdit", employee);
                request.getRequestDispatcher("/employee_ids.jsp").forward(request, response);
            } else if ("save".equals(action)) {
                String formAction = request.getParameter("formAction");
                String employeeId = request.getParameter("employeeId");
                String email = request.getParameter("email");

                if ("add".equals(formAction)) {
                    String checkIdSql = "SELECT COUNT(*) FROM employee_ids WHERE employee_id = ?";
                    String checkEmailSql = "SELECT COUNT(*) FROM employee_ids WHERE email = ?";
                    try (PreparedStatement pstmtId = conn.prepareStatement(checkIdSql);
                         PreparedStatement pstmtEmail = conn.prepareStatement(checkEmailSql)) {
                        pstmtId.setString(1, employeeId);
                        ResultSet rsId = pstmtId.executeQuery();
                        rsId.next();
                        pstmtEmail.setString(1, email);
                        ResultSet rsEmail = pstmtEmail.executeQuery();
                        rsEmail.next();

                        if (rsId.getInt(1) > 0) {
                            request.setAttribute("message", "Employee ID already exists");
                            request.setAttribute("success", false);
                        } else if (rsEmail.getInt(1) > 0) {
                            request.setAttribute("message", "Email ID already exists");
                            request.setAttribute("success", false);
                        } else {
                            String insertSql = "INSERT INTO employee_ids (employee_id, Name, Email, Year, Batch, Designation, Department) VALUES (?, ?, ?, ?, ?, ?, ?)";
                            try (PreparedStatement pstmtInsert = conn.prepareStatement(insertSql)) {
                                pstmtInsert.setString(1, employeeId);
                                pstmtInsert.setString(2, request.getParameter("name"));
                                pstmtInsert.setString(3, email);
                                pstmtInsert.setString(4, request.getParameter("year"));
                                pstmtInsert.setString(5, request.getParameter("batch"));
                                pstmtInsert.setString(6, request.getParameter("designation"));
                                pstmtInsert.setString(7, request.getParameter("department"));
                                pstmtInsert.executeUpdate();
                                request.setAttribute("message", "Successfully added!");
                                request.setAttribute("success", true);
                            }
                        }
                    }
                } else if ("edit".equals(formAction)) {
                    String originalEmployeeId = request.getParameter("originalEmployeeId");
                    String checkEmailSql = "SELECT COUNT(*) FROM employee_ids WHERE email = ? AND employee_id != ?";
                    try (PreparedStatement pstmtEmail = conn.prepareStatement(checkEmailSql)) {
                        pstmtEmail.setString(1, email);
                        pstmtEmail.setString(2, originalEmployeeId);
                        ResultSet rsEmail = pstmtEmail.executeQuery();
                        rsEmail.next();

                        if (rsEmail.getInt(1) > 0) {
                            request.setAttribute("message", "Email ID already exists");
                            request.setAttribute("success", false);
                        } else {
                            String updateSql = "UPDATE employee_ids SET employee_id=?, Name=?, Email=?, Year=?, Batch=?, Designation=?, Department=? WHERE employee_id=?";
                            try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                                pstmt.setString(1, employeeId);
                                pstmt.setString(2, request.getParameter("name"));
                                pstmt.setString(3, email);
                                pstmt.setString(4, request.getParameter("year"));
                                pstmt.setString(5, request.getParameter("batch"));
                                pstmt.setString(6, request.getParameter("designation"));
                                pstmt.setString(7, request.getParameter("department"));
                                pstmt.setString(8, originalEmployeeId);
                                pstmt.executeUpdate();
                                request.setAttribute("message", "Successfully updated!");
                                request.setAttribute("success", true);
                            }
                        }
                    }
                }
                request.getRequestDispatcher("/employee_ids.jsp").forward(request, response);
            } else if ("confirmDelete".equals(action)) {
                request.getRequestDispatcher("/employee_ids.jsp").forward(request, response);
            } else if ("delete".equals(action)) {
                String deleteSql = "DELETE FROM employee_ids WHERE employee_id=?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteSql)) {
                    pstmt.setString(1, request.getParameter("employeeId"));
                    pstmt.executeUpdate();
                    request.setAttribute("message", "Employee deleted successfully!");
                    request.setAttribute("success", true);
                }
                request.getRequestDispatcher("/employee_ids.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("message", "Database error: " + e.getMessage());
            request.setAttribute("success", false);
            request.getRequestDispatcher("/employee_ids.jsp").forward(request, response);
        }
    }

    private Map<String, String> fetchEmployeeById(String employeeId) {
        Map<String, String> employee = new HashMap<>();
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM employee_ids WHERE employee_id = ?")) {
            pstmt.setString(1, employeeId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                employee.put("employee_id", rs.getString("employee_id"));
                employee.put("name", rs.getString("Name"));
                employee.put("email", rs.getString("Email") != null ? rs.getString("Email") : "N/A");
                employee.put("year", rs.getString("Year"));
                employee.put("batch", rs.getString("Batch"));
                employee.put("designation", rs.getString("Designation"));
                employee.put("department", rs.getString("Department"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return employee;
    }
}