import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

@WebServlet("/ExamAssignmentServlet")
public class ExamAssignmentServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata"; // IST
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("publish".equals(action)) {
            handlePublish(request, response);
        } else {
            request.getRequestDispatcher("exam_creation.jsp").forward(request, response);
        }
    }

    private void handlePublish(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");
        LocalDateTime currentDateTime = LocalDateTime.now(ZoneId.of("Asia/Kolkata")); // Current IST time
        Connection conn = null;
        PreparedStatement stmt = null;
        JSONObject jsonResponse = new JSONObject();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            String sql = "UPDATE assigned_exams SET Actions = 'Running' WHERE ID = ? AND Deadline >= ? AND Actions NOT IN ('Running', 'Completed')";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(id));
            stmt.setTimestamp(2, Timestamp.valueOf(currentDateTime)); // Compare with current date and time
            int rowsAffected = stmt.executeUpdate();

            jsonResponse.put("success", rowsAffected > 0);
            if (!jsonResponse.getBoolean("success")) {
                jsonResponse.put("error", "Cannot publish: Deadline has passed, already running, or completed.");
            }
        } catch (Exception e) {
            jsonResponse.put("success", false);
            jsonResponse.put("error", e.getMessage());
            log("Publish Error: ", e);
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(jsonResponse.toString());
    }
}