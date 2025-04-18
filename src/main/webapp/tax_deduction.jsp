<%-- tax_deduction.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("adminlogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tax Deduction Rules</title>
    <style>
        /* Embedded CSS */
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: #ecf0f1;
            color: #2c3e50;
        }
        .container {
            max-width: 800px;
            margin: 20px auto;
            background: #fff;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }
        .header {
            background: #34495e;
            color: white;
            padding: 15px;
            border-radius: 10px 10px 0 0;
            text-align: center;
        }
        h2 {
            margin: 20px 0 10px;
            color: #34495e;
            text-align: center;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
            border-right: 1px solid #ddd;
        }
        th:last-child, td:last-child {
            border-right: none;
        }
        th {
            background: #34495e;
            color: white;
        }
        .notes {
            margin-top: 20px;
            padding: 10px;
            background: #f9f9f9;
            border-radius: 5px;
        }
        .notes p {
            margin: 5px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Income Tax Deduction Rules</h1>
        </div>
        
        <h2>FY 2024-25 (AY 2025-26) - New Regime</h2>
        <table>
            <thead>
                <tr>
                    <th>Income Range (₹)</th>
                    <th>Tax Rate</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Up to 3,00,000</td>
                    <td>Nil</td>
                </tr>
                <tr>
                    <td>3,00,001 - 7,00,000</td>
                    <td>5%</td>
                </tr>
                <tr>
                    <td>7,00,001 - 10,00,000</td>
                    <td>10%</td>
                </tr>
                <tr>
                    <td>10,00,001 - 12,00,000</td>
                    <td>15%</td>
                </tr>
                <tr>
                    <td>12,00,001 - 15,00,000</td>
                    <td>20%</td>
                </tr>
                <tr>
                    <td>Above 15,00,000</td>
                    <td>30%</td>
                </tr>
            </tbody>
        </table>
        <div class="notes">
            <p><strong>Key Benefits:</strong></p>
            <p>- <strong>Rebate (Section 87A):</strong> Up to ₹25,000 if income ≤ ₹7,00,000 (no tax).</p>
            <p>- <strong>Standard Deduction:</strong> ₹75,000 for salaried individuals.</p>
            <p>- <strong>Family Pension Deduction:</strong> ₹25,000.</p>
            <p>- <strong>NPS Contribution:</strong> Employer’s contribution up to 14% of salary deductible.</p>
        </div>

        <h2>FY 2025-26 (AY 2026-27) - New Regime</h2>
        <table>
            <thead>
                <tr>
                    <th>Income Range (₹)</th>
                    <th>Tax Rate</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Up to 4,00,000</td>
                    <td>Nil</td>
                </tr>
                <tr>
                    <td>4,00,001 - 8,00,000</td>
                    <td>5%</td>
                </tr>
                <tr>
                    <td>8,00,001 - 12,00,000</td>
                    <td>10%</td>
                </tr>
                <tr>
                    <td>12,00,001 - 16,00,000</td>
                    <td>15%</td>
                </tr>
                <tr>
                    <td>16,00,001 - 20,00,000</td>
                    <td>20%</td>
                </tr>
                <tr>
                    <td>20,00,001 - 24,00,000</td>
                    <td>25%</td>
                </tr>
                <tr>
                    <td>Above 24,00,000</td>
                    <td>30%</td>
                </tr>
            </tbody>
        </table>
        <div class="notes">
            <p><strong>Key Benefits:</strong></p>
            <p>- <strong>Rebate (Section 87A):</strong> Up to ₹60,000 if income ≤ ₹12,00,000 (no tax).</p>
            <p>- <strong>Standard Deduction:</strong> ₹75,000 for salaried individuals (income up to ₹12,75,000 tax-free).</p>
        </div>
    </div>

    <script>
        // Embedded JavaScript (minimal, as no dynamic functionality is needed)
        window.onload = function() {
            console.log("Tax Deduction Rules Loaded");
        };
    </script>
</body>
</html>