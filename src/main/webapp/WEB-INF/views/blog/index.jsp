<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Real Estate Blog | PropNexium</title>
    <meta name="description" content="Expert real estate advice, buying guides, market trends and legal tips from PropNexium."/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f8fafc; color: #1e293b; margin: 0; padding: 0; }
        .hero-banner {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            color: white;
            text-align: center;
            padding: 80px 20px;
        }
        .hero-banner h1 { font-size: 42px; font-weight: 800; margin: 0 0 16px; letter-spacing: -1px; }
        .hero-banner p { font-size: 18px; color: #94a3b8; margin: 0; max-width: 600px; margin: 0 auto; }
        
        .container { max-width: 1280px; margin: 0 auto; padding: 40px 20px; display: flex; gap: 40px; }
        .main-content { flex: 1; min-width: 0; }
        .sidebar { width: 320px; flex-shrink: 0; }
        
        /* Category Pills */
        .category-nav {
            display: flex; gap: 12px; overflow-x: auto; padding-bottom: 12px; margin-bottom: 32px;
            scrollbar-width: none;
        }
        .category-nav::-webkit-scrollbar { display: none; }
        .cat-pill {
            padding: 10px 20px; border-radius: 30px; font-size: 14px; font-weight: 600;
            text-decoration: none; white-space: nowrap; transition: all 0.2s;
            background: white; color: #64748b; border: 1px solid #e2e8f0;
        }
        .cat-pill:hover { border-color: #cbd5e1; color: #334155; }
        .cat-pill.active { background: #3b82f6; color: white; border-color: #3b82f6; box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25); }
        
        /* Grid */
        .blog-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 30px; }
        .blog-card {
            background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            transition: transform 0.2s, box-shadow 0.2s; border: 1px solid #f1f5f9; display: flex; flex-direction: column;
        }
        .blog-card:hover { transform: translateY(-4px); box-shadow: 0 12px 24px -8px rgba(0,0,0,0.1); }
        .card-img-wrapper { height: 200px; overflow: hidden; position: relative; }
        .card-img-wrapper img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s; }
        .blog-card:hover .card-img-wrapper img { transform: scale(1.05); }
        .card-badge {
            position: absolute; top: 16px; left: 16px; background: rgba(255,255,255,0.95);
            color: #2563eb; font-size: 12px; font-weight: 700; padding: 6px 12px; border-radius: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1); backdrop-filter: blur(4px);
        }
        .card-body { padding: 24px; display: flex; flex-direction: column; flex: 1; }
        .card-title {
            font-size: 18px; font-weight: 700; color: #0f172a; margin: 0 0 12px; line-height: 1.4;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
            text-decoration: none;
        }
        .card-title:hover { color: #2563eb; }
        .card-excerpt {
            font-size: 14px; color: #64748b; margin: 0 0 20px; line-height: 1.6;
            display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;
            flex: 1;
        }
        .card-footer {
            display: flex; align-items: center; justify-content: space-between;
            padding-top: 16px; border-top: 1px solid #f1f5f9;
        }
        .meta-info { font-size: 12px; color: #94a3b8; display: flex; gap: 12px; align-items: center; }
        .read-link { font-size: 13px; font-weight: 600; color: #2563eb; text-decoration: none; display: flex; align-items: center; gap: 4px; }
        .read-link:hover { color: #1d4ed8; }
        
        /* Sidebar */
        .sidebar-widget { background: white; border-radius: 16px; padding: 24px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid #f1f5f9; margin-bottom: 30px; }
        .widget-title { font-size: 16px; font-weight: 700; margin: 0 0 20px; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9; color: #0f172a; }
        .popular-list { display: flex; flex-direction: column; gap: 16px; }
        .popular-item { display: flex; gap: 12px; text-decoration: none; align-items: center; }
        .popular-item img { width: 64px; height: 64px; border-radius: 8px; object-fit: cover; }
        .popular-item-info { flex: 1; }
        .popular-item-title { font-size: 13px; font-weight: 600; color: #334155; margin: 0 0 4px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .popular-item:hover .popular-item-title { color: #2563eb; }
        .popular-item-meta { font-size: 11px; color: #94a3b8; }
        
        /* Pagination */
        .pagination { display: flex; justify-content: center; gap: 8px; margin-top: 50px; }
        .page-link {
            width: 40px; height: 40px; display: flex; align-items: center; justify-content: center;
            border-radius: 8px; background: white; color: #64748b; text-decoration: none; font-weight: 600; font-size: 14px;
            border: 1px solid #e2e8f0; transition: all 0.2s;
        }
        .page-link:hover { background: #f8fafc; border-color: #cbd5e1; }
        .page-link.active { background: #2563eb; color: white; border-color: #2563eb; }
        .page-link.disabled { opacity: 0.5; pointer-events: none; }
        
        @media (max-width: 992px) {
            .container { flex-direction: column; }
            .sidebar { width: 100%; }
        }
    </style>
</head>
<body>

<jsp:include page="../common/navbar.jsp" />

<div class="hero-banner">
    <h1>PropNexium Blog</h1>
    <p>Expert advice for smarter property decisions</p>
</div>

<div class="container">
    <div class="main-content">
        <!-- Categories -->
        <div class="category-nav">
            <a href="/blog" class="cat-pill ${empty currentCategory ? 'active' : ''}">All Articles</a>
            <c:forEach var="cat" items="${categories}">
                <a href="/blog?category=${cat}" class="cat-pill ${currentCategory == cat ? 'active' : ''}">${cat}</a>
            </c:forEach>
        </div>
        
        <!-- Articles Grid -->
        <c:choose>
            <c:when test="${not empty posts.content}">
                <div class="blog-grid">
                    <c:forEach var="post" items="${posts.content}">
                        <div class="blog-card">
                            <div class="card-img-wrapper">
                                <span class="card-badge">${post.category}</span>
                                <!-- For simplicity, assume coverImage is a full URL or relative path if it starts with / or http, otherwise a placeholder -->
                                <c:choose>
                                    <c:when test="${not empty post.coverImage}">
                                        <img src="${post.coverImage}" alt="${post.title}">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://images.unsplash.com/photo-1560518884-ce58822b07b4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80" alt="Placeholder">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="card-body">
                                <a href="/blog/${post.slug}" class="card-title">${post.title}</a>
                                <p class="card-excerpt">${post.excerpt}</p>
                                <div class="card-footer">
                                    <div class="meta-info">
                                        <span><fmt:formatDate value="${post.publishedDate}" pattern="MMM dd, yyyy" /></span>
                                        <span>•</span>
                                        <span>⏱ ${post.readTimeMinutes} min read</span>
                                    </div>
                                    <a href="/blog/${post.slug}" class="read-link">Read <span style="font-size: 16px;">→</span></a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                
                <!-- Pagination -->
                <c:if test="${posts.totalPages > 1}">
                    <div class="pagination">
                        <a href="?page=${posts.number - 1}${not empty currentCategory ? '&category=' += currentCategory : ''}" 
                           class="page-link ${posts.first ? 'disabled' : ''}">&laquo;</a>
                        <c:forEach begin="0" end="${posts.totalPages - 1}" var="i">
                            <a href="?page=${i}${not empty currentCategory ? '&category=' += currentCategory : ''}" 
                               class="page-link ${posts.number == i ? 'active' : ''}">${i + 1}</a>
                        </c:forEach>
                        <a href="?page=${posts.number + 1}${not empty currentCategory ? '&category=' += currentCategory : ''}" 
                           class="page-link ${posts.last ? 'disabled' : ''}">&raquo;</a>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise>
                <div style="text-align: center; padding: 60px 0; background: white; border-radius: 16px; border: 1px dashed #cbd5e1;">
                    <div style="font-size: 48px; margin-bottom: 16px;">📭</div>
                    <h3 style="margin:0 0 8px; color: #0f172a;">No articles found</h3>
                    <p style="color: #64748b; margin: 0;">Try selecting a different category.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <div class="sidebar">
        <div class="sidebar-widget">
            <h3 class="widget-title">🔥 Popular Posts</h3>
            <div class="popular-list">
                <c:forEach var="popPost" items="${popularPosts}">
                    <a href="/blog/${popPost.slug}" class="popular-item">
                        <c:choose>
                            <c:when test="${not empty popPost.coverImage}">
                                <img src="${popPost.coverImage}" alt="${popPost.title}">
                            </c:when>
                            <c:otherwise>
                                <img src="https://images.unsplash.com/photo-1560518884-ce58822b07b4?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80" alt="Placeholder">
                            </c:otherwise>
                        </c:choose>
                        <div class="popular-item-info">
                            <h4 class="popular-item-title">${popPost.title}</h4>
                            <div class="popular-item-meta">
                                <fmt:formatDate value="${popPost.publishedDate}" pattern="MMM dd, yyyy" />
                                 • 👁 ${popPost.viewCount}
                            </div>
                        </div>
                    </a>
                </c:forEach>
                <c:if test="${empty popularPosts}">
                    <p style="color: #94a3b8; font-size: 13px; margin: 0;">No popular posts yet.</p>
                </c:if>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />

</body>
</html>
