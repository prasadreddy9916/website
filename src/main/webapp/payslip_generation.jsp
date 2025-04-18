<%-- payslip_generation.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, com.itextpdf.text.*, com.itextpdf.text.pdf.*, java.io.*, java.text.DecimalFormat" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    String URL = "jdbc:mysql://localhost:3306/exam?useSSL=false&serverTimezone=Asia/Kolkata";
    String USERNAME = "root";
    String PASSWORD = "hacker#Tag1";

    class Helper {
        static int getTotalDays(String month, int year) {
            boolean isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
            switch (month) {
                case "February": return isLeapYear ? 29 : 28;
                case "April": case "June": case "September": case "November": return 30;
                default: return 31;
            }
        }

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

    // Handle payslip generation
    if ("POST".equalsIgnoreCase(request.getMethod()) && "generate".equals(request.getParameter("action"))) {
        String empId = request.getParameter("empId");
        String month = request.getParameter("month");
        int year = Integer.parseInt(request.getParameter("year"));
        String empName = request.getParameter("empName");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD)) {
                PreparedStatement attStmt = conn.prepareStatement(
                    "SELECT attendance FROM check_old_attendance WHERE employee_id = ? AND month = ? AND year = ?");
                attStmt.setString(1, empId);
                attStmt.setString(2, month);
                attStmt.setInt(3, year);
                ResultSet attRs = attStmt.executeQuery();

                if (attRs.next()) {
                    int attendance = attRs.getInt("attendance");
                    int totalDays = Helper.getTotalDays(month, year);
                    int lopDays = totalDays - attendance;
                    int paidDays = attendance;

                    PreparedStatement empStmt = conn.prepareStatement(
                        "SELECT * FROM ctc_employees WHERE employee_id = ?");
                    empStmt.setString(1, empId);
                    ResultSet empRs = empStmt.executeQuery();

                    if (empRs.next()) {
                        double basicSalary = empRs.getDouble("basic_salary");
                        double hra = empRs.getDouble("hra");
                        double flexiblePlan = empRs.getDouble("special_allowance");
                        double otherEarnings = empRs.getDouble("conveyance_allowance") + empRs.getDouble("medical_allowance") + empRs.getDouble("bonus");
                        double grossSalary = basicSalary + hra + flexiblePlan + otherEarnings;

                        double epf = empRs.getDouble("pf");
                        double professionalTax = empRs.getDouble("professional_tax");
                        double esi = empRs.getDouble("esi");
                        double tds = empRs.getDouble("tds");
                        double otherDeductions = (grossSalary / totalDays) * lopDays; // LOP deduction
                        double totalDeductions = epf + professionalTax + esi + tds + otherDeductions;
                        double netSalary = grossSalary - totalDeductions;

                        PreparedStatement insertStmt = conn.prepareStatement(
                            "INSERT INTO payslips (employee_id, employee_name, month, year, total_working_days, lop_days, paid_days, " +
                            "basic_salary, hra, flexible_plan, other_earnings, gross_salary, epf, professional_tax, esi, tds, other_deductions, total_deductions, net_salary, work_location) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                        insertStmt.setString(1, empId);
                        insertStmt.setString(2, empName);
                        insertStmt.setString(3, month);
                        insertStmt.setInt(4, year);
                        insertStmt.setInt(5, totalDays);
                        insertStmt.setInt(6, lopDays);
                        insertStmt.setInt(7, paidDays);
                        insertStmt.setDouble(8, basicSalary);
                        insertStmt.setDouble(9, hra);
                        insertStmt.setDouble(10, flexiblePlan);
                        insertStmt.setDouble(11, otherEarnings);
                        insertStmt.setDouble(12, grossSalary);
                        insertStmt.setDouble(13, epf);
                        insertStmt.setDouble(14, professionalTax);
                        insertStmt.setDouble(15, esi);
                        insertStmt.setDouble(16, tds);
                        insertStmt.setDouble(17, otherDeductions);
                        insertStmt.setDouble(18, totalDeductions);
                        insertStmt.setDouble(19, netSalary);
                        insertStmt.setString(20, empRs.getString("work_location"));
                        insertStmt.executeUpdate();

                        request.setAttribute("message", "Payslip generated successfully for " + empName + " for " + month + "/" + year);
                    }
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error generating payslip: " + e.getMessage());
        }
    }

    // Handle PDF download
    if ("POST".equalsIgnoreCase(request.getMethod()) && "download".equals(request.getParameter("action"))) {
        String empId = request.getParameter("empId");
        String empName = request.getParameter("empName");
        String month = request.getParameter("month");
        int year = Integer.parseInt(request.getParameter("year"));

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD)) {
                PreparedStatement pstmt = conn.prepareStatement(
                    "SELECT p.*, c.designation, c.department, c.date_of_joining, c.bank_name, c.bank_account_no, c.uan_number, c.company_name, c.company_address, c.work_location, c.pf_number " +
                    "FROM payslips p JOIN ctc_employees c ON p.employee_id = c.employee_id " +
                    "WHERE p.employee_id = ? AND p.month = ? AND p.year = ?");
                pstmt.setString(1, empId);
                pstmt.setString(2, month);
                pstmt.setInt(3, year);
                ResultSet rs = pstmt.executeQuery();

                if (rs.next()) {
                    // Create PDF
                    Document document = new Document(PageSize.A4, 30, 30, 20, 20);
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    PdfWriter writer = PdfWriter.getInstance(document, baos);
                    document.open();

                    // Fonts
                    Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, BaseColor.BLACK);
                    Font subHeaderFont = FontFactory.getFont(FontFactory.HELVETICA, 12, BaseColor.BLACK);
                    Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 10, BaseColor.BLACK);
                    Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, BaseColor.BLACK);

                    // Header Table (Company Details and Logo)
                    PdfPTable headerTable = new PdfPTable(2);
                    headerTable.setWidthPercentage(100);
                    headerTable.setWidths(new float[]{3, 1});

                    PdfPCell companyCell = new PdfPCell();
                    companyCell.setBorder(Rectangle.NO_BORDER);
                    companyCell.setPadding(10);
                    Paragraph companyName = new Paragraph("CYE TECHNOLOGY PVT LTD", headerFont);
                    companyName.setAlignment(Element.ALIGN_LEFT);
                    companyCell.addElement(companyName);
                    Paragraph companyAddress = new Paragraph("3rd Floor, R3 Building adjacent to LB Nagar Metro Station Gate -C, Hyderabad, Telangana 500074", normalFont);
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

                    // Payslip Title
                    Paragraph title = new Paragraph("Payslip for " + month + " " + year, subHeaderFont);
                    title.setAlignment(Element.ALIGN_CENTER);
                    title.setSpacingBefore(20);
                    title.setSpacingAfter(10);
                    document.add(title);

                    // Horizontal Line
                    PdfContentByte cb = writer.getDirectContent();
                    cb.setLineWidth(0.5f);
                    cb.setColorStroke(BaseColor.GRAY);
                    float pageWidth = PageSize.A4.getWidth();
                    float pageHeight = PageSize.A4.getHeight();
                    cb.moveTo(30, pageHeight - 110);
                    cb.lineTo(pageWidth - 30, pageHeight - 110);
                    cb.stroke();

                    // Employee Details
                    PdfPTable empTable = new PdfPTable(2);
                    empTable.setWidthPercentage(100);
                    empTable.setWidths(new float[]{1, 2});
                    empTable.setSpacingBefore(15);

                    empTable.addCell(new PdfPCell(new Phrase("Employee ID", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(empId, normalFont)));
                    empTable.addCell(new PdfPCell(new Phrase("Name", boldFont)));
                    empTable.addCell(new PdfPCell(new Phrase(empName, normalFont)));
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

                    // Attendance Details
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

                    // Earnings and Deductions Table
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

                    // Net Salary
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

                    // Footer
                    Paragraph footer = new Paragraph("Confidential | Generated by CYE TECHNOLOGY PVT LTD", normalFont);
                    footer.setAlignment(Element.ALIGN_CENTER);
                    footer.setSpacingBefore(20);
                    document.add(footer);

                    document.close();

                    // Send PDF to client
                    response.setContentType("application/pdf");
                    response.setHeader("Content-Disposition", "attachment; filename=Payslip_" + empId + "_" + month + "_" + year + ".pdf");
                    response.setContentLength(baos.size());
                    OutputStream os = response.getOutputStream();
                    baos.writeTo(os);
                    os.flush();
                    os.close();
                    return;
                } else {
                    request.setAttribute("error", "Payslip not found for " + empId + " for " + month + "/" + year);
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error generating PDF: " + e.getMessage());
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payslip Generation</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/payslip_styles.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Generate Pay Slips</h1>
            <button class="generate-btn" onclick="openGenerateModal()">Generate</button>
        </div>
        <div class="filters">
            <div class="filter-group">
                <label>Employee ID</label>
                <input type="text" id="filterEmpId" placeholder="Enter Employee ID">
            </div>
            <div class="filter-group">
                <label>Name</label>
                <input type="text" id="filterName" placeholder="Enter Name">
            </div>
            <div class="filter-group">
                <label>Month</label>
                <select id="filterMonth">
                    <option value="">All Months</option>
                    <option value="January">January</option>
                    <option value="February">February</option>
                    <option value="March">March</option>
                    <option value="April">April</option>
                    <option value="May">May</option>
                    <option value="June">June</option>
                    <option value="July">July</option>
                    <option value="August">August</option>
                    <option value="September">September</option>
                    <option value="October">October</option>
                    <option value="November">November</option>
                    <option value="December">December</option>
                </select>
            </div>
            <div class="filter-group">
                <label>Year</label>
                <input type="number" id="filterYear" placeholder="Enter Year">
            </div>
        </div>
        <div class="content">
            <h2>Employee Payslips Monthly PDFs</h2>
            <div class="table-container scrollable">
                <table>
                    <thead>
                        <tr>
                            <th>Employee ID</th>
                            <th>Name</th>
                            <th>Month/Year</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="payslipTable">
                    <%
                        StringBuilder jsonBuilder = new StringBuilder();
                        jsonBuilder.append("{");
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD)) {
                                PreparedStatement pstmt = conn.prepareStatement(
                                    "SELECT p.*, c.designation, c.department, c.date_of_joining, c.bank_name, c.bank_account_no, c.uan_number, c.company_name, c.company_address, c.work_location, c.pf_number " +
                                    "FROM payslips p JOIN ctc_employees c ON p.employee_id = c.employee_id " +
                                    "ORDER BY p.year DESC, FIELD(p.month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December') DESC");
                                ResultSet rs = pstmt.executeQuery();
                                while (rs.next()) {
                                    String empId = rs.getString("employee_id");
                                    String empName = rs.getString("employee_name");
                                    String month = rs.getString("month");
                                    int year = rs.getInt("year");
                    %>
                        <tr>
                            <td><%= empId %></td>
                            <td><%= empName %></td>
                            <td><%= month + "/" + year %></td>
                            <td>
                                <button class="view-btn" onclick="openViewModal('<%= empId %>', '<%= empName %>', '<%= month %>', <%= year %>)">View</button>
                                <button class="download-btn" onclick="downloadPayslip('<%= empId %>', '<%= empName %>', '<%= month %>', <%= year %>)">Download PDF</button>
                            </td>
                        </tr>
                    <%
                                    jsonBuilder.append(String.format("\"%s-%s-%d\": {", empId, month, year));
                                    jsonBuilder.append(String.format("\"employee_id\": \"%s\",", empId));
                                    jsonBuilder.append(String.format("\"employee_name\": \"%s\",", empName));
                                    jsonBuilder.append(String.format("\"month\": \"%s\",", month));
                                    jsonBuilder.append(String.format("\"year\": %d,", year));
                                    jsonBuilder.append(String.format("\"company_name\": \"%s\",", rs.getString("company_name")));
                                    jsonBuilder.append(String.format("\"company_address\": \"%s\",", rs.getString("company_address")));
                                    jsonBuilder.append(String.format("\"designation\": \"%s\",", rs.getString("designation")));
                                    jsonBuilder.append(String.format("\"department\": \"%s\",", rs.getString("department")));
                                    jsonBuilder.append(String.format("\"date_of_joining\": \"%s\",", rs.getString("date_of_joining")));
                                    jsonBuilder.append(String.format("\"bank_name\": \"%s\",", rs.getString("bank_name")));
                                    jsonBuilder.append(String.format("\"bank_account_no\": \"%s\",", rs.getString("bank_account_no")));
                                    jsonBuilder.append(String.format("\"uan_number\": \"%s\",", rs.getString("uan_number")));
                                    jsonBuilder.append(String.format("\"pf_number\": \"%s\",", rs.getString("pf_number")));
                                    jsonBuilder.append(String.format("\"work_location\": \"%s\",", rs.getString("work_location")));
                                    jsonBuilder.append(String.format("\"total_working_days\": %d,", rs.getInt("total_working_days")));
                                    jsonBuilder.append(String.format("\"lop_days\": %d,", rs.getInt("lop_days")));
                                    jsonBuilder.append(String.format("\"paid_days\": %d,", rs.getInt("paid_days")));
                                    jsonBuilder.append(String.format("\"basic_salary\": %.2f,", rs.getDouble("basic_salary")));
                                    jsonBuilder.append(String.format("\"hra\": %.2f,", rs.getDouble("hra")));
                                    jsonBuilder.append(String.format("\"flexible_plan\": %.2f,", rs.getDouble("flexible_plan")));
                                    jsonBuilder.append(String.format("\"other_earnings\": %.2f,", rs.getDouble("other_earnings")));
                                    jsonBuilder.append(String.format("\"gross_salary\": %.2f,", rs.getDouble("gross_salary")));
                                    jsonBuilder.append(String.format("\"epf\": %.2f,", rs.getDouble("epf")));
                                    jsonBuilder.append(String.format("\"professional_tax\": %.2f,", rs.getDouble("professional_tax")));
                                    jsonBuilder.append(String.format("\"esi\": %.2f,", rs.getDouble("esi")));
                                    jsonBuilder.append(String.format("\"tds\": %.2f,", rs.getDouble("tds")));
                                    jsonBuilder.append(String.format("\"other_deductions\": %.2f,", rs.getDouble("other_deductions")));
                                    jsonBuilder.append(String.format("\"total_deductions\": %.2f,", rs.getDouble("total_deductions")));
                                    jsonBuilder.append(String.format("\"net_salary\": %.2f", rs.getDouble("net_salary")));
                                    jsonBuilder.append("},");
                                }
                                pstmt = conn.prepareStatement(
                                    "SELECT a.employee_id, a.employee_name, a.month, a.year, a.attendance, c.* " +
                                    "FROM check_old_attendance a " +
                                    "LEFT JOIN payslips p ON a.employee_id = p.employee_id AND a.month = p.month AND a.year = p.year " +
                                    "JOIN ctc_employees c ON a.employee_id = c.employee_id " +
                                    "WHERE p.employee_id IS NULL " +
                                    "ORDER BY a.year DESC, FIELD(a.month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December') DESC");
                                rs = pstmt.executeQuery();
                                while (rs.next()) {
                                    String empId = rs.getString("employee_id");
                                    String month = rs.getString("month");
                                    int year = rs.getInt("year");
                                    int attendance = rs.getInt("attendance");
                                    int totalDays = Helper.getTotalDays(month, year);
                                    int lopDays = totalDays - attendance;
                                    int paidDays = attendance;
                                    double basicSalary = rs.getDouble("basic_salary");
                                    double hra = rs.getDouble("hra");
                                    double flexiblePlan = rs.getDouble("special_allowance");
                                    double otherEarnings = rs.getDouble("conveyance_allowance") + rs.getDouble("medical_allowance") + rs.getDouble("bonus");
                                    double grossSalary = basicSalary + hra + flexiblePlan + otherEarnings;
                                    double epf = rs.getDouble("pf");
                                    double professionalTax = rs.getDouble("professional_tax");
                                    double esi = rs.getDouble("esi");
                                    double tds = rs.getDouble("tds");
                                    double otherDeductions = (grossSalary / totalDays) * lopDays;
                                    double totalDeductions = epf + professionalTax + esi + tds + otherDeductions;
                                    double netSalary = grossSalary - totalDeductions;
                                    jsonBuilder.append(String.format("\"%s-%s-%d\": {", empId, month, year));
                                    jsonBuilder.append(String.format("\"employee_id\": \"%s\",", empId));
                                    jsonBuilder.append(String.format("\"employee_name\": \"%s\",", rs.getString("employee_name")));
                                    jsonBuilder.append(String.format("\"month\": \"%s\",", month));
                                    jsonBuilder.append(String.format("\"year\": %d,", year));
                                    jsonBuilder.append(String.format("\"company_name\": \"%s\",", rs.getString("company_name")));
                                    jsonBuilder.append(String.format("\"company_address\": \"%s\",", rs.getString("company_address")));
                                    jsonBuilder.append(String.format("\"designation\": \"%s\",", rs.getString("designation")));
                                    jsonBuilder.append(String.format("\"department\": \"%s\",", rs.getString("department")));
                                    jsonBuilder.append(String.format("\"date_of_joining\": \"%s\",", rs.getString("date_of_joining")));
                                    jsonBuilder.append(String.format("\"bank_name\": \"%s\",", rs.getString("bank_name")));
                                    jsonBuilder.append(String.format("\"bank_account_no\": \"%s\",", rs.getString("bank_account_no")));
                                    jsonBuilder.append(String.format("\"uan_number\": \"%s\",", rs.getString("uan_number")));
                                    jsonBuilder.append(String.format("\"pf_number\": \"%s\",", rs.getString("pf_number")));
                                    jsonBuilder.append(String.format("\"work_location\": \"%s\",", rs.getString("work_location")));
                                    jsonBuilder.append(String.format("\"total_working_days\": %d,", totalDays));
                                    jsonBuilder.append(String.format("\"lop_days\": %d,", lopDays));
                                    jsonBuilder.append(String.format("\"paid_days\": %d,", paidDays));
                                    jsonBuilder.append(String.format("\"basic_salary\": %.2f,", basicSalary));
                                    jsonBuilder.append(String.format("\"hra\": %.2f,", hra));
                                    jsonBuilder.append(String.format("\"flexible_plan\": %.2f,", flexiblePlan));
                                    jsonBuilder.append(String.format("\"other_earnings\": %.2f,", otherEarnings));
                                    jsonBuilder.append(String.format("\"gross_salary\": %.2f,", grossSalary));
                                    jsonBuilder.append(String.format("\"epf\": %.2f,", epf));
                                    jsonBuilder.append(String.format("\"professional_tax\": %.2f,", professionalTax));
                                    jsonBuilder.append(String.format("\"esi\": %.2f,", esi));
                                    jsonBuilder.append(String.format("\"tds\": %.2f,", tds));
                                    jsonBuilder.append(String.format("\"other_deductions\": %.2f,", otherDeductions));
                                    jsonBuilder.append(String.format("\"total_deductions\": %.2f,", totalDeductions));
                                    jsonBuilder.append(String.format("\"net_salary\": %.2f", netSalary));
                                    jsonBuilder.append("},");
                                }
                            }
                            if (jsonBuilder.length() > 1) {
                                jsonBuilder.setLength(jsonBuilder.length() - 1);
                            }
                            jsonBuilder.append("}");
                        } catch (Exception e) {
                            out.println("<tr><td colspan='4'>Error loading payslips: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="generateModal" class="modal" style="display: none;">
            <div class="modal-content">
                <div class="modal-header sticky-header">
                    <h2>Generate Pay Slips</h2>
                    <button class="cancel-btn" onclick="closeGenerateModal()">Cancel</button>
                </div>
                <div class="table-container scrollable">
                    <table>
                        <thead>
                            <tr>
                                <th>Employee ID</th>
                                <th>Name</th>
                                <th>Month/Year</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="generateTable">
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                try (Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
                                     PreparedStatement pstmt = conn.prepareStatement(
                                         "SELECT a.employee_id, a.employee_name, a.month, a.year " +
                                         "FROM check_old_attendance a " +
                                         "LEFT JOIN payslips p ON a.employee_id = p.employee_id AND a.month = p.month AND a.year = p.year " +
                                         "WHERE p.employee_id IS NULL " +
                                         "ORDER BY a.year DESC, FIELD(a.month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December') DESC");
                                     ResultSet rs = pstmt.executeQuery()) {
                                    while (rs.next()) {
                        %>
                            <tr>
                                <td><%= rs.getString("employee_id") %></td>
                                <td><%= rs.getString("employee_name") %></td>
                                <td><%= rs.getString("month") + "/" + rs.getInt("year") %></td>
                                <td>
                                    <button class="generate-btn" onclick="generatePayslip('<%= rs.getString("employee_id") %>', '<%= rs.getString("employee_name") %>', '<%= rs.getString("month") %>', <%= rs.getInt("year") %>)">Generate</button>
                                    <button class="view-btn" onclick="openViewModal('<%= rs.getString("employee_id") %>', '<%= rs.getString("employee_name") %>', '<%= rs.getString("month") %>', <%= rs.getInt("year") %>)">View</button>
                                </td>
                            </tr>
                        <%
                                    }
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='4'>Error loading data: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div id="viewModal" class="modal" style="display: none;">
            <div class="modal-content">
                <div class="modal-header sticky-header">
                    <h2>Payslip</h2>
                    <button class="cancel-btn" onclick="closeViewModal()">Cancel</button>
                </div>
                <div class="payslip-content" id="payslipContent"></div>
            </div>
        </div>

        <% if (request.getAttribute("message") != null) { %>
            <div id="popup" class="popup success" style="display: block;"><%= request.getAttribute("message") %></div>
        <% } else if (request.getAttribute("error") != null) { %>
            <div id="popup" class="popup error" style="display: block;"><%= request.getAttribute("error") %></div>
        <% } %>

        <input type="hidden" id="payslipData" value='<%= jsonBuilder.toString() %>'>
    </div>

    <script src="<%= request.getContextPath() %>/js/payslip_scripts.js"></script>
</body>
</html>