<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
    <title>PropNexium - Real Estate News & Updates</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f8fafc; margin: 0; color: #1e293b; }
        .hero {
            background: linear-gradient(135deg, #0D47A1 0%, #1A73E8 100%);
            padding: 60px 20px; text-align: center; color: white;
        }
        .hero h1 { margin: 0 0 10px; font-size: 36px; font-weight: 800; }
        .hero p { margin: 0; font-size: 16px; color: rgba(255,255,255,0.85); }

        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; }

        /* Locked State */
        .locked-wrapper {
            background: white; border-radius: 16px; padding: 60px 30px; text-align: center;
            box-shadow: 0 10px 40px rgba(0,0,0,0.06); border: 1px solid #e5e7eb;
            margin-top: -30px; position: relative; z-index: 10;
        }
        .locked-icon { font-size: 64px; margin-bottom: 20px; }
        .locked-title { font-size: 24px; font-weight: 700; margin-bottom: 12px; }
        .locked-subtitle { font-size: 15px; color: #64748b; line-height: 1.6; max-width: 500px; margin: 0 auto 30px; }
        
        .subscribe-box {
            background: #f8fafc; padding: 24px; border-radius: 12px;
            border: 1px solid #e2e8f0; max-width: 460px; margin: 0 auto;
        }
        .subscribe-input {
            width: 100%; padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;
            font-size: 15px; box-sizing: border-box; margin-bottom: 12px; outline: none;
        }
        .subscribe-btn {
            width: 100%; padding: 14px; background: #1a73e8; color: white;
            border: none; border-radius: 8px; font-weight: 700; font-size: 16px; 
            cursor: pointer; transition: background 0.2s;
        }
        .subscribe-btn:hover { background: #1557b0; }

        .login-prompt { margin-top: 20px; font-size: 14px; color: #64748b; }
        .login-prompt a { color: #1a73e8; text-decoration: none; font-weight: 600; }

        /* News Layout */
        .news-article {
            background: white; border-radius: 12px; padding: 30px; margin-bottom: 24px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.04); border: 1px solid #f1f5f9;
        }
        .news-meta { font-size: 13px; color: #64748b; margin-bottom: 12px; font-weight: 500; }
        .news-title { font-size: 24px; font-weight: 800; color: #1e293b; margin: 0 0 16px; line-height: 1.3; }
        .news-content { font-size: 15px; color: #334155; line-height: 1.7; }
        
        /* Message area */
        #newsSubscribeMessage { display: none; margin-top: 16px; font-size: 14px; font-weight: 600; padding: 12px; border-radius: 8px; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/navbar.jsp" %>

<header class="hero">
    <h1>PropNexium Market News</h1>
    <p>Exclusive insights and updates from the real estate world.</p>
</header>

<div class="container">
    <c:choose>
        <c:when test="${hasAccess}">
            <!-- USER HAS ACCESS -->
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 24px;">
                <h2 style="margin:0; font-size:20px; color:#1e293b;">Latest Articles</h2>
                <form action="/news/unsubscribe" method="post" onsubmit="return confirm('Are you sure you want to completely unsubscribe from market news? You will lose access to this page.');">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <button type="submit" style="padding:8px 16px; background:#fef2f2; color:#dc2626; border:1px solid #fca5a5; border-radius:8px; font-weight:600; cursor:pointer;font-size:14px; transition:background 0.2s;">
                        Unsubscribe from News
                    </button>
                </form>
            </div>
            
            <c:if test="${not empty successMessage}">
                <div style="background:#f0fdf4; color:#16a34a; padding:16px; border-radius:8px; border:1px solid #bbf7d0; margin-bottom: 24px;">
                    ${successMessage}
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty newsList}">
                    <div style="text-align:center;padding:60px 20px;color:#94a3b8;font-size:16px;">
                        No news articles have been published yet. Check back soon!
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="news" items="${newsList}">
                        <article class="news-article">
                            <div class="news-meta">
                                📅 ${news.createdAt.toLocalDate()} &nbsp;•&nbsp; ✍️ ${news.author}
                            </div>
                            <h2 class="news-title">${news.title}</h2>
                            <div class="news-content">
                                ${news.content}
                            </div>
                        </article>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </c:when>
        <c:otherwise>
            <!-- USER LOCKED OUT -->
            <div class="locked-wrapper">
                <div class="locked-icon">🔒</div>
                <h2 class="locked-title">Subscriber Only Content</h2>
                <p class="locked-subtitle">
                    To read the latest real estate news and market updates, you must be a registered subscriber. It's completely free!
                </p>
                
                <div class="subscribe-box">
                    <input type="email" id="newsEmail" class="subscribe-input" placeholder="Enter your email address..." />
                    <button class="subscribe-btn" id="newsSubscribeBtn">Unlock News</button>
                    <div id="newsSubscribeMessage"></div>
                </div>

                <div class="login-prompt">
                    Already subscribed but using a different account? <a href="/auth/login">Log in here</a>.
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const btn = document.getElementById('newsSubscribeBtn');
    if (!btn) return;
    
    btn.addEventListener('click', function() {
        const email = document.getElementById('newsEmail').value;
        const msgDiv = document.getElementById('newsSubscribeMessage');
        const csrfToken = document.querySelector('meta[name="_csrf"]').content;
        const csrfHeader = document.querySelector('meta[name="_csrf_header"]').content;

        if (!email) {
            msgDiv.style.display = 'block';
            msgDiv.style.background = '#fef2f2';
            msgDiv.style.color = '#dc2626';
            msgDiv.textContent = 'Please enter a valid email.';
            return;
        }

        btn.disabled = true;
        btn.textContent = 'Subscribing...';

        fetch('/subscribe', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                [csrfHeader]: csrfToken
            },
            body: 'email=' + encodeURIComponent(email)
        })
        .then(response => response.json())
        .then(data => {
            msgDiv.style.display = 'block';
            if (data.success) {
                msgDiv.style.background = '#f0fdf4';
                msgDiv.style.color = '#16a34a';
                msgDiv.textContent = 'Success! Please refresh the page or login to read the news.';
                btn.textContent = 'Subscribed!';
            } else {
                msgDiv.style.background = '#fef2f2';
                msgDiv.style.color = '#dc2626';
                msgDiv.textContent = data.message || 'Error occurred.';
                btn.disabled = false;
                btn.textContent = 'Unlock News';
            }
        })
        .catch(err => {
            msgDiv.style.display = 'block';
            msgDiv.style.background = '#fef2f2';
            msgDiv.style.color = '#dc2626';
            msgDiv.textContent = 'Network error. Try again.';
            btn.disabled = false;
            btn.textContent = 'Unlock News';
        });
    });
});
</script>
</body>
</html>
