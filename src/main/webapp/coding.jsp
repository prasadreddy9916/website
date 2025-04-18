<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Online Code Compiler</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.5/codemirror.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.5/theme/dracula.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.5/codemirror.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.5/mode/clike/clike.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.5/mode/python/python.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.5/mode/javascript/javascript.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.5/mode/c/c.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.5/mode/cpp/cpp.min.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background-color: #f4f6f8;
            color: #333;
            margin: 0;
            padding: 0;
            min-height: 100vh;
        }

        .navbar {
            background-color: #2c3e50;
            color: #ecf0f1;
            padding: 15px 20px;
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1000;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
        }

        .navbar .time-remaining {
            background-color: #82b74b;
            padding: 8px 20px;
            border-radius: 25px;
            font-size: 18px;
            font-weight: bold;
            color: #fff;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
            margin-right: 20px;
            transition: background-color 0.3s ease;
        }

        .navbar .time-remaining:hover {
            background-color: #c0392b;
        }

        .time-remaining.low-time {
            background-color: #d32f2f;
            animation: pulse 1s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        @media (max-width: 600px) {
            .navbar {
                flex-direction: column;
                padding: 10px;
            }
            .employee-info, .time-remaining {
                margin: 5px 0;
            }
        }

        .container {
            width: 90%;
            max-width: 1400px;
            margin: 80px auto 20px;
            display: flex;
            flex-direction: column;
            gap: 20px;
            background: #ffffff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }

        .main-content {
            display: flex;
            gap: 20px;
        }

        .left-panel, .right-panel {
            flex: 1;
            padding: 20px;
            background: #fafafa;
            border-radius: 8px;
        }

        .left-panel {
            border-right: 1px solid #e0e0e0;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .problem-statement {
            flex-grow: 1;
        }

        .navigation-box {
            display: flex;
            flex-direction: row;
            gap: 10px;
            flex-wrap: wrap;
        }

        .question-label {
            padding: 10px;
            color: white;
            border-radius: 5px;
            width: 40px;
            text-align: center;
            cursor: default;
        }

        .question-label.not-attempted {
            background-color: #1a73e8;
        }

        .question-label.submitted {
            background-color: #28a745;
        }

        .question-label.current {
            background-color: #9c27b0;
        }

        h1, h2, h3 {
            color: #1a73e8;
            margin-bottom: 15px;
        }

        button {
            padding: 10px;
            font-size: 16px;
            background-color: #1a73e8;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            margin-right: 10px;
        }

        button:hover {
            background-color: #1557b0;
        }

        button:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
        }

        .code-editor {
            margin-top: 15px;
            margin-bottom: 20px;
        }

        .CodeMirror {
            border: 1px solid #ddd;
            border-radius: 5px;
            height: 400px;
            font-size: 14px;
            background: #000000 !important;
            color: #ffffff;
        }

        .cm-keyword { color: #569cd6; }
        .cm-string { color: #ce9178; }
        .cm-number { color: #b5cea8; }
        .cm-comment { color: #6a9955; }
        .cm-operator { color: #d4d4d4; }
        .cm-variable { color: #9cdcfe; }
        .cm-builtin { color: #dcdcaa; }
        .cm-def { color: #4ec9b0; }

        pre {
            background: #f1f3f5;
            color: #333;
            padding: 15px;
            border-radius: 5px;
            text-align: left;
            overflow-x: auto;
            font-size: 14px;
        }

        .output-container, .sample-question {
            margin-top: 20px;
        }

        label {
            font-weight: bold;
            margin-bottom: 10px;
            display: block;
            text-align: left;
            color: #555;
        }

        .sample-question {
            background: #fff;
            padding: 15px;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            display: none;
        }

        .sample-question.active {
            display: block;
        }

        .language-selector {
            margin-bottom: 10px;
            position: relative;
        }

        select {
            padding: 8px;
            font-size: 16px;
            border-radius: 5px;
            border: 1px solid #ddd;
            background-color: #fff;
            width: 200px;
        }

        select:focus {
            outline: none;
            border-color: #1a73e8;
        }

        .language-indicator {
            margin-top: 5px;
            font-size: 14px;
            color: #1a73e8;
            font-weight: bold;
        }

        .test-case {
            margin: 10px 0;
        }

        .final-submit {
            background-color: #28a745;
        }

        .final-submit:hover {
            background-color: #218838;
        }

        .button-container {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }

        iframe#compileFrame {
            display: none;
        }

        .begin-exam-container {
            text-align: center;
        }

        .hidden {
            display: none;
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .modal-content {
            background-color: #fff;
            padding: 20px;
            border-radius: 5px;
            text-align: center;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            max-width: 400px;
            width: 80%;
        }

        .modal-content p {
            margin-bottom: 20px;
            font-size: 16px;
            color: #333;
        }

        .modal-content button {
            padding: 10px 20px;
        }

        .instructions {
            line-height: 1.6;
            text-align: left;
            padding: 10px;
            background: #fff3cd;
            border: 1px solid #ffeeba;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        .warning {
            color: #D32F2F;
            font-weight: bold;
        }
    </style>
    <script>
        var editor;
        var examStarted = false;
        var exitAttempts = 0;
        var isFinalSubmitting = false;
        var submittedCount = 0;
        var currentQuestionId = null;
        var tabSwitchCount = 0;
        const MAX_TAB_SWITCHES = 3;

        function enterFullscreen() {
            try {
                if (!document.fullscreenElement) {
                    document.documentElement.requestFullscreen()
                        .then(() => console.log('Fullscreen entered successfully'))
                        .catch(err => console.error('Fullscreen request failed:', err));
                }
            } catch (e) {
                console.error('Error entering fullscreen:', e);
            }
        }

        function startTimer(duration) {
            try {
                var timer = duration, minutes, seconds;
                var interval = setInterval(function () {
                    minutes = parseInt(timer / 60, 10);
                    seconds = parseInt(timer % 60, 10);
                    minutes = minutes < 10 ? "0" + minutes : minutes;
                    seconds = seconds < 10 ? "0" + seconds : seconds;
                    document.getElementById("countdown").textContent = minutes + ":" + seconds;
                    if (timer < 5 * 60) {
                        document.getElementById("countdown").classList.add("low-time");
                    }
                    if (timer-- <= 0) {
                        clearInterval(interval);
                        document.getElementById("countdown").textContent = "00:00";
                        finalSubmit(); // Replaced alert and forceSubmit with finalSubmit
                    }
                }, 1000);
            } catch (e) {
                console.error('Error in startTimer:', e);
            }
        }

        function beginExam() {
            console.log('Begin Exam button clicked');
            examStarted = true;
            const beginContainer = document.querySelector('.begin-exam-container');
            const mainContent = document.querySelector('.main-content');
            if (!beginContainer || !mainContent) {
                console.error('Container not found - beginContainer:', beginContainer, 'mainContent:', mainContent);
                alert('Error: Container not found');
                return;
            }
            beginContainer.classList.add('hidden');
            mainContent.classList.remove('hidden');
            enterFullscreen();
            startTimer(60 * 60); // Kept at 7 minutes as per your last change
            loadFirstQuestion();
            updateLanguageIndicator();
            setupTabSwitchDetection();
        }

        function loadFirstQuestion() {
            console.log('Loading first question');
            loadQuestion('1');
        }

        function compileAndSubmit() {
            var questionId = document.getElementById("questionIdInput").value;
            if (!questionId) {
                alert("Please select a question to submit.");
                return;
            }
            document.getElementById("submitAction").value = "submit";
            document.getElementById("codeForm").target = "compileFrame";
            document.getElementById("codeForm").submit();
        }

        function finalSubmit() {
            console.log('Final Submit clicked');
            isFinalSubmitting = true;
            window.location.href = "${pageContext.request.contextPath}/CompilerServlet?action=finalSubmit";
        }

        function showWarningModal() {
            const modal = document.getElementById("warningModal");
            modal.style.display = "flex";
        }

        function hideWarningModal() {
            const modal = document.getElementById("warningModal");
            modal.style.display = "none";
        }

        function showSubmitPopup(questionId) {
            submittedCount++;
            const popup = document.getElementById("submitPopup");
            const popupText = document.getElementById("submitPopupText");
            popupText.innerText = `Question ${questionId} Submitted Successfully`;
            popup.style.display = "flex";
            setTimeout(() => {
                popup.style.display = "none";
            }, 3000);
        }

        function showExitModal() {
            const modal = document.getElementById("exitModal");
            modal.style.display = "flex";
        }

        function hideExitModal() {
            const modal = document.getElementById("exitModal");
            modal.style.display = "none";
        }

        function scrollToBottom() {
            window.scrollTo({
                top: document.body.scrollHeight,
                behavior: 'smooth'
            });
        }

        function updateLanguageIndicator() {
            const language = document.getElementById("language").value;
            const indicator = document.getElementById("languageIndicator");
            indicator.innerText = `Selected Language: ${language.charAt(0).toUpperCase() + language.slice(1)}`;
        }

        function handleIframeLoad() {
            const iframe = document.getElementById("compileFrame");
            const responseText = iframe.contentDocument.body.innerText;
            try {
                const response = JSON.parse(responseText);
                console.log("Response:", response);
                document.querySelector(".output-container pre").innerText = response.output;

                if (response.action === "submit" && response.success) {
                    showSubmitPopup(response.submittedQuestionId);
                    if (response.nextQuestionId !== null) {
                        loadQuestion(response.nextQuestionId);
                    }
                    if (response.allSubmitted) {
                        if (!document.querySelector(".navigation .final-submit")) {
                            const navigationDiv = document.createElement("div");
                            navigationDiv.className = "navigation";
                            navigationDiv.style.textAlign = "center";
                            navigationDiv.style.marginTop = "20px";
                            navigationDiv.innerHTML = '<button class="final-submit" onclick="finalSubmit()">Final Submit</button>';
                            document.querySelector(".container").appendChild(navigationDiv);
                            setTimeout(scrollToBottom, 100);
                        }
                    }
                    const submittedLabel = document.querySelector(`.question-label[data-id='${response.submittedQuestionId}']`);
                    if (submittedLabel) {
                        submittedLabel.classList.remove("current");
                        submittedLabel.classList.add("submitted");
                    }
                }
            } catch (e) {
                console.error("Error parsing response:", e);
                document.querySelector(".output-container pre").innerText = responseText;
            }
        }

        function loadQuestion(questionId) {
            fetch("${pageContext.request.contextPath}/CompilerServlet?questionId=" + questionId + "&language=" + document.getElementById("language").value)
                .then(response => response.text())
                .then(html => {
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(html, "text/html");
                    document.querySelector(".problem-statement").innerHTML = doc.querySelector(".problem-statement").innerHTML;
                    document.querySelector(".navigation-box").innerHTML = doc.querySelector(".navigation-box").innerHTML;
                    document.getElementById("questionIdInput").value = questionId;
                    const selectedLanguage = document.getElementById("language").value;
                    editor.setValue(getDefaultCode(selectedLanguage));
                    document.querySelector(".output-container pre").innerText = "";
                    currentQuestionId = questionId;

                    document.querySelectorAll('.question-label').forEach(label => {
                        const id = label.getAttribute('data-id');
                        if (id === questionId) {
                            label.classList.add('current');
                            label.classList.remove('not-attempted', 'submitted');
                        } else if (label.classList.contains('submitted')) {
                            // Keep submitted as green
                        } else {
                            label.classList.add('not-attempted');
                            label.classList.remove('current');
                        }
                    });
                })
                .catch(error => console.error('Error loading question:', error));
        }

        function getDefaultCode(language) {
            switch (language) {
                case "java":
                    return `import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        // Write your code here\n        // Read input using sc.nextInt(), sc.nextLine(), etc.\n        // Output your result with System.out.println()\n    }\n}`;
                case "python":
                    return `# Write your code here\n# Use input() to read a line, split() to separate values\n# Print your result with print()\n`;
                case "c":
                    return `#include <stdio.h>\nint main() {\n    // Write your code here\n    // Use scanf() to read input, e.g., scanf("%d", &var)\n    // Use printf() to output, e.g., printf("%d\\n", result)\n    return 0;\n}`;
                case "cpp":
                    return `#include <iostream>\nusing namespace std;\nint main() {\n    // Write your code here\n    // Use cin >> var to read input\n    // Use cout << result << endl to output\n    return 0;\n}`;
                case "javascript":
                    return `const readline = require('readline');\nconst rl = readline.createInterface({\n    input: process.stdin,\n    output: process.stdout\n});\nrl.on('line', (input) => {\n    // Write your code here\n    // Input is a string; use split(' ') and map(Number) for numbers\n    // Use console.log() to output your result\n    rl.close();\n});`;
                default:
                    return "";
            }
        }

        function setupTabSwitchDetection() {
            document.addEventListener('visibilitychange', handleVisibilityChange);
        }

        function handleVisibilityChange() {
            if (!examStarted || isFinalSubmitting) return;

            if (document.visibilityState === 'hidden') {
                tabSwitchCount++;
                console.log('Tab switch detected. Count:', tabSwitchCount);

                if (tabSwitchCount > MAX_TAB_SWITCHES) {
                    alert('You have exceeded the allowed number of tab switches (' + MAX_TAB_SWITCHES + '). The exam will now be auto-submitted.');
                    finalSubmit(); // Trigger finalSubmit instead of forceSubmit
                } else {
                    showTabSwitchWarning();
                }
            }
        }

        function showTabSwitchWarning() {
            const modal = document.getElementById("tabSwitchWarningModal");
            const remainingSwitches = MAX_TAB_SWITCHES - tabSwitchCount;
            document.getElementById("tabSwitchWarningText").innerText = 
                `Warning: You have switched tabs ${tabSwitchCount} time(s). You have ${remainingSwitches} switch(es) remaining before auto-submission.`;
            modal.style.display = "flex";
            setTimeout(() => {
                modal.style.display = "none";
            }, 3000);
        }

        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOM fully loaded');
            const beginButton = document.getElementById('beginExamBtn');
            if (beginButton) {
                beginButton.addEventListener('click', beginExam);
                console.log('Event listener added to Begin Exam button');
            } else {
                console.error('Begin button not found');
                alert('Error: Begin button not found');
            }
        });

        window.onload = function() {
            console.log('Window loaded');
            const mainContent = document.querySelector('.main-content');
            const beginContainer = document.querySelector('.begin-exam-container');
            if (mainContent && beginContainer) {
                if (!examStarted) {
                    mainContent.classList.add('hidden');
                    beginContainer.classList.remove('hidden');
                }
            } else {
                console.error('Main content or begin container not found');
            }

            var language = document.getElementById("language").value;
            editor = CodeMirror.fromTextArea(document.getElementById("code"), {
                lineNumbers: true,
                mode: getModeForLanguage(language),
                theme: "dracula",
                matchBrackets: true,
                autoCloseBrackets: true,
                styleActiveLine: true
            });
            editor.setValue(getDefaultCode(language));
            document.getElementById("language").addEventListener("change", function() {
                var newLanguage = this.value;
                editor.setOption("mode", getModeForLanguage(newLanguage));
                editor.setValue(getDefaultCode(newLanguage));
                updateLanguageIndicator();
            });

            document.addEventListener('keydown', function(event) {
                if (!examStarted || isFinalSubmitting) return;
                if ((event.ctrlKey && event.key === 'r') || event.key === 'F5' || event.key === 'F11' || event.key === 'Escape') {
                    event.preventDefault();
                    showExitModal();
                }
            });
        };

        function getModeForLanguage(language) {
            switch (language) {
                case "java": return "text/x-java";
                case "python": return "python";
                case "c": return "text/x-c";
                case "cpp": return "text/x-c++";
                case "javascript": return "javascript";
                default: return "text/plain";
            }
        }
    </script>
</head>
<body>
    <div class="navbar" role="navigation">
        <div class="employee-info" aria-label="Employee Information">
            <span style="color:orange;font-size:20px;font-weight:bold;">Employee:</span> <c:out value="${employeeName}" default="Unknown" />
            <span style="color:orange;font-size:20px;font-weight:bold;">ID:</span> <c:out value="${employeeId}" default="N/A" />
        </div>
        <div id="countdown" class="time-remaining" aria-live="polite">07:00</div> <!-- Updated to 7 minutes -->
    </div>
    <div class="container">
        <div class="begin-exam-container">
            <h1>Welcome to the Online Coding Exam</h1>
            <div class="instructions">
                <p>Please read the following instructions carefully before beginning the exam:</p>
                <ol>
                    <li><strong>Time Limit:</strong> The exam has a fixed duration of 7 minutes.</li> <!-- Updated to 7 minutes -->
                    <li><strong>Single Attempt:</strong> You have only one attempt.</li>
                    <li><strong>Sequential Navigation:</strong> You must solve questions in order. You cannot go back to previous questions.</li>
                    <li><span class="warning">Do Not Refresh:</span> Refreshing will prompt submission.</li>
                    <li><span class="warning">Stay in Fullscreen:</span> Exiting fullscreen or switching tabs more than 3 times will auto-submit your exam.</li>
                </ol>
            </div>
            <button id="beginExamBtn">Begin Exam</button>
        </div>
        <div class="main-content hidden">
            <div class="left-panel">
                <div class="navigation-box">
                    <c:choose>
                        <c:when test="${empty allQuestions}">
                            <p>No questions available. Please contact the administrator.</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${allQuestions}" var="q">
                                <span data-id="${q.id}"
                                      class="question-label ${q.id == question.id ? 'current' : submittedQuestions.contains(q.id) ? 'submitted' : 'not-attempted'}">
                                    Q${q.id}
                                </span>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="problem-statement">
                    <h1>Problem Statement</h1>
                    <c:forEach items="${allQuestions}" var="q">
                        <div class="sample-question ${q.id == question.id ? 'active' : ''}">
                            <h3>${q.title} (Q${q.id})</h3>
                            <p><strong>Description:</strong> ${q.description}</p>
                            <p><strong>Test Cases:</strong></p>
                            <c:forEach items="${q.testCases}" var="testCase" varStatus="loop">
                                <div class="test-case">
                                    <p>Test Case ${testCase.order}:</p>
                                    <pre>Input: ${testCase.input}</pre>
                                    <pre>Output: ${testCase.output}</pre>
                                </div>
                            </c:forEach>
                            <c:if test="${not empty q.hint}">
                                <p><strong>Hint:</strong> <code>${q.hint}</code></p>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </div>
            <div class="right-panel">
                <h2>Code Compiler</h2>
                <form id="codeForm" action="${pageContext.request.contextPath}/CompilerServlet" method="post">
                    <div class="language-selector">
                        <label for="language">Select Language:</label>
                        <select id="language" name="language">
                            <option value="java" ${param.language == 'java' || param.language == null ? 'selected' : ''}>Java</option>
                            <option value="python" ${param.language == 'python' ? 'selected' : ''}>Python</option>
                            <option value="c" ${param.language == 'c' ? 'selected' : ''}>C</option>
                            <option value="cpp" ${param.language == 'cpp' ? 'selected' : ''}>C++</option>
                            <option value="javascript" ${param.language == 'javascript' ? 'selected' : ''}>JavaScript</option>
                        </select>
                        <div id="languageIndicator" class="language-indicator"></div>
                    </div>
                    <div class="code-editor">
                        <label>Write Your Code:</label>
                        <textarea name="code" id="code" rows="15" cols="80">${requestScope.code}</textarea>
                    </div>
                    <div class="button-container">
                        <input type="hidden" name="questionId" id="questionIdInput" value="${question.id}">
                        <input type="hidden" name="submitAction" id="submitAction" value="submit">
                        <button type="button" onclick="compileAndSubmit()"
                                <c:if test="${submittedQuestions.contains(question.id)}">disabled</c:if>>Submit</button>
                    </div>
                </form>
                <div class="output-container">
                    <h3>Output</h3>
                    <pre><c:out value="${requestScope.output}" /></pre>
                </div>
            </div>
        </div>
    </div>
    <iframe id="compileFrame" name="compileFrame" onload="handleIframeLoad()"></iframe>
    <div id="warningModal" class="modal">
        <div class="modal-content">
            <p>You are unable to exit the exam. Click "Enter" to return to fullscreen.</p>
            <button onclick="enterFullscreen(); hideWarningModal();">Enter</button>
        </div>
    </div>
    <div id="submitPopup" class="modal" style="display: none;">
        <div class="modal-content">
            <p id="submitPopupText"></p>
        </div>
    </div>
    <div id="exitModal" class="modal" style="display: none;">
        <div class="modal-content">
            <p>Are you sure you want to exit? Unsubmitted questions will be scored as 0.</p>
            <button onclick="hideExitModal()">Cancel</button>
            <button class="final-submit" onclick="finalSubmit()">Final Submit</button>
        </div>
    </div>
    <div id="tabSwitchWarningModal" class="modal" style="display: none;">
        <div class="modal-content">
            <p id="tabSwitchWarningText"></p>
        </div>
    </div>
</body>
</html>