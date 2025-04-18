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
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background: #ecf0f1;
            color: #2c3e50;
        }
        
.container {
    max-width: calc(100% - 40px);
    max-height: 100%;
    margin-left: 70px;
    margin-right: 20px;
    margin-top: 20px;
    margin-bottom: 20px;
    padding: 20px;
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    height: calc(100vh - 40px);
    overflow-y: auto;
}
        .header {
            background: #34495e;
            color: white;
            padding: 15px;
            border-radius: 10px 10px 0 0;
            text-align: center;
        }
        h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 600;
        }
        h2 {
            margin: 30px 0 15px;
            color: #34495e;
            text-align: center;
            font-size: 22px;
            font-weight: 600;
            position: relative;
        }
        h2::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 3px;
            background: #3498db;
            border-radius: 2px;
        }
        .tax-section {
            margin-bottom: 40px;
            padding: 20px;
            background: #f9fbfc;
            border-radius: 15px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s ease;
        }
        .tax-section:hover {
            transform: translateY(-5px);
        }
        .tax-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        .tax-item {
            background: #ffffff;
            padding: 15px;
            border-radius: 10px;
            border-left: 4px solid #3498db;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }
        .tax-item span {
            display: block;
        }
        .tax-item .range {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        .tax-item .rate {
            color: #3498db;
            font-size: 16px;
            font-weight: 500;
        }
        .notes {
            background: #e6f0fa;
            padding: 15px;
            border-radius: 10px;
            border: 1px solid #d1e0ee;
        }
        .notes p {
            margin: 8px 0;
            line-height: 1.5;
        }
        .notes strong {
            color: #2c3e50;
            font-weight: 600;
        }
        .notes .highlight {
            color: #e74c3c;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Income Tax Deduction Rules</h1>
        </div>
        
        <div class="tax-section">
            <h2>FY 2024-25 (AY 2025-26) - New Regime</h2>
            <div class="tax-grid">
                <div class="tax-item">
                    <span class="range">Up to ₹3,00,000</span>
                    <span class="rate">Nil</span>
                </div>
                <div class="tax-item">
                    <span class="range">₹3,00,001 - ₹7,00,000</span>
                    <span class="rate">5%</span>
                </div>
                <div class="tax-item">
                    <span class="range">₹7,00,001 - ₹10,00,000</span>
                    <span class="rate">10%</span>
                </div>
                <div class="tax-item">
                    <span class="range">₹10,00,001 - ₹12,00,000</span>
                    <span class="rate">15%</span>
                </div>
                <div class="tax-item">
                    <span class="range">₹12,00,001 - ₹15,00,000</span>
                    <span class="rate">20%</span>
                </div>
                <div class="tax-item">
                    <span class="range">Above ₹15,00,000</span>
                    <span class="rate">30%</span>
                </div>
            </div>
            <div class="notes">
                <p><strong>Key Benefits:</strong></p>
                <p>- <strong>Rebate (Section 87A):</strong> Up to <span class="highlight">₹25,000</span> if income ≤ ₹7,00,000 (no tax).</p>
                <p>- <strong>Standard Deduction:</strong> <span class="highlight">₹75,000</span> for salaried individuals.</p>
                <p>- <strong>Family Pension Deduction:</strong> <span class="highlight">₹25,000</span>.</p>
                <p>- <strong>NPS Contribution:</strong> Employer’s contribution up to <span class="highlight">14%</span> of salary deductible.</p>
            </div>
        </div>

        <div class="tax-section">
            <h2>FY 2025-26 (AY 2026-27) - New Regime</h2>
            <div class="tax-grid">
                <div class="tax-item">
                    <span class="range">Up to ₹4,00,000</span>
                    <span class="rate">Nil</span>
                </div>
                <div class="tax-item">
                    <span class="range">₹4,00,001 - ₹8,00,000</span>
                    <span class="rate">5%</span>
                </div>
                <div class="tax-item">
                    <span class="range">₹8,00,001 - ₹12,00,000</span>
                    <span class="rate">10%</span>
                </div>
                <div class="tax-item">
                    <span class="range">₹12,00,001 - ₹16,00,000</span>
                    <span class="rate">15%</span>
                </div>
                <div class="tax-item">
                    <span class="range">₹16,00,001 - ₹20,00,000</span>
                    <span class="rate">20%</span>
                </div>
                <div class="tax-item">
                    <span class="range">₹20,00,001 - ₹24,00,000</span>
                    <span class="rate">25%</span>
                </div>
                <div class="tax-item">
                    <span class="range">Above ₹24,00,000</span>
                    <span class="rate">30%</span>
                </div>
            </div>
            <div class="notes">
                <p><strong>Key Benefits:</strong></p>
                <p>- <strong>Rebate (Section 87A):</strong> Up to <span class="highlight">₹60,000</span> if income ≤ ₹12,00,000 (no tax).</p>
                <p>- <strong>Standard Deduction:</strong> <span class="highlight">₹75,000</span> for salaried individuals (income up to ₹12,75,000 tax-free).</p>
            </div>
        </div>
    </div>

    <script>
        // Embedded JavaScript
        window.onload = function() {
            console.log("Tax Deduction Rules Loaded");
            const sections = document.querySelectorAll('.tax-section');
            sections.forEach((section, index) => {
                section.style.opacity = '0';
                section.style.transform = 'translateY(20px)';
                setTimeout(() => {
                    section.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                    section.style.opacity = '1';
                    section.style.transform = 'translateY(0)';
                }, index * 200);
            });
        };
    </script>
</body>
</html>