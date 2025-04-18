<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.util.Calendar" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attendance Details</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/employee_attendance_styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
</head>
<body>

<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String employeeId = "", employeeName = "";
    boolean hasAttendance = false;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam", "root", "hacker#Tag1");

        String sql1 = "SELECT ID FROM employee_registrations WHERE email = ?";
        pstmt = conn.prepareStatement(sql1);
        pstmt.setString(1, email);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            employeeId = rs.getString("ID");
        } else {
            out.println("<p>No employee record found for this email.</p>");
            return;
        }
        rs.close();
        pstmt.close();
    } catch (Exception e) {
        out.println("<p>Error fetching employee ID: " + e.getMessage() + "</p>");
        return;
    }

    String selectedMonth = request.getParameter("month");
    String selectedYear = request.getParameter("year");
%>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-calendar-check"></i> Attendance Details</h1>
    </div>
    <div class="content">
        <div class="filter-section">
            <form method="get" action="employee_attendance.jsp">
                <div class="filter-group">
                    <label for="month">Month</label>
                    <select id="month" name="month">
                        <option value="">All Months</option>
                        <%
                            String[] months = {"January","February","March","April","May","June","July","August","September","October","November","December"};
                            for (String m : months) {
                        %>
                        <option value="<%= m %>" <%= m.equalsIgnoreCase(selectedMonth) ? "selected" : "" %>><%= m %></option>
                        <% } %>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="year">Year</label>
                    <input type="text" id="year" name="year" placeholder="e.g., 2025" value="<%= selectedYear != null ? selectedYear : "" %>">
                </div>
                <button type="submit"><i class="fas fa-filter"></i> Apply Filter</button>
            </form>
        </div>

<%
    try {
        String sql2 = "SELECT employee_name, attendance, month, year FROM check_old_attendance WHERE employee_id = ?";
        if (selectedMonth != null && !selectedMonth.isEmpty()) {
            sql2 += " AND LOWER(month) = LOWER(?)";
        }
        if (selectedYear != null && !selectedYear.isEmpty()) {
            sql2 += " AND year = ?";
        }

        pstmt = conn.prepareStatement(sql2);
        pstmt.setString(1, employeeId);
        int paramIndex = 2;
        if (selectedMonth != null && !selectedMonth.isEmpty()) {
            pstmt.setString(paramIndex++, selectedMonth);
        }
        if (selectedYear != null && !selectedYear.isEmpty()) {
            pstmt.setInt(paramIndex++, Integer.parseInt(selectedYear));
        }

        rs = pstmt.executeQuery();

        if (rs.next()) {
            hasAttendance = true;
%>
        <div class="attendance-details">
            <table>
                <thead>
                    <tr>
                        <th>Month</th>
                        <th>Year</th>
                        <th>Total Days</th>
                        <th>Present Days</th>
                        <th>Progress</th>
                    </tr>
                </thead>
                <tbody>
<%
            do {
                employeeName = rs.getString("employee_name");
                int presentDays = rs.getInt("attendance");
                String month = rs.getString("month");
                int year = rs.getInt("year");

                int totalDays = getDaysInMonth(month, year);
                if (presentDays > totalDays) {
                    presentDays = totalDays;
                }

                double percentage = (presentDays * 100.0) / totalDays;
                String progress;
                if (percentage > 90) {
                    progress = "Super";
                } else if (percentage >= 70) {
                    progress = "Good";
                } else {
                    progress = "Fair";
                }
%>
                    <tr>
                        <td><%= month %></td>
                        <td><%= year %></td>
                        <td><%= totalDays %></td>
                        <td><%= presentDays %></td>
                        <td>
                            <span class="progress-badge <%= progress.toLowerCase() %>"><%= progress %></span>
                            <div class="progress-bar">
                                <div class="progress-fill <%= progress.toLowerCase() %>" style="width: <%= percentage %>%;"></div>
                            </div>
                        </td>
                    </tr>
<%
            } while (rs.next());
%>
                </tbody>
            </table>
        </div>
<%
        } else {
%>
        <div class="no-attendance-message">
            <i class="fas fa-clock"></i>
            <p>Attendance details will be updated shortly. Please wait for a while.</p>
        </div>
<%
        }
    } catch (Exception e) {
        out.println("<p>Error fetching attendance: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/employee_attendance_scripts.js"></script>
</body>

<%!
    public int getDaysInMonth(String month, int year) {
        if (month == null) return 0;

        int monthIndex = -1;
        month = month.trim().toLowerCase();

        switch (month) {
            case "january": monthIndex = Calendar.JANUARY; break;
            case "february": monthIndex = Calendar.FEBRUARY; break;
            case "march": monthIndex = Calendar.MARCH; break;
            case "april": monthIndex = Calendar.APRIL; break;
            case "may": monthIndex = Calendar.MAY; break;
            case "june": monthIndex = Calendar.JUNE; break;
            case "july": monthIndex = Calendar.JULY; break;
            case "august": monthIndex = Calendar.AUGUST; break;
            case "september": monthIndex = Calendar.SEPTEMBER; break;
            case "october": monthIndex = Calendar.OCTOBER; break;
            case "november": monthIndex = Calendar.NOVEMBER; break;
            case "december": monthIndex = Calendar.DECEMBER; break;
            default: return 0;
        }

        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.YEAR, year);
        cal.set(Calendar.MONTH, monthIndex);
        cal.set(Calendar.DAY_OF_MONTH, 1);
        return cal.getActualMaximum(Calendar.DAY_OF_MONTH);
    }
%>

</html>
