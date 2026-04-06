<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>403 – Access Denied | PropNexium</title>
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                min-height: 100vh;
                background: linear-gradient(135deg, #f0f4ff 0%, #dce8ff 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 24px;
            }

            .error-card {
                background: #fff;
                border-radius: 20px;
                padding: 64px 48px;
                text-align: center;
                box-shadow: 0 12px 50px rgba(0, 0, 0, 0.1);
                max-width: 480px;
                width: 100%;
            }

            .error-icon {
                font-size: 72px;
                margin-bottom: 20px;
                display: block;
            }

            .error-code {
                font-size: 80px;
                font-weight: 800;
                color: #1a73e8;
                line-height: 1;
                margin-bottom: 8px;
            }

            .error-title {
                font-size: 22px;
                font-weight: 700;
                color: #1a1a2e;
                margin-bottom: 12px;
            }

            .error-desc {
                font-size: 14px;
                color: #888;
                line-height: 1.7;
                margin-bottom: 32px;
            }

            .btn-group {
                display: flex;
                gap: 12px;
                justify-content: center;
                flex-wrap: wrap;
            }

            .btn {
                padding: 12px 24px;
                border-radius: 8px;
                font-size: 14px;
                font-weight: 600;
                text-decoration: none;
                transition: opacity 0.2s, transform 0.15s;
                cursor: pointer;
                border: none;
            }

            .btn:hover {
                opacity: 0.9;
                transform: translateY(-1px);
            }

            .btn-primary {
                background: linear-gradient(135deg, #1a73e8, #1557b0);
                color: #fff;
            }

            .btn-outline {
                background: #fff;
                color: #1a73e8;
                border: 2px solid #1a73e8;
            }
        </style>
    </head>

    <body>
        <div class="error-card">
            <span class="error-icon">🔒</span>
            <div class="error-code">403</div>
            <h1 class="error-title">Access Denied</h1>
            <p class="error-desc">
                You don't have permission to view this page.<br>
                Please contact your administrator or sign in with a different account.
            </p>
            <div class="btn-group">
                <a href="/" class="btn btn-primary">Go to Homepage</a>
                <a href="/auth/login" class="btn btn-outline">Sign In</a>
            </div>
        </div>
    </body>

    </html>