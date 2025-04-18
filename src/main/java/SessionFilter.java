import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.logging.Logger;

@WebFilter("/*")
public class SessionFilter implements Filter {
    private static final Logger LOGGER = Logger.getLogger(SessionFilter.class.getName());

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        // Allow access to login-related pages and servlets without session checks
        if (requestURI.equals(contextPath + "/login.jsp") ||
                requestURI.equals(contextPath + "/login") ||
                requestURI.equals(contextPath + "/adminlogin.jsp") ||
                requestURI.equals(contextPath + "/login_home.jsp") ||
                requestURI.equals(contextPath + "/adminLogin") ||
                requestURI.equals(contextPath + "/forgotpassword.jsp") ||
                requestURI.equals(contextPath + "/ForgotPasswordServlet")) {
            LOGGER.info("Allowing access to public page: " + requestURI);
            chain.doFilter(request, response);
            return;
        }

        // Set no-cache headers for all responses
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        String email = null;
        if (session != null) {
            email = (String) session.getAttribute("email");
        }

        if (email != null && session != null) {
            HttpSession activeSession = UserSessionManager.getSession(email);
            if (activeSession == null || !session.getId().equals(activeSession.getId())) {
                LOGGER.info("Session mismatch for email: " + email + "; allowing new login attempt");
                chain.doFilter(request, response);
                return;
            }
        }

        // If no valid session, redirect to appropriate login page
        if (email == null && session == null) {
            if (requestURI.contains("admin")) {
                LOGGER.info("No session found, redirecting to adminlogin.jsp");
                httpResponse.sendRedirect(contextPath + "/login_home.jsp");
            } else {
                LOGGER.info("No session found, redirecting to login.jsp");
                httpResponse.sendRedirect(contextPath + "/login_home.jsp");
            }
            return;
        }

        LOGGER.info("Session valid for email: " + email + ", proceeding with request");
        chain.doFilter(request, response);
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("Initializing SessionFilter, cleaning up invalid sessions");
        UserSessionManager.cleanupInvalidSessions();
    }

    @Override
    public void destroy() {
        LOGGER.info("Destroying SessionFilter");
    }
}