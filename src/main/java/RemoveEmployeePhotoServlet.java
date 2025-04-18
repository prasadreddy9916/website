import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/RemoveEmployeePhotoServlet")
public class RemoveEmployeePhotoServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");

        System.out.println("RemoveEmployeePhotoServlet: email = " + email);

        if (email == null || email.trim().isEmpty()) {
            System.err.println("RemoveEmployeePhotoServlet: Missing or invalid email");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing or invalid email");
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement("UPDATE employee_registrations SET Profile_Photo = NULL WHERE email = ?")) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            pstmt.setString(1, email);
            int rows = pstmt.executeUpdate();

            System.out.println("RemoveEmployeePhotoServlet: Rows affected = " + rows);

            if (rows > 0) {
                System.out.println("RemoveEmployeePhotoServlet: Photo removed successfully for email " + email);
                response.setStatus(HttpServletResponse.SC_OK);
            } else {
                System.err.println("RemoveEmployeePhotoServlet: No rows updated. Email " + email + " not found.");
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Email not found: " + email);
            }
        } catch (SQLException e) {
            System.err.println("RemoveEmployeePhotoServlet: SQL error - " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("RemoveEmployeePhotoServlet: Unexpected error - " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}