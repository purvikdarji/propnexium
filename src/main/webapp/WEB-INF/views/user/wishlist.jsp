<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>My Wishlist – PropNexium</title>
                <style>
                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

                    body {
                        font-family: 'Segoe UI', sans-serif;
                        background: #f0f2f5;
                    }

                    .page-wrap {
                        max-width: 1100px;
                        margin: 0 auto;
                        padding: 30px 20px;
                    }

                    .page-title {
                        font-size: 22px;
                        font-weight: 700;
                        color: #222;
                        margin-bottom: 6px;
                    }

                    .page-sub {
                        color: #888;
                        font-size: 14px;
                        margin-bottom: 28px;
                    }

                    .grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                        gap: 22px;
                    }

                    .pcard {
                        background: white;
                        border-radius: 12px;
                        overflow: hidden;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.07);
                        transition: box-shadow .2s, transform .2s;
                    }

                    .pcard:hover {
                        box-shadow: 0 6px 22px rgba(0, 0, 0, 0.12);
                        transform: translateY(-2px);
                    }

                    .thumb {
                        height: 150px;
                        background: linear-gradient(135deg, #e8eeff, #c7d7fc);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 42px;
                        position: relative;
                    }

                    .badge-cat {
                        position: absolute;
                        top: 10px;
                        left: 10px;
                        background: #1a73e8;
                        color: white;
                        font-size: 11px;
                        font-weight: 700;
                        padding: 3px 10px;
                        border-radius: 20px;
                    }

                    .info {
                        padding: 14px 16px;
                    }

                    .title {
                        font-weight: 700;
                        font-size: 15px;
                        margin-bottom: 4px;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                    }

                    .price {
                        color: #1a73e8;
                        font-size: 16px;
                        font-weight: 600;
                        margin-bottom: 4px;
                    }

                    .meta {
                        color: #888;
                        font-size: 12px;
                        margin-bottom: 12px;
                    }

                    .actions {
                        display: flex;
                        gap: 8px;
                    }

                    .btn-view {
                        flex: 1;
                        padding: 9px;
                        text-align: center;
                        background: #1a73e8;
                        color: white;
                        border-radius: 8px;
                        text-decoration: none;
                        font-size: 13px;
                        font-weight: 600;
                    }

                    .btn-remove {
                        padding: 9px 14px;
                        background: #fff0f0;
                        border: 1.5px solid #ffcccc;
                        color: #e53935;
                        border-radius: 8px;
                        cursor: pointer;
                        font-size: 13px;
                        font-weight: 600;
                        transition: background .2s;
                    }

                    .btn-remove:hover {
                        background: #ffe0e0;
                    }

                    .empty-state {
                        text-align: center;
                        padding: 80px 20px;
                        color: #aaa;
                    }

                    .empty-state .emoji {
                        font-size: 60px;
                        margin-bottom: 16px;
                    }

                    .empty-state h3 {
                        font-size: 20px;
                        color: #555;
                        margin-bottom: 8px;
                    }

                    .empty-state a {
                        display: inline-block;
                        margin-top: 16px;
                        padding: 11px 28px;
                        background: #1a73e8;
                        color: white;
                        border-radius: 30px;
                        text-decoration: none;
                        font-weight: 600;
                    }

                    .alert-success {
                        background: #d4edda;
                        color: #155724;
                        padding: 13px 18px;
                        border-radius: 8px;
                        margin-bottom: 20px;
                        font-size: 14px;
                    }
                </style>
            </head>

            <body>

                <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                    <div class="page-wrap">
                        <div class="page-title">❤️ My Wishlist</div>
                        <div class="page-sub">Properties you've saved for later</div>

                        <c:if test="${not empty successMessage}">
                            <div class="alert-success">✅ ${successMessage}</div>
                        </c:if>

                        <c:choose>
                            <c:when test="${empty wishlistItems}">
                                <div class="empty-state">
                                    <div class="emoji">🏚️</div>
                                    <h3>Your wishlist is empty</h3>
                                    <p>Start saving properties you love!</p>
                                    <a href="/properties">Browse Properties</a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="grid">
                                    <c:forEach var="item" items="${wishlistItems}">
                                        <div class="pcard">
                                            <div class="thumb">
                                                <c:choose>
                                                    <c:when test="${not empty item.property.images}">
                                                        <img src="${item.property.images[0].imageUrl}" alt="${item.property.title}" 
                                                             style="width:100%; height:100%; object-fit:cover;">
                                                    </c:when>
                                                    <c:otherwise>
                                                        🏠
                                                    </c:otherwise>
                                                </c:choose>
                                                <span class="badge-cat">${item.property.category}</span>
                                            </div>
                                            <div class="info">
                                                <div class="title">${item.property.title}</div>
                                                <div class="price">
                                                    ₹
                                                    <fmt:formatNumber value="${item.property.price}"
                                                        groupingUsed="true" />
                                                </div>
                                                <div class="meta">
                                                    📍 ${item.property.city}
                                                    <c:if test="${item.property.bedrooms > 0}">
                                                        &nbsp;·&nbsp; 🛏 ${item.property.bedrooms} BHK
                                                    </c:if>
                                                </div>
                                                <div class="actions">
                                                    <a href="/properties/${item.property.id}" class="btn-view">View
                                                        Property</a>
                                                    <form method="post" action="/user/wishlist/remove"
                                                        style="display:inline;"
                                                        onsubmit="return confirm('Remove from wishlist?')">
                                                        <input type="hidden" name="propertyId"
                                                            value="${item.property.id}">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}">
                                                        <button type="submit" class="btn-remove">🗑</button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <%@ include file="/WEB-INF/views/common/footer.jsp" %>

                        <script>
                            /* AJAX-based remove — falls back to form POST if JS disabled */
                            document.querySelectorAll('.btn-remove').forEach(btn => {
                                btn.closest('form').addEventListener('submit', async function (e) {
                                    e.preventDefault();
                                    if (!confirm('Remove from wishlist?')) return;
                                    const propertyId = this.querySelector('[name=propertyId]').value;
                                    const token = this.querySelector('[name^=_csrf]').value;
                                    const tokenName = this.querySelector('[name^=_csrf]').name;
                                    try {
                                        const res = await fetch('/api/v1/wishlist/' + propertyId, {
                                            method: 'DELETE',
                                            headers: { [tokenName]: token }
                                        });
                                        if (res.ok) {
                                            this.closest('.pcard').remove();
                                        } else {
                                            this.submit();
                                        }
                                    } catch (err) { this.submit(); }
                                });
                            });
                        </script>
            </body>

            </html>