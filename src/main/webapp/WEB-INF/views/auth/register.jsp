<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account – PropNexium</title>
    <meta name="description" content="Register on PropNexium — India's trusted real estate platform.">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            display: flex;
            min-height: 100vh;
            background: #f0f4ff;
        }

        /* ── Left Panel ─────────────────────────────────────────── */
        .left-panel {
            width: 42%;
            background: linear-gradient(145deg, #1a73e8 0%, #0d47a1 60%, #002171 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px 40px;
            color: #fff;
            position: relative;
            overflow: hidden;
        }
        .left-panel::before {
            content: '';
            position: absolute;
            top: -80px; right: -80px;
            width: 320px; height: 320px;
            background: rgba(255,255,255,0.05);
            border-radius: 50%;
        }
        .left-panel::after {
            content: '';
            position: absolute;
            bottom: -100px; left: -60px;
            width: 280px; height: 280px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
        }
        .left-content { position: relative; z-index: 1; }
        .brand-logo {
            font-size: 32px;
            font-weight: 800;
            letter-spacing: -1px;
            margin-bottom: 8px;
        }
        .brand-logo span { color: #7ecfff; }
        .brand-tagline { font-size: 14px; opacity: 0.8; margin-bottom: 36px; }
        .left-headline { font-size: 28px; font-weight: 700; line-height: 1.3; margin-bottom: 14px; }
        .left-desc { font-size: 15px; opacity: 0.85; line-height: 1.7; margin-bottom: 32px; }
        .features-list { list-style: none; }
        .features-list li {
            padding: 8px 0;
            font-size: 14px;
            opacity: 0.9;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .features-list li::before {
            content: '✓';
            background: rgba(126,207,255,0.25);
            color: #7ecfff;
            width: 22px; height: 22px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 12px;
            flex-shrink: 0;
        }
        .stat-row {
            display: flex; gap: 20px; margin-top: 36px;
        }
        .stat-box {
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            padding: 14px 18px;
            text-align: center;
            flex: 1;
        }
        .stat-box .num { font-size: 22px; font-weight: 800; color: #7ecfff; }
        .stat-box .lbl { font-size: 11px; opacity: 0.75; margin-top: 2px; }

        /* ── Right Panel ────────────────────────────────────────── */
        .right-panel {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 32px 24px;
            overflow-y: auto;
        }
        .form-card {
            background: #fff;
            border-radius: 16px;
            padding: 40px 36px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 8px 40px rgba(0,0,0,0.09);
        }
        .form-title { font-size: 24px; font-weight: 700; color: #1a1a2e; margin-bottom: 4px; }
        .form-subtitle { font-size: 13px; color: #888; margin-bottom: 24px; }

        /* ── Alerts ─────────────────────────────────────────────── */
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 18px;
            font-size: 13px;
            font-weight: 500;
        }
        .alert-error { background: #fde8e8; color: #c0392b; border-left: 4px solid #e53935; }
        .alert-success { background: #e8f5e9; color: #2e7d32; border-left: 4px solid #43a047; }

        /* ── Role Selector ─────────────────────────────────────── */
        .role-selector { display: flex; gap: 12px; margin-bottom: 20px; }
        .role-option {
            flex: 1;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            padding: 14px 10px;
            text-align: center;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s, transform 0.15s;
            user-select: none;
        }
        .role-option:hover { border-color: #90b8f8; transform: translateY(-1px); }
        .role-option.selected {
            border-color: #1a73e8;
            background: linear-gradient(135deg, #f0f4ff, #dce8ff);
        }
        .role-option input[type="radio"] { display: none; }
        .role-icon { font-size: 26px; display: block; margin-bottom: 6px; }
        .role-option strong { display: block; font-size: 14px; color: #333; }
        .role-option small { font-size: 11px; color: #888; }

        /* ── Form Fields ─────────────────────────────────────────── */
        .form-row { display: flex; gap: 14px; }
        .form-group { margin-bottom: 16px; flex: 1; }
        .form-group label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            color: #555;
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 11px 14px;
            border: 1.5px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            color: #333;
            transition: border-color 0.2s, box-shadow 0.2s;
            outline: none;
            background: #fafafa;
        }
        .form-group input:focus,
        .form-group select:focus {
            border-color: #1a73e8;
            box-shadow: 0 0 0 3px rgba(26,115,232,0.12);
            background: #fff;
        }
        .field-error {
            color: #e53935;
            font-size: 11px;
            margin-top: 5px;
            display: block;
        }

        /* ── Submit Button ──────────────────────────────────────── */
        .btn-register {
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
            margin-top: 4px;
        }
        .btn-register:hover { opacity: 0.92; transform: translateY(-1px); }
        .btn-register:active { transform: translateY(0); }

        /* ── Footer ─────────────────────────────────────────────── */
        .login-link {
            text-align: center;
            margin-top: 18px;
            font-size: 13px;
            color: #888;
        }
        .login-link a { color: #1a73e8; text-decoration: none; font-weight: 600; }
        .login-link a:hover { text-decoration: underline; }

        @media (max-width: 768px) {
            body { flex-direction: column; }
            .left-panel { width: 100%; min-height: 200px; padding: 28px; }
            .form-row { flex-direction: column; }
        }
    </style>
</head>
<body>

<!-- ══════════════════ LEFT PANEL ══════════════════ -->
<div class="left-panel">
    <div class="left-content">
        <div class="brand-logo">Prop<span>Nexium</span></div>
        <div class="brand-tagline">India's Trusted Real Estate Platform</div>

        <h1 class="left-headline">Find Your Perfect<br>Property Today</h1>
        <p class="left-desc">Join thousands of buyers, renters, and agents<br>on India's fastest-growing property marketplace.</p>

        <ul class="features-list">
            <li>10,000+ verified properties across India</li>
            <li>Connect directly with licensed agents</li>
            <li>Advanced search with smart filters</li>
            <li>Save and track favorite properties</li>
            <li>Secure and transparent transactions</li>
        </ul>

        <div class="stat-row">
            <div class="stat-box">
                <div class="num">10K+</div>
                <div class="lbl">Properties</div>
            </div>
            <div class="stat-box">
                <div class="num">500+</div>
                <div class="lbl">Agents</div>
            </div>
            <div class="stat-box">
                <div class="num">50K+</div>
                <div class="lbl">Happy Users</div>
            </div>
        </div>
    </div>
</div>

<!-- ══════════════════ RIGHT PANEL ══════════════════ -->
<div class="right-panel">
    <div class="form-card">
        <h2 class="form-title">Create Your Account</h2>
        <p class="form-subtitle">Start your property journey in seconds</p>

        <!-- Error / success alerts -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error" role="alert">${errorMessage}</div>
        </c:if>
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success" role="alert">${successMessage}</div>
        </c:if>

        <form:form method="POST" action="/auth/register" modelAttribute="registrationDto">
            <!-- CSRF Token -->
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <!-- Role Selector -->
            <div class="role-selector">
                <label class="role-option selected" id="roleUser">
                    <input type="radio" name="role" value="USER" checked
                           onchange="selectRole('roleUser','roleAgent')">
                    <span class="role-icon">🏠</span>
                    <strong>User</strong>
                    <small>Browse &amp; Buy</small>
                </label>
                <label class="role-option" id="roleAgent">
                    <input type="radio" name="role" value="AGENT"
                           onchange="selectRole('roleAgent','roleUser')">
                    <span class="role-icon">👔</span>
                    <strong>Agent</strong>
                    <small>List &amp; Sell</small>
                </label>
            </div>

            <!-- Name + Phone -->
            <div class="form-row">
                <div class="form-group">
                    <label for="name">Full Name *</label>
                    <form:input id="name" path="name" placeholder="Your full name"/>
                    <form:errors path="name" cssClass="field-error" element="span"/>
                </div>
                <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <form:input id="phone" path="phone" placeholder="10-digit number"/>
                    <form:errors path="phone" cssClass="field-error" element="span"/>
                </div>
            </div>

            <!-- Email -->
            <div class="form-group">
                <label for="email">Email Address *</label>
                <form:input id="email" path="email" type="email" placeholder="your@email.com"/>
                <form:errors path="email" cssClass="field-error" element="span"/>
            </div>

            <!-- Password + Confirm -->
            <div class="form-row">
                <div class="form-group">
                    <label for="password">Password *</label>
                    <form:password id="password" path="password" placeholder="Min 8 chars"/>
                    <form:errors path="password" cssClass="field-error" element="span"/>
                </div>
                <div class="form-group">
                    <label for="confirmPassword">Confirm Password *</label>
                    <form:password id="confirmPassword" path="confirmPassword" placeholder="Repeat password"/>
                    <form:errors path="confirmPassword" cssClass="field-error" element="span"/>
                </div>
            </div>

            <button type="submit" class="btn-register" id="registerBtn">
                Create Account →
            </button>
        </form:form>

        <div class="login-link">
            Already have an account? <a href="/auth/login">Sign In</a>
        </div>
    </div>
</div>

<script>
    function selectRole(selected, other) {
        document.getElementById(selected).classList.add('selected');
        document.getElementById(other).classList.remove('selected');
    }
</script>
</body>
</html>
