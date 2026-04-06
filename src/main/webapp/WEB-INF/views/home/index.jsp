<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <meta name="_csrf" content="${_csrf.token}" />
                <meta name="_csrf_header" content="${_csrf.headerName}" />
                <title>PropNexium - Find Your Dream Property</title>
                <style>
                    /* ── Property Card (Premium Style) ── */
                    .property-grid {
                        display: grid;
                        grid-template-columns: repeat(4, 1fr);
                        gap: 24px;
                        margin-bottom: 48px;
                    }

                    @media (max-width: 1100px) {
                        .property-grid { grid-template-columns: repeat(2, 1fr); }
                    }
                    @media (max-width: 640px) {
                        .property-grid { grid-template-columns: 1fr; }
                    }

                    .pcard {
                        background: white;
                        border-radius: 20px;
                        overflow: hidden;
                        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.04);
                        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                        display: flex;
                        flex-direction: column;
                        height: 100%;
                        position: relative;
                        border: 1px solid #f1f5f9;
                    }

                    .pcard:hover {
                        transform: translateY(-10px);
                        box-shadow: 0 20px 40px rgba(15, 23, 42, 0.12);
                        border-color: #e2e8f0;
                    }

                    .pcard-img {
                        position: relative;
                        height: 210px;
                        overflow: hidden;
                        background: #f8fafc;
                    }

                    .pcard-img img {
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                        transition: transform 0.6s ease;
                    }

                    .pcard:hover .pcard-img img {
                        transform: scale(1.1);
                    }

                    .no-img-overlay {
                        position: absolute;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 52px;
                        background: rgba(0,0,0,0.05);
                        z-index: 1;
                    }

                    .badge-row {
                        position: absolute;
                        top: 15px;
                        left: 15px;
                        display: flex;
                        gap: 8px;
                        z-index: 2;
                    }

                    .badge {
                        padding: 5px 12px;
                        border-radius: 8px;
                        font-size: 10px;
                        font-weight: 800;
                        text-transform: uppercase;
                        letter-spacing: 0.8px;
                        box-shadow: 0 4px 10px rgba(0,0,0,0.15);
                        backdrop-filter: blur(4px);
                    }

                    .badge-featured {
                        background: linear-gradient(135deg, #fbbf24, #f59e0b);
                        color: #78350f;
                        border: 1px solid rgba(255,255,255,0.4);
                    }

                    .badge-buy { background: rgba(26, 115, 232, 0.9); color: white; }
                    .badge-rent { background: rgba(16, 185, 129, 0.9); color: white; }

                    .wish-btn {
                        position: absolute;
                        top: 15px;
                        right: 15px;
                        background: rgba(255, 255, 255, 0.9);
                        backdrop-filter: blur(6px);
                        border: none;
                        width: 38px;
                        height: 38px;
                        border-radius: 50%;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 19px;
                        transition: all 0.3s;
                        z-index: 2;
                        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
                    }

                    .wish-btn:hover {
                        background: white;
                        transform: scale(1.15) rotate(5deg);
                        color: #ef4444;
                    }

                    .pcard-body {
                        padding: 22px;
                        flex: 1;
                        display: flex;
                        flex-direction: column;
                    }

                    .pcard-title {
                        font-size: 17px;
                        font-weight: 700;
                        color: #0f172a;
                        margin-bottom: 10px;
                        display: -webkit-box;
                        -webkit-line-clamp: 1;
                        line-clamp: 1;
                        -webkit-box-orient: vertical;
                        overflow: hidden;
                        line-height: 1.4;
                    }

                    .pcard-price {
                        font-size: 22px;
                        font-weight: 800;
                        color: #1a73e8;
                        margin-bottom: 12px;
                        display: flex;
                        align-items: baseline;
                        gap: 6px;
                    }

                    .pcard-price .neg {
                        font-size: 12px;
                        color: #10b981;
                        font-weight: 700;
                        background: #f0fdf4;
                        padding: 2px 8px;
                        border-radius: 4px;
                    }

                    .pcard-loc {
                        font-size: 13.5px;
                        color: #64748b;
                        margin-bottom: 18px;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                    }

                    .pcard-meta {
                        display: flex;
                        gap: 15px;
                        margin-bottom: 20px;
                        padding-top: 15px;
                        border-top: 1px solid #f1f5f9;
                    }

                    .pcard-meta span {
                        font-size: 13px;
                        color: #475569;
                        display: flex;
                        align-items: center;
                        gap: 5px;
                        font-weight: 600;
                    }

                    .pcard-foot {
                        margin-top: auto;
                        display: flex;
                        flex-direction: column;
                        gap: 10px;
                    }

                    .btn-view {
                        width: 100%;
                        background: linear-gradient(135deg, #1a73e8, #1557b0);
                        color: white;
                        text-align: center;
                        text-decoration: none;
                        padding: 12px;
                        border-radius: 10px;
                        font-weight: 700;
                        font-size: 14px;
                        transition: all 0.3s;
                        box-shadow: 0 4px 12px rgba(26, 115, 232, 0.2);
                    }

                    .btn-view:hover {
                        background: linear-gradient(135deg, #1557b0, #0d47a1);
                        transform: translateY(-2px);
                        box-shadow: 0 6px 16px rgba(26, 115, 232, 0.3);
                    }

                    .btn-compare-small {
                        width: 100%;
                        background: white;
                        color: #1a73e8;
                        border: 1.5px solid #1a73e8;
                        padding: 10px;
                        border-radius: 10px;
                        font-size: 13px;
                        font-weight: 700;
                        cursor: pointer;
                        transition: all 0.2s;
                    }

                    .btn-compare-small:hover {
                        background: #f0f7ff;
                    }

                    .type-chip {
                        background: #f8fafc;
                        color: #64748b;
                        padding: 4px 10px;
                        border-radius: 6px;
                        font-size: 10px;
                        font-weight: 800;
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
                        border: 1px solid #e2e8f0;
                    }
                </style>
            </head>

            <body
                style="margin: 0; font-family: 'Inter', system-ui, -apple-system, sans-serif; background-color: #f8fafc;">

                <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                    <!-- HERO SECTION -->
                    <div style="background:linear-gradient(135deg, #0D47A1 0%, #1A73E8 50%, #42A5F5 100%);
                padding:80px 20px;text-align:center;position:relative;overflow:hidden;">
                        <!-- Diagonal pattern overlay -->
                        <div style="position:absolute;inset:0;opacity:0.05;
                  background:repeating-linear-gradient(
                    45deg, white, white 2px, transparent 2px, transparent 20px);"></div>

                        <div style="position:relative;z-index:1;max-width:800px;margin:0 auto;">
                            <h1 style="color:white;font-size:48px;font-weight:800;
                   margin:0 0 12px;line-height:1.2;">
                                Find Your Dream Property
                            </h1>
                            <p style="color:rgba(255,255,255,0.85);font-size:18px;margin:0 0 36px;">
                                India's Most Trusted Real Estate Platform
                            </p>

                            <!-- Search bar card -->
                            <div style="background:white;border-radius:12px;padding:20px;
                    box-shadow:0 8px 40px rgba(0,0,0,0.2);max-width:700px;margin:0 auto;">
                                <!-- Buy / Rent toggle -->
                                <div style="display:flex;gap:0;margin-bottom:16px;
                      border:1px solid #e5e7eb;border-radius:6px;overflow:hidden;
                      width:fit-content;">
                                    <a href="/search?category=BUY" style="padding:8px 24px;background:#1a73e8;color:white;
                      text-decoration:none;font-weight:600;font-size:14px;">Buy</a>
                                    <a href="/search?category=RENT" style="padding:8px 24px;background:white;color:#374151;
                      text-decoration:none;font-size:14px;
                      border-left:1px solid #e5e7eb;">Rent</a>
                                </div>

                                <!-- Search inputs row -->
                                <div style="display:flex;gap:10px;">
                                    <!-- City dropdown -->
                                    <select onchange="if(this.value) window.location='/search?city='+this.value" style="padding:12px;border:1px solid #e5e7eb;border-radius:6px;
                     font-size:14px;background:white;min-width:140px;">
                                        <option value="">All Cities</option>
                                        <c:forEach var="city" items="${popularCities}">
                                            <option value="${city.city}">${city.city}</option>
                                        </c:forEach>
                                    </select>

                                    <!-- Keyword input with autocomplete -->
                                    <div style="flex:1;position:relative;">
                                        <input type="text" id="heroKeyword"
                                            placeholder="Search by keyword, property type..." autocomplete="off" style="width:100%;padding:12px;border:1px solid #e5e7eb;
                       border-radius:6px;font-size:14px;box-sizing:border-box;" />
                                        <div id="heroAutocomplete" style="display:none;position:absolute;top:100%;left:0;right:0;
                          background:white;border:1px solid #e5e7eb;border-radius:6px;
                          box-shadow:0 4px 12px rgba(0,0,0,0.1);z-index:100;"></div>
                                    </div>

                                    <!-- Search button -->
                                    <button onclick="heroSearch()" style="padding:12px 28px;background:#1a73e8;color:white;border:none;
                     border-radius:6px;font-size:15px;font-weight:700;cursor:pointer;">
                                        Search
                                    </button>
                                </div>

                                <!-- City pill tags -->
                                <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:12px;">
                                    <c:forEach var="city" items="${popularCities}" begin="0" end="4">
                                        <a href="/search?city=${city.city}" style="background:#f0f4ff;color:#1a73e8;padding:4px 12px;
                        border-radius:20px;font-size:12px;text-decoration:none;
                        font-weight:600;">
                                            ${city.city} (${city.listingCount})
                                        </a>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- DARK STATS BAR -->
                    <div style="background:#1e293b;padding:20px 40px;">
                        <div style="max-width:1200px;margin:0 auto;display:flex;
                  justify-content:center;gap:60px;flex-wrap:wrap;">
                            <div style="text-align:center;">
                                <div style="font-size:28px;font-weight:800;color:#1a73e8;">${totalAvailable}+</div>
                                <div style="font-size:13px;color:#94a3b8;margin-top:2px;">Properties Listed</div>
                            </div>
                            <div style="text-align:center;">
                                <div style="font-size:28px;font-weight:800;color:#22c55e;">${distinctCities}+</div>
                                <div style="font-size:13px;color:#94a3b8;margin-top:2px;">Cities Covered</div>
                            </div>
                            <div style="text-align:center;">
                                <div style="font-size:28px;font-weight:800;color:#f59e0b;">${totalAgents}+</div>
                                <div style="font-size:13px;color:#94a3b8;margin-top:2px;">Verified Agents</div>
                            </div>
                        </div>
                    </div>

                    <div style="max-width:1200px;margin:0 auto;padding:40px 20px;">

                        <!-- PROPERTY TYPE QUICK FILTER GRID -->
                        <h2 style="text-align:center;color:#1e293b;font-size:24px;margin:0 0 24px;">
                            Browse by Property Type
                        </h2>
                        <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:12px;margin-bottom:48px;">
                            <c:forEach var="item" items="${[
          {'type':'APARTMENT','emoji':'🏢','label':'Apartment'},
          {'type':'HOUSE','emoji':'🏠','label':'House'},
          {'type':'VILLA','emoji':'🏡','label':'Villa'},
          {'type':'PLOT','emoji':'📐','label':'Plot'},
          {'type':'COMMERCIAL','emoji':'🏪','label':'Commercial'},
          {'type':'STUDIO','emoji':'🛋️','label':'Studio'},
          {'type':'PENTHOUSE','emoji':'🌆','label':'Penthouse'}
        ]}">
                                <a href="/search?type=${item.type}" style="background:white;border-radius:10px;padding:20px 10px;
                    text-align:center;text-decoration:none;
                    box-shadow:0 1px 8px rgba(0,0,0,0.06);
                    transition:transform 0.2s,box-shadow 0.2s;display:block;" onmouseover="this.style.transform='translateY(-4px)';
                          this.style.boxShadow='0 6px 20px rgba(26,115,232,0.15)'" onmouseout="this.style.transform='';this.style.boxShadow=
                         '0 1px 8px rgba(0,0,0,0.06)'">
                                    <div style="font-size:28px;margin-bottom:8px;">${item.emoji}</div>
                                    <div style="font-size:13px;font-weight:600;color:#374151;">${item.label}</div>
                                </a>
                            </c:forEach>
                        </div>

                        <!-- FEATURED PROPERTIES -->
                        <div style="display:flex;justify-content:space-between;align-items:center;
                                  margin-bottom:28px;">
                            <div style="display:flex;align-items:center;gap:12px;">
                                <div style="width:4px;height:24px;background:#1a73e8;border-radius:2px;"></div>
                                <h2 style="margin:0;color:#0f172a;font-size:26px;font-weight:800;">✨ Featured Properties</h2>
                            </div>
                            <a href="/search?featured=true"
                                style="background:#f0f7ff;color:#1a73e8;text-decoration:none;font-size:14px;
                                       font-weight:700;padding:8px 18px;border-radius:30px;transition:all 0.2s;"
                                onmouseover="this.style.background='#1a73e8';this.style.color='white'"
                                onmouseout="this.style.background='#f0f7ff';this.style.color='#1a73e8'">
                                Explore All Properties →
                            </a>
                        </div>
                        <div class="property-grid">
                            <c:forEach var="p" items="${featuredProperties}">
                                <%@ include file="/WEB-INF/views/common/property-card.jsp" %>
                            </c:forEach>
                        </div>

                        <!-- POPULAR CITIES -->
                        <h2 style="text-align:center;color:#1e293b;font-size:22px;margin:0 0 20px;">
                            🏙️ Popular Cities
                        </h2>
                        <div style="display:grid;grid-template-columns:repeat(4,1fr);
                  gap:16px;margin-bottom:48px;">
                            <c:forEach var="city" items="${popularCities}">
                                <a href="/search?city=${city.city}" style="background:white;border-radius:10px;padding:20px;
                    text-decoration:none;box-shadow:0 1px 8px rgba(0,0,0,0.06);
                    border-left:4px solid #1a73e8;display:block;">
                                    <div style="font-size:17px;font-weight:700;color:#1e293b;margin-bottom:4px;">
                                        ${city.city}
                                    </div>
                                    <div style="font-size:13px;color:#64748b;">
                                        ${city.listingCount} properties
                                    </div>
                                    <div style="font-size:12px;color:#94a3b8;margin-top:4px;">
                                        From ₹
                                        <fmt:formatNumber value="${city.minPrice}" groupingUsed="true" />
                                    </div>
                                </a>
                            </c:forEach>
                        </div>

                        <!-- RECENTLY VIEWED (only if session has items) -->
                        <c:if test="${not empty recentlyViewed}">
                            <div style="display:flex;align-items:center;gap:12px;margin-bottom:28px;">
                                <div style="width:4px;height:24px;background:#64748b;border-radius:2px;"></div>
                                <h2 style="color:#1e293b;font-size:24px;font-weight:800;margin:0;">🕐 Recently Viewed</h2>
                            </div>
                            <div class="property-grid">
                                <c:forEach var="p" items="${recentlyViewed}" end="3">
                                    <%@ include file="/WEB-INF/views/common/property-card.jsp" %>
                                </c:forEach>
                            </div>
                        </c:if>

                        <!-- WHY PROPNEXIUM -->
                        <h2 style="text-align:center;color:#1e293b;font-size:22px;margin:0 0 24px;">
                            Why Choose PropNexium?
                        </h2>
                        <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:16px;
                  margin-bottom:40px;">
                            <c:forEach var="feature" items="${[
          {'icon':'🔒','title':'Verified Listings','desc':'Every property verified by our team'},
          {'icon':'🤝','title':'Trusted Agents','desc':'Rated and reviewed by real buyers'},
          {'icon':'📱','title':'Easy Contact','desc':'Connect with agents instantly'},
          {'icon':'🏆','title':'Best Deals','desc':'Compare and find the best value'}
        ]}">
                                <div style="background:white;border-radius:10px;padding:24px;text-align:center;
                      box-shadow:0 1px 8px rgba(0,0,0,0.06);">
                                    <div style="font-size:32px;margin-bottom:12px;">${feature.icon}</div>
                                    <h3 style="margin:0 0 8px;font-size:15px;color:#1e293b;">${feature.title}</h3>
                                    <p style="margin:0;font-size:13px;color:#94a3b8;line-height:1.5;">
                                        ${feature.desc}
                                    </p>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                     <!-- ── FOOTER ── -->
                    <%@ include file="/WEB-INF/views/common/footer.jsp" %>

                    <!-- Hero search JS -->
                    <script>
                        let heroTimer;
                        document.getElementById('heroKeyword').addEventListener('input', function () {
                            clearTimeout(heroTimer);
                            const q = this.value.trim();
                            const dropdown = document.getElementById('heroAutocomplete');
                            if (q.length < 2) { dropdown.style.display = 'none'; return; }
                            heroTimer = setTimeout(() => {
                                fetch('/search/autocomplete?q=' + encodeURIComponent(q))
                                    .then(r => r.json())
                                    .then(data => {
                                        if (!data.data || !data.data.length) {
                                            dropdown.style.display = 'none'; return;
                                        }
                                        dropdown.innerHTML = data.data.map(s =>
                                            '<div onclick="document.getElementById(\'heroKeyword\').value=\'' +
                                            s.replace(/'/g, "\\'") + '\';document.getElementById(\'heroAutocomplete\').style.display=\'none\'"' +
                                            ' style="padding:10px 14px;cursor:pointer;font-size:14px;color:#1e293b;' +
                                            'border-bottom:1px solid #f1f5f9;">' + s + '</div>'
                                        ).join('');
                                        dropdown.style.display = 'block';
                                    });
                            }, 250);
                        });

                        function heroSearch() {
                            const keyword = document.getElementById('heroKeyword').value.trim();
                            if (keyword) window.location = '/search?keyword=' + encodeURIComponent(keyword);
                            else window.location = '/search';
                        }

                        document.getElementById('heroKeyword').addEventListener('keydown', e => {
                            if (e.key === 'Enter') heroSearch();
                        });
                    </script>
            </body>

            </html>