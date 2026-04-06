<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${post.title} | PropNexium Blog</title>
    <meta name="description" content="${post.excerpt}"/>
    <meta property="og:title" content="${post.title}"/>
    <meta property="og:description" content="${post.excerpt}"/>
    <meta property="og:image" content="${post.coverImage}"/>
    <meta property="og:type" content="article"/>
    <meta property="article:published_time" content="${post.publishedDate}"/>
    <meta property="article:section" content="${post.category}"/>
    
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f8fafc; color: #1e293b; margin: 0; padding: 0; }
        .container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; display: flex; gap: 40px; justify-content: center; }
        .main-content { flex: 1; min-width: 0; max-width: 850px; background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05); border: 1px solid #f1f5f9; margin: 0; }
        .sidebar { width: 320px; flex-shrink: 0; }
        
        .article-hero { position: relative; height: 400px; background: #e2e8f0; }
        .article-hero img { width: 100%; height: 100%; object-fit: cover; }
        
        .article-body { padding: 40px; }
        .category-badge { display: inline-block; background: #eff6ff; color: #2563eb; padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: 700; margin-bottom: 20px; }
        .article-title { font-size: 36px; font-weight: 800; line-height: 1.2; margin: 0 0 20px; color: #0f172a; letter-spacing: -0.5px; }
        
        .author-bar { display: flex; align-items: center; justify-content: space-between; padding: 20px 0; border-top: 1px solid #f1f5f9; border-bottom: 1px solid #f1f5f9; margin-bottom: 40px; }
        .author-info { display: flex; align-items: center; gap: 12px; }
        .author-avatar { width: 48px; height: 48px; border-radius: 50%; background: #e2e8f0; display: flex; align-items: center; justify-content: center; font-size: 20px; overflow: hidden; }
        .author-avatar img { width: 100%; height: 100%; object-fit: cover; }
        .author-meta { display: flex; flex-direction: column; }
        .author-name { font-weight: 600; color: #1e293b; font-size: 15px; margin-bottom: 2px; }
        .post-date { font-size: 13px; color: #64748b; }
        .post-stats { font-size: 13px; color: #64748b; display: flex; gap: 16px; align-items: center; }
        
        .prose { font-size: 16px; line-height: 1.8; color: #334155; }
        .prose h2 { font-size: 24px; font-weight: 700; color: #0f172a; margin: 40px 0 20px; }
        .prose h3 { font-size: 20px; font-weight: 600; color: #0f172a; margin: 30px 0 16px; }
        .prose p { margin-bottom: 20px; }
        .prose ul, .prose ol { margin-bottom: 20px; padding-left: 20px; }
        .prose li { margin-bottom: 10px; }
        .prose img { max-width: 100%; height: auto; border-radius: 12px; margin: 30px 0; }
        .prose blockquote { border-left: 4px solid #3b82f6; padding-left: 20px; margin: 30px 0; font-style: italic; color: #475569; }
        .prose a { color: #2563eb; text-decoration: none; }
        .prose a:hover { text-decoration: underline; }
        
        .tags { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 40px; padding-top: 20px; border-top: 1px dashed #e2e8f0; }
        .tag { background: #f1f5f9; color: #475569; padding: 6px 12px; border-radius: 6px; font-size: 13px; text-decoration: none; }
        .tag:hover { background: #e2e8f0; }
        
        /* Sidebar layout */
        .sidebar-widget { background: white; border-radius: 16px; padding: 24px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid #f1f5f9; margin-bottom: 30px; }
        .widget-title { font-size: 16px; font-weight: 700; margin: 0 0 20px; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9; color: #0f172a; }
        
        .share-btns { display: flex; gap: 10px; flex-wrap: wrap; }
        .share-btn { flex: 1; min-width: 120px; display: flex; align-items: center; justify-content: center; gap: 8px; padding: 12px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; border: none; color: white; transition: opacity 0.2s; }
        .share-btn:hover { opacity: 0.9; }
        .btn-whatsapp { background: #25D366; }
        .btn-email { background: #ea4335; }
        .btn-copy { border: 1px solid #cbd5e1; background: white; color: #475569; }
        .btn-copy:hover { background: #f8fafc; opacity: 1; }
        
        .related-list { display: flex; flex-direction: column; gap: 16px; }
        .related-item { display: flex; gap: 12px; text-decoration: none; align-items: center; }
        .related-img { width: 80px; height: 60px; border-radius: 8px; object-fit: cover; }
        .related-title { font-size: 14px; font-weight: 600; color: #334155; margin: 0 0 4px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .related-item:hover .related-title { color: #2563eb; }
        .related-meta { font-size: 12px; color: #94a3b8; }
        
        /* You Might Also Like Section */
        .more-section { padding: 60px 20px; max-width: 1200px; margin: 0 auto; }
        .more-title { font-size: 24px; font-weight: 700; margin-bottom: 30px; text-align: center; }
        .blog-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 30px; }
        .blog-card { background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); transition: transform 0.2s; border: 1px solid #f1f5f9; display: flex; flex-direction: column; }
        .blog-card:hover { transform: translateY(-4px); box-shadow: 0 12px 24px -8px rgba(0,0,0,0.1); }
        .card-img { height: 180px; object-fit: cover; width: 100%; border-bottom: 1px solid #f1f5f9; }
        .card-body { padding: 20px; display: flex; flex-direction: column; flex: 1; }
        .card-cat { color: #2563eb; font-size: 12px; font-weight: 700; margin-bottom: 8px; }
        .card-title { font-size: 16px; font-weight: 700; color: #0f172a; margin: 0 0 12px; line-height: 1.4; text-decoration: none; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .card-title:hover { color: #2563eb; }
        
        @media (max-width: 992px) {
            .container { flex-direction: column; }
            .sidebar { width: 100%; }
            .article-title { font-size: 28px; }
            .article-body { padding: 24px; }
            .article-hero { height: 250px; }
        }
    </style>
</head>
<body>

<jsp:include page="../common/navbar.jsp" />

<div class="container">
    <div class="main-content">
        <div class="article-hero">
            <c:choose>
                <c:when test="${not empty post.coverImage}">
                    <img src="${post.coverImage}" alt="${post.title}">
                </c:when>
                <c:otherwise>
                    <img src="https://images.unsplash.com/photo-1560518884-ce58822b07b4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80" alt="Placeholder">
                </c:otherwise>
            </c:choose>
        </div>
        
        <div class="article-body">
            <span class="category-badge">${post.category}</span>
            <h1 class="article-title">${post.title}</h1>
            
            <div class="author-bar">
                <div class="author-info">
                    <div class="author-avatar">
                        <!-- Using avatar from User object if exists, else generic -->
                        <c:choose>
                            <c:when test="${not empty post.author && not empty post.author.profilePicture}">
                                <img src="${post.author.profilePicture}" alt="Author">
                            </c:when>
                            <c:otherwise>
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: #64748b;"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="author-meta">
                        <span class="author-name">
                            <c:choose>
                                <c:when test="${not empty post.author}">${post.author.name}</c:when>
                                <c:otherwise>PropNexium Editorial</c:otherwise>
                            </c:choose>
                        </span>
                        <span class="post-date">
                            <c:choose>
                                <c:when test="${not empty post.publishedDate}">
                                    <fmt:formatDate value="${post.publishedDate}" pattern="MMMM dd, yyyy" />
                                </c:when>
                                <c:otherwise>Recently Published</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>
                <div class="post-stats">
                    <span title="Read Time">⏱ ${post.readTimeMinutes} min read</span>
                    <span title="Views">👁 ${post.viewCount} views</span>
                </div>
            </div>
            
            <div class="prose">
                <c:out value="${post.content}" escapeXml="false" />
            </div>
            
            <c:if test="${not empty post.tags}">
                <div class="tags">
                    <c:forEach var="tag" items="${post.tags.split(',')}">
                        <span class="tag">#${tag.trim()}</span>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </div>
    
    <div class="sidebar">
        <div class="sidebar-widget">
            <h3 class="widget-title">📢 Share this Article</h3>
            <div class="share-btns">
                <button class="share-btn btn-whatsapp" onclick="shareWhatsApp()">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" style="margin-right: 8px;"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L0 24l6.335-1.662c1.72.937 3.659 1.432 5.631 1.433h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                    WhatsApp
                </button>
                <button class="share-btn btn-copy" onclick="copyLink()">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 8px;"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
                    Copy Link
                </button>
                <button class="share-btn btn-email" onclick="shareEmail()">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 8px;"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                    Email
                </button>
            </div>
        </div>
        
        <div class="sidebar-widget">
            <h3 class="widget-title">📑 Related Articles</h3>
            <div class="related-list">
                <c:forEach var="rel" items="${relatedPosts}">
                    <a href="/blog/${rel.slug}" class="related-item">
                        <c:choose>
                            <c:when test="${not empty rel.coverImage}">
                                <img src="${rel.coverImage}" class="related-img" alt="${rel.title}">
                            </c:when>
                            <c:otherwise>
                                <img src="https://images.unsplash.com/photo-1560518884-ce58822b07b4?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80" class="related-img" alt="Placeholder">
                            </c:otherwise>
                        </c:choose>
                        <div>
                            <h4 class="related-title">${rel.title}</h4>
                            <div class="related-meta"><fmt:formatDate value="${rel.publishedDate}" pattern="MMM dd, yyyy" /></div>
                        </div>
                    </a>
                </c:forEach>
                <c:if test="${empty relatedPosts}">
                    <p style="color: #94a3b8; font-size: 13px;">No related articles found.</p>
                </c:if>
            </div>
        </div>
        
        <div class="sidebar-widget">
            <h3 class="widget-title">🔥 Popular Posts</h3>
            <div class="related-list">
                <c:forEach var="pop" items="${popularPosts}">
                    <a href="/blog/${pop.slug}" class="related-item">
                        <div>
                            <h4 class="related-title">${pop.title}</h4>
                            <div class="related-meta">👁 ${pop.viewCount} views</div>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </div>
    </div>
</div>

<script>
    function shareWhatsApp() {
        const text = encodeURIComponent("Check out this article: " + document.title + " - " + window.location.href);
        window.open('https://api.whatsapp.com/send?text=' + text);
    }
    
    function shareEmail() {
        const title = document.title;
        const url = window.location.href;
        const subject = encodeURIComponent(title);
        const body = encodeURIComponent("Check out this interesting article:\n\n" + title + "\n" + url);
        const gmailUrl = "https://mail.google.com/mail/?view=cm&fs=1&tf=1&to=&su=" + subject + "&body=" + body;
        window.open(gmailUrl, '_blank');
    }
    
    function copyLink() {
        navigator.clipboard.writeText(window.location.href).then(() => {
            alert('Link copied to clipboard!');
        });
    }
</script>

<jsp:include page="../common/footer.jsp" />

</body>
</html>
