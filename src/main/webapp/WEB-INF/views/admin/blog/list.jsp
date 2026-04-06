<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Blog Posts | Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f1f5f9; color: #1e293b; margin: 0; padding: 0; }
        .wrapper { display: flex; height: 100vh; overflow: hidden; }
        .main-content { flex: 1; overflow-y: auto; padding: 40px; }
        
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .header h1 { font-size: 24px; margin: 0; font-weight: 700; color: #0f172a; }
        .btn-new { background: #2563eb; color: white; padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 14px; transition: 0.2s; }
        .btn-new:hover { background: #1d4ed8; }
        
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        th { background: #f8fafc; padding: 16px; text-align: left; font-size: 13px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #e2e8f0; }
        td { padding: 16px; border-bottom: 1px solid #e2e8f0; vertical-align: middle; font-size: 14px; }
        tr:last-child td { border-bottom: none; }
        tr:hover { background: #f8fafc; }
        
        .title-cell { display: flex; align-items: center; gap: 12px; }
        .title-cell img { width: 48px; height: 36px; border-radius: 6px; object-fit: cover; }
        .title-cell span { font-weight: 600; color: #0f172a; }
        
        .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .badge-published { background: #dcfce7; color: #166534; }
        .badge-draft { background: #f1f5f9; color: #475569; }
        
        .actions { display: flex; gap: 8px; }
        .btn-sm { padding: 6px 12px; border-radius: 6px; text-decoration: none; font-size: 13px; font-weight: 500; border: none; cursor: pointer; }
        .btn-edit { background: #eff6ff; color: #2563eb; }
        .btn-edit:hover { background: #dbeafe; }
        .btn-delete { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
        .btn-delete:hover { background: #fee2e2; }
    </style>
</head>
<body>
    <div class="wrapper">
        <div class="main-content">
            <div class="header">
                <h1>Blog Posts</h1>
                <a href="/admin/blog/new" class="btn-new">Write New Post</a>
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Category</th>
                        <th>Status</th>
                        <th>Published</th>
                        <th>Views</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${posts.content}">
                        <tr>
                            <td>
                                <div class="title-cell">
                                    <c:choose>
                                        <c:when test="${not empty p.coverImage}">
                                            <img src="${p.coverImage}" alt="Cover">
                                        </c:when>
                                        <c:otherwise>
                                            <div style="width:48px;height:36px;background:#e2e8f0;border-radius:6px;"></div>
                                        </c:otherwise>
                                    </c:choose>
                                    <span>${p.title}</span>
                                </div>
                            </td>
                            <td>${p.category}</td>
                            <td>
                                <span class="badge ${p.status == 'PUBLISHED' ? 'badge-published' : 'badge-draft'}">
                                    ${p.status}
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty p.publishedDate}">
                                        <span><fmt:formatDate value="${p.publishedDate}" pattern="MMM dd, yyyy" /></span>
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                            <td>${p.viewCount}</td>
                            <td>
                                <div class="actions">
                                    <a href="/admin/blog/${p.id}/edit" class="btn-sm btn-edit">Edit</a>
                                    <form action="/admin/blog/${p.id}/delete" method="POST" style="margin:0;display:inline;" onsubmit="return confirm('Are you sure you want to delete this post?');">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                        <button type="submit" class="btn-sm btn-delete">Delete</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty posts.content}">
                        <tr>
                            <td colspan="6" style="text-align:center;padding:40px;color:#64748b;">No blog posts found. <a href="/admin/blog/new">Create one</a>.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
