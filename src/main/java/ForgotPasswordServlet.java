import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Logger;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";
    private static final Logger LOGGER = Logger.getLogger(ForgotPasswordServlet.class.getName());
    private static final long OTP_VALIDITY_DURATION = 300_000; // 5 minutes in milliseconds
    private static final ExecutorService EMAIL_EXECUTOR = Executors.newFixedThreadPool(2); // Thread pool for email sending
    private static final String COMPANY_NAME = "CYE Technology Private Limited";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        response.setContentType("text/plain");

        if ("sendOtp".equals(action)) {
            String email = request.getParameter("email");
            if (email == null || email.trim().isEmpty()) {
                response.getWriter().write("Email is required");
                return;
            }

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                    // Fetch employee name along with checking existence
                    PreparedStatement ps = conn.prepareStatement(
                        "SELECT Name FROM employee_registrations WHERE email = ?");
                    ps.setString(1, email);
                    ResultSet rs = ps.executeQuery();

                    if (rs.next()) {
                        String employeeName = rs.getString("Name");
                        String otp = String.format("%06d", new Random().nextInt(999999));
                        long currentTime = System.currentTimeMillis();
                        session.setAttribute("otp", otp);
                        session.setAttribute("email", email);
                        session.setAttribute("otpTimestamp", currentTime);
                        session.setMaxInactiveInterval(600);

                        // Send email with employee name in a separate thread
                        EMAIL_EXECUTOR.submit(() -> {
                            try {
                                sendOtpEmail(email, otp, employeeName);
                            } catch (MessagingException e) {
                                LOGGER.severe("Email sending failed: " + e.getMessage());
                            }
                        });

                        response.getWriter().write("success");
                    } else {
                        response.getWriter().write("Email not registered");
                    }
                }
            } catch (Exception e) {
                LOGGER.severe("Error: " + e.getMessage());
                response.getWriter().write("An error occurred");
            }

        } else if ("resetPassword".equals(action)) {
            String email = request.getParameter("email");
            String enteredOtp = request.getParameter("otp");
            String storedOtp = (String) session.getAttribute("otp");
            Long otpTimestamp = (Long) session.getAttribute("otpTimestamp");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (storedOtp == null || email == null || otpTimestamp == null) {
                response.getWriter().write("Session expired, please start again");
                return;
            }

            long currentTime = System.currentTimeMillis();
            if (currentTime - otpTimestamp > OTP_VALIDITY_DURATION) {
                response.getWriter().write("OTP expired");
                return;
            }

            if (!enteredOtp.equals(storedOtp)) {
                response.getWriter().write("Invalid OTP");
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                response.getWriter().write("Passwords do not match");
                return;
            }

            String passwordPattern = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{6,15}$";
            if (!newPassword.matches(passwordPattern)) {
                response.getWriter().write("Password must be 6-15 characters, with at least 1 uppercase, 1 number, and 1 symbol");
                return;
            }

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                    String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE employee_registrations SET Password = ? WHERE email = ?");
                    ps.setString(1, hashedPassword);
                    ps.setString(2, email);
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        session.invalidate();
                        response.getWriter().write("success");
                    } else {
                        response.getWriter().write("Failed to update password");
                    }
                }
            } catch (Exception e) {
                LOGGER.severe("Error: " + e.getMessage());
                response.getWriter().write("Database error");
            }
        }
    }

    private void sendOtpEmail(String toEmail, String otp, String employeeName) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        final String username = "vasanthcyetechnology@gmail.com"; // Update to your email
        final String password = "grzgetigommdtbat"; // Update to your App Password

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(username));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("Password Reset OTP - " + COMPANY_NAME);

        // Structured email body with employee name fetched from DB
        String emailBody = "Dear " + employeeName + ",\n\n" +
                          "Company Name: " + COMPANY_NAME + "\n\n" +
                          "Reset your password by entering this OTP:\n" +
                          "Your OTP: " + otp + "\n\n" +
                          "This OTP is valid for 5 minutes. Please do not share it with anyone.\n\n" +
                          "Best Regards,\n" +
                          "CYETechnology";

        message.setText(emailBody);
        Transport.send(message);
    }

    @Override
    public void destroy() {
        EMAIL_EXECUTOR.shutdown();
    }
}