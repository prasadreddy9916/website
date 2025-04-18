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

@WebServlet("/UploadPhotoServlet")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB limit
public class UploadPhotoServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String adminId = request.getParameter("adminId");
        Part filePart = request.getPart("photo");

        System.out.println("UploadPhotoServlet: adminId = " + adminId);
        System.out.println("UploadPhotoServlet: filePart = " + (filePart != null ? filePart.getSubmittedFileName() : "null"));

        if (filePart == null || adminId == null || adminId.trim().isEmpty()) {
            System.err.println("UploadPhotoServlet: Missing or invalid adminId/photo");
            response.getWriter().write("error: Missing or invalid adminId or photo");
            return;
        }

        try (InputStream photoStream = filePart.getInputStream();
             Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement("UPDATE admin SET Profile_Photo = ? WHERE Admin_ID = ?")) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            pstmt.setBlob(1, photoStream);
            pstmt.setString(2, adminId);
            int rows = pstmt.executeUpdate();

            System.out.println("UploadPhotoServlet: Rows affected = " + rows);

            if (rows > 0) {
                System.out.println("UploadPhotoServlet: Photo updated successfully for adminId " + adminId);
                response.getWriter().write("success");
            } else {
                System.err.println("UploadPhotoServlet: No rows updated. Admin ID " + adminId + " not found.");
                response.getWriter().write("error: Admin ID not found");
            }
        } catch (SQLException e) {
            System.err.println("UploadPhotoServlet: SQL error - " + e.getMessage());
            response.getWriter().write("error: Database error - " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("UploadPhotoServlet: Unexpected error - " + e.getMessage());
            response.getWriter().write("error: Unexpected error - " + e.getMessage());
            e.printStackTrace();
        }
    }
}