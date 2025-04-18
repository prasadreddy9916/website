import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/UpdateEmployeeServlet")
@MultipartConfig
public class UpdateEmployeeServlet extends HttpServlet {
    private static final String URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USER = "root";
    private static final String PASS = "hacker#Tag1";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id") != null ? request.getParameter("id").trim() : null;
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/employee_registrations.jsp?success=false&error=Employee ID is missing");
            return;
        }
        System.out.println("ID from form: '" + id + "'"); // Debug

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(URL, USER, PASS);
            String sql = "UPDATE employee_registrations SET Name=?, Email=?, Batch=?, Mother_Name=?, Father_Name=?, Aadhar=?, PAN=?, Mobile=?, Gender=?, Marital_Status=?, Date_of_Birth=?, Exam=?, hasClicked=?";
            Part filePart = request.getPart("profilePhoto");
            if (filePart != null && filePart.getSize() > 0) {
                sql += ", Profile_Photo=? WHERE ID=?";
            } else {
                sql += " WHERE ID=?";
            }
            PreparedStatement pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, request.getParameter("name"));
            pstmt.setString(2, request.getParameter("email"));
            pstmt.setString(3, request.getParameter("batch"));
            pstmt.setString(4, request.getParameter("motherName"));
            pstmt.setString(5, request.getParameter("fatherName"));
            pstmt.setString(6, request.getParameter("aadhar"));
            pstmt.setString(7, request.getParameter("pan"));
            pstmt.setString(8, request.getParameter("mobile"));
            pstmt.setString(9, request.getParameter("gender"));
            pstmt.setString(10, request.getParameter("maritalStatus"));

            // Handle Date_of_Birth
            String dob = request.getParameter("dob");
            if (dob == null || dob.trim().isEmpty()) {
                pstmt.setNull(11, java.sql.Types.DATE);
            } else {
                pstmt.setString(11, dob);
            }

            pstmt.setString(12, request.getParameter("exam"));
            pstmt.setString(13, request.getParameter("hasClicked"));

            if (filePart != null && filePart.getSize() > 0) {
                InputStream photoStream = filePart.getInputStream();
                pstmt.setBlob(14, photoStream);
                pstmt.setString(15, id);
            } else {
                pstmt.setString(14, id);
            }

            int rowsUpdated = pstmt.executeUpdate();
            System.out.println("Rows updated: " + rowsUpdated); // Debug
            conn.close();

            if (rowsUpdated > 0) {
                response.sendRedirect(request.getContextPath() + "/employee_registrations.jsp?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/employee_registrations.jsp?success=false&error=No rows updated");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            if (e.getMessage().contains("Data too long for column")) {
                response.sendRedirect(request.getContextPath() + "/employee_registrations.jsp?success=false&error=DataTooLong");
            } else {
                response.sendRedirect(request.getContextPath() + "/employee_registrations.jsp?success=false&error=" + e.getMessage());
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/employee_registrations.jsp?success=false&error=" + e.getMessage());
        }
    }
}