import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;
import org.mindrot.jbcrypt.BCrypt;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@WebServlet("/AdminActionServlet")
public class AdminActionServlet extends HttpServlet {
    private static final String URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USER = "root";
    private static final String PASS = "hacker#Tag1";
    private static final String EMAIL_FROM = "vasanthcyetechnology@gmail.com"; // Replace with your email
    private static final String EMAIL_PASSWORD = "grzgetigommdtbat"; // Replace with your app-specific password
    private ExecutorService emailExecutor;

    @Override
    public void init() throws ServletException {
        emailExecutor = Executors.newFixedThreadPool(5);
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("MySQL Driver not found", e);
        }
    }

    @Override
    public void destroy() {
        emailExecutor.shutdown();
        super.destroy();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DriverManager.getConnection(URL, USER, PASS);

            if ("edit".equals(action)) {
                String adminId = request.getParameter("adminId");
                String newAdminId = request.getParameter("newAdminId");
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String phoneNumber = request.getParameter("phoneNumber");
                String password = request.getParameter("password");
                String role = request.getParameter("role");
                String joiningDate = request.getParameter("joiningDate");
                String department = request.getParameter("department");
                String designation = request.getParameter("designation");

                String fetchSql = "SELECT Admin_ID, Email, Role, Joining_Date FROM admin WHERE Admin_ID = ?";
                ps = conn.prepareStatement(fetchSql);
                ps.setString(1, adminId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    String origAdminId = rs.getString("Admin_ID");
                    String origEmail = rs.getString("Email");
                    String origRole = rs.getString("Role");
                    String origJoiningDate = rs.getString("Joining_Date");

                    boolean fieldsChanged = !newAdminId.equals(origAdminId) || !email.equals(origEmail) ||
                                           !role.equals(origRole) || !joiningDate.equals(origJoiningDate);

                    if (fieldsChanged) {
                        response.sendRedirect("admin_login_history.jsp?warning=nonEditableFieldsChanged");
                        return;
                    }
                }

                String sql = "UPDATE admin SET Name = ?, Phone_Number = ?, Department = ?, Designation = ?" +
                             (password != null && !password.isEmpty() ? ", Password = ?" : "") +
                             " WHERE Admin_ID = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, phoneNumber);
                ps.setString(3, department);
                ps.setString(4, designation);
                if (password != null && !password.isEmpty()) {
                    String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
                    ps.setString(5, hashedPassword);
                    ps.setString(6, adminId);
                } else {
                    ps.setString(5, adminId);
                }
                ps.executeUpdate();
                response.sendRedirect("admin_login_history.jsp");

            } else if ("delete".equals(action)) {
                String adminId = request.getParameter("adminId");
                String deleteHistorySql = "DELETE FROM admin_login_history WHERE Admin_ID = ?";
                ps = conn.prepareStatement(deleteHistorySql);
                ps.setString(1, adminId);
                ps.executeUpdate();

                String deleteAdminSql = "DELETE FROM admin WHERE Admin_ID = ?";
                ps = conn.prepareStatement(deleteAdminSql);
                ps.setString(1, adminId);
                ps.executeUpdate();
                response.sendRedirect("admin_login_history.jsp");

            } else if ("sendOtp".equals(action)) {
                response.setContentType("application/json");
                JSONObject jsonResponse = new JSONObject();

                StringBuilder sb = new StringBuilder();
                try (BufferedReader reader = request.getReader()) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                String email = new JSONObject(sb.toString()).getString("email");

                if (!email.endsWith("@gmail.com")) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Only Gmail addresses are allowed");
                    response.getWriter().write(jsonResponse.toString());
                    return;
                }

                String checkQuery = "SELECT COUNT(*) FROM admin WHERE Email = ?";
                ps = conn.prepareStatement(checkQuery);
                ps.setString(1, email);
                rs = ps.executeQuery();
                rs.next();
                if (rs.getInt(1) > 0) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Email already registered");
                } else {
                    String otp = String.format("%06d", new Random().nextInt(999999));
                    HttpSession session = request.getSession();
                    session.setAttribute("otp_" + email, otp);
                    session.setAttribute("otp_expiry_" + email, System.currentTimeMillis() + 5 * 60 * 1000); // 5 minutes

                    emailExecutor.submit(() -> {
                        try {
                            sendEmail(email, "Cye Technology Pvt Ltd - OTP Verification",
                                    "Dear Admin,\n\n" +
                                            "We have received a request to verify your email for registration with Cye Technology Pvt Ltd. Please use the following One-Time Password (OTP) to complete the process:\n\n" +
                                            "OTP: " + otp + "\n\n" +
                                            "This OTP is valid for 5 minutes. For security reasons, do not share this OTP with anyone.\n\n" +
                                            "Best Regards,\n" +
                                            "Cye Technology Pvt Ltd Team\n" +
                                            "www.cyetechnology.in");
                        } catch (MessagingException e) {
                            e.printStackTrace();
                        }
                    });

                    jsonResponse.put("success", true);
                }
                response.getWriter().write(jsonResponse.toString());

            } else if ("verifyOtp".equals(action)) {
                response.setContentType("application/json");
                JSONObject jsonResponse = new JSONObject();

                StringBuilder sb = new StringBuilder();
                try (BufferedReader reader = request.getReader()) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                JSONObject jsonRequest = new JSONObject(sb.toString());
                String email = jsonRequest.getString("email");
                String otp = jsonRequest.getString("otp");

                HttpSession session = request.getSession();
                String storedOtp = (String) session.getAttribute("otp_" + email);
                Long expiry = (Long) session.getAttribute("otp_expiry_" + email);

                if (storedOtp == null || expiry == null) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "No OTP sent or session expired");
                } else if (System.currentTimeMillis() > expiry) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "OTP has expired");
                    session.removeAttribute("otp_" + email);
                    session.removeAttribute("otp_expiry_" + email);
                } else if (storedOtp.equals(otp)) {
                    session.setAttribute("email_verified_" + email, true);
                    session.removeAttribute("otp_" + email);
                    session.removeAttribute("otp_expiry_" + email);
                    jsonResponse.put("success", true);
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Invalid OTP");
                }
                response.getWriter().write(jsonResponse.toString());

            } else if ("add".equals(action)) {
                String adminId = request.getParameter("adminId");
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String phoneNumber = request.getParameter("phoneNumber");
                String password = request.getParameter("password");
                String role = request.getParameter("role");
                String joiningDate = request.getParameter("joiningDate");
                String department = request.getParameter("department");
                String designation = request.getParameter("designation");

                HttpSession session = request.getSession();
                if (!Boolean.TRUE.equals(session.getAttribute("email_verified_" + email))) {
                    response.sendRedirect("admin_login_history.jsp?error=Email not verified");
                    return;
                }

                String checkQuery = "SELECT COUNT(*) FROM admin WHERE Admin_ID = ? OR Email = ?";
                ps = conn.prepareStatement(checkQuery);
                ps.setString(1, adminId);
                ps.setString(2, email);
                rs = ps.executeQuery();
                rs.next();
                if (rs.getInt(1) > 0) {
                    response.sendRedirect("admin_login_history.jsp?error=Admin ID or Email already exists");
                    return;
                }

                String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
                String insertSql = "INSERT INTO admin (Admin_ID, Name, Email, Phone_Number, Password, Role, Joining_Date, Department, Designation, Account_Created) " +
                                   "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE())";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, adminId);
                ps.setString(2, name);
                ps.setString(3, email);
                ps.setString(4, phoneNumber);
                ps.setString(5, hashedPassword);
                ps.setString(6, role);
                ps.setString(7, joiningDate);
                ps.setString(8, department);
                ps.setString(9, designation);
                int rowsAffected = ps.executeUpdate();

                if (rowsAffected > 0) {
                    session.removeAttribute("email_verified_" + email);
                    response.sendRedirect("admin_login_history.jsp?success=true");
                } else {
                    response.sendRedirect("admin_login_history.jsp?error=Failed to add admin to database");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_login_history.jsp?error=Server error: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void sendEmail(String to, String subject, String body) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
                return new javax.mail.PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(EMAIL_FROM));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        message.setText(body);
        Transport.send(message);
    }
}