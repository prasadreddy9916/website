import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/EmployeeLogoutServlet")
public class EmployeeLogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(EmployeeLogoutServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String email = null;

        if (session != null) {
            email = (String) session.getAttribute("email");
            LOGGER.info("Logout attempt for email: " + (email != null ? email : "unknown"));
            try {
                // Remove session from UserSessionManager first
                if (email != null) {
                    UserSessionManager.removeSession(email);
                }
                // No need to call session.invalidate() here since UserSessionManager handles it
                LOGGER.info("Session cleanup completed for email: " + (email != null ? email : "unknown"));
            } catch (IllegalStateException e) {
                LOGGER.info("Session was already invalidated for email: " + (email != null ? email : "unknown"));
            }
        } else {
            LOGGER.info("No session found for logout");
        }

        // Prevent caching
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // Redirect to login.jsp
        LOGGER.info("Redirecting to login.jsp");
        response.sendRedirect("login.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}