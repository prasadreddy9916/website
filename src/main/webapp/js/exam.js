const maxQuestions = 50;
let questionIndex = 0;
let userAnswers = {};
let remainingTime = 60 * 60; // 60 minutes
let warningCount = 0;
const maxWarnings = 3;
let isSubmitting = false;
let refreshAttempted = false;
let lastSwitchTime = 0;
let timeWarningShown = false;
let examCompleted = false;

function launchAssessment() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            console.error("Fullscreen request failed:", err);
        });
    }

    document.addEventListener("fullscreenchange", () => {
        if (!document.fullscreenElement && !examCompleted) {
            showEscWarning("You cannot exit fullscreen mode until the exam is over!");
            document.documentElement.requestFullscreen();
        }
    });

    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape" && !examCompleted) {
            showEscWarning("You cannot exit fullscreen mode until the exam is over!");
        }
        if (e.key === "F5" || (e.ctrlKey && e.key === "r") || (e.metaKey && e.key === "r")) {
            e.preventDefault();
            refreshAttempted = true;
            showRefreshPopup();
        }
    });

    document.addEventListener("visibilitychange", handleSwitch);
    window.addEventListener("blur", handleSwitch);

    document.addEventListener('contextmenu', (event) => {
        event.preventDefault();
        showAlert('Right-click is disabled during the assessment.', null, hideAlert);
    });

    window.addEventListener('beforeunload', (event) => {
        if (isSubmitting || examCompleted) return;
        if (!refreshAttempted) {
            refreshAttempted = true;
            submitAssessmentForRefresh();
        }
        event.preventDefault();
        event.returnValue = 'Are you sure you want to leave? Your exam will be submitted.';
        return 'Are you sure you want to leave? Your exam will be submitted.';
    });

    showQuestion();
    updateProgressBar();
    runTimer();
    setupEndButton();
}

function showEscWarning(message) {
    const warningDiv = document.createElement("div");
    warningDiv.id = "esc-warning";
    warningDiv.textContent = message;
    warningDiv.style.position = "fixed";
    warningDiv.style.top = "20px";
    warningDiv.style.left = "50%";
    warningDiv.style.transform = "translateX(-50%)";
    warningDiv.style.backgroundColor = "red";
    warningDiv.style.color = "white";
    warningDiv.style.padding = "10px 20px";
    warningDiv.style.borderRadius = "5px";
    warningDiv.style.zIndex = "1000";
    warningDiv.style.boxShadow = "0 2px 10px rgba(0, 0, 0, 0.2)";
    document.body.appendChild(warningDiv);

    setTimeout(() => {
        if (warningDiv.parentNode) document.body.removeChild(warningDiv);
    }, 3000);
}

function showRefreshPopup() {
    showAlert(
        'The exam will be submitted if you refresh the page. Submit now?',
        submitAssessmentForRefresh,
        () => {
            refreshAttempted = false;
            hideAlert();
        }
    );
}

function showQuestion() {
    const q = assessmentQuestionsForExam[questionIndex];
    document.getElementById("question-header").textContent = `Question ${questionIndex + 1}`;
    document.getElementById("question-body").textContent = q.question;
    
    const choicesDiv = document.getElementById("answer-choices");
    choicesDiv.innerHTML = "";
    q.choices.forEach((choice, i) => {
        const choiceDiv = document.createElement("div");
        const radio = document.createElement("input");
        radio.type = "radio";
        radio.name = `q${questionIndex}`;
        radio.id = `choice${i}`;
        radio.onclick = () => {
            userAnswers[questionIndex] = choice;
            document.getElementById("advance-btn").disabled = false;
        };
        const label = document.createElement("label");
        label.htmlFor = `choice${i}`;
        label.textContent = choice;
        choiceDiv.appendChild(radio);
        choiceDiv.appendChild(label);
        choicesDiv.appendChild(choiceDiv);
    });

    const advanceBtn = document.getElementById("advance-btn");
    advanceBtn.textContent = questionIndex === maxQuestions - 1 ? "Submit" : "Next";
    advanceBtn.disabled = !userAnswers[questionIndex];
    advanceBtn.onclick = moveToNext;
}

function updateProgressBar() {
    const progressBar = document.getElementById("progress-bar");
    progressBar.innerHTML = "";
    for (let i = 0; i < maxQuestions; i++) {
        const indicator = document.createElement("div");
        indicator.className = "q-indicator" + (i < questionIndex ? " completed" : i === questionIndex ? " active" : "");
        indicator.textContent = `Q${i + 1}`;
        progressBar.appendChild(indicator);
    }
}

function runTimer() {
    setInterval(() => {
        if (remainingTime <= 0) {
            submitAssessment();
        } else {
            remainingTime--;
            const mins = Math.floor(remainingTime / 60);
            const secs = String(remainingTime % 60).padStart(2, "0");
            document.getElementById("time-remaining").textContent = `Time Left: ${mins}:${secs}`;
            
            if (remainingTime === 300 && !timeWarningShown) {
                showTimeWarning("Only 5 minutes remaining!");
                timeWarningShown = true;
            }
        }
    }, 1000);
}

function moveToNext() {
    if (questionIndex < maxQuestions - 1) {
        questionIndex++;
        showQuestion();
        updateProgressBar();
    } else {
        submitAssessmentFull();
    }
}

function calculateScoreDetails() {
    let correct = 0;
    const totalQuestions = 50;

    for (let i = 0; i < totalQuestions; i++) {
        if (userAnswers[i] === assessmentQuestionsForExam[i].answer) {
            correct++;
        }
    }

    const score = `${correct}/${totalQuestions}`;
    const percentage = (correct / totalQuestions) * 100;

    return { score, correct, percentage };
}

function submitAssessment() {
    isSubmitting = true;
    const { score, percentage } = calculateScoreDetails();
    const email = document.body.getAttribute("data-email");
    const data = `email=${encodeURIComponent(email)}&score=${encodeURIComponent(score)}`;

    fetch("exam.jsp", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: data
    })
    .then(response => {
        if (!response.ok) throw new Error("Network response was not ok: " + response.status);
        return response.text();
    })
    .then(text => {
        const data = JSON.parse(text);
        if (data.status === "success") {
            examCompleted = true;
            showSuccessMessage(`Exam successfully submitted`);
            setTimeout(() => {
                document.exitFullscreen().then(() => {
                    window.close();
                }).catch(err => {
                    console.error("Error exiting fullscreen:", err);
                    window.close();
                });
            }, 3000);
        } else {
            throw new Error(data.message || "Failed to submit exam");
        }
    })
    .catch(error => {
        console.error("Submission error:", error);
        alert("Failed to submit exam. Please try again.");
        isSubmitting = false;
    });
}

function submitAssessmentFull() {
    isSubmitting = true;
    const { score, percentage } = calculateScoreDetails();
    const email = document.body.getAttribute("data-email");
    const data = `email=${encodeURIComponent(email)}&score=${encodeURIComponent(score)}`;

    fetch("exam.jsp", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: data
    })
    .then(response => {
        if (!response.ok) throw new Error("Network response was not ok: " + response.status);
        return response.text();
    })
    .then(text => {
        const data = JSON.parse(text);
        if (data.status === "success") {
            examCompleted = true;
            showSuccessMessage(`Exam successfully submitted`);
            setTimeout(() => {
                document.exitFullscreen().then(() => {
                    window.close();
                }).catch(err => {
                    console.error("Error exiting fullscreen:", err);
                    window.close();
                });
            }, 3000);
        } else {
            throw new Error(data.message || "Failed to submit exam");
        }
    })
    .catch(error => {
        console.error("Submission error:", error);
        alert("Failed to submit exam. Please try again.");
        isSubmitting = false;
    });
}

function handleSwitch() {
    const currentTime = Date.now();
    if (currentTime - lastSwitchTime < 500) return;
    lastSwitchTime = currentTime;

    if (document.hidden || document.hasFocus() === false) {
        warningCount++;
        if (warningCount >= maxWarnings) {
            submitAssessment();
        } else {
            showAlert(
                'Warning: Do not switch tabs or browsers during the exam.',
                null,
                hideAlert
            );
        }
    }
}

function setupEndButton() {
    document.getElementById("end-assessment").onclick = () => {
        const answered = Object.keys(userAnswers).length;
        if (answered === maxQuestions) {
            showAlert("Do you want to submit the exam?", submitAssessmentFull, hideAlert);
        } else {
            showAlert(
                "You haven't answered all questions. Force submit or cancel?",
                null,
                null,
                submitAssessmentFull,
                hideAlert
            );
        }
    };
}

function showAlert(msg, submitFn, stayFn, forceFn, cancelFn) {
    const alertBox = document.getElementById("alert-box");
    document.getElementById("alert-text").textContent = msg;
    const submitBtn = document.getElementById("alert-submit");
    const stayBtn = document.getElementById("alert-stay");
    const forceBtn = document.getElementById("alert-force");
    const cancelBtn = document.getElementById("alert-cancel");

    submitBtn.classList.add("hidden");
    stayBtn.classList.add("hidden");
    forceBtn.classList.add("hidden");
    cancelBtn.classList.add("hidden");

    if (submitFn && stayFn) {
        submitBtn.classList.remove("hidden");
        stayBtn.classList.remove("hidden");
        submitBtn.onclick = submitFn;
        stayBtn.onclick = stayFn;
    } else if (forceFn && cancelFn) {
        forceBtn.classList.remove("hidden");
        cancelBtn.classList.remove("hidden");
        forceBtn.onclick = forceFn;
        cancelBtn.onclick = cancelFn;
    } else if (submitFn) {
        submitBtn.classList.remove("hidden");
        submitBtn.onclick = submitFn;
    } else if (stayFn) {
        stayBtn.classList.remove("hidden");
        stayBtn.onclick = stayFn;
    }
    alertBox.classList.remove("hidden");
}

function hideAlert() {
    document.getElementById("alert-box").classList.add("hidden");
}

function submitAssessmentForRefresh() {
    isSubmitting = true;
    const { score, percentage } = calculateScoreDetails();
    const email = document.body.getAttribute("data-email");
    const data = `email=${encodeURIComponent(email)}&score=${encodeURIComponent(score)}`;

    fetch("exam.jsp", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: data
    })
    .then(response => {
        if (!response.ok) throw new Error("Network response was not ok: " + response.status);
        return response.text();
    })
    .then(text => {
        const data = JSON.parse(text);
        if (data.status === "success") {
            examCompleted = true;
            showSuccessMessage(`Exam successfully submitted`);
            setTimeout(() => {
                document.exitFullscreen().then(() => {
                    window.close();
                }).catch(err => {
                    console.error("Error exiting fullscreen:", err);
                    window.close();
                });
            }, 3000);
        } else {
            throw new Error(data.message || "Failed to submit exam");
        }
    })
    .catch(error => {
        console.error("Submission error:", error);
        alert("Failed to submit exam due to refresh. Please try again.");
        isSubmitting = false;
        refreshAttempted = false;
    });
}

function showSuccessMessage(message) {
    const successDiv = document.createElement("div");
    successDiv.id = "success-message";
    successDiv.textContent = message;
    successDiv.style.position = "fixed";
    successDiv.style.top = "20px";
    successDiv.style.left = "50%";
    successDiv.style.transform = "translateX(-50%)";
    successDiv.style.backgroundColor = "green";
    successDiv.style.color = "white";
    successDiv.style.padding = "10px 20px";
    successDiv.style.borderRadius = "5px";
    successDiv.style.zIndex = "1000";
    successDiv.style.boxShadow = "0 2px 10px rgba(0, 0, 0, 0.2)";
    document.body.appendChild(successDiv);

    setTimeout(() => {
        if (successDiv.parentNode) document.body.removeChild(successDiv);
    }, 3000);
}

function showTimeWarning(message) {
    const warningDiv = document.createElement("div");
    warningDiv.id = "time-warning";
    warningDiv.textContent = message;
    warningDiv.style.position = "fixed";
    warningDiv.style.top = "20px";
    warningDiv.style.left = "50%";
    warningDiv.style.transform = "translateX(-50%)";
    warningDiv.style.backgroundColor = "red";
    warningDiv.style.color = "white";
    warningDiv.style.padding = "10px 20px";
    warningDiv.style.borderRadius = "5px";
    warningDiv.style.zIndex = "1000";
    warningDiv.style.boxShadow = "0 2px 10px rgba(0, 0, 0, 0.2)";
    document.body.appendChild(warningDiv);

    setTimeout(() => {
        if (warningDiv.parentNode) document.body.removeChild(warningDiv);
    }, 3000);
}

launchAssessment();