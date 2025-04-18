<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Exam Instructions</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            height: 100vh;
            background-color: #f5f5f5;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .container {
            width: 90%;
            margin-top: 2%;
            padding: 20px;
            margin-bottom: 2%;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        h1 { color: #2E2E2E; }
        .instructions {
            line-height: 1.6;
            text-align: left;
            max-height: 60vh;
            overflow-y: auto;
            padding-right: 10px;
        }
        .warning { color: #D32F2F; font-weight: bold; }
        button {
            padding: 10px 20px;
            background-color: #1976D2;
            color: white;
            border: none;
            cursor: pointer;
            margin-top: 20px;
        }
        button:hover { background-color: #115293; }
    </style>
    <script>
        function startCoding() {
            // Open CompilerServlet in a new fullscreen window
            let newWindow = window.open('<%=request.getContextPath()%>/CompilerServlet', '_blank', 'toolbar=no,location=no,status=no,menubar=no,scrollbars=no,resizable=no,fullscreen=yes');
            if (newWindow) {
                newWindow.focus();
                // Close the current instructions tab after opening the coding window
                setTimeout(() => {
                    window.close();
                }, 500);
            } else {
                alert('Failed to start the coding exam. Please allow popups and try again.');
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>Exam Instructions</h1>
        <div class="instructions">
            <p>Please read the following instructions carefully before beginning the exam.</p>
            <ol>
                <li><strong>Time Limit:</strong> The exam has a fixed duration of 1 hour.</li>
                <li><strong>Single Attempt:</strong> You have only one attempt.</li>
                <li><span class="warning">Do Not Refresh:</span> Refreshing will prompt submission.</li>
                <li><span class="warning">Stay in Fullscreen:</span> Exiting fullscreen or switching tabs may submit your exam after 3 warnings.</li>
            </ol>
            <p>Click "Start Coding" to begin.</p>
        </div>
        <button onclick="startCoding()">Start Coding</button>
    </div>
</body>
</html>