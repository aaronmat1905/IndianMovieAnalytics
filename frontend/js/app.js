// Main Application

// Current page module
let currentModule = null;

// Page modules mapping
const pageModules = {
    'dashboard': Dashboard,
    'movies': Movies,
    'producers': Producers,
    'actors': Actors,
    'crew': Crew,
    'box-office': BoxOffice,
    'analytics': Analytics,
    'procedures': Procedures
};

// Initialize app on page load
document.addEventListener('DOMContentLoaded', function() {
    console.log('Indian Cinema DBMS - Frontend Loaded');

    // Set up navigation
    setupNavigation();

    // Load dashboard by default
    navigateTo('dashboard');
});

// Setup navigation handlers
function setupNavigation() {
    const navLinks = document.querySelectorAll('.navbar-nav .nav-link');

    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();

            // Update active state
            navLinks.forEach(l => l.classList.remove('active'));
            this.classList.add('active');

            // Get page name
            const page = this.dataset.page;
            if (page) {
                navigateTo(page);
            }
        });
    });
}

// Navigate to a page
async function navigateTo(pageName) {
    const module = pageModules[pageName];

    if (!module) {
        console.error('Page module not found:', pageName);
        showToast('Page not found', 'Error', 'error');
        return;
    }

    try {
        // Destroy current module if it has a destroy method
        if (currentModule && typeof currentModule.destroy === 'function') {
            currentModule.destroy();
        }

        // Set current module
        currentModule = module;

        // Initialize the module
        await module.init();

    } catch (error) {
        console.error('Error loading page:', error);
        showToast('Failed to load page', 'Error', 'error');

        // Show error page
        document.getElementById('content-area').innerHTML = `
            <div class="alert alert-danger">
                <h4><i class="bi bi-exclamation-triangle"></i> Error Loading Page</h4>
                <p>${error.message || 'An unexpected error occurred'}</p>
                <button class="btn btn-primary" onclick="navigateTo('dashboard')">
                    <i class="bi bi-house"></i> Go to Dashboard
                </button>
            </div>
        `;
    }
}

// Global error handler
window.addEventListener('error', function(e) {
    console.error('Global error:', e.error);
});

// Handle unhandled promise rejections
window.addEventListener('unhandledrejection', function(e) {
    console.error('Unhandled promise rejection:', e.reason);
    showToast('An error occurred. Check console for details.', 'Error', 'error');
});
