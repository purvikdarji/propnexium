<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <meta name="_csrf" content="${_csrf.token}" />
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                    <title>Properties – PropNexium</title>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
                    <style>
                        * {
                            box-sizing: border-box;
                            margin: 0;
                            padding: 0
                        }

                        body {
                            font-family: 'Inter', sans-serif;
                            background: #f4f6fb;
                            color: #222
                        }

                        /* ── Filter Bar ── */
                        .filter-bar {
                            background: white;
                            padding: 16px 30px;
                            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
                            position: sticky;
                            top: 60px;
                            z-index: 100;
                        }

                        .filter-form {
                            display: flex;
                            gap: 10px;
                            flex-wrap: wrap;
                            align-items: center
                        }

                        .filter-form select,
                        .filter-form input[type=number],
                        .filter-form input[type=text] {
                            padding: 9px 12px;
                            border: 1.5px solid #ddd;
                            border-radius: 8px;
                            font-size: 13px;
                            font-family: inherit;
                            background: white;
                            color: #333;
                            outline: none;
                            transition: border-color .2s;
                        }

                        .filter-form select:focus,
                        .filter-form input[type=number]:focus,
                        .filter-form input[type=text]:focus {
                            border-color: #1a73e8
                        }

                        .filter-form input[type=number] {
                            width: 130px
                        }

                        .cat-tabs {
                            display: flex;
                            border: 1.5px solid #ddd;
                            border-radius: 8px;
                            overflow: hidden
                        }

                        .cat-tab {
                            padding: 9px 20px;
                            text-decoration: none;
                            font-size: 13px;
                            font-weight: 500;
                            transition: background .2s;
                        }

                        .cat-tab.active {
                            background: #1a73e8;
                            color: white
                        }

                        .cat-tab:not(.active) {
                            background: white;
                            color: #333
                        }

                        .btn-search {
                            padding: 9px 22px;
                            background: #1a73e8;
                            color: white;
                            border: none;
                            border-radius: 8px;
                            cursor: pointer;
                            font-size: 13px;
                            font-weight: 600;
                            font-family: inherit;
                            transition: opacity .2s;
                        }

                        .btn-search:hover {
                            opacity: .88
                        }

                        .btn-reset {
                            padding: 9px 16px;
                            border: 1.5px solid #ddd;
                            border-radius: 8px;
                            text-decoration: none;
                            color: #555;
                            font-size: 13px;
                            font-weight: 500;
                            white-space: nowrap;
                        }

                        /* ── Page Body ── */
                        .page-body {
                            max-width: 1280px;
                            margin: 0 auto;
                            padding: 24px 30px 40px
                        }

                        .results-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 20px;
                        }

                        .results-header h2 {
                            font-size: 20px;
                            font-weight: 700
                        }

                        .results-header h2 span {
                            color: #888;
                            font-size: 15px;
                            font-weight: 400;
                            margin-left: 8px
                        }

                        .results-count {
                            color: #888;
                            font-size: 14px
                        }

                        /* ── Property Grid ── */
                        .property-grid {
                            display: grid;
                            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                            gap: 22px;
                        }

                        /* ── Property Card ── */
                        /* ── Property Card (Premium Style) ── */
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
                            transform: translateY(-8px);
                            box-shadow: 0 20px 40px rgba(15, 23, 42, 0.12);
                            border-color: #e2e8f0;
                        }

                        .pcard-img {
                            position: relative;
                            height: 200px;
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
                            font-size: 48px;
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
                            transform: scale(1.15);
                        }

                        .pcard-body {
                            padding: 20px;
                            flex: 1;
                            display: flex;
                            flex-direction: column;
                        }

                        .pcard-title {
                            font-size: 16px;
                            font-weight: 700;
                            color: #0f172a;
                            margin-bottom: 8px;
                            display: -webkit-box;
                            -webkit-line-clamp: 1;
                            line-clamp: 1;
                            -webkit-box-orient: vertical;
                            overflow: hidden;
                        }

                        .pcard-price {
                            font-size: 20px;
                            font-weight: 800;
                            color: #1a73e8;
                            margin-bottom: 10px;
                        }

                        .pcard-price .neg {
                            font-size: 12px;
                            color: #10b981;
                            font-weight: 700;
                        }

                        .pcard-loc {
                            font-size: 13px;
                            color: #64748b;
                            margin-bottom: 14px;
                            display: flex;
                            align-items: center;
                            gap: 4px;
                        }

                        .pcard-meta {
                            display: flex;
                            gap: 12px;
                            margin-bottom: 16px;
                            padding-top: 12px;
                            border-top: 1px solid #f1f5f9;
                        }

                        .pcard-meta span {
                            font-size: 13px;
                            color: #475569;
                            display: flex;
                            align-items: center;
                            gap: 4px;
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
                            padding: 10px;
                            border-radius: 8px;
                            font-weight: 700;
                            font-size: 13px;
                            transition: all 0.3s;
                        }

                        .btn-view:hover { opacity: 0.9; }

                        .btn-compare-small {
                            width: 100%;
                            background: white;
                            color: #1a73e8;
                            border: 1.5px solid #1a73e8;
                            padding: 8px;
                            border-radius: 8px;
                            font-size: 12px;
                            font-weight: 700;
                            cursor: pointer;
                            transition: all 0.2s;
                        }

                        .btn-compare-small:hover { background: #f0f7ff; }

                        .type-chip {
                            background: #f1f5f9;
                            color: #475569;
                            padding: 4px 10px;
                            border-radius: 6px;
                            font-size: 11px;
                            font-weight: 700;
                            text-transform: uppercase;
                        }

                        /* ── Empty State ── */
                        .empty-state {
                            text-align: center;
                            padding: 80px 20px;
                            grid-column: 1/-1;
                        }

                        .empty-state .emoji {
                            font-size: 64px;
                            margin-bottom: 20px
                        }

                        .empty-state h3 {
                            font-size: 22px;
                            margin-bottom: 8px
                        }

                        .empty-state p {
                            color: #888
                        }

                        .empty-state a {
                            color: #1a73e8;
                            text-decoration: none
                        }

                        /* ── Pagination ── */
                        .pagination {
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            gap: 6px;
                            margin-top: 36px;
                        }

                        .pagination a,
                        .pagination span {
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            width: 38px;
                            height: 38px;
                            border-radius: 9px;
                            font-size: 14px;
                            text-decoration: none;
                            font-weight: 500;
                        }

                        .pagination a {
                            border: 1.5px solid #ddd;
                            color: #333;
                            transition: all .2s
                        }

                        .pagination a:hover {
                            background: #1a73e8;
                            color: white;
                            border-color: #1a73e8
                        }

                        .pagination .active {
                            background: #1a73e8;
                            color: white;
                            border: 1.5px solid #1a73e8;
                            font-weight: 700;
                        }

                        .pagination .dots {
                            color: #aaa;
                            border: none;
                            cursor: default
                        }

                        /* ── Toast ── */
                        #toast {
                            position: fixed;
                            bottom: 30px;
                            right: 30px;
                            padding: 13px 24px;
                            border-radius: 9px;
                            font-size: 14px;
                            font-weight: 600;
                            z-index: 9999;
                            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
                            display: none;
                            animation: slideIn .3s ease;
                            color: white;
                        }

                        @keyframes slideIn {
                            from {
                                opacity: 0;
                                transform: translateY(20px)
                            }

                            to {
                                opacity: 1;
                                transform: translateY(0)
                            }
                        }
                        /* ── Save Search Button ── */
                        .btn-save-search {
                            padding: 9px 16px;
                            background: white;
                            border: 1.5px solid #1a73e8;
                            color: #1a73e8;
                            border-radius: 8px;
                            cursor: pointer;
                            font-size: 13px;
                            font-weight: 600;
                            display: flex;
                            align-items: center;
                            gap: 6px;
                            transition: all .2s;
                        }
                        .btn-save-search:hover {
                            background: #f0f4ff;
                        }

                        /* ── Modal ── */
                        .modal-overlay {
                            position: fixed;
                            top: 0; left: 0; right: 0; bottom: 0;
                            background: rgba(15, 23, 42, 0.6);
                            display: none;
                            align-items: center;
                            justify-content: center;
                            z-index: 10000;
                            backdrop-filter: blur(4px);
                        }
                        .modal-content {
                            background: white;
                            padding: 28px;
                            border-radius: 16px;
                            width: 100%;
                            max-width: 420px;
                            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
                        }
                        .modal-content h3 {
                            margin: 0 0 12px;
                            font-size: 18px;
                            font-weight: 700;
                        }
                        .modal-content p {
                            font-size: 14px;
                            color: #64748b;
                            margin-bottom: 20px;
                        }
                        .modal-content input {
                            width: 100%;
                            padding: 11px 14px;
                            border: 1.5px solid #e2e8f0;
                            border-radius: 10px;
                            font-size: 14px;
                            margin-bottom: 24px;
                            outline: none;
                        }
                        .modal-actions {
                            display: flex;
                            gap: 12px;
                            justify-content: flex-end;
                        }
                        .btn-cancel {
                            padding: 9px 18px;
                            border: 1.5px solid #e2e8f0;
                            background: white;
                            border-radius: 8px;
                            cursor: pointer;
                            font-weight: 600;
                            font-size: 14px;
                        }
                        .btn-confirm {
                            padding: 9px 22px;
                            background: #1a73e8;
                            color: white;
                            border: none;
                            border-radius: 8px;
                            cursor: pointer;
                            font-weight: 600;
                            font-size: 14px;
                        }
                    </style>
                </head>

                <body>

                    <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                        <!-- ══════════════════ FILTER BAR ══════════════════ -->
                        <div class="filter-bar">
                            <form action="/properties" method="GET" class="filter-form">


                                <!-- City -->
                                <select name="city">
                                    <option value="">All Cities</option>
                                    <c:forEach var="c" items="${supportedCities}">
                                        <option value="${c}" ${filterCity==c ? 'selected' : '' }>${c}</option>
                                    </c:forEach>
                                </select>

                                <!-- Type -->
                                <select name="type">
                                    <option value="">All Types</option>
                                    <c:forEach var="t" items="${propertyTypes}">
                                        <option value="${t}" ${filterType==t.name() ? 'selected' : '' }>${t}</option>
                                    </c:forEach>
                                </select>

                                <!-- Category tabs -->
                                <div class="cat-tabs">
                                    <a href="?category=BUY&city=${filterCity}&type=${filterType}&minPrice=${filterMinPrice}&maxPrice=${filterMaxPrice}&bedrooms=${filterBedrooms}&keyword=${filterKeyword}&sortBy=${sortBy}&sortDir=${sortDir}"
                                        class="cat-tab ${filterCategory == 'BUY' ? 'active' : ''}">Buy</a>
                                    <a href="?category=RENT&city=${filterCity}&type=${filterType}&minPrice=${filterMinPrice}&maxPrice=${filterMaxPrice}&bedrooms=${filterBedrooms}&keyword=${filterKeyword}&sortBy=${sortBy}&sortDir=${sortDir}"
                                        class="cat-tab ${filterCategory == 'RENT' ? 'active' : ''}">Rent</a>
                                </div>

                                <!-- Price Range -->
                                <input type="number" name="minPrice" placeholder="Min Price ₹" value="${filterMinPrice}"
                                    min="0">
                                <input type="number" name="maxPrice" placeholder="Max Price ₹" value="${filterMaxPrice}"
                                    min="0">

                                <!-- Bedrooms -->
                                <select name="bedrooms">
                                    <option value="">Any BHK</option>
                                    <option value="1" ${filterBedrooms==1 ? 'selected' :''}>1 BHK</option>
                                    <option value="2" ${filterBedrooms==2 ? 'selected' :''}>2 BHK</option>
                                    <option value="3" ${filterBedrooms==3 ? 'selected' :''}>3 BHK</option>
                                    <option value="4" ${filterBedrooms==4 ? 'selected' :''}>4+ BHK</option>
                                </select>

                                <!-- Sort -->
                                <select name="sortBy">
                                    <option value="createdAt" ${sortBy=='createdAt' ?'selected':''}>Newest First
                                    </option>
                                    <option value="price" ${sortBy=='price' ?'selected':''}>Price</option>
                                    <option value="areaSqft" ${sortBy=='areaSqft' ?'selected':''}>Area</option>
                                    <option value="viewCount" ${sortBy=='viewCount' ?'selected':''}>Popular</option>
                                </select>
                                <select name="sortDir">
                                    <option value="DESC" ${sortDir=='DESC' ?'selected':''}>↓ High-Low</option>
                                    <option value="ASC" ${sortDir=='ASC' ?'selected':''}>↑ Low-High</option>
                                </select>

                                <button type="submit" class="btn-search">Apply Filters</button>
                                <a href="/properties" class="btn-reset">Reset</a>
                            </form>
                        </div>

                        <!-- ══════════════════ BODY ══════════════════ -->
                        <div class="page-body">

                            <!-- Results Header -->
                            <div class="results-header">
                                <div>
                                    <h2>
                                        <c:choose>
                                            <c:when test="${not empty filterCity}">${filterCity} Properties</c:when>
                                            <c:otherwise>All Properties</c:otherwise>
                                        </c:choose>
                                        <span>(${totalElements} found)</span>
                                    </h2>
                                    <div class="results-count">
                                        Page ${currentPage + 1} of ${totalPages > 0 ? totalPages : 1}
                                    </div>
                                </div>
                                <div style="display:flex; gap:10px; align-items:center;">
                                    <button class="btn-save-search" onclick="toggleMap()">
                                        🗺️ Toggle Map
                                    </button>
                                    <c:if test="${isLoggedIn}">
                                        <button class="btn-save-search" onclick="showSaveModal()">
                                            💾 Save This Search
                                        </button>
                                    </c:if>
                                </div>
                            </div>

                            <div id="split-view" style="display:flex; gap:20px; align-items:flex-start;">
                                <div id="grid-container" style="flex:1;">
                                    <!-- Property Grid -->
                                    <div class="property-grid">

                                <c:choose>
                                    <c:when test="${empty properties}">
                                        <div class="empty-state">
                                            <div class="emoji">🔍</div>
                                            <h3>No properties found</h3>
                                            <p>Try adjusting your filters or <a href="/properties">view all
                                                    properties</a></p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="p" items="${properties}">
                                            <%@ include file="/WEB-INF/views/common/property-card.jsp" %>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- ══ Pagination ══ -->
                            <c:if test="${totalPages > 1}">
                                <div class="pagination">
                                    <!-- Prev -->
                                    <c:if test="${currentPage > 0}">
                                        <a href="?page=${currentPage-1}&size=9&sortBy=${sortBy}&sortDir=${sortDir}&city=${filterCity}&type=${filterType}&category=${filterCategory}&minPrice=${filterMinPrice}&maxPrice=${filterMaxPrice}&bedrooms=${filterBedrooms}&keyword=${filterKeyword}">‹</a>
                                    </c:if>

                                    <!-- Page numbers -->
                                    <c:forEach begin="0" end="${totalPages - 1}" var="i">
                                        <c:choose>
                                            <c:when test="${i == currentPage}">
                                                <span class="active">${i + 1}</span>
                                            </c:when>
                                            <c:when test="${i == 0 || i == totalPages-1 || (i >= currentPage-1 && i <= currentPage+1)}">
                                                <a href="?page=${i}&size=9&sortBy=${sortBy}&sortDir=${sortDir}&city=${filterCity}&type=${filterType}&category=${filterCategory}&minPrice=${filterMinPrice}&maxPrice=${filterMaxPrice}&bedrooms=${filterBedrooms}&keyword=${filterKeyword}">${i + 1}</a>
                                            </c:when>
                                            <c:when test="${i == 1 && currentPage > 3}">
                                                <span class="dots">…</span>
                                            </c:when>
                                            <c:when test="${i == totalPages-2 && currentPage < totalPages-4}">
                                                <span class="dots">…</span>
                                            </c:when>
                                        </c:choose>
                                    </c:forEach>

                                    <!-- Next -->
                                    <c:if test="${currentPage < totalPages - 1}">
                                        <a href="?page=${currentPage+1}&size=9&sortBy=${sortBy}&sortDir=${sortDir}&city=${filterCity}&type=${filterType}&category=${filterCategory}&minPrice=${filterMinPrice}&maxPrice=${filterMaxPrice}&bedrooms=${filterBedrooms}&keyword=${filterKeyword}">›</a>
                                    </c:if>
                                </div>
                            </c:if>
                                </div> <!-- end grid-container -->

                                <!-- Map Container -->
                                <div id="map-container" style="display:none; width:45%; height:calc(100vh - 140px); position:sticky; top:110px; border-radius:12px; border:1px solid #ddd; z-index:10; overflow:hidden;">
                                    <div id="propMap" style="width:100%; height:100%; background:#e0e7ff;"></div>
                                </div>
                            </div> <!-- end split-view -->
                        </div><!-- /page-body -->

                        <%@ include file="/WEB-INF/views/common/footer.jsp" %>

                            <!-- Toast -->
                            <div id="toast"></div>

                            <script>
                                const CSRF_TOKEN = document.querySelector("meta[name='_csrf']").getAttribute("content");
                                const CSRF_HEADER = document.querySelector("meta[name='_csrf_header']").getAttribute("content");
                                
                                // Save Search Modal Functions
                                 function showSaveModal() {
                                     document.getElementById('saveSearchModal').style.display = 'flex';
                                     document.getElementById('savedSearchName').focus();
                                 }
                                 function closeSaveModal() {
                                     document.getElementById('saveSearchModal').style.display = 'none';
                                 }
                                 function confirmSaveSearch() {
                                     const nameInput = document.getElementById('savedSearchName');
                                     const name = nameInput.value.trim();
                                     if(!name) {
                                         nameInput.style.borderColor = '#ef4444';
                                         return;
                                     }
                                     
                                     const params = new URLSearchParams(window.location.search);
                                     params.append('name', name);
                                     
                                     fetch('/user/saved-searches', {
                                         method: 'POST',
                                         headers: {
                                             'Content-Type': 'application/x-www-form-urlencoded',
                                             [CSRF_HEADER]: CSRF_TOKEN
                                         },
                                         body: params.toString()
                                     })
                                     .then(r => r.json())
                                     .then(data => {
                                         closeSaveModal();
                                         showToast(data.message || 'Search saved!', 'success');
                                     })
                                     .catch(() => showToast('Failed to save search', 'error'));
                                 }
                             </script>

                             <!-- Modal -->
                             <div id="saveSearchModal" class="modal-overlay">
                                 <div class="modal-content">
                                     <h3>💾 Save Search</h3>
                                     <p>Give your search a name so you can easily access it later from your dashboard.</p>
                                     <input type="text" id="savedSearchName" placeholder="e.g. 2BHK Mumbai Properties">
                                     <div class="modal-actions">
                                         <button class="btn-cancel" onclick="closeSaveModal()">Cancel</button>
                                         <button class="btn-confirm" onclick="confirmSaveSearch()">Save Now</button>
                                     </div>
                                 </div>
                             </div>

                     <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
                    <script>
                        const propertiesJson = '${mapDataJson}';
                        let map = null;
                        let markers = [];

                        function toggleMap() {
                            const mapContainer = document.getElementById('map-container');
                            const gridContainer = document.getElementById('grid-container');
                            const propertyGrid = document.querySelector('.property-grid');
                            
                            if (mapContainer.style.display === 'none') {
                                mapContainer.style.display = 'block';
                                propertyGrid.style.gridTemplateColumns = 'repeat(auto-fill, minmax(280px, 1fr))';
                                initMap();
                            } else {
                                mapContainer.style.display = 'none';
                                propertyGrid.style.gridTemplateColumns = 'repeat(auto-fill, minmax(300px, 1fr))';
                            }
                        }

                        function initMap() {
                            if (map) {
                                map.invalidateSize();
                                return;
                            }
                            
                            map = L.map('propMap').setView([20.5937, 78.9629], 5); // Default to India
                            L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
                                attribution: '© OpenStreetMap contributors © CARTO'
                            }).addTo(map);

                            try {
                                const data = JSON.parse(propertiesJson || '[]');
                                if (data.length === 0) return;

                                const bounds = L.latLngBounds();
                                data.forEach(p => {
                                    if (p.lat && p.lng) {
                                        const marker = L.marker([p.lat, p.lng]).addTo(map);
                                        bounds.extend([p.lat, p.lng]);
                                        
                                        const popupContent = `
                                            <div style="font-family:Inter; width:200px;">
                                                <img src="\${p.image || '🏠'}" style="width:100%; height:100px; object-fit:cover; border-radius:6px; margin-bottom:8px;">
                                                <div style="font-weight:600; font-size:13px; line-height:1.4;">\${p.title}</div>
                                                <div style="color:#1a73e8; font-weight:700; margin-top:4px;">₹\${p.price.toLocaleString('en-IN')}</div>
                                                <a href="/properties/\${p.id}" style="display:block; margin-top:8px; text-decoration:none; color:white; background:#1a73e8; padding:6px; text-align:center; border-radius:4px; font-weight:600; font-size:12px;">View</a>
                                            </div>
                                        `;
                                        marker.bindPopup(popupContent);
                                    }
                                });
                                // Fit bounds if there are markers
                                if (data.some(p => p.lat && p.lng)) {
                                    map.fitBounds(bounds, { padding: [30, 30] });
                                }
                            } catch (e) {
                                console.error('Map loading error', e);
                            }
                        }
                    </script>
                </body>

                </html>