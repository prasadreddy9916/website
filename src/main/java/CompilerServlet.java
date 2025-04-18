import java.io.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import javax.tools.*;
import java.sql.*;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/CompilerServlet")
public class CompilerServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "hacker#Tag1";
    private static final Map<String, Map<Integer, String>> userOutputs = new HashMap<>();
    private static final int MARKS_PER_TEST_CASE = 5;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    private Map<String, String> getEmployeeDetailsFromEmail(String email) {
        Map<String, String> details = new HashMap<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT ID, Name FROM employee_registrations WHERE email = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                details.put("ID", rs.getString("ID"));
                details.put("Name", rs.getString("Name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return details;
    }

    private int calculateTotalTestCasesAcrossAllQuestions() {
        int total = 0;
        try (Connection conn = getConnection()) {
            String sql = "SELECT test_cases FROM coding_questions";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                JSONArray jsonArray = new JSONArray(rs.getString("test_cases"));
                total += jsonArray.length();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    private Map<Integer, Integer> getSubmittedTestCasesPassed(String sessionId) {
        Map<Integer, Integer> testCasesPassedMap = (Map<Integer, Integer>) getServletContext().getAttribute(sessionId + "_testCasesPassed");
        if (testCasesPassedMap == null) {
            testCasesPassedMap = new HashMap<>();
            getServletContext().setAttribute(sessionId + "_testCasesPassed", testCasesPassedMap);
        }
        return testCasesPassedMap;
    }

    private void saveSubmissionResult(String userId, int totalTestCasesPassed, int totalTestCases) {
        try (Connection conn = getConnection()) {
            String sql = "INSERT INTO submission_results (user_id, test_cases_passed, total_test_cases, marks) " +
                         "VALUES (?, ?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE test_cases_passed = ?, total_test_cases = ?, marks = ?, submission_time = NOW()";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            int marks = totalTestCasesPassed * MARKS_PER_TEST_CASE;
            pstmt.setString(1, userId);
            pstmt.setInt(2, totalTestCasesPassed);
            pstmt.setInt(3, totalTestCases);
            pstmt.setInt(4, marks);
            pstmt.setInt(5, totalTestCasesPassed);
            pstmt.setInt(6, totalTestCases);
            pstmt.setInt(7, marks);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("email");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Map<String, String> employeeDetails = getEmployeeDetailsFromEmail(email);
        String userId = employeeDetails.get("ID");
        String employeeName = employeeDetails.get("Name");

        if (userId == null || employeeName == null) {
            userId = "UnknownID";
            employeeName = "Unknown Employee";
        }

        session.setAttribute("userId", userId);
        request.setAttribute("employeeId", userId);
        request.setAttribute("employeeName", employeeName);

        String action = request.getParameter("action");

        if ("finalSubmit".equals(action) || "forceSubmit".equals(action)) {
            handleFinalSubmit(request, response, userId);
            return;
        }

        try (Connection conn = getConnection()) {
            String sql = "SELECT * FROM coding_questions ORDER BY id";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();
            List<Map<String, Object>> allQuestions = new ArrayList<>();

            while (rs.next()) {
                Map<String, Object> question = new HashMap<>();
                question.put("id", rs.getInt("id"));
                question.put("title", rs.getString("title"));
                question.put("description", rs.getString("description"));
                question.put("hint", rs.getString("hint"));

                String testCasesJson = rs.getString("test_cases");
                JSONArray jsonArray = new JSONArray(testCasesJson);
                List<Map<String, String>> testCases = new ArrayList<>();
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject jsonObj = jsonArray.getJSONObject(i);
                    Map<String, String> testCase = new HashMap<>();
                    testCase.put("input", jsonObj.getString("input"));
                    testCase.put("output", jsonObj.getString("output"));
                    testCase.put("order", String.valueOf(jsonObj.getInt("order")));
                    testCases.add(testCase);
                }
                question.put("testCases", testCases);
                allQuestions.add(question);
            }

            if (allQuestions.isEmpty()) {
                throw new SQLException("No questions found in the database");
            }

            String questionIdParam = request.getParameter("questionId");
            Set<Integer> submittedQuestionIds = (Set<Integer>) session.getAttribute("submittedQuestionIds");
            if (submittedQuestionIds == null) {
                submittedQuestionIds = new HashSet<>();
                session.setAttribute("submittedQuestionIds", submittedQuestionIds);
            }

            int selectedId;
            if (questionIdParam != null && !questionIdParam.isEmpty()) {
                selectedId = Integer.parseInt(questionIdParam);
                int maxSubmittedId = submittedQuestionIds.isEmpty() ? 0 : Collections.max(submittedQuestionIds);
                if (selectedId <= maxSubmittedId && !submittedQuestionIds.contains(selectedId)) {
                    selectedId = maxSubmittedId + 1;
                }
            } else {
                int maxSubmittedId = submittedQuestionIds.isEmpty() ? 0 : Collections.max(submittedQuestionIds);
                selectedId = maxSubmittedId + 1;
            }

            final int finalSelectedId = selectedId;
            Map<String, Object> selectedQuestion = allQuestions.stream()
                .filter(q -> (int) q.get("id") == finalSelectedId)
                .findFirst()
                .orElse(allQuestions.get(0));

            String sessionId = session.getId();
            Map<Integer, String> userOutputMap = userOutputs.getOrDefault(sessionId, new HashMap<>());
            String output = userOutputMap.getOrDefault(finalSelectedId, "Run your code to see the output here.");

            request.setAttribute("question", selectedQuestion);
            request.setAttribute("testCases", selectedQuestion.get("testCases"));
            request.setAttribute("allQuestions", allQuestions);
            request.setAttribute("output", output);
            request.setAttribute("submittedQuestions", submittedQuestionIds);
            request.setAttribute("allQuestionsSubmitted", submittedQuestionIds.size() == allQuestions.size());
            request.getRequestDispatcher("/coding.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Database error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("email");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Map<String, String> employeeDetails = getEmployeeDetailsFromEmail(email);
        String userId = employeeDetails.get("ID");
        if (userId == null) {
            userId = "UnknownID";
        }
        session.setAttribute("userId", userId);

        String action = request.getParameter("action");
        if ("forceSubmit".equals(action)) {
            handleFinalSubmit(request, response, userId);
            return;
        }

        String code = request.getParameter("code");
        String questionIdParam = request.getParameter("questionId");
        String submitAction = request.getParameter("submitAction");
        String language = request.getParameter("language");
        String sessionId = session.getId();

        response.setContentType("application/json");

        if (code == null || code.trim().isEmpty() || questionIdParam == null || questionIdParam.isEmpty()) {
            JSONObject errorResponse = new JSONObject();
            errorResponse.put("output", "Error: Code or question ID missing");
            errorResponse.put("success", false);
            response.getWriter().write(errorResponse.toString());
            return;
        }

        int questionId;
        try {
            questionId = Integer.parseInt(questionIdParam);
        } catch (NumberFormatException e) {
            JSONObject errorResponse = new JSONObject();
            errorResponse.put("output", "Error: Invalid question ID");
            errorResponse.put("success", false);
            response.getWriter().write(errorResponse.toString());
            return;
        }

        String output;
        int testCasesPassed;
        int totalTestCases;

        switch (language.toLowerCase()) {
            case "java":
                Map<String, Object> javaResult = handleJavaCode(code, questionId, submitAction, sessionId, language, userId);
                output = (String) javaResult.get("output");
                testCasesPassed = (int) javaResult.get("testCasesPassed");
                totalTestCases = (int) javaResult.get("totalTestCases");
                break;
            case "python":
                Map<String, Object> pythonResult = handlePythonCode(code, questionId, submitAction, sessionId, language, userId);
                output = (String) pythonResult.get("output");
                testCasesPassed = (int) pythonResult.get("testCasesPassed");
                totalTestCases = (int) pythonResult.get("totalTestCases");
                break;
            case "c":
                Map<String, Object> cResult = handleCCode(code, questionId, submitAction, sessionId, language, userId);
                output = (String) cResult.get("output");
                testCasesPassed = (int) cResult.get("testCasesPassed");
                totalTestCases = (int) cResult.get("totalTestCases");
                break;
            case "cpp":
                Map<String, Object> cppResult = handleCPPCode(code, questionId, submitAction, sessionId, language, userId);
                output = (String) cppResult.get("output");
                testCasesPassed = (int) cppResult.get("testCasesPassed");
                totalTestCases = (int) cppResult.get("totalTestCases");
                break;
            case "javascript":
                Map<String, Object> jsResult = handleJavaScriptCode(code, questionId, submitAction, sessionId, language, userId);
                output = (String) jsResult.get("output");
                testCasesPassed = (int) jsResult.get("testCasesPassed");
                totalTestCases = (int) jsResult.get("totalTestCases");
                break;
            default:
                output = "Error: Unsupported language";
                testCasesPassed = 0;
                totalTestCases = calculateTotalTestCases(questionId);
        }

        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("output", output);
        jsonResponse.put("action", submitAction);
        jsonResponse.put("success", true);

        if ("submit".equals(submitAction)) {
            int nextQuestionId = getNextQuestionId(questionId);
            jsonResponse.put("nextQuestionId", nextQuestionId != -1 ? nextQuestionId : JSONObject.NULL);
            jsonResponse.put("submittedQuestionId", questionId);

            Set<Integer> submittedQuestionIds = (Set<Integer>) session.getAttribute("submittedQuestionIds");
            if (submittedQuestionIds == null) {
                submittedQuestionIds = new HashSet<>();
                session.setAttribute("submittedQuestionIds", submittedQuestionIds);
            }
            submittedQuestionIds.add(questionId);

            Map<Integer, Integer> testCasesPassedMap = getSubmittedTestCasesPassed(sessionId);
            testCasesPassedMap.put(questionId, testCasesPassed);

            int totalTestCasesPassed = testCasesPassedMap.values().stream().mapToInt(Integer::intValue).sum();
            int totalTestCasesAllQuestions = calculateTotalTestCasesAcrossAllQuestions();

            saveSubmissionResult(userId, totalTestCasesPassed, totalTestCasesAllQuestions);

            try (Connection conn = getConnection()) {
                String sql = "SELECT COUNT(*) FROM coding_questions";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    int totalQuestions = rs.getInt(1);
                    boolean allSubmitted = submittedQuestionIds.size() == totalQuestions && nextQuestionId == -1;
                    jsonResponse.put("allSubmitted", allSubmitted);
                } else {
                    jsonResponse.put("allSubmitted", false);
                }
            } catch (SQLException e) {
                e.printStackTrace();
                jsonResponse.put("allSubmitted", false);
            }

            Map<Integer, String> userOutputMap = userOutputs.getOrDefault(sessionId, new HashMap<>());
            userOutputMap.put(questionId, output);
            userOutputs.put(sessionId, userOutputMap);
        }

        response.getWriter().write(jsonResponse.toString());
    }

    private Map<String, Object> handleJavaCode(String javaCode, int questionId, String submitAction, String sessionId, String language, String userId)
            throws IOException {
        Map<String, Object> result = new HashMap<>();
        String className = extractClassName(javaCode);
        if (className == null) {
            className = "Main";
            javaCode = "import java.util.Scanner;\npublic class Main {\npublic static void main(String[] args) {\nScanner sc = new Scanner(System.in);\n" + javaCode + "\n}\n}";
        }

        String javaFileName = className + ".java";
        File sourceFile = new File(System.getProperty("java.io.tmpdir"), javaFileName);

        try (FileWriter writer = new FileWriter(sourceFile)) {
            writer.write(javaCode);
        }

        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        if (compiler == null) {
            sourceFile.delete();
            result.put("output", "Error: Java compiler not available");
            result.put("testCasesPassed", 0);
            result.put("totalTestCases", calculateTotalTestCases(questionId));
            result.put("marks", 0);
            return result;
        }

        StringWriter errorOutput = new StringWriter();
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        StandardJavaFileManager fileManager = compiler.getStandardFileManager(diagnostics, null, null);
        Iterable<? extends JavaFileObject> compilationUnits = fileManager.getJavaFileObjects(sourceFile);

        JavaCompiler.CompilationTask task = compiler.getTask(new PrintWriter(errorOutput), fileManager, diagnostics, null, null, compilationUnits);
        boolean success = task.call();

        if (!success) {
            fileManager.close();
            sourceFile.delete();
            result.put("output", "Compilation Error: " + errorOutput.toString());
            result.put("testCasesPassed", 0);
            result.put("totalTestCases", calculateTotalTestCases(questionId));
            result.put("marks", 0);
            return result;
        }

        fileManager.close();
        result = executeAndTestCode(javaCode, questionId, submitAction, sessionId, language, userId,
            "java", "-cp", System.getProperty("java.io.tmpdir"), className);
        sourceFile.delete();
        return result;
    }

    private Map<String, Object> executeAndTestCode(String code, int questionId, String submitAction, String sessionId, String language, String userId,
            String... command) throws IOException {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, String>> testCases = new ArrayList<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT test_cases FROM coding_questions WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, questionId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                JSONArray jsonArray = new JSONArray(rs.getString("test_cases"));
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject jsonObj = jsonArray.getJSONObject(i);
                    Map<String, String> testCase = new HashMap<>();
                    testCase.put("input", jsonObj.getString("input"));
                    testCase.put("output", jsonObj.getString("output"));
                    testCase.put("order", String.valueOf(jsonObj.getInt("order")));
                    testCases.add(testCase);
                }
            }
        } catch (SQLException e) {
            result.put("output", "Error fetching test cases: " + e.getMessage());
            result.put("testCasesPassed", 0);
            result.put("totalTestCases", calculateTotalTestCases(questionId));
            result.put("marks", 0);
            return result;
        }

        int passedCount = 0;
        int totalTestCases = testCases.size();

        for (int i = 0; i < totalTestCases; i++) {
            String input = testCases.get(i).get("input");
            String expectedOutput = testCases.get(i).get("output");

            try {
                ProcessBuilder pb = new ProcessBuilder(command);
                Process process = pb.start();

                try (BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(process.getOutputStream()))) {
                    writer.write(input + "\n");
                    writer.flush();
                    writer.close();
                }

                BufferedReader outputReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()));
                StringBuilder programOutput = new StringBuilder();
                StringBuilder runtimeError = new StringBuilder();

                String line;
                while ((line = outputReader.readLine()) != null) {
                    programOutput.append(line).append("\n");
                }
                while ((line = errorReader.readLine()) != null) {
                    runtimeError.append(line).append("\n");
                }

                process.waitFor();
                String actualOutput = programOutput.toString().trim();
                if (runtimeError.length() > 0) {
                    result.put("output", "Runtime Error: " + runtimeError.toString());
                    result.put("testCasesPassed", 0);
                    result.put("totalTestCases", totalTestCases);
                    result.put("marks", 0);
                    return result;
                }

                if (actualOutput.equals(expectedOutput)) {
                    passedCount++;
                }
            } catch (Exception e) {
                result.put("output", "Execution Error: " + e.getMessage());
                result.put("testCasesPassed", 0);
                result.put("totalTestCases", totalTestCases);
                result.put("marks", 0);
                return result;
            }
        }

        result.put("output", "✅ Code submitted successfully.");
        result.put("testCasesPassed", passedCount);
        result.put("totalTestCases", totalTestCases);
        result.put("marks", passedCount * MARKS_PER_TEST_CASE);

        return result;
    }

    private String extractClassName(String javaCode) {
        String[] lines = javaCode.split("\n");
        for (String line : lines) {
            line = line.trim();
            if (line.startsWith("public class ")) {
                String[] parts = line.split("\\s+");
                for (int i = 0; i < parts.length; i++) {
                    if (parts[i].equals("class") && i + 1 < parts.length) {
                        return parts[i + 1].replace("{", "").trim();
                    }
                }
            }
        }
        return null;
    }

    private Map<String, Object> handlePythonCode(String pythonCode, int questionId, String submitAction, String sessionId, String language, String userId)
            throws IOException {
        String pythonFileName = "script.py";
        File sourceFile = new File(System.getProperty("java.io.tmpdir"), pythonFileName);

        try (FileWriter writer = new FileWriter(sourceFile)) {
            writer.write(pythonCode);
        }

        String osName = System.getProperty("os.name").toLowerCase();
        String pythonCommand;
        if (osName.contains("win")) {
            pythonCommand = "C:\\Users\\user\\AppData\\Local\\Programs\\Python\\Python312\\python.exe";
        } else {
            pythonCommand = "python3";
        }

        Map<String, Object> result = executeAndTestCode(pythonCode, questionId, submitAction, sessionId, language, userId,
            pythonCommand, sourceFile.getAbsolutePath());
        sourceFile.delete();
        return result;
    }

    private Map<String, Object> handleCCode(String cCode, int questionId, String submitAction, String sessionId, String language, String userId)
            throws IOException {
        Map<String, Object> result = new HashMap<>();
        String cFileName = "program.c";
        File sourceFile = new File(System.getProperty("java.io.tmpdir"), cFileName);
        File executableFile = new File(System.getProperty("java.io.tmpdir"), "program");

        try (FileWriter writer = new FileWriter(sourceFile)) {
            writer.write(cCode);
        }

        ProcessBuilder compilePb = new ProcessBuilder("gcc", "-o", executableFile.getAbsolutePath(), sourceFile.getAbsolutePath());
        Process compileProcess = compilePb.start();
        int compileExitCode;
        try {
            compileExitCode = compileProcess.waitFor();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            sourceFile.delete();
            result.put("output", "Error: Compilation interrupted");
            result.put("testCasesPassed", 0);
            result.put("totalTestCases", calculateTotalTestCases(questionId));
            result.put("marks", 0);
            return result;
        }

        if (compileExitCode != 0) {
            BufferedReader errorReader = new BufferedReader(new InputStreamReader(compileProcess.getErrorStream()));
            StringBuilder errorOutput = new StringBuilder();
            String line;
            while ((line = errorReader.readLine()) != null) {
                errorOutput.append(line).append("\n");
            }
            sourceFile.delete();
            result.put("output", "Compilation Error: " + errorOutput.toString());
            result.put("testCasesPassed", 0);
            result.put("totalTestCases", calculateTotalTestCases(questionId));
            result.put("marks", 0);
            return result;
        }

        result = executeAndTestCode(cCode, questionId, submitAction, sessionId, language, userId, executableFile.getAbsolutePath());
        executableFile.delete();
        sourceFile.delete();
        return result;
    }

    private Map<String, Object> handleCPPCode(String cppCode, int questionId, String submitAction, String sessionId, String language, String userId)
            throws IOException {
        Map<String, Object> result = new HashMap<>();
        String cppFileName = "program.cpp";
        File sourceFile = new File(System.getProperty("java.io.tmpdir"), cppFileName);
        File executableFile = new File(System.getProperty("java.io.tmpdir"), "program");

        try (FileWriter writer = new FileWriter(sourceFile)) {
            writer.write(cppCode);
        }

        ProcessBuilder compilePb = new ProcessBuilder("g++", "-o", executableFile.getAbsolutePath(), sourceFile.getAbsolutePath());
        Process compileProcess = compilePb.start();
        int compileExitCode;
        try {
            compileExitCode = compileProcess.waitFor();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            sourceFile.delete();
            result.put("output", "Error: Compilation interrupted");
            result.put("testCasesPassed", 0);
            result.put("totalTestCases", calculateTotalTestCases(questionId));
            result.put("marks", 0);
            return result;
        }

        if (compileExitCode != 0) {
            BufferedReader errorReader = new BufferedReader(new InputStreamReader(compileProcess.getErrorStream()));
            StringBuilder errorOutput = new StringBuilder();
            String line;
            while ((line = errorReader.readLine()) != null) {
                errorOutput.append(line).append("\n");
            }
            sourceFile.delete();
            result.put("output", "Compilation Error: " + errorOutput.toString());
            result.put("testCasesPassed", 0);
            result.put("totalTestCases", calculateTotalTestCases(questionId));
            result.put("marks", 0);
            return result;
        }

        result = executeAndTestCode(cppCode, questionId, submitAction, sessionId, language, userId, executableFile.getAbsolutePath());
        executableFile.delete();
        sourceFile.delete();
        return result;
    }

    private Map<String, Object> handleJavaScriptCode(String jsCode, int questionId, String submitAction, String sessionId, String language, String userId)
            throws IOException {
        String jsFileName = "script.js";
        File sourceFile = new File(System.getProperty("java.io.tmpdir"), jsFileName);

        try (FileWriter writer = new FileWriter(sourceFile)) {
            writer.write(jsCode);
        }

        Map<String, Object> result = executeAndTestCode(jsCode, questionId, submitAction, sessionId, language, userId, "node", sourceFile.getAbsolutePath());
        sourceFile.delete();
        return result;
    }

    private int getNextQuestionId(int currentQuestionId) {
        try (Connection conn = getConnection()) {
            String sql = "SELECT id FROM coding_questions WHERE id > ? ORDER BY id LIMIT 1";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, currentQuestionId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    
    private void handleFinalSubmit(HttpServletRequest request, HttpServletResponse response, String userId)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String sessionId = session.getId();
        Map<Integer, Integer> testCasesPassedMap = getSubmittedTestCasesPassed(sessionId);
        int totalTestCasesPassed = testCasesPassedMap.values().stream().mapToInt(Integer::intValue).sum();
        int totalTestCasesAllQuestions = calculateTotalTestCasesAcrossAllQuestions();

        saveSubmissionResult(userId, totalTestCasesPassed, totalTestCasesAllQuestions);

        userOutputs.remove(sessionId);
        session.removeAttribute("submittedQuestionIds");
        getServletContext().removeAttribute(sessionId + "_testCasesPassed");

        String email = (String) session.getAttribute("email");
        Map<String, String> employeeDetails = getEmployeeDetailsFromEmail(email);
        String employeeName = employeeDetails.get("Name") != null ? employeeDetails.get("Name") : "Unknown Employee";

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html>");
        out.println("<html lang='en'>");
        out.println("<head>");
        out.println("    <meta charset='UTF-8'>");
        out.println("    <meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("    <title>Exam Submitted</title>");
        out.println("    <style>");
        out.println("        body {");
        out.println("            margin: 0;");
        out.println("            padding: 0;");
        out.println("            font-family: 'Segoe UI', Arial, sans-serif;");
        out.println("            background:white;");
        out.println("            height: 100vh;");
        out.println("            display: flex;");
        out.println("            justify-content: center;");
        out.println("            align-items: center;");
        out.println("        }");
        out.println("        .container {");
        out.println("            background-color: #ffffff;");
        out.println("            padding: 40px;");
        out.println("            border-radius: 15px;");
        out.println("            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);");
        out.println("            text-align: center;");
        out.println("            max-width: 500px;");
        out.println("            width: 90%;");
        out.println("            animation: fadeIn 1s ease-in-out;");
        out.println("        }");
        out.println("        @keyframes fadeIn {");
        out.println("            from { opacity: 0; transform: translateY(-20px); }");
        out.println("            to { opacity: 1; transform: translateY(0); }");
        out.println("        }");
        out.println("        h1 {");
        out.println("            color: #28a745;");
        out.println("            font-size: 32px;");
        out.println("            margin-bottom: 20px;");
        out.println("            text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.1);");
        out.println("        }");
        out.println("        p {");
        out.println("            color: #333;");
        out.println("            font-size: 18px;");
        out.println("            margin: 15px 0;");
        out.println("        }");
        out.println("        .highlight {");
        out.println("            color: #1a73e8;");
        out.println("            font-weight: bold;");
        out.println("        }");
        out.println("        .closing-note {");
        out.println("            font-style: italic;");
        out.println("            color: #666;");
        out.println("        }");
        out.println("    </style>");
        out.println("</head>");
        out.println("<body>");
        out.println("    <div class='container'>");
        out.println("        <h1>Exam Submitted Successfully</h1>");
        out.println("        <p>Thank you, <span class='highlight'>" + employeeName + "</span>, for completing the exam.</p>");
        out.println("        <p>Your results have been saved successfully.</p>");
        out.println("        <p class='closing-note'>This tab will close in 3 seconds.</p>");
        out.println("    </div>");
        out.println("    <script>");
        
        out.println("        setTimeout(function() { window.close(); }, 3000);");
        out.println("    </script>");
        out.println("</body>");
        out.println("</html>");
    }
    
    
    private int calculateTotalTestCases(int questionId) {
        try (Connection conn = getConnection()) {
            String sql = "SELECT test_cases FROM coding_questions WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, questionId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                JSONArray jsonArray = new JSONArray(rs.getString("test_cases"));
                return jsonArray.length();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}