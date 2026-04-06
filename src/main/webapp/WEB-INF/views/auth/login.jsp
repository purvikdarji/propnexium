<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Sign In – PropNexium</title>
            <meta name="description" content="Sign in to PropNexium — India's trusted real estate platform.">
            <style>
                * {
                    box-sizing: border-box;
                    margin: 0;
                    padding: 0;
                }

                body {
                    font-family: 'Segoe UI', Arial, sans-serif;
                    min-height: 100vh;
                    background: linear-gradient(135deg, #0d47a1 0%, #1a73e8 40%, #1565c0 100%);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 24px;
                }

                .login-container {
                    display: flex;
                    background: #fff;
                    border-radius: 20px;
                    overflow: hidden;
                    box-shadow: 0 24px 80px rgba(0, 0, 0, 0.25);
                    width: 100%;
                    max-width: 860px;
                }

                /* ── Welcome Panel ──────────────────────────────────── */
                .welcome-panel {
                    width: 42%;
                    background: linear-gradient(160deg, #1a73e8 0%, #0d47a1 100%);
                    padding: 52px 40px;
                    color: #fff;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    position: relative;
                    overflow: hidden;
                }

                .welcome-panel::after {
                    content: '';
                    position: absolute;
                    bottom: -80px;
                    right: -60px;
                    width: 240px;
                    height: 240px;
                    background: rgba(255, 255, 255, 0.06);
                    border-radius: 50%;
                }

                .brand {
                    font-size: 30px;
                    font-weight: 800;
                    margin-bottom: 6px;
                    letter-spacing: -1px;
                }

                .brand span {
                    color: #7ecfff;
                }

                .brand-sub {
                    font-size: 13px;
                    opacity: 0.75;
                    margin-bottom: 40px;
                }

                .welcome-panel h2 {
                    font-size: 22px;
                    font-weight: 700;
                    margin-bottom: 12px;
                }

                .welcome-panel p {
                    font-size: 14px;
                    opacity: 0.85;
                    line-height: 1.7;
                    margin-bottom: 32px;
                }

                .feature-chip {
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    background: rgba(255, 255, 255, 0.12);
                    border-radius: 20px;
                    padding: 7px 14px;
                    font-size: 12px;
                    margin: 4px 4px 0 0;
                }

                /* ── Login Form Panel ───────────────────────────────── */
                .form-panel {
                    flex: 1;
                    padding: 52px 44px;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                }

                .form-panel h2 {
                    font-size: 26px;
                    font-weight: 700;
                    color: #1a1a2e;
                    margin-bottom: 4px;
                }

                .form-panel .subtitle {
                    font-size: 13px;
                    color: #999;
                    margin-bottom: 28px;
                }

                /* Alerts */
                .alert {
                    padding: 12px 16px;
                    border-radius: 8px;
                    margin-bottom: 18px;
                    font-size: 13px;
                    font-weight: 500;
                }

                .alert-error {
                    background: #fde8e8;
                    color: #c0392b;
                    border-left: 4px solid #e53935;
                }

                .alert-success {
                    background: #e8f5e9;
                    color: #2e7d32;
                    border-left: 4px solid #43a047;
                }

                .alert-info {
                    background: #e3f2fd;
                    color: #1565c0;
                    border-left: 4px solid #1a73e8;
                }

                /* Form fields */
                .form-group {
                    margin-bottom: 18px;
                }

                .form-group label {
                    display: block;
                    font-size: 12px;
                    font-weight: 600;
                    color: #555;
                    margin-bottom: 7px;
                    text-transform: uppercase;
                    letter-spacing: 0.4px;
                }

                .input-wrap {
                    position: relative;
                }

                .input-wrap .icon {
                    position: absolute;
                    left: 13px;
                    top: 50%;
                    transform: translateY(-50%);
                    font-size: 16px;
                    pointer-events: none;
                }

                .form-group input[type="email"],
                .form-group input[type="password"],
                .form-group input[type="text"] {
                    width: 100%;
                    padding: 12px 14px 12px 40px;
                    border: 1.5px solid #e0e0e0;
                    border-radius: 8px;
                    font-size: 14px;
                    color: #333;
                    outline: none;
                    transition: border-color 0.2s, box-shadow 0.2s;
                    background: #fafafa;
                }

                .form-group input:focus {
                    border-color: #1a73e8;
                    box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.12);
                    background: #fff;
                }

                /* Remember-me row */
                .options-row {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    margin-bottom: 22px;
                    font-size: 13px;
                }

                .remember-label {
                    display: flex;
                    align-items: center;
                    gap: 7px;
                    cursor: pointer;
                    color: #555;
                }

                .remember-label input[type="checkbox"] {
                    accent-color: #1a73e8;
                    width: 15px;
                    height: 15px;
                }

                .forgot-link {
                    color: #1a73e8;
                    text-decoration: none;
                    font-weight: 500;
                }

                .forgot-link:hover {
                    text-decoration: underline;
                }

                /* Submit button */
                .btn-login {
                    width: 100%;
                    padding: 13px;
                    background: linear-gradient(135deg, #1a73e8, #1557b0);
                    color: #fff;
                    border: none;
                    border-radius: 8px;
                    font-size: 15px;
                    font-weight: 600;
                    cursor: pointer;
                    letter-spacing: 0.3px;
                    transition: opacity 0.2s, transform 0.15s;
                }

                .btn-login:hover {
                    opacity: 0.92;
                    transform: translateY(-1px);
                }

                .btn-login:active {
                    transform: translateY(0);
                }

                /* Register link */
                .register-link {
                    text-align: center;
                    margin-top: 22px;
                    font-size: 13px;
                    color: #888;
                }

                .register-link a {
                    color: #1a73e8;
                    text-decoration: none;
                    font-weight: 600;
                }

                .register-link a:hover {
                    text-decoration: underline;
                }

                /* Divider */
                .divider {
                    display: flex;
                    align-items: center;
                    margin: 20px 0;
                    color: #ccc;
                    font-size: 12px;
                    gap: 10px;
                }

                .divider::before,
                .divider::after {
                    content: '';
                    flex: 1;
                    height: 1px;
                    background: #ebebeb;
                }

                @media (max-width: 640px) {
                    .login-container {
                        flex-direction: column;
                    }

                    .welcome-panel {
                        width: 100%;
                        padding: 28px;
                    }

                    .form-panel {
                        padding: 28px;
                    }
                }
            </style>
        </head>

        <body>

            <div class="login-container">
                <!-- ══ Welcome Panel ══ -->
                <div class="welcome-panel">
                    <div class="brand">Prop<span>Nexium</span></div>
                    <div class="brand-sub">India's Trusted Real Estate Platform</div>

                    <h2>Welcome Back! 👋</h2>
                    <p>Sign in to access your personalized dashboard, saved properties, and more.</p>

                    <div>
                        <span class="feature-chip">🏠 10,000+ Properties</span>
                        <span class="feature-chip">⭐ Verified Agents</span>
                        <span class="feature-chip">💼 Smart Search</span>
                        <span class="feature-chip">🔖 Save Wishlists</span>
                    </div>
                </div>

                <!-- ══ Form Panel ══ -->
                <div class="form-panel">
                    <h2>Sign In</h2>
                    <p class="subtitle">Enter your credentials to continue</p>

                    <!-- Alerts -->
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-error" role="alert">
                            ⚠️ ${errorMessage}
                        </div>
                    </c:if>
                    <c:if test="${not empty logoutMessage}">
                        <div class="alert alert-info" role="alert">
                            ✅ ${logoutMessage}
                        </div>
                    </c:if>
                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success" role="alert">
                            🎉 ${successMessage}
                        </div>
                    </c:if>

                    <!-- Login form — Spring Security processes POST /auth/do-login -->
                    <form id="loginForm" method="POST" action="/auth/do-login">
                        <!-- CSRF Token -->
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <div class="input-wrap">
                                <span class="icon">📧</span>
                                <input type="email" id="email" name="email" placeholder="your@email.com" required
                                    autocomplete="email" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="password">Password</label>
                            <div class="input-wrap">
                                <span class="icon">🔒</span>
                                <input type="password" id="password" name="password" placeholder="Your password"
                                    required autocomplete="current-password" />
                            </div>
                        </div>

                        <div class="options-row">
                            <label class="remember-label">
                                <input type="checkbox" name="remember-me" id="rememberMe" />
                                Remember me for 7 days
                            </label>
                            <a href="${pageContext.request.contextPath}/auth/forgot-password" class="forgot-link">Forgot password?</a>
                        </div>

                        <button type="submit" class="btn-login" id="loginBtn">
                            Sign In →
                        </button>
                    </form>

                    <div class="divider">or</div>

                    <div class="register-link">
                        Don't have an account? <a href="/auth/register">Create one now</a>
                    </div>
                </div>
            </div>

        </body>

        </html>