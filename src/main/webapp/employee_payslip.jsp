<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, com.itextpdf.text.*, com.itextpdf.text.pdf.*, java.io.*, java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Payslip</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/employee_payslip_styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
</head>
<body>
    <%
        String email = (String) session.getAttribute("email");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String employeeId = "";
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

        class Helper {
            static String numberToWords(int num) {
                String[] units = {"", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"};
                String[] teens = {"Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"};
                String[] tens = {"", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"};
                String[] thousands = {"", "Thousand", "Million", "Billion"};

                if (num == 0) return "Zero";
                String words = "";
                int chunkCount = 0;

                while (num > 0) {
                    int chunk = num % 1000;
                    if (chunk > 0) {
                        String chunkWords = "";
                        if (chunk >= 100) {
                            chunkWords += units[chunk / 100] + " Hundred ";
                            chunk %= 100;
                        }
                        if (chunk >= 20) {
                            chunkWords += tens[chunk / 10] + " ";
                            chunk %= 10;
                        }
                        if (chunk >= 10 && chunk < 20) {
                            chunkWords += teens[chunk - 10] + " ";
                            chunk = 0;
                        }
                        if (chunk > 0) {
                            chunkWords += units[chunk] + " ";
                        }
                        words = chunkWords + thousands[chunkCount] + " " + words;
                    }
                    num /= 1000;
                    chunkCount++;
                }
                return words.trim();
            }
        }

        DecimalFormat df = new DecimalFormat("#,##0.00");

        if ("POST".equalsIgnoreCase(request.getMethod()) && "download".equals(request.getParameter("action"))) {
            String month = request.getParameter("month");
            String yearStr = request.getParameter("year");
            int year = Integer.parseInt(yearStr);

            try {
                String sqlPayslip = "SELECT p.*, c.designation, c.department, c.date_of_joining, c.bank_name, " +
                                   "c.bank_account_no, c.uan_number, c.pf_number, c.company_name, c.company_address " +
                                   "FROM payslips p JOIN ctc_employees c ON p.employee_id = c.employee_id " +
                                   "WHERE p.employee_id = ? AND p.month = ? AND p.year = ?";
                pstmt = conn.prepareStatement(sqlPayslip);
                pstmt.setString(1, employeeId);
                pstmt.setString(2, month);
                pstmt.setInt(3, year);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    Document document = new Document(PageSize.A4, 30, 30, 20, 20);
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    PdfWriter writer = PdfWriter.getInstance(document, baos);
                    document.open();

                    Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, BaseColor.BLACK);
                    Font subHeaderFont = FontFactory.getFont(FontFactory.HELVETICA, 12, BaseColor.BLACK);
                    Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 10, BaseColor.BLACK);
                    Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, BaseColor.BLACK);

                    PdfPTable headerTable = new PdfPTable(2);
                    headerTable.setWidthPercentage(100);
                    headerTable.setWidths(new float[]{3, 1});

                    PdfPCell companyCell = new PdfPCell();
                    companyCell.setBorder(Rectangle.NO_BORDER);
                    companyCell.setPadding(10);
                    Paragraph companyName = new Paragraph(rs.getString("company_name"), headerFont);
                    companyName.setAlignment(Element.ALIGN_LEFT);
                    companyCell.addElement(companyName);
                    Paragraph companyAddress = new Paragraph(rs.getString("company_address"), normalFont);
                    companyAddress.setAlignment(Element.ALIGN_LEFT);
                    companyCell.addElement(companyAddress);
                    headerTable.addCell(companyCell);

                    String logoPath = application.getRealPath("/images/default_profile.jpg");
                    Image logo = Image.getInstance(logoPath);
                    logo.scaleToFit(100, 100);
                    PdfPCell logoCell = new PdfPCell(logo);
                    logoCell.setBorder(Rectangle.NO_BORDER);
                    logoCell.setPadding(10);
                    logoCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
                    logoCell.setVerticalAlignment(Element.ALIGN_TOP);
                    headerTable.addCell(logoCell);
                    document.add(headerTable);

                    Paragraph title = new Paragraph("Payslip for " + month + " " + year, subHeaderFont);
                    title.setAlignment(Element.ALIGN_CENTER);
                    title.setSpacingBefore(20);
                    title.setSpacingAfter(10);
                    document.add(title);

                    PdfContentByte cb = writer.getDirectContent();
                    cb.setLineWidth(0.5f);
                    cb.setColorStroke(BaseColor.GRAY);
                    float pageWidth = PageSize.A4.getWidth();
                    float pageHeight = PageSize.A4.getHeight();
                    cb.moveTo(30, pageHeight - 110);
                    cb.lineTo(pageWidth - 30, pageHeight - 110);
                    cb.stroke();

                    PdfPTable empTable = new PdfPTable(2);
                    empTable.setWidthPercentage(100);
                    empTable.setWidths(new float[]{1, 2});
                    empTable.setSpacingBefore(15);

                    empTable.addCell(new PdfPCell(new Phrase("Employee ID", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(employeeId, normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("Name", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(rs.getString("employee_name"), normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("Designation", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(rs.getString("designation"), normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("Department", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(rs.getString("department"), normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("Date of Joining", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(rs.getString("date_of_joining"), normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("Bank Name", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(rs.getString("bank_name"), normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("Bank A/c No", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(rs.getString("bank_account_no"), normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("UAN Number", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(rs.getString("uan_number"), normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("PF Number", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(rs.getString("pf_number"), normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("Location", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(rs.getString("work_location"), normalFont)));

                    for (PdfPCell cell : empTable.getRows().stream().flatMap(row -> java.util.Arrays.stream(row.getCells())).toArray(PdfPCell[]::new)) {
                        cell.setPadding(5);
                        cell.setBorderWidth(0.5f);
                        cell.setBorderColor(BaseColor.GRAY);
                    }
                    document.add(empTable);

                    PdfPTable attTable = new PdfPTable(2);
                    attTable.setWidthPercentage(50);
                    attTable.setWidths(new float[]{1, 1});
                    attTable.setSpacingBefore(15);
                    attTable.setHorizontalAlignment(Element.ALIGN_LEFT);

                    attTable.addCell(new PdfPCell(new Phrase("Total Working Days", boldFont)));
                    attTable.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("total_working_days")), normalFont)));
                    attTable.addCell(new PdfPCell(new Phrase("LOP Days", boldFont)));
                    attTable.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("lop_days")), normalFont)));
                    attTable.addCell(new PdfPCell(new Phrase("Paid Days", boldFont)));
                    attTable.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("paid_days")), normalFont)));

                    for (PdfPCell cell : attTable.getRows().stream().flatMap(row -> java.util.Arrays.stream(row.getCells())).toArray(PdfPCell[]::new)) {
                        cell.setPadding(5);
                        cell.setBorderWidth(0.5f);
                        cell.setBorderColor(BaseColor.GRAY);
                    }
                    document.add(attTable);

                    PdfPTable salaryTable = new PdfPTable(4);
                    salaryTable.setWidthPercentage(100);
                    salaryTable.setWidths(new float[]{2, 1, 2, 1});
                    salaryTable.setSpacingBefore(15);

                    PdfPCell headerCell = new PdfPCell(new Phrase("Earnings", boldFont));
                    headerCell.setPadding(6);
                    headerCell.setBorderWidth(0.5f);
                    headerCell.setBorderColor(BaseColor.GRAY);
                    salaryTable.addCell(headerCell);
                    headerCell = new PdfPCell(new Phrase("Amount (₹)", boldFont));
                    headerCell.setPadding(6);
                    headerCell.setBorderWidth(0.5f);
                    headerCell.setBorderColor(BaseColor.GRAY);
                    salaryTable.addCell(headerCell);
                    headerCell = new PdfPCell(new Phrase("Deductions", boldFont));
                    headerCell.setPadding(6);
                    headerCell.setBorderWidth(0.5f);
                    headerCell.setBorderColor(BaseColor.GRAY);
                    salaryTable.addCell(headerCell);
                    headerCell = new PdfPCell(new Phrase("Amount (₹)", boldFont));
                    headerCell.setPadding(6);
                    headerCell.setBorderWidth(0.5f);
                    headerCell.setBorderColor(BaseColor.GRAY);
                    salaryTable.addCell(headerCell);

                    salaryTable.addCell(new PdfPCell(new Phrase("Basic Salary", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase(df.format(rs.getDouble("basic_salary")), normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase("EPF", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase(df.format(rs.getDouble("epf")), normalFont)));

                    salaryTable.addCell(new PdfPCell(new Phrase("House Rent Allowance", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase(df.format(rs.getDouble("hra")), normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase("Professional Tax", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase(df.format(rs.getDouble("professional_tax")), normalFont)));

                    salaryTable.addCell(new PdfPCell(new Phrase("Flexible Plan", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase(df.format(rs.getDouble("flexible_plan")), normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase("ESI", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase(df.format(rs.getDouble("esi")), normalFont)));

                    salaryTable.addCell(new PdfPCell(new Phrase("Other Earnings", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase(df.format(rs.getDouble("other_earnings")), normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase("TDS", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase(df.format(rs.getDouble("tds")), normalFont)));

                    salaryTable.addCell(new PdfPCell(new Phrase("", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase("", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase("Other Deductions (LOP)", normalFont)));
                    salaryTable.addCell(new PdfPCell(new Phrase(df.format(rs.getDouble("other_deductions")), normalFont)));

                    PdfPCell grossCell = new PdfPCell(new Phrase("Gross Earnings", boldFont));
                    grossCell.setBorderWidth(0.5f);
                    grossCell.setBorderColor(BaseColor.GRAY);
                    salaryTable.addCell(grossCell);
                    PdfPCell grossAmountCell = new PdfPCell(new Phrase(df.format(rs.getDouble("gross_salary")), boldFont));
                    grossAmountCell.setBorderWidth(0.5f);
                    grossAmountCell.setBorderColor(BaseColor.GRAY);
                    salaryTable.addCell(grossAmountCell);
                    PdfPCell dedCell = new PdfPCell(new Phrase("Total Deductions", boldFont));
                    dedCell.setBorderWidth(0.5f);
                    dedCell.setBorderColor(BaseColor.GRAY);
                    salaryTable.addCell(dedCell);
                    PdfPCell dedAmountCell = new PdfPCell(new Phrase(df.format(rs.getDouble("total_deductions")), boldFont));
                    dedAmountCell.setBorderWidth(0.5f);
                    dedAmountCell.setBorderColor(BaseColor.GRAY);
                    salaryTable.addCell(dedAmountCell);

                    for (PdfPCell cell : salaryTable.getRows().stream().flatMap(row -> java.util.Arrays.stream(row.getCells())).toArray(PdfPCell[]::new)) {
                        cell.setPadding(6);
                    }
                    document.add(salaryTable);

                    PdfPTable netTable = new PdfPTable(2);
                    netTable.setWidthPercentage(100);
                    netTable.setWidths(new float[]{1, 2});
                    netTable.setSpacingBefore(15);

                    PdfPCell netLabel = new PdfPCell(new Phrase("Net Salary", boldFont));
                    netLabel.setPadding(8);
                    netLabel.setBorderWidth(0.5f);
                    netLabel.setBorderColor(BaseColor.GRAY);
                    netTable.addCell(netLabel);
                    PdfPCell netAmount = new PdfPCell(new Phrase("₹ " + df.format(rs.getDouble("net_salary")), boldFont));
                    netAmount.setPadding(8);
                    netAmount.setBorderWidth(0.5f);
                    netAmount.setBorderColor(BaseColor.GRAY);
                    netTable.addCell(netAmount);

                    PdfPCell wordsLabel = new PdfPCell(new Phrase("In Words: " + Helper.numberToWords((int) Math.round(rs.getDouble("net_salary"))) + " Rupees Only", normalFont));
                    wordsLabel.setPadding(8);
                    wordsLabel.setColspan(2);
                    wordsLabel.setBorderWidth(0.5f);
                    wordsLabel.setBorderColor(BaseColor.GRAY);
                    netTable.addCell(wordsLabel);
                    document.add(netTable);

                    Paragraph footer = new Paragraph("Confidential | Generated by " + rs.getString("company_name"), normalFont);
                    footer.setAlignment(Element.ALIGN_CENTER);
                    footer.setSpacingBefore(20);
                    document.add(footer);

                    document.close();

                    response.setContentType("application/pdf");
                    response.setHeader("Content-Disposition", "attachment; filename=Payslip_" + employeeId + "_" + month + "_" + year + ".pdf");
                    response.setContentLength(baos.size());
                    OutputStream os = response.getOutputStream();
                    baos.writeTo(os);
                    os.flush();
                    os.close();
                    return;
                }
            } catch (Exception e) {
                request.setAttribute("error", "Error generating PDF: " + e.getMessage());
            }
        }
    %>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-file-invoice"></i> Employee Payslip</h1>
        </div>
        <div class="filters">
            <form method="get" action="employee_payslip.jsp">
                <div class="filter-group">
                    <label for="month">Month</label>
                    <input type="text" id="month" name="month" placeholder="e.g., January" value="<%= selectedMonth != null ? selectedMonth : "" %>">
                </div>
                <div class="filter-group">
                    <label for="year">Year</label>
                    <input type="number" id="year" name="year" placeholder="e.g., 2025" value="<%= selectedYear != null ? selectedYear : "" %>">
                </div>
                <button type="submit" class="filter-btn"><i class="fas fa-search"></i> Filter</button>
            </form>
        </div>
        <div class="content">
            <h2>Monthly Payslip</h2>
            <div class="payslip-table">
                <table>
                    <thead>
                        <tr>
                            <th>Month</th>
                            <th>Year</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                String sqlPayslip = "SELECT month, year FROM payslips WHERE employee_id = ?";
                                if (selectedMonth != null && !selectedMonth.trim().isEmpty()) {
                                    sqlPayslip += " AND month = ?";
                                }
                                if (selectedYear != null && !selectedYear.trim().isEmpty()) {
                                    sqlPayslip += " AND year = ?";
                                }
                                sqlPayslip += " ORDER BY year DESC, FIELD(month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December') DESC";

                                pstmt = conn.prepareStatement(sqlPayslip);
                                pstmt.setString(1, employeeId);
                                int paramIndex = 2;
                                if (selectedMonth != null && !selectedMonth.trim().isEmpty()) {
                                    pstmt.setString(paramIndex++, selectedMonth.trim());
                                }
                                if (selectedYear != null && !selectedYear.trim().isEmpty()) {
                                    pstmt.setInt(paramIndex, Integer.parseInt(selectedYear.trim()));
                                }
                                rs = pstmt.executeQuery();

                                if (rs.next()) {
                                    do {
                                        String month = rs.getString("month");
                                        int year = rs.getInt("year");
                        %>
                            <tr>
                                <td><%= month %></td>
                                <td><%= year %></td>
                                <td>
                                    <button class="action-btn view-btn" onclick="viewPayslip('<%= employeeId %>', '<%= month %>', <%= year %>)">View</button>
                                    <button class="action-btn download-btn" onclick="downloadPayslip('<%= employeeId %>', '<%= month %>', <%= year %>)">Download</button>
                                </td>
                            </tr>
                        <%
                                    } while (rs.next());
                                } else {
                        %>
                            <tr>
                                <td colspan="3" class="no-data">No payslips available for this period.</td>
                            </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='3'>Error fetching payslips: " + e.getMessage() + "</td></tr>");
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                                if (conn != null) try { conn.close(); } catch (SQLException e) {}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="viewModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>Payslip</h2>
                    <button class="close-btn" onclick="closeModal()">Close</button>
                </div>
                <div class="modal-body" id="modalBody"></div>
            </div>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div id="errorPopup" class="popup error"><%= request.getAttribute("error") %></div>
        <% } %>
    </div>
    <script src="<%= request.getContextPath() %>/js/employee_payslip_scripts.js"></script>
</body>
</html>