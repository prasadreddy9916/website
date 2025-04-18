import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Logger;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/login")
public class Login extends HttpServlet {
    private static final String URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USER = "root";
    private static final String PASS = "hacker#Tag1";
    private static final Logger LOGGER = Logger.getLogger(Login.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Prevent caching
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        LOGGER.info("Employee login attempt for: " + email);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Load driver explicitly
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASS);
            LOGGER.info("Database connection established");

            String query = "SELECT id, Name, Password FROM employee_registrations WHERE email = ?";
            ps = conn.prepareStatement(query);
            ps.setString(1, email);
            rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("Password");
                String employeeId = rs.getString("id");
                String employeeName = rs.getString("Name");

                LOGGER.info("Retrieved stored password hash for " + email);
                if (storedHash == null || storedHash.isEmpty()) {
                    LOGGER.severe("Password hash is null or empty for " + email);
                    response.sendRedirect("login.jsp?error=1");
                    return;
                }

                if (BCrypt.checkpw(password, storedHash)) {
                    LOGGER.info("Password verified for " + email);

                    // Create new session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("employeeId", employeeId);
                    session.setAttribute("employeeName", employeeName);
                    session.setAttribute("email", email);
                    UserSessionManager.registerSession(email, session);

                    LOGGER.info("Employee login successful for " + email + ", redirecting to dashboard");
                    response.sendRedirect("employee_dashboard.jsp");
                } else {
                    LOGGER.warning("Password mismatch for: " + email);
                    response.sendRedirect("login.jsp?error=1");
                }
            } else {
                LOGGER.warning("No employee found with email: " + email);
                response.sendRedirect("login.jsp?error=1");
            }
        } catch (Exception e) {
            LOGGER.severe("Employee login error for " + email + ": " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=2&message=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
                LOGGER.info("Database resources closed");
            } catch (Exception e) {
                LOGGER.severe("Error closing resources: " + e.getMessage());
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        response.sendRedirect("login.jsp");
    }
}