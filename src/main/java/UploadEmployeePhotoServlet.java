import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/UploadEmployeePhotoServlet")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB limit
public class UploadEmployeePhotoServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        Part filePart = request.getPart("photo");

        System.out.println("UploadEmployeePhotoServlet: email = " + email);
        System.out.println("UploadEmployeePhotoServlet: filePart = " + (filePart != null ? filePart.getSubmittedFileName() : "null"));

        if (filePart == null || email == null || email.trim().isEmpty()) {
            System.err.println("UploadEmployeePhotoServlet: Missing or invalid email/photo");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing or invalid email or photo");
            return;
        }

        try (InputStream photoStream = filePart.getInputStream();
             Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement("UPDATE employee_registrations SET Profile_Photo = ? WHERE email = ?")) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            pstmt.setBlob(1, photoStream);
            pstmt.setString(2, email);
            int rows = pstmt.executeUpdate();

            System.out.println("UploadEmployeePhotoServlet: Rows affected = " + rows);

            if (rows > 0) {
                System.out.println("UploadEmployeePhotoServlet: Photo updated successfully for email " + email);
                response.setStatus(HttpServletResponse.SC_OK);
            } else {
                System.err.println("UploadEmployeePhotoServlet: No rows updated. Email " + email + " not found.");
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Email not found: " + email);
            }
        } catch (SQLException e) {
            System.err.println("UploadEmployeePhotoServlet: SQL error - " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("UploadEmployeePhotoServlet: Unexpected error - " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}