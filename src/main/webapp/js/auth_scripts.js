document.addEventListener('DOMContentLoaded', () => {
    // Banner Rotation
    const banners = document.querySelectorAll('.banner');
    const dots = document.querySelectorAll('.banner-indicators .dot');
    let currentBanner = 0;

    function showNextBanner() {
        banners[currentBanner].classList.remove('active');
        dots[currentBanner].classList.remove('active');
        currentBanner = (currentBanner + 1) % banners.length;
        banners[currentBanner].classList.add('active');
        dots[currentBanner].classList.add('active');
    }

    // Initialize first banner and dot
    banners[0].classList.add('active');
    dots[0].classList.add('active');
    setInterval(showNextBanner, 5000); // Change every 5 seconds

    // Toggle Menu
    const toggleBtn = document.querySelector('.toggle-btn');
    const toggleMenu = document.querySelector('.toggle-menu');

    toggleBtn.addEventListener('click', (e) => {
        e.stopPropagation(); // Prevent immediate closure
        toggleMenu.classList.toggle('active');
    });

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!toggleMenu.contains(e.target) && !toggleBtn.contains(e.target)) {
            toggleMenu.classList.remove('active');
        }
    });
});