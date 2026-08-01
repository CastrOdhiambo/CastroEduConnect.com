<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login - CastroEduConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="style.css" />
    
    <!-- Supabase SDK -->
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    
    <style>
        .input-error {
            border-color: #EF4444 !important;
        }
        .input-error:focus {
            border-color: #EF4444 !important;
            ring-color: #EF4444 !important;
        }
        
        .error-message {
            color: #EF4444;
            font-size: 0.75rem;
            margin-top: 0.25rem;
            display: none;
        }
        .error-message.show {
            display: block;
        }
        
        .spinner {
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .login-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
        }
        .dark .login-card {
            background: rgba(17, 24, 39, 0.9);
        }
        
        .toast-container {
            position: fixed;
            top: 1rem;
            right: 1rem;
            z-index: 9999;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        .toast {
            padding: 1rem 1.5rem;
            border-radius: 0.75rem;
            color: white;
            animation: slideInRight 0.5s ease;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            min-width: 300px;
            max-width: 450px;
        }
        .toast-success { background: #10B981; }
        .toast-error { background: #EF4444; }
        .toast-warning { background: #F59E0B; }
        .toast-info { background: #3B82F6; }
        @keyframes slideInRight {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 p-4">
    <div class="w-full max-w-md">
        <div class="login-card rounded-3xl shadow-2xl p-8 border border-gray-200 dark:border-gray-700">
            <!-- Logo & Header -->
            <div class="text-center mb-8">
                <div class="flex justify-center mb-4">
                    <div class="w-16 h-16 gradient-bg rounded-2xl flex items-center justify-center shadow-lg">
                        <i class="fas fa-graduation-cap text-white text-3xl"></i>
                    </div>
                </div>
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Welcome Back!</h2>
                <p class="text-gray-600 dark:text-gray-400 mt-2">Login to your CastroEduConnect account</p>
            </div>
            
            <!-- Login Form -->
            <form id="login-form" class="space-y-6">
                <!-- Email -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                        <i class="fas fa-envelope text-blue-600 dark:text-blue-400 mr-1"></i> Email Address
                    </label>
                    <div class="relative">
                        <i class="fas fa-envelope absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                        <input type="email" id="email" required placeholder="you@example.com" 
                               class="w-full pl-10 pr-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white transition" />
                    </div>
                    <div class="error-message" id="email-error">Please enter your email address</div>
                </div>
                
                <!-- Password -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                        <i class="fas fa-lock text-blue-600 dark:text-blue-400 mr-1"></i> Password
                    </label>
                    <div class="relative">
                        <i class="fas fa-lock absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                        <input type="password" id="password" required placeholder="••••••••" 
                               class="w-full pl-10 pr-12 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white transition" />
                        <button type="button" onclick="togglePassword()" 
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition">
                            <i id="password-toggle-icon" class="fas fa-eye"></i>
                        </button>
                    </div>
                    <div class="error-message" id="password-error">Please enter your password</div>
                </div>
                
                <!-- Remember Me & Forgot Password -->
                <div class="flex items-center justify-between">
                    <label class="flex items-center space-x-2 cursor-pointer">
                        <input type="checkbox" id="remember-me" 
                               class="w-4 h-4 rounded border-gray-300 dark:border-gray-600 text-blue-600 focus:ring-blue-500" />
                        <span class="text-sm text-gray-600 dark:text-gray-400">Remember me</span>
                    </label>
                    <a href="forgot-password.html" class="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 font-medium transition">
                        Forgot password?
                    </a>
                </div>
                
                <!-- Login Button -->
                <button type="submit" id="login-btn" 
                        class="w-full btn-primary py-3 rounded-xl text-white font-semibold text-lg transition-all duration-300 flex items-center justify-center space-x-2">
                    <i class="fas fa-sign-in-alt"></i>
                    <span>Login</span>
                </button>
            </form>
            
            <!-- Register Link -->
            <div class="mt-6 text-center">
                <p class="text-gray-600 dark:text-gray-400">
                    Don't have an account? 
                    <a href="register.html" class="text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 font-medium transition">
                        Sign up
                    </a>
                </p>
            </div>
            
            <!-- Divider -->
            <div class="relative my-6">
                <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-gray-300 dark:border-gray-600"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                    <span class="px-4 bg-white dark:bg-gray-800 text-gray-500 dark:text-gray-400">or continue with</span>
                </div>
            </div>
            
            <!-- Social Login -->
            <div class="flex justify-center space-x-4">
                <button type="button" onclick="socialLogin('google')" 
                        class="w-12 h-12 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center hover:bg-gray-200 dark:hover:bg-gray-600 transition transform hover:scale-105">
                    <i class="fab fa-google text-red-500 text-xl"></i>
                </button>
                <button type="button" onclick="socialLogin('facebook')" 
                        class="w-12 h-12 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center hover:bg-gray-200 dark:hover:bg-gray-600 transition transform hover:scale-105">
                    <i class="fab fa-facebook text-blue-600 text-xl"></i>
                </button>
                <button type="button" onclick="socialLogin('github')" 
                        class="w-12 h-12 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center hover:bg-gray-200 dark:hover:bg-gray-600 transition transform hover:scale-105">
                    <i class="fab fa-github text-gray-900 dark:text-white text-xl"></i>
                </button>
            </div>
        </div>
        
        <!-- Footer -->
        <p class="text-center text-gray-500 dark:text-gray-400 text-sm mt-6">
            © 2026 CastroEduConnect. All rights reserved.
        </p>
    </div>
    
    <!-- Toast Container -->
    <div id="toast-container" class="toast-container"></div>
    
    <script>
        // ============================================
        // SUPABASE CONFIGURATION
        // ============================================
        const SUPABASE_URL = 'https://kfeqmjveemfacrmqrhzk.supabase.co';
        const SUPABASE_ANON_KEY = 'sb_publishable_p5OiC1XnOlBLKs2nUYAL1w_LBBh5kDo';
        
        // Initialize Supabase client
        const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        console.log('✅ Supabase client initialized');

        // ============================================
        // TOGGLE PASSWORD VISIBILITY
        // ============================================
        function togglePassword() {
            const input = document.getElementById('password');
            const icon = document.getElementById('password-toggle-icon');
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.className = 'fas fa-eye-slash';
            } else {
                input.type = 'password';
                icon.className = 'fas fa-eye';
            }
        }

        // ============================================
        // SHOW TOAST MESSAGES
        // ============================================
        function showToast(message, type = 'info', duration = 3000) {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            toast.className = `toast toast-${type}`;
            toast.innerHTML = `
                <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-2">
                        ${type === 'success' ? '<i class="fas fa-check-circle"></i>' : ''}
                        ${type === 'error' ? '<i class="fas fa-exclamation-circle"></i>' : ''}
                        ${type === 'warning' ? '<i class="fas fa-exclamation-triangle"></i>' : ''}
                        ${type === 'info' ? '<i class="fas fa-info-circle"></i>' : ''}
                        <span>${message}</span>
                    </div>
                    <button onclick="this.parentElement.parentElement.remove()" class="text-white/80 hover:text-white">
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

        // ============================================
        // CHECK IF USER IS ALREADY LOGGED IN
        // ============================================
        async function checkExistingSession() {
            try {
                const { data: { session }, error } = await supabaseClient.auth.getSession();
                
                if (error) {
                    console.error('Session check error:', error);
                    return false;
                }
                
                if (session) {
                    console.log('✅ User already logged in:', session.user.email);
                    return true;
                }
                
                return false;
            } catch (error) {
                console.error('Session check error:', error);
                return false;
            }
        }

        // ============================================
        // SOCIAL LOGIN
        // ============================================
        async function socialLogin(provider) {
            try {
                showToast(`Redirecting to ${provider}...`, 'info');
                
                const { data, error } = await supabaseClient.auth.signInWithOAuth({
                    provider: provider,
                    options: {
                        redirectTo: `${window.location.origin}/dashboard.html`
                    }
                });
                
                if (error) throw error;
                
            } catch (error) {
                console.error('Social login error:', error);
                showToast(`Failed to login with ${provider}: ${error.message}`, 'error');
            }
        }

        // ============================================
        // HANDLE LOGIN
        // ============================================
        document.getElementById('login-form').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            // Get values
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;
            const rememberMe = document.getElementById('remember-me').checked;
            
            // Reset errors
            document.querySelectorAll('.input-error').forEach(el => el.classList.remove('input-error'));
            document.querySelectorAll('.error-message.show').forEach(el => el.classList.remove('show'));
            
            // Validate Email
            if (!email) {
                document.getElementById('email').classList.add('input-error');
                document.getElementById('email-error').classList.add('show');
                showToast('Please enter your email address', 'error');
                return;
            }
            
            // Validate Password
            if (!password) {
                document.getElementById('password').classList.add('input-error');
                document.getElementById('password-error').classList.add('show');
                showToast('Please enter your password', 'error');
                return;
            }
            
            // Show loading state
            const btn = document.getElementById('login-btn');
            const originalText = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner spinner"></i> Logging in...';
            
            try {
                // ============================================
                // SUPABASE LOGIN
                // ============================================
                const { data, error } = await supabaseClient.auth.signInWithPassword({
                    email: email,
                    password: password
                });
                
                if (error) {
                    throw new Error(error.message);
                }
                
                console.log('✅ Login successful:', data.user.email);
                
                // Store session in localStorage if remember me is checked
                if (rememberMe) {
                    localStorage.setItem('supabase.auth.token', JSON.stringify(data.session));
                }
                
                // Show success message
                showToast('Welcome back! 🎉 Redirecting...', 'success');
                
                // Update button
                btn.innerHTML = '<i class="fas fa-check-circle"></i> Logged In!';
                btn.className = 'w-full bg-green-500 py-3 rounded-xl text-white font-semibold text-lg';
                
                // Redirect to dashboard
                setTimeout(() => {
                    window.location.href = 'dashboard.html';
                }, 1500);
                
            } catch (error) {
                console.error('❌ Login error:', error);
                
                // Handle specific error cases
                let errorMessage = error.message;
                if (error.message.includes('Invalid login credentials')) {
                    errorMessage = 'Invalid email or password. Please try again.';
                } else if (error.message.includes('Email not confirmed')) {
                    errorMessage = 'Please verify your email address before logging in.';
                } else if (error.message.includes('Too many requests')) {
                    errorMessage = 'Too many login attempts. Please wait a moment.';
                }
                
                showToast(errorMessage, 'error');
                
                // Reset button
                btn.disabled = false;
                btn.innerHTML = originalText;
                btn.className = 'w-full btn-primary py-3 rounded-xl text-white font-semibold text-lg flex items-center justify-center space-x-2';
            }
        });

        // ============================================
        // REMOVE ERROR STATES ON INPUT
        // ============================================
        document.getElementById('email').addEventListener('input', function() {
            this.classList.remove('input-error');
            document.getElementById('email-error').classList.remove('show');
        });
        
        document.getElementById('password').addEventListener('input', function() {
            this.classList.remove('input-error');
            document.getElementById('password-error').classList.remove('show');
        });

        // ============================================
        // KEYBOARD SHORTCUTS
        // ============================================
        document.addEventListener('keydown', function(e) {
            // Ctrl+Enter to submit form
            if (e.ctrlKey && e.key === 'Enter') {
                document.getElementById('login-form').dispatchEvent(new Event('submit'));
            }
        });

        // ============================================
        // DEMO CREDENTIALS (for testing)
        // ============================================
        function fillDemoCredentials() {
            document.getElementById('email').value = 'demo@castroeduconnect.com';
            document.getElementById('password').value = 'Demo123!@#';
            showToast('Demo credentials filled! Click Login', 'info');
        }

        // ============================================
        // INITIALIZATION
        // ============================================
        (async function init() {
            console.log('🚀 CastroEduConnect Login Page Loading...');
            console.log('📧 Supabase URL:', SUPABASE_URL);
            console.log('🔑 Supabase Key:', SUPABASE_ANON_KEY.substring(0, 20) + '...');
            
            // Check if user is already logged in
            const hasSession = await checkExistingSession();
            
            if (hasSession) {
                console.log('👤 Active session found, redirecting to dashboard...');
                showToast('You are already logged in! Redirecting...', 'info');
                setTimeout(() => {
                    window.location.href = 'dashboard.html';
                }, 1000);
                return;
            }
            
            console.log('👤 No active session, showing login form');
            
            // Add demo fill option (double-click on logo)
            document.querySelector('.gradient-bg').addEventListener('dblclick', fillDemoCredentials);
            console.log('💡 Double-click the logo to fill demo credentials');
            
            console.log('✅ Login page initialized successfully');
        })();
    </script>
</body>
</html>
