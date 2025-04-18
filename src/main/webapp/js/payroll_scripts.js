function loadSection(page) {
    // This assumes you're using the same iframe loading mechanism as in admin_dashboard.jsp
    // The parent refers to the admin_dashboard.jsp window
    parent.loadIframe(page);
}