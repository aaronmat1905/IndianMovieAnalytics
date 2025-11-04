// Utility Functions

// Show loading overlay
function showLoading() {
    document.getElementById('loading-overlay').classList.remove('d-none');
}

// Hide loading overlay
function hideLoading() {
    document.getElementById('loading-overlay').classList.add('d-none');
}

// Show toast notification
function showToast(message, title = 'Notification', type = 'info') {
    const toast = document.getElementById('notification-toast');
    const toastTitle = document.getElementById('toast-title');
    const toastMessage = document.getElementById('toast-message');

    toastTitle.textContent = title;
    toastMessage.textContent = message;

    // Update toast color based on type
    toast.className = 'toast';
    if (type === 'success') {
        toast.classList.add('bg-success', 'text-white');
    } else if (type === 'error') {
        toast.classList.add('bg-danger', 'text-white');
    } else if (type === 'warning') {
        toast.classList.add('bg-warning');
    } else {
        toast.classList.add('bg-info', 'text-white');
    }

    const bsToast = new bootstrap.Toast(toast, {
        autohide: true,
        delay: APP_CONFIG.TOAST_DURATION
    });
    bsToast.show();
}

// Format currency (Indian Rupees)
function formatCurrency(amount) {
    if (!amount && amount !== 0) return '₹0';
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 2
    }).format(amount);
}

// Format currency in Crores
function formatCurrencyCrores(amount) {
    if (!amount && amount !== 0) return '₹0 Cr';
    const crores = amount / 10000000;
    return `₹${crores.toFixed(2)} Cr`;
}

// Format date
function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

// Format datetime
function formatDateTime(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// Debounce function
function debounce(func, delay) {
    let timeoutId;
    return function (...args) {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => func.apply(this, args), delay);
    };
}

// Sanitize HTML to prevent XSS
function sanitizeHTML(str) {
    const temp = document.createElement('div');
    temp.textContent = str;
    return temp.innerHTML;
}

// Get status badge HTML
function getStatusBadge(status) {
    const statusMap = {
        'Not Scheduled': 'secondary',
        'Upcoming': 'info',
        'Releasing Today': 'warning',
        'Released (Collection Pending)': 'primary',
        'Released': 'success'
    };
    const badgeClass = statusMap[status] || 'secondary';
    return `<span class="badge bg-${badgeClass}">${status}</span>`;
}

// Get collection status badge
function getCollectionStatusBadge(status) {
    const statusMap = {
        'pending': 'warning',
        'updated': 'success'
    };
    const badgeClass = statusMap[status] || 'secondary';
    return `<span class="badge bg-${badgeClass}">${status}</span>`;
}

// Calculate profit percentage
function calculateProfitPercentage(budget, collection) {
    if (!budget || budget === 0) return 0;
    const profit = collection - budget;
    return ((profit / budget) * 100).toFixed(2);
}

// Get profit badge with color
function getProfitBadge(profitPercentage) {
    let badgeClass = 'secondary';
    if (profitPercentage > 50) {
        badgeClass = 'success';
    } else if (profitPercentage > 0) {
        badgeClass = 'info';
    } else if (profitPercentage < 0) {
        badgeClass = 'danger';
    }
    return `<span class="badge bg-${badgeClass}">${profitPercentage}%</span>`;
}

// Create pagination HTML
function createPagination(currentPage, totalPages, onPageChange) {
    if (totalPages <= 1) return '';

    let html = '<nav><ul class="pagination justify-content-center">';

    // Previous button
    html += `<li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
        <a class="page-link" href="#" data-page="${currentPage - 1}">Previous</a>
    </li>`;

    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        if (i === 1 || i === totalPages || (i >= currentPage - 2 && i <= currentPage + 2)) {
            html += `<li class="page-item ${i === currentPage ? 'active' : ''}">
                <a class="page-link" href="#" data-page="${i}">${i}</a>
            </li>`;
        } else if (i === currentPage - 3 || i === currentPage + 3) {
            html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
        }
    }

    // Next button
    html += `<li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
        <a class="page-link" href="#" data-page="${currentPage + 1}">Next</a>
    </li>`;

    html += '</ul></nav>';

    return html;
}

// Handle pagination clicks
function handlePaginationClick(event, callback) {
    event.preventDefault();
    const page = parseInt(event.target.dataset.page);
    if (page && !isNaN(page)) {
        callback(page);
    }
}

// Confirm dialog
function confirmAction(message) {
    return confirm(message);
}

// Get rating stars HTML
function getRatingStars(rating) {
    if (!rating) return '-';
    const fullStars = Math.floor(rating);
    const halfStar = rating % 1 >= 0.5 ? 1 : 0;
    const emptyStars = 5 - fullStars - halfStar;

    let html = '';
    for (let i = 0; i < fullStars; i++) {
        html += '<i class="bi bi-star-fill text-warning"></i>';
    }
    if (halfStar) {
        html += '<i class="bi bi-star-half text-warning"></i>';
    }
    for (let i = 0; i < emptyStars; i++) {
        html += '<i class="bi bi-star text-warning"></i>';
    }
    html += ` <span class="text-muted">${rating.toFixed(1)}</span>`;
    return html;
}

// Validate form fields
function validateForm(formId) {
    const form = document.getElementById(formId);
    if (!form) return false;

    if (!form.checkValidity()) {
        form.classList.add('was-validated');
        return false;
    }
    return true;
}

// Get form data as object
function getFormData(formId) {
    const form = document.getElementById(formId);
    if (!form) return {};

    const formData = new FormData(form);
    const data = {};

    for (let [key, value] of formData.entries()) {
        // Convert empty strings to null
        if (value === '') {
            data[key] = null;
        } else {
            data[key] = value;
        }
    }

    return data;
}

// Reset form
function resetForm(formId) {
    const form = document.getElementById(formId);
    if (form) {
        form.reset();
        form.classList.remove('was-validated');
    }
}

// Populate select element with options
function populateSelect(selectId, options, valueKey = 'id', labelKey = 'name', includeEmpty = true) {
    const select = document.getElementById(selectId);
    if (!select) return;

    select.innerHTML = '';

    if (includeEmpty) {
        select.innerHTML = '<option value="">-- Select --</option>';
    }

    options.forEach(option => {
        const optionElement = document.createElement('option');
        optionElement.value = option[valueKey];
        optionElement.textContent = option[labelKey];
        select.appendChild(optionElement);
    });
}

// Format duration in minutes to hours and minutes
function formatDuration(minutes) {
    if (!minutes) return '-';
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours}h ${mins}m`;
}

// Truncate text
function truncateText(text, maxLength = 100) {
    if (!text) return '-';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
}

// Export to CSV
function exportToCSV(data, filename) {
    if (!data || !data.length) {
        showToast('No data to export', 'Export', 'warning');
        return;
    }

    const headers = Object.keys(data[0]);
    const csvContent = [
        headers.join(','),
        ...data.map(row => headers.map(header => {
            const value = row[header];
            return typeof value === 'string' && value.includes(',')
                ? `"${value}"`
                : value;
        }).join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);

    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    showToast('Data exported successfully', 'Export', 'success');
}
