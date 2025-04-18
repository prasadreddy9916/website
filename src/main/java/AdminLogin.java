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
import java.sql.Timestamp;
import java.util.logging.Logger;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/adminLogin")
public class AdminLogin extends HttpServlet {
    private static final String URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USER = "root";
    private static final String PASS = "hacker#Tag1";
    private static final Logger LOGGER = Logger.getLogger(AdminLogin.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Prevent caching
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String ipAddress = request.getRemoteAddr();
        Timestamp loginTime = new Timestamp(System.currentTimeMillis());

        LOGGER.info("Admin login attempt for: " + email);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Load driver explicitly
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASS);
            LOGGER.info("Database connection established");

            // Query admin table
            String adminQuery = "SELECT Admin_ID, Email, Password, Role FROM admin WHERE Email = ?";
            ps = conn.prepareStatement(adminQuery);
            ps.setString(1, email);
            rs = ps.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("Password");
                String adminId = rs.getString("Admin_ID");
                String role = rs.getString("Role");

                LOGGER.info("Retrieved stored password hash for " + email);
                if (storedPassword == null || storedPassword.isEmpty()) {
                    LOGGER.severe("Password hash is null or empty for " + email);
                    response.sendRedirect("adminlogin.jsp?error=1");
                    return;
                }

                if (BCrypt.checkpw(password, storedPassword)) {
                    LOGGER.info("Password verified for " + email);

                    // Update Last_Login
                    String updateLastLogin = "UPDATE admin SET Last_Login = ? WHERE Email = ?";
                    try (PreparedStatement psUpdate = conn.prepareStatement(updateLastLogin)) {
                        psUpdate.setTimestamp(1, loginTime);
                        psUpdate.setString(2, email);
                        psUpdate.executeUpdate();
                        LOGGER.info("Updated last login for " + email);
                    }

                    // Insert into admin_login_history
                    String historyQuery = "INSERT INTO admin_login_history (Admin_ID, Login_Timestamp, IP_Address) VALUES (?, ?, ?)";
                    try (PreparedStatement psHistory = conn.prepareStatement(historyQuery)) {
                        psHistory.setString(1, adminId);
                        psHistory.setTimestamp(2, loginTime);
                        psHistory.setString(3, ipAddress);
                        psHistory.executeUpdate();
                        LOGGER.info("Logged login history for " + email);
                    }

                    // Create new session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("email", email);
                    session.setAttribute("role", role);
                    UserSessionManager.registerSession(email, session);

                    LOGGER.info("Admin login successful for " + email + ", redirecting to dashboard");
                    response.sendRedirect("admin_dashboard.jsp");
                } else {
                    LOGGER.warning("Password mismatch for admin: " + email);
                    response.sendRedirect("adminlogin.jsp?error=1");
                }
            } else {
                LOGGER.warning("No admin found with email: " + email);
                response.sendRedirect("adminlogin.jsp?error=1");
            }
        } catch (Exception e) {
            LOGGER.severe("Admin login error for " + email + ": " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("adminlogin.jsp?error=2&message=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
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
        response.sendRedirect("adminlogin.jsp");
    }
}