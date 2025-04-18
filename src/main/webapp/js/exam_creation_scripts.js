document.addEventListener('DOMContentLoaded', () => {
    const successMessage = document.getElementById('successMessage');
    const form = document.getElementById('assignmentForm');

    if (successMessage) {
        setTimeout(() => {
            successMessage.classList.add('hidden');
            setTimeout(() => {
                successMessage.style.display = 'none';
                form.reset();
            }, 500); // Match transition duration
        }, 3000); // Display for 3 seconds
    }
});