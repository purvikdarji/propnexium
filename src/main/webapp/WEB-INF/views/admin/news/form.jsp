<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} – Admin | PropNexium</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/admin-shared.css">
    <style>
        .form-group { margin-bottom: 20px; }
        .form-label { display: block; font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; }
        .form-input {
            width: 100%; padding: 12px; border: 1px solid #e2e8f0; border-radius: 8px;
            font-size: 15px; box-sizing: border-box; font-family: inherit;
            transition: border-color 0.2s; outline: none;
        }
        .form-input:focus { border-color: #1a73e8; }
        .btn-submit {
            padding: 14px 28px; background: #1a73e8; color: white; border: none;
            border-radius: 8px; font-size: 15px; font-weight: 700; cursor: pointer;
            transition: background 0.2s;
        }
        .btn-submit:hover { background: #1557b0; }
        .btn-cancel {
            padding: 14px 28px; background: #f1f5f9; color: #475569; border: none;
            border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer;
            text-decoration: none; display: inline-block; margin-left: 10px;
        }
        .btn-cancel:hover { background: #e2e8f0; }
    </style>
</head>
<body>
<div class="admin-wrap">
    <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>
    <div class="main">
        <div class="topbar">
            <h1>✍️ ${pageTitle}</h1>
            <a href="/admin/news" style="color:#64748b;font-size:14px;text-decoration:none;font-weight:600;">← Back to News</a>
        </div>
        <div class="content">

            <div style="background:white;border-radius:12px;padding:32px;box-shadow:0 2px 12px rgba(0,0,0,.06);max-width:800px;">
                <form action="/admin/news/${empty news.id ? 'new' : 'edit/' += news.id}" method="POST">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    
                    <div class="form-group">
                        <label class="form-label" for="title">News Title *</label>
                        <input type="text" id="title" class="form-input" name="title" value="${news.title}" required />
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="author">Author Handle (Optional)</label>
                        <input type="text" id="author" class="form-input" name="author" value="${news.author}" placeholder="e.g., PropNexium Editorial" />
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="content">Article Content *</label>
                        <textarea id="content" class="form-input" name="content" rows="12" required placeholder="Write the news article here... Html is supported!">${news.content}</textarea>
                        <p style="font-size:12px;color:#94a3b8;margin-top:6px;">You can use standard HTML formatting inside the editor.</p>
                    </div>

                    <div style="margin-top:30px;">
                        <button type="submit" class="btn-submit">${empty news.id ? 'Publish News' : 'Save Changes'}</button>
                        <a href="/admin/news" class="btn-cancel">Cancel</a>
                    </div>
                </form>
            </div>

        </div><!-- /content -->
    </div><!-- /main -->
</div><!-- /admin-wrap -->
</body>
</html>
