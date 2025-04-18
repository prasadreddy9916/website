import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/AdminLogout")
public class AdminLogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AdminLogoutServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get the session, if it exists
        HttpSession session = request.getSession(false);
        if (session != null) {
            String email = (String) session.getAttribute("email");
            LOGGER.info("Logging out admin with email: " + (email != null ? email : "unknown"));
            try {
                session.invalidate();
                LOGGER.info("Session invalidated for admin");
            } catch (IllegalStateException e) {
                LOGGER.warning("Session was already invalidated: " + e.getMessage());
            }
        } else {
            LOGGER.info("No session found for logout request");
        }

        // Prevent caching to ensure fresh login page
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // Redirect to adminlogin.jsp
        response.sendRedirect(request.getContextPath() + "/login_home.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response); // Handle GET requests the same way
    }
}