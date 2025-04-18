import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class DeviceCheckServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String requestURI = request.getRequestURI();

        // Handle /pass: Set session flag and redirect to main app (login.jsp)
        if (requestURI.endsWith("/pass")) {
            request.getSession().setAttribute("accessAllowed", "true");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Handle /block: Show access denied and stop
        if (requestURI.endsWith("/block")) {
            sendBlockedResponse(response);
            return;
        }

        // Default /setDeviceToken: Serve the check page
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<script type=\"text/javascript\">");
        out.println("var isTouchDevice = ('ontouchstart' in window) || (navigator.maxTouchPoints > 0);");
        out.println("var isSmallScreen = window.screen.width <= 800;");
        out.println("if (isTouchDevice && isSmallScreen) {"); // Block if touch AND small screen
        out.println("  window.location.href = '" + request.getContextPath() + "/block';");
        out.println("} else {");
        out.println("  window.location.href = '" + request.getContextPath() + "/pass';");
        out.println("}");
        out.println("</script>");
        out.println("</body></html>");
    }

    private void sendBlockedResponse(HttpServletResponse response) throws IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<script type=\"text/javascript\">");
        out.println("alert('Access denied in mobile and tablet');");
        out.println("setTimeout(function(){ window.location.href = 'about:blank'; }, 3000);");
        out.println("</script>");
        out.println("</body></html>");
    }
}