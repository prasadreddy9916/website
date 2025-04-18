import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/CtcServlet")
public class CtcServlet extends HttpServlet {
    private static final String URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "hacker#Tag1";
    private static final Logger LOGGER = Logger.getLogger(CtcServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String formAction = request.getParameter("formAction");
        String empId = request.getParameter("empId");

        if ("fetchEmployee".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
        }

        try (Connection conn = getConnection()) {
            if ("fetchEmployee".equals(action)) {
                String sql = "SELECT Name, Designation, Department, Registration_DateTime FROM employee_registrations WHERE ID = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, empId);
                    ResultSet rs = pstmt.executeQuery();
                    PrintWriter out = response.getWriter();
                    if (rs.next()) {
                        String json = String.format(
                            "{\"Name\":\"%s\",\"Designation\":\"%s\",\"Department\":\"%s\",\"Registration_DateTime\":\"%s\"}",
                            rs.getString("Name"),
                            rs.getString("Designation"),
                            rs.getString("Department"),
                            rs.getString("Registration_DateTime")
                        );
                        out.print(json);
                    } else {
                        out.print("{\"error\":\"Employee not found in registration table\"}");
                    }
                    out.flush();
                    return;
                }
            }

            if ("save".equals(action)) {
                String sql;
                if ("add".equals(formAction)) {
                    sql = "INSERT INTO ctc_employees (employee_id, employee_name, designation, department, " +
                          "date_of_joining, end_date, work_location, basic_salary, hra, special_allowance, " +
                          "conveyance_allowance, medical_allowance, bonus, gratuity, pf, professional_tax, " +
                          "tds, esi) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    // Only prepend "CT-" if it’s not already present
                    if (empId != null && !empId.startsWith("CT-")) {
                        empId = "CT-" + empId;
                    }
                } else if ("edit".equals(formAction)) {
                    sql = "UPDATE ctc_employees SET employee_name=?, designation=?, department=?, " +
                          "date_of_joining=?, end_date=?, work_location=?, basic_salary=?, hra=?, " +
                          "special_allowance=?, conveyance_allowance=?, medical_allowance=?, bonus=?, " +
                          "gratuity=?, pf=?, professional_tax=?, tds=?, esi=? WHERE employee_id=?";
                } else {
                    request.setAttribute("error", "Invalid form action");
                    request.getRequestDispatcher("/ctc.jsp").forward(request, response);
                    return;
                }

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    setParameters(pstmt, request);
                    if ("add".equals(formAction)) {
                        pstmt.setString(1, empId); // Use the modified empId
                        int rows = pstmt.executeUpdate();
                        if (rows > 0) {
                            request.setAttribute("message", "Employee added successfully");
                        } else {
                            request.setAttribute("error", "Failed to add employee");
                        }
                    } else {
                        pstmt.setString(18, request.getParameter("employeeId"));
                        int rows = pstmt.executeUpdate();
                        if (rows > 0) {
                            request.setAttribute("message", "Employee updated successfully");
                        } else {
                            request.setAttribute("error", "Failed to update employee");
                        }
                    }
                }
            } else if ("edit".equals(action)) {
                String sql = "SELECT * FROM ctc_employees WHERE employee_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, empId);
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        request.setAttribute("editEmpId", rs.getString("employee_id"));
                        request.setAttribute("editEmpName", rs.getString("employee_name"));
                        request.setAttribute("editDesignation", rs.getString("designation"));
                        request.setAttribute("editDepartment", rs.getString("department"));
                        request.setAttribute("editJoiningDate", rs.getString("date_of_joining"));
                        request.setAttribute("editEndDate", rs.getString("end_date"));
                        request.setAttribute("editLocation", rs.getString("work_location"));
                        request.setAttribute("editBasic", rs.getDouble("basic_salary"));
                        request.setAttribute("editHra", rs.getDouble("hra"));
                        request.setAttribute("editSpecial", rs.getDouble("special_allowance"));
                        request.setAttribute("editConveyance", rs.getDouble("conveyance_allowance"));
                        request.setAttribute("editMedical", rs.getDouble("medical_allowance"));
                        request.setAttribute("editBonus", rs.getDouble("bonus"));
                        request.setAttribute("editGratuity", rs.getDouble("gratuity"));
                        request.setAttribute("editPf", rs.getDouble("pf"));
                        request.setAttribute("editPt", rs.getDouble("professional_tax"));
                        request.setAttribute("editTds", rs.getDouble("tds"));
                        request.setAttribute("editEsi", rs.getDouble("esi"));
                    } else {
                        request.setAttribute("error", "Employee not found");
                    }
                }
            } else if ("add".equals(action)) {
                // Just open the add form
            }
        } catch (SQLException e) {
            LOGGER.severe("Database error: " + e.getMessage());
            if ("fetchEmployee".equals(action)) {
                response.setContentType("application/json");
                response.getWriter().print("{\"error\":\"Database error: " + e.getMessage() + "\"}");
                return;
            }
            request.setAttribute("error", "Database error: " + e.getMessage());
        }
        request.getRequestDispatcher("/ctc.jsp").forward(request, response);
    }

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("JDBC Driver not found", e);
        }
    }

    private void setParameters(PreparedStatement pstmt, HttpServletRequest request) throws SQLException {
        int index = 1;
        if ("add".equals(request.getParameter("formAction"))) {
            index = 2;
        }
        pstmt.setString(index++, request.getParameter("empName"));
        pstmt.setString(index++, request.getParameter("designation"));
        pstmt.setString(index++, request.getParameter("department"));
        String joiningDate = request.getParameter("joiningDate");
        pstmt.setString(index++, joiningDate != null && !joiningDate.isEmpty() ? joiningDate : null);
        String endDate = request.getParameter("endDate");
        pstmt.setString(index++, endDate != null && !endDate.isEmpty() ? endDate : null);
        pstmt.setString(index++, request.getParameter("location"));
        pstmt.setDouble(index++, parseDouble(request.getParameter("basic")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("hra")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("special")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("conveyance")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("medical")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("bonus")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("gratuity")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("pf")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("pt")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("tds")));
        pstmt.setDouble(index++, parseDouble(request.getParameter("esi")));
    }

    private double parseDouble(String value) {
        try {
            return value != null && !value.trim().isEmpty() ? Double.parseDouble(value) : 0.0;
        } catch (NumberFormatException e) {
            LOGGER.warning("Invalid number format: " + value);
            return 0.0;
        }
    }
}