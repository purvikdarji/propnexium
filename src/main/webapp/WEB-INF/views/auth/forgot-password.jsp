<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Forgot Password — PropNexium</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Inter', sans-serif;
      background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 50%, #0f172a 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }
    .card {
      background: rgba(255,255,255,0.97);
      border-radius: 20px;
      box-shadow: 0 25px 60px rgba(0,0,0,0.4);
      width: 100%;
      max-width: 480px;
      overflow: hidden;
    }
    .card-header {
      background: linear-gradient(135deg, #1A73E8, #0d47a1);
      padding: 40px 36px 32px;
      text-align: center;
      color: white;
    }
    .lock-icon {
      width: 64px; height: 64px;
      background: rgba(255,255,255,0.2);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 28px;
      margin: 0 auto 16px;
      backdrop-filter: blur(4px);
    }
    .card-header h1 { font-size: 24px; font-weight: 700; }
    .card-header p  { font-size: 13px; color: rgba(255,255,255,0.8); margin-top: 6px; }

    .card-body { padding: 36px; }

    .alert {
      padding: 13px 16px;
      border-radius: 10px;
      font-size: 14px;
      margin-bottom: 20px;
      display: flex; align-items: flex-start; gap: 10px;
    }
    .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    .alert-error   { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    label { display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px; }
    .input-wrap { position: relative; }
    .input-wrap .icon {
      position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
      color: #6b7280; pointer-events: none;
    }
    input[type="email"] {
      width: 100%;
      padding: 13px 14px 13px 42px;
      border: 2px solid #e5e7eb;
      border-radius: 10px;
      font-size: 14px;
      font-family: 'Inter', sans-serif;
      color: #111827;
      transition: border-color 0.2s, box-shadow 0.2s;
      outline: none;
    }
    input[type="email"]:focus {
      border-color: #1A73E8;
      box-shadow: 0 0 0 3px rgba(26,115,232,0.15);
    }
    .btn {
      width: 100%;
      padding: 14px;
      background: linear-gradient(135deg, #1A73E8, #0d47a1);
      color: white;
      border: none;
      border-radius: 10px;
      font-size: 15px;
      font-weight: 700;
      font-family: 'Inter', sans-serif;
      cursor: pointer;
      margin-top: 22px;
      transition: transform 0.15s, box-shadow 0.15s, opacity 0.15s;
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

    .form-group { margin-bottom: 4px; }
  </style>
</head>
<body>
<div class="card">
  <div class="card-header">
    <div class="lock-icon">&#128274;</div>
    <h1>Forgot Password?</h1>
    <p>Enter your registered email to receive a reset link</p>
  </div>
  <div class="card-body">

    <!-- Flash messages -->
    <c:if test="${not empty successMessage}">
      <div class="alert alert-success">
        <span>&#10003;</span>
        <span>${successMessage}</span>
      </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
      <div class="alert alert-error">
        <span>&#9888;</span>
        <span>${errorMessage}</span>
      </div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/auth/forgot-password">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
      <div class="form-group">
        <label for="email">Email Address</label>
        <div class="input-wrap">
          <svg class="icon" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1-0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
            <polyline points="22,6 12,13 2,6"/>
          </svg>
          <input
            type="email"
            id="email"
            name="email"
            placeholder="you@example.com"
            required
            autocomplete="email"
          />
        </div>
      </div>

      <button type="submit" class="btn">Send Reset Link</button>
    </form>

    <a href="${pageContext.request.contextPath}/auth/login" class="back-link">&#8592; Back to <span>Login</span></a>
  </div>
</div>
</body>
</html>
