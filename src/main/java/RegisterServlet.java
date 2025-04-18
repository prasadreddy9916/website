import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Properties;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.json.JSONObject;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";
    private static final String EMAIL_FROM = "vasanthcyetechnology@gmail.com";
    private static final String EMAIL_PASSWORD = "grzgetigommdtbat"; // Replace with your App Password
    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());
    private static final int OTP_EXPIRY_MINUTES = 5;
    private ExecutorService emailExecutor; // Thread pool for email sending

    @Override
    public void init() throws ServletException {
        LOGGER.info("RegisterServlet initialized");
        emailExecutor = Executors.newFixedThreadPool(5); // Initialize thread pool with 5 threads
    }

    @Override
    public void destroy() {
        emailExecutor.shutdown(); // Shutdown thread pool on servlet destroy
        super.destroy();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        LOGGER.info("Received request with action: " + action);

        if ("sendOtp".equals(action)) {
            handleSendOtp(request, response);
        } else if ("verifyOtp".equals(action)) {
            handleVerifyOtp(request, response);
        } else if ("fetchEmployee".equals(action)) {
            handleFetchEmployee(request, response);
        } else {
            handleRegistration(request, response);
        }
    }

    private void handleSendOtp(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        JSONObject jsonResponse = new JSONObject();

        StringBuilder sb = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error reading request body", e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error reading request: " + e.getMessage());
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        String requestBody = sb.toString();
        String email;
        try {
            email = new JSONObject(requestBody).getString("email");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Invalid JSON in request body: " + requestBody, e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Invalid request format");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        LOGGER.info("Handling sendOtp for email: " + email);

        if (email == null || email.isEmpty() || !email.endsWith("@gmail.com")) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Invalid Gmail address");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        String otp = String.format("%06d", new Random().nextInt(999999));
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String checkEmailQuery = "SELECT COUNT(*) FROM employee_registrations WHERE email = ?";
            stmt = conn.prepareStatement(checkEmailQuery);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Email already registered");
            } else {
                String otpQuery = "INSERT INTO otp_table (email, otp, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL ? MINUTE)) " +
                                 "ON DUPLICATE KEY UPDATE otp = ?, expires_at = DATE_ADD(NOW(), INTERVAL ? MINUTE), is_verified = FALSE";
                stmt = conn.prepareStatement(otpQuery);
                stmt.setString(1, email);
                stmt.setString(2, otp);
                stmt.setInt(3, OTP_EXPIRY_MINUTES);
                stmt.setString(4, otp);
                stmt.setInt(5, OTP_EXPIRY_MINUTES);
                stmt.executeUpdate();

                // Offload email sending to a separate thread
                emailExecutor.submit(() -> {
                    try {
                        sendEmail(email, "Cye Technology Pvt Ltd - OTP Verification", 
                            "Dear Employee,\n\n" +
                            "We have received a request to verify your email for registration with Cye Technology Pvt Ltd. Please use the following One-Time Password (OTP) to complete the process:\n\n" +
                            "OTP: " + otp + "\n\n" +
                            "This OTP is valid for " + OTP_EXPIRY_MINUTES + " minutes. For security reasons, do not share this OTP with anyone.\n\n" +
                            "Best Regards,\n" +
                            "Cye Technology Pvt Ltd Team\n" +
                            "www.cyetechnology.in");
                    } catch (MessagingException e) {
                        LOGGER.log(Level.SEVERE, "Error sending email in thread for: " + email, e);
                    }
                });

                jsonResponse.put("success", true);
                LOGGER.info("OTP queued for sending to: " + email);
            }
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL Driver not found", e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Database driver error: " + e.getMessage());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "SQL error in sendOtp for email: " + email, e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Database error: " + e.getMessage());
        } finally {
            closeResources(rs, stmt, conn);
            response.getWriter().write(jsonResponse.toString());
        }
    }

    private void handleVerifyOtp(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        JSONObject jsonResponse = new JSONObject();

        StringBuilder sb = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error reading request body", e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error reading request: " + e.getMessage());
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        JSONObject jsonRequest = new JSONObject(sb.toString());
        String email = jsonRequest.optString("email");
        String otp = jsonRequest.optString("otp");
        LOGGER.info("Handling verifyOtp for email: " + email);

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String query = "SELECT otp, expires_at FROM otp_table WHERE email = ? AND otp = ? AND is_verified = FALSE";
            stmt = conn.prepareStatement(query);
            stmt.setString(1, email);
            stmt.setString(2, otp);
            rs = stmt.executeQuery();

            if (rs.next()) {
                Timestamp expiresAt = rs.getTimestamp("expires_at");
                if (expiresAt.after(new Timestamp(System.currentTimeMillis()))) {
                    String updateQuery = "UPDATE otp_table SET is_verified = TRUE WHERE email = ? AND otp = ?";
                    stmt = conn.prepareStatement(updateQuery);
                    stmt.setString(1, email);
                    stmt.setString(2, otp);
                    stmt.executeUpdate();
                    jsonResponse.put("success", true);
                    LOGGER.info("OTP verified successfully for email: " + email);
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "OTP has expired");
                }
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Invalid OTP");
            }
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL Driver not found", e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Database driver error: " + e.getMessage());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "SQL error in verifyOtp for email: " + email, e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error verifying OTP: " + e.getMessage());
        } finally {
            closeResources(rs, stmt, conn);
            response.getWriter().write(jsonResponse.toString());
        }
    }

    private void handleFetchEmployee(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        JSONObject jsonResponse = new JSONObject();

        String employeeId = request.getParameter("employeeId");
        if (employeeId == null || employeeId.isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Employee ID is required");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        if (!employeeId.startsWith("CT-")) {
            employeeId = "CT-" + employeeId;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String query = "SELECT Name, Email, Year, Batch, Designation, Department FROM employee_ids WHERE employee_id = ?";
            stmt = conn.prepareStatement(query);
            stmt.setString(1, employeeId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                jsonResponse.put("success", true);
                jsonResponse.put("name", rs.getString("Name"));
                jsonResponse.put("email", rs.getString("Email") != null ? rs.getString("Email") : "");
                jsonResponse.put("year", rs.getString("Year"));
                jsonResponse.put("batch", rs.getString("Batch"));
                jsonResponse.put("designation", rs.getString("Designation"));
                jsonResponse.put("department", rs.getString("Department"));
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Employee ID not found");
            }
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL Driver not found", e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Database driver error: " + e.getMessage());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "SQL error fetching employee: " + employeeId, e);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Database error: " + e.getMessage());
        } finally {
            closeResources(rs, stmt, conn);
            response.getWriter().write(jsonResponse.toString());
        }
    }

    private void handleRegistration(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String aadhar = request.getParameter("aadhar");
        String mobile = request.getParameter("mobile");
        String pan = request.getParameter("pan");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String motherName = request.getParameter("motherName");
        String fatherName = request.getParameter("fatherName");
        String gender = request.getParameter("gender");
        String maritalStatus = request.getParameter("maritalStatus");
        String password = request.getParameter("password");
        String batch = request.getParameter("batch");
        String batchYear = request.getParameter("batchYear");
        String exam = request.getParameter("exam");
        String designation = request.getParameter("designation");
        String department = request.getParameter("department");

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        if (batchYear == null || batchYear.trim().isEmpty()) {
            if (batch != null && batch.matches("Batch \\d{4}-[A-Z]")) {
                batchYear = batch.split(" ")[1].split("-")[0];
            } else {
                batchYear = "";
            }
        }

        Connection conn = null;
        PreparedStatement checkEmployeeStmt = null;
        PreparedStatement checkDuplicateStmt = null;
        PreparedStatement checkOtpStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String checkEmployeeQuery = "SELECT COUNT(*) FROM employee_ids WHERE employee_id = ?";
            checkEmployeeStmt = conn.prepareStatement(checkEmployeeQuery);
            checkEmployeeStmt.setString(1, id);
            rs = checkEmployeeStmt.executeQuery();
            rs.next();
            if (rs.getInt(1) == 0) {
                request.setAttribute("errorMessage", "Employee ID not registered in company");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            String checkDuplicateQuery = "SELECT COUNT(*) FROM employee_registrations WHERE ID = ? OR email = ? OR aadhar = ? OR mobile = ? OR pan = ?";
            checkDuplicateStmt = conn.prepareStatement(checkDuplicateQuery);
            checkDuplicateStmt.setString(1, id);
            checkDuplicateStmt.setString(2, email);
            checkDuplicateStmt.setString(3, aadhar);
            checkDuplicateStmt.setString(4, mobile);
            checkDuplicateStmt.setString(5, pan);
            rs = checkDuplicateStmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                request.setAttribute("errorMessage", "Employee ID, Email, Aadhar, Mobile, or PAN already registered!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            String checkOtpQuery = "SELECT COUNT(*) FROM otp_table WHERE email = ? AND is_verified = TRUE";
            checkOtpStmt = conn.prepareStatement(checkOtpQuery);
            checkOtpStmt.setString(1, email);
            rs = checkOtpStmt.executeQuery();
            rs.next();
            if (rs.getInt(1) == 0) {
                request.setAttribute("errorMessage", "Email not verified!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            String insertQuery = "INSERT INTO employee_registrations (ID, Name, Email, aadhar, mobile, pan, date_of_birth, mother_name, father_name, gender, marital_status, Password, Batch, batch_year, Exam, Designation, Department) " +
                                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            insertStmt = conn.prepareStatement(insertQuery);
            insertStmt.setString(1, id);
            insertStmt.setString(2, name);
            insertStmt.setString(3, email);
            insertStmt.setString(4, aadhar);
            insertStmt.setString(5, mobile);
            insertStmt.setString(6, pan);
            insertStmt.setString(7, dateOfBirth);
            insertStmt.setString(8, motherName);
            insertStmt.setString(9, fatherName);
            insertStmt.setString(10, gender);
            insertStmt.setString(11, maritalStatus);
            insertStmt.setString(12, hashedPassword);
            insertStmt.setString(13, batch);
            insertStmt.setString(14, batchYear);
            insertStmt.setString(15, exam);
            insertStmt.setString(16, designation);
            insertStmt.setString(17, department);

            int rowsAffected = insertStmt.executeUpdate();
            if (rowsAffected > 0) {
                String deleteOtpQuery = "DELETE FROM otp_table WHERE email = ?";
                insertStmt = conn.prepareStatement(deleteOtpQuery);
                insertStmt.setString(1, email);
                insertStmt.executeUpdate();

                request.setAttribute("successMessage", "Registered successfully");
                LOGGER.info("Registration successful for ID: " + id);
                request.getRequestDispatcher("register.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Registration failed!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL Driver not found", e);
            request.setAttribute("errorMessage", "Database driver error: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in registration for ID: " + id, e);
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } finally {
            closeResources(rs, checkEmployeeStmt, conn);
            closeResources(null, checkDuplicateStmt, null);
            closeResources(null, checkOtpStmt, null);
            closeResources(null, insertStmt, null);
        }
    }

    private void sendEmail(String to, String subject, String body) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.debug", "false");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(EMAIL_FROM));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        message.setText(body);
        Transport.send(message);
        LOGGER.info("Email sent successfully to: " + to);
    }

    private void closeResources(ResultSet rs, PreparedStatement stmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing database resources", e);
        }
    }
}