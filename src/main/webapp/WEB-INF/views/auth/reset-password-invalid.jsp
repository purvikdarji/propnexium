<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Invalid Reset Link — PropNexium</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
  <style>
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
      text-align: center;
    }
    .card-header {
      background: linear-gradient(135deg, #dc2626, #991b1b);
      padding: 40px 36px 32px;
      color: white;
    }
    .warn-icon {
      width: 64px; height: 64px;
      background: rgba(255,255,255,0.2);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 28px;
      margin: 0 auto 16px;
    }
    .card-header h1 { font-size: 22px; font-weight: 700; }
    .card-header p  { font-size: 13px; color: rgba(255,255,255,0.8); margin-top: 6px; }
    .card-body { padding: 36px; }
    .card-body p {
      color: #374151;
      line-height: 1.7;
      font-size: 15px;
      margin-bottom: 28px;
    }
    .btn {
      display: inline-block;
      padding: 13px 32px;
      background: linear-gradient(135deg, #1A73E8, #0d47a1);
      color: white; border-radius: 10px;
      font-weight: 700; font-size: 14px;
      text-decoration: none;
      transition: transform 0.15s, box-shadow 0.15s;
    }
    .btn:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(26,115,232,0.4); }
    .secondary-link {
      display: block; margin-top: 16px;
      font-size: 14px; color: #6b7280; text-decoration: none;
    }
    .secondary-link span { color: #1A73E8; font-weight: 600; }
    .secondary-link:hover span { text-decoration: underline; }
  </style>
</head>
<body>
<div class="card">
  <div class="card-header">
    <div class="warn-icon">&#9888;</div>
    <h1>Link Expired or Invalid</h1>
    <p>This password reset link cannot be used</p>
  </div>
  <div class="card-body">
    <p>
      <c:out value="${not empty error ? error : 'This reset link is invalid or has expired. Password reset links are only valid for 1 hour.'}" />
    </p>
    <a href="${pageContext.request.contextPath}/auth/forgot-password" class="btn">Request New Link</a>
    <a href="${pageContext.request.contextPath}/auth/login" class="secondary-link">&#8592; Back to <span>Login</span></a>
  </div>
</div>
</body>
</html>
