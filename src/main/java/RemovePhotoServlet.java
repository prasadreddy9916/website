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

@WebServlet("/RemovePhotoServlet")
public class RemovePhotoServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String adminId = request.getParameter("adminId");

        System.out.println("RemovePhotoServlet: adminId = " + adminId);

        if (adminId == null || adminId.trim().isEmpty()) {
            System.err.println("RemovePhotoServlet: Missing or invalid adminId");
            response.getWriter().write("error: Missing or invalid adminId");
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement("UPDATE admin SET Profile_Photo = NULL WHERE Admin_ID = ?")) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            pstmt.setString(1, adminId);
            int rows = pstmt.executeUpdate();

            System.out.println("RemovePhotoServlet: Rows affected = " + rows);

            if (rows > 0) {
                System.out.println("RemovePhotoServlet: Photo removed successfully for adminId " + adminId);
                response.getWriter().write("success");
            } else {
                System.err.println("RemovePhotoServlet: No rows updated. Admin ID " + adminId + " not found.");
                response.getWriter().write("error: Admin ID not found");
            }
        } catch (SQLException e) {
            System.err.println("RemovePhotoServlet: SQL error - " + e.getMessage());
            response.getWriter().write("error: Database error - " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("RemovePhotoServlet: Unexpected error - " + e.getMessage());
            response.getWriter().write("error: Unexpected error - " + e.getMessage());
            e.printStackTrace();
        }
    }
}