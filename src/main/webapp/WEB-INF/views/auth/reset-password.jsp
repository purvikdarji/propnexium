<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Set New Password — PropNexium</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
  <style>
    /* ... existing styles ... */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Inter', sans-serif;
      background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 50%, #0f172a 100%);
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
      padding: 24px;
    }
    .card {
      background: rgba(255,255,255,0.97);
      border-radius: 20px;
      box-shadow: 0 25px 60px rgba(0,0,0,0.4);
      width: 100%; max-width: 480px;
      overflow: hidden;
    }
    .card-header {
      background: linear-gradient(135deg, #1A73E8, #0d47a1);
      padding: 40px 36px 32px;
      text-align: center;
      color: white;
    }
    .shield-icon {
      width: 64px; height: 64px;
      background: rgba(255,255,255,0.2);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 28px;
      margin: 0 auto 16px;
    }
    .card-header h1 { font-size: 24px; font-weight: 700; }
    .card-header p  { font-size: 13px; color: rgba(255,255,255,0.8); margin-top: 6px; }
    .card-body { padding: 36px; }

    .alert {
      padding: 13px 16px; border-radius: 10px; font-size: 14px;
      margin-bottom: 20px; display: flex; align-items: flex-start; gap: 10px;
    }
    .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    .form-group { margin-bottom: 18px; }
    label { display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px; }
    .input-wrap { position: relative; }
    .input-wrap .icon {
      position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
      color: #6b7280; pointer-events: none;
    }
    .input-wrap .toggle-pw {
      position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
      cursor: pointer; color: #9ca3af; border: none; background: none;
      font-size: 14px; padding: 0;
    }
    input[type="password"], input[type="text"] {
      width: 100%;
      padding: 13px 40px 13px 42px;
      border: 2px solid #e5e7eb;
      border-radius: 10px;
      font-size: 14px;
      font-family: 'Inter', sans-serif;
      color: #111827;
      outline: none;
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    input:focus { border-color: #1A73E8; box-shadow: 0 0 0 3px rgba(26,115,232,0.15); }

    /* Password strength bar */
    .strength-bar { height: 4px; border-radius: 4px; background: #e5e7eb; margin-top: 8px; overflow: hidden; }
    .strength-fill { height: 100%; width: 0; transition: width 0.3s, background 0.3s; border-radius: 4px; }
    .strength-label { font-size: 11px; color: #6b7280; margin-top: 4px; }

    /* Match indicator */
    .match-hint { font-size: 11px; margin-top: 4px; }
    .match-ok  { color: #16a34a; }
    .match-bad { color: #dc2626; }

    /* Requirements */
    .requirements {
      background: #f8fafc; border: 1px solid #e2e8f0;
      border-radius: 8px; padding: 12px 16px; margin-bottom: 20px;
    }
    .requirements p { font-size: 12px; color: #64748b; font-weight: 600; margin-bottom: 6px; }
    .requirements ul { list-style: none; padding: 0; }
    .requirements li { font-size: 12px; color: #64748b; padding: 2px 0; }
    .requirements li::before { content: "• "; color: #94a3b8; }

    .btn {
      width: 100%; padding: 14px;
      background: linear-gradient(135deg, #1A73E8, #0d47a1);
      color: white; border: none; border-radius: 10px;
      font-size: 15px; font-weight: 700; font-family: 'Inter', sans-serif;
      cursor: pointer; margin-top: 8px;
      transition: transform 0.15s, box-shadow 0.15s;
      letter-spacing: 0.3px;
    }
    .btn:hover  { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(26,115,232,0.4); }
    .btn:active { transform: translateY(0); }
    
    .back-link {
        display: block;
        text-align: center;
        margin-top: 18px;
        font-size: 14px;
        color: #6b7280;
        text-decoration: none;
    }
    .back-link span { color: #1A73E8; font-weight: 600; }
    .back-link:hover span { text-decoration: underline; }
  </style>
</head>
<body>
<div class="card">
  <div class="card-header">
    <div class="shield-icon">&#128737;</div>
    <h1>Set New Password</h1>
    <p>Choose a strong password for your account</p>
  </div>
  <div class="card-body">

    <c:if test="${not empty errorMessage}">
      <div class="alert alert-error">
        <span>&#9888;</span>
        <span>${errorMessage}</span>
      </div>
    </c:if>

    <div class="requirements">
      <p>Password requirements:</p>
      <ul>
        <li>At least 8 characters long</li>
        <li>At least one uppercase letter (A–Z)</li>
        <li>At least one digit (0–9)</li>
      </ul>
    </div>

    <form id="resetForm" method="post" action="${pageContext.request.contextPath}/auth/reset-password">
      <!-- Hidden token -->
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
      <input type="hidden" name="token" value="${token}"/>

      <!-- New Password -->
      <div class="form-group">
        <label for="newPassword">New Password</label>
        <div class="input-wrap">
          <svg class="icon" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
          </svg>
          <input type="password" id="newPassword" name="newPassword"
                 placeholder="Minimum 8 characters" required minlength="8"
                 oninput="checkStrength(this.value); checkMatch();"/>
          <button type="button" class="toggle-pw" onclick="togglePw('newPassword', this)" title="Show/Hide">&#128065;</button>
        </div>
        <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
        <div class="strength-label" id="strengthLabel"></div>
      </div>

      <!-- Confirm Password -->
      <div class="form-group">
        <label for="confirmPassword">Confirm Password</label>
        <div class="input-wrap">
          <svg class="icon" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
          </svg>
          <input type="password" id="confirmPassword" name="confirmPassword"
                 placeholder="Re-enter password" required
                 oninput="checkMatch();"/>
          <button type="button" class="toggle-pw" onclick="togglePw('confirmPassword', this)" title="Show/Hide">&#128065;</button>
        </div>
        <div class="match-hint" id="matchHint"></div>
      </div>

      <button type="submit" class="btn">Reset Password</button>
    </form>
    
    <a href="${pageContext.request.contextPath}/auth/login" class="back-link">&#8592; Back to <span>Login</span></a>
  </div>
</div>

<script>
  function togglePw(id, btn) {
    const inp = document.getElementById(id);
    inp.type = inp.type === 'password' ? 'text' : 'password';
  }

  function checkStrength(pw) {
    const fill  = document.getElementById('strengthFill');
    const label = document.getElementById('strengthLabel');
    let score = 0;
    if (pw.length >= 8)          score++;
    if (/[A-Z]/.test(pw))        score++;
    if (/[0-9]/.test(pw))        score++;
    if (/[^A-Za-z0-9]/.test(pw)) score++;

    const levels = [
      { pct: '0%',   color: '#e5e7eb', text: '' },
      { pct: '25%',  color: '#ef4444', text: 'Weak' },
      { pct: '50%',  color: '#f97316', text: 'Fair' },
      { pct: '75%',  color: '#eab308', text: 'Good' },
      { pct: '100%', color: '#22c55e', text: 'Strong' },
    ];
    const lvl = levels[score] || levels[0];
    fill.style.width      = lvl.pct;
    fill.style.background = lvl.color;
    label.textContent     = lvl.text;
    label.style.color     = lvl.color;
  }

  function checkMatch() {
    const pw1   = document.getElementById('newPassword').value;
    const pw2   = document.getElementById('confirmPassword').value;
    const hint  = document.getElementById('matchHint');
    if (!pw2) { hint.textContent = ''; return; }
    if (pw1 === pw2) {
      hint.textContent  = '&#10003; Passwords match';
      hint.innerHTML    = '&#10003; Passwords match';
      hint.className    = 'match-hint match-ok';
    } else {
      hint.innerHTML    = '&#10007; Passwords do not match';
      hint.className    = 'match-hint match-bad';
    }
  }
</script>
</body>
</html>
