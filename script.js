// CastroEduConnect - Main JavaScript

// ============================================
// 1. CONFIGURATION
// ============================================

const CONFIG = {
    SUPABASE_URL: 'https://kfeqmjveemfacrmqrhzk.supabase.co',
    SUPABASE_ANON_KEY: 'sb_publishable_p5OiC1XnOlBLKs2nUYAL1w_LBBh5kDo',
    APP_NAME: 'CastroEduConnect',
    APP_VERSION: '1.0.0'
};

// ============================================
// 2. UTILITY FUNCTIONS
// ============================================

// Toast notifications
function showToast(message, type = 'info', duration = 3000) {
    const container = document.getElementById('toast-container') || createToastContainer();
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
        <div class="flex items-center justify-between">
            <span>${message}</span>
            <button onclick="this.parentElement.parentElement.remove()" class="ml-4 text-white/80 hover:text-white">
                <i class="fas fa-times"></i>
            </button>
        </div>
    `;
    container.appendChild(toast);
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(100%)';
        toast.style.transition = 'all 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, duration);
}

function createToastContainer() {
    const container = document.createElement('div');
    container.id = 'toast-container';
    container.className = 'toast-container';
    document.body.appendChild(container);
    return container;
}

// Loading skeleton
function showSkeleton(containerId, count = 3) {
    const container = document.getElementById(containerId);
    if (!container) return;
    container.innerHTML = '';
    for (let i = 0; i < count; i++) {
        const skeleton = document.createElement('div');
        skeleton.className = 'skeleton rounded-xl p-6 h-32';
        skeleton.style.marginBottom = '1rem';
        container.appendChild(skeleton);
    }
}

function hideSkeleton(containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;
    container.innerHTML = '';
}

// Format date
function formatDate(date) {
    return new Date(date).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// Format time
function formatTime(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hours ? hours + 'h ' : ''}${minutes}m ${secs}s`;
}

// Calculate grade
function calculateGrade(percentage) {
    if (percentage >= 80) return { letter: 'A', color: '#10B981' };
    if (percentage >= 70) return { letter: 'B', color: '#3B82F6' };
    if (percentage >= 60) return { letter: 'C', color: '#F59E0B' };
    if (percentage >= 50) return { letter: 'D', color: '#F97316' };
    return { letter: 'F', color: '#EF4444' };
}

// ============================================
// 3. DARK MODE TOGGLE
// ============================================

function toggleDarkMode() {
    const html = document.documentElement;
    const isDark = html.classList.toggle('dark');
    localStorage.setItem('darkMode', isDark ? 'true' : 'false');
    updateDarkModeIcon(isDark);
}

function updateDarkModeIcon(isDark) {
    const icon = document.getElementById('dark-mode-icon');
    if (icon) {
        icon.className = isDark ? 'fas fa-sun' : 'fas fa-moon';
    }
}

function initDarkMode() {
    const saved = localStorage.getItem('darkMode');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const isDark = saved ? saved === 'true' : prefersDark;
    if (isDark) {
        document.documentElement.classList.add('dark');
        updateDarkModeIcon(true);
    }
}

// ============================================
// 4. SEARCH FUNCTIONALITY
// ============================================

function globalSearch(query) {
    if (!query || query.length < 2) {
        showToast('Please enter at least 2 characters', 'warning');
        return;
    }
    // This will be implemented with Supabase
    console.log('Searching for:', query);
    showToast(`Searching for "${query}"...`, 'info');
}

// ============================================
// 5. PAGINATION
// ============================================

function setupPagination(totalItems, itemsPerPage, currentPage = 1) {
    const totalPages = Math.ceil(totalItems / itemsPerPage);
    const start = (currentPage - 1) * itemsPerPage;
    const end = Math.min(start + itemsPerPage, totalItems);
    return { totalPages, start, end, currentPage };
}

// ============================================
// 6. FILE UPLOAD HANDLER
// ============================================

function handleFileUpload(file, allowedTypes = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'mp4']) {
    const extension = file.name.split('.').pop().toLowerCase();
    if (!allowedTypes.includes(extension)) {
        showToast(`File type .${extension} not allowed`, 'error');
        return false;
    }
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (file.size > maxSize) {
        showToast('File size exceeds 10MB limit', 'error');
        return false;
    }
    return true;
}

// ============================================
// 7. CHART HELPERS (Using Canvas API)
// ============================================

function createBarChart(canvasId, data, labels, colors) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const width = canvas.width || 400;
    const height = canvas.height || 200;
    const barWidth = (width / data.length) * 0.6;
    const maxValue = Math.max(...data) * 1.2;
    
    ctx.clearRect(0, 0, width, height);
    
    // Draw bars
    data.forEach((value, index) => {
        const x = (index / data.length) * width + (width / data.length - barWidth) / 2;
        const barHeight = (value / maxValue) * (height - 40);
        const y = height - barHeight - 20;
        
        ctx.fillStyle = colors[index] || '#2563EB';
        ctx.shadowColor = 'rgba(37, 99, 235, 0.3)';
        ctx.shadowBlur = 10;
        ctx.fillRect(x, y, barWidth, barHeight);
        ctx.shadowBlur = 0;
        
        // Labels
        ctx.fillStyle = '#6B7280';
        ctx.font = '12px Inter, sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText(labels[index] || '', x + barWidth / 2, height - 5);
        
        // Values
        ctx.fillStyle = '#1F2937';
        ctx.font = 'bold 12px Inter, sans-serif';
        ctx.fillText(value, x + barWidth / 2, y - 8);
    });
}

// ============================================
// 8. FORM VALIDATION
// ============================================

function validateForm(formId) {
    const form = document.getElementById(formId);
    if (!form) return false;
    
    const inputs = form.querySelectorAll('input[required], select[required], textarea[required]');
    let isValid = true;
    
    inputs.forEach(input => {
        if (!input.value.trim()) {
            input.classList.add('border-red-500');
            isValid = false;
            showToast(`Please fill in ${input.name || 'all required fields'}`, 'error');
        } else {
            input.classList.remove('border-red-500');
        }
    });
    
    return isValid;
}

// ============================================
// 9. INITIALIZATION
// ============================================

document.addEventListener('DOMContentLoaded', function() {
    // Initialize dark mode
    initDarkMode();
    
    // Setup dark mode toggle
    const darkToggle = document.getElementById('dark-mode-toggle');
    if (darkToggle) {
        darkToggle.addEventListener('click', toggleDarkMode);
    }
    
    // Setup search
    const searchInput = document.getElementById('global-search');
    if (searchInput) {
        let searchTimeout;
        searchInput.addEventListener('input', function(e) {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                globalSearch(e.target.value);
            }, 500);
        });
    }
    
    // Show welcome message
    console.log(`🚀 ${CONFIG.APP_NAME} v${CONFIG.APP_VERSION} loaded successfully!`);
});

// ============================================
// 10. EXPOSE GLOBALLY
// ============================================

window.showToast = showToast;
window.showSkeleton = showSkeleton;
window.hideSkeleton = hideSkeleton;
window.formatDate = formatDate;
window.calculateGrade = calculateGrade;
window.toggleDarkMode = toggleDarkMode;
window.globalSearch = globalSearch;
window.validateForm = validateForm;
window.handleFileUpload = handleFileUpload;
window.createBarChart = createBarChart;