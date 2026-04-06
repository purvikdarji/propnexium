<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${_csrf.token}" />
    <meta name="_csrf_header" content="${_csrf.headerName}" />
    <title>Search Properties – PropNexium</title>
    <meta name="description" content="Search through thousands of properties for sale and rent. Filter by city, type, price, bedrooms and more.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: #f8fafc; color: #1e293b; }

        /* ── Sidebar ── */
        .sidebar {
            width: 280px; flex-shrink: 0;
            background: white;
            border-right: 1px solid #e5e7eb;
            position: sticky; top: 60px;
            height: calc(100vh - 60px);
            overflow-y: auto;
            padding: 24px 20px;
        }
        .sidebar::-webkit-scrollbar { width: 4px; }
        .sidebar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 2px; }

        .filter-label {
            display: block; font-size: 11px; font-weight: 700;
            color: #94a3b8; text-transform: uppercase; letter-spacing: .7px;
            margin-bottom: 8px;
        }
        .filter-group { margin-bottom: 20px; }

        .filter-input {
            width: 100%; padding: 9px 12px;
            border: 1.5px solid #e2e8f0; border-radius: 8px;
            font-size: 14px; font-family: inherit; color: #1e293b;
            outline: none; transition: border-color .2s;
            background: white;
        }
        .filter-input:focus { border-color: #1a73e8; }

        .radio-tab-group {
            display: flex; border: 1.5px solid #e2e8f0;
            border-radius: 8px; overflow: hidden;
        }
        .radio-tab-label { flex: 1; text-align: center; cursor: pointer; }
        .radio-tab-label:not(:first-child) { border-left: 1.5px solid #e2e8f0; }
        .radio-tab-label span {
            display: block; padding: 9px 4px; font-size: 13px; font-weight: 500;
            transition: background .15s, color .15s;
        }
        .radio-tab-label input[type=radio] { display: none; }
        .radio-tab-label input:checked + span {
            background: #1a73e8; color: white;
        }

        .type-radio-item {
            display: flex; align-items: center; gap: 8px;
            padding: 6px 0; font-size: 13px; cursor: pointer; color: #374151;
        }
        .type-radio-item:hover { color: #1a73e8; }
        .type-radio-item input { accent-color: #1a73e8; }

        .bhk-chips { display: flex; gap: 6px; flex-wrap: wrap; }
        .bhk-label { cursor: pointer; }
        .bhk-label input { display: none; }
        .bhk-chip {
            display: inline-block; padding: 5px 14px;
            border: 1.5px solid #e2e8f0; border-radius: 20px;
            font-size: 12px; font-weight: 600; color: #64748b;
            transition: all .15s;
        }
        .bhk-label input:checked + .bhk-chip {
            border-color: #1a73e8; background: #e8f0fe; color: #1a73e8;
        }

        .price-row { display: flex; gap: 8px; }
        .price-row input { flex: 1; }

        .btn-apply {
            width: 100%; padding: 11px; background: #1a73e8; color: white;
            border: none; border-radius: 8px; font-size: 14px; font-weight: 600;
            cursor: pointer; margin-bottom: 8px; transition: background .2s;
            font-family: inherit;
        }
        .btn-apply:hover { background: #1557b0; }
        .btn-reset {
            display: block; width: 100%; padding: 11px; text-align: center;
            background: #f1f5f9; color: #64748b; border-radius: 8px;
            font-size: 14px; text-decoration: none; font-weight: 500;
            transition: background .15s;
        }
        .btn-reset:hover { background: #e2e8f0; }

        /* ── Main ── */
        .main { flex: 1; padding: 24px 28px; min-height: calc(100vh - 60px); }

        /* Filter chips */
        .chip-row { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 18px; }
        .chip {
            display: flex; align-items: center; gap: 6px;
            background: #e8f0fe; color: #1a73e8;
            padding: 5px 12px; border-radius: 20px;
            font-size: 12px; font-weight: 600;
        }
        .chip-remove {
            color: #1a73e8; text-decoration: none; font-weight: 700;
            font-size: 14px; line-height: 1;
        }
        .chip-remove:hover { color: #dc2626; }
        .chip-clear {
            background: #fee2e2; color: #dc2626;
            padding: 5px 12px; border-radius: 20px;
            font-size: 12px; font-weight: 600; text-decoration: none;
        }

        /* Results meta */
        .results-meta { color: #64748b; font-size: 14px; margin-bottom: 20px; }
        .results-meta strong { color: #1e293b; }
        .results-time { color: #94a3b8; font-size: 12px; margin-left: 6px; }

        /* ── Property Card (Consolidated) ── */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }
        .pcard {
            background: white; border-radius: 20px; overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.04);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex; flex-direction: column; height: 100%;
            position: relative; border: 1px solid #f1f5f9;
        }
        .pcard:hover { transform: translateY(-8px); box-shadow: 0 20px 40px rgba(15, 23, 42, 0.12); border-color: #e2e8f0; }
        .pcard-img { position: relative; height: 200px; overflow: hidden; background: #f8fafc; }
        .pcard-img img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.6s ease; }
        .pcard:hover .pcard-img img { transform: scale(1.1); }
        .no-img-overlay {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            display: flex; align-items: center; justify-content: center;
            font-size: 48px; background: rgba(0,0,0,0.05); z-index: 1;
        }
        .badge-row { position: absolute; top: 15px; left: 15px; display: flex; gap: 8px; z-index: 2; }
        .badge { padding: 5px 12px; border-radius: 8px; font-size: 10px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.8px; box-shadow: 0 4px 10px rgba(0,0,0,0.15); backdrop-filter: blur(4px); }
        .badge-featured { background: linear-gradient(135deg, #fbbf24, #f59e0b); color: #78350f; border: 1px solid rgba(255,255,255,0.4); }
        .badge-buy { background: rgba(26, 115, 232, 0.9); color: white; }
        .badge-rent { background: rgba(16, 185, 129, 0.9); color: white; }
        .wish-btn { position: absolute; top: 15px; right: 15px; background: rgba(255, 255, 255, 0.9); backdrop-filter: blur(6px); border: none; width: 38px; height: 38px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 19px; transition: all 0.3s; z-index: 2; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        .wish-btn:hover { background: white; transform: scale(1.15); }
        .pcard-body { padding: 20px; flex: 1; display: flex; flex-direction: column; }
        .pcard-title { font-size: 16px; font-weight: 700; color: #0f172a; margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 1; line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; }
        .pcard-price { font-size: 20px; font-weight: 800; color: #1a73e8; margin-bottom: 10px; }
        .pcard-price .neg { font-size: 12px; color: #10b981; font-weight: 700; }
        .pcard-loc { font-size: 13px; color: #64748b; margin-bottom: 14px; display: flex; align-items: center; gap: 4px; }
        .pcard-meta { display: flex; gap: 12px; margin-bottom: 16px; padding-top: 12px; border-top: 1px solid #f1f5f9; }
        .pcard-meta span { font-size: 12px; color: #475569; display: flex; align-items: center; gap: 4px; font-weight: 600; }
        .pcard-foot { margin-top: auto; }
        .type-chip { display: inline-block; padding: 4px 10px; background: #f1f5f9; border-radius: 8px; font-size: 12px; color: #64748b; font-weight: 600; }
        .btn-view { display: inline-block; padding: 8px 16px; background: #1a73e8; color: white; border-radius: 8px; font-size: 13px; font-weight: 600; text-decoration: none; transition: background .2s; }
        .btn-view:hover { background: #1557b0; }
        .btn-compare-small { width: 100%; margin-top: 8px; padding: 8px; background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 8px; color: #64748b; font-size: 11px; font-weight: 700; cursor: pointer; transition: all .2s; }
        .btn-compare-small:hover { border-color: #1a73e8; color: #1a73e8; background: #f0f4ff; }

        /* Empty / loading states */
        .empty-state {
            text-align: center; padding: 80px 20px; color: #94a3b8;
        }
        .empty-state .icon { font-size: 56px; margin-bottom: 16px; }
        .empty-state h3 { font-size: 20px; color: #374151; margin-bottom: 8px; font-weight: 600; }
        .empty-state p { font-size: 14px; }
        .empty-state a {
            display: inline-block; margin-top: 16px; padding: 10px 24px;
            background: #1a73e8; color: white; text-decoration: none;
            border-radius: 8px; font-size: 14px; font-weight: 600;
        }

        /* Pagination */
        .pagination {
            display: flex; justify-content: center;
            align-items: center; gap: 6px; margin-top: 24px; flex-wrap: wrap;
        }
        .page-link {
            padding: 8px 14px; border: 1.5px solid #e2e8f0; border-radius: 8px;
            color: #374151; text-decoration: none; font-size: 14px; font-weight: 500;
            transition: all .15s; display: inline-block;
        }
        .page-link:hover { border-color: #1a73e8; color: #1a73e8; background: #f0f4ff; }
        .page-link.active {
            background: #1a73e8; border-color: #1a73e8; color: white;
            font-weight: 700;
        }

        /* Autocomplete dropdown */
        #autocompleteDropdown {
            position: absolute; top: 100%; left: 0; right: 0;
            background: white; border: 1.5px solid #e2e8f0;
            border-top: none; border-radius: 0 0 8px 8px;
            box-shadow: 0 6px 16px rgba(0,0,0,0.1);
            z-index: 200; max-height: 200px; overflow-y: auto;
            display: none;
        }
        .ac-item {
            padding: 10px 14px; cursor: pointer; font-size: 14px;
            color: #1e293b; border-bottom: 1px solid #f8fafc;
            transition: background .1s;
        }
        .ac-item:hover { background: #f0f4ff; color: #1a73e8; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/navbar.jsp" %>

<div style="display:flex;">

    <aside class="sidebar">
        <h3 style="font-size:16px;font-weight:700;color:#1e293b;margin-bottom:20px;">
            🔍 Filter Properties
        </h3>

        <form id="searchForm" method="GET" action="/search">
            <div class="filter-group" style="position:relative;">
                <label class="filter-label">Keyword</label>
                <input type="text" name="keyword" id="keywordInput" class="filter-input"
                       value="${criteria.keyword}" placeholder="Title, description..."
                       autocomplete="off">
                <div id="autocompleteDropdown"></div>
            </div>

            <div class="filter-group">
                <label class="filter-label">Category</label>
                <div class="radio-tab-group">
                    <label class="radio-tab-label">
                        <input type="radio" name="category" value=""
                               <c:if test="${empty criteria.category}">checked</c:if>
                               onchange="this.form.submit()">
                        <span>All</span>
                    </label>
                    <label class="radio-tab-label">
                        <input type="radio" name="category" value="BUY"
                               <c:if test="${criteria.category == 'BUY'}">checked</c:if>
                               onchange="this.form.submit()">
                        <span>Buy</span>
                    </label>
                    <label class="radio-tab-label">
                        <input type="radio" name="category" value="RENT"
                               <c:if test="${criteria.category == 'RENT'}">checked</c:if>
                               onchange="this.form.submit()">
                        <span>Rent</span>
                    </label>
                </div>
            </div>

            <div class="filter-group">
                <label class="filter-label">City</label>
                <select name="city" class="filter-input" onchange="this.form.submit()">
                    <option value="">All Cities</option>
                    <c:forEach var="c" items="${cities}">
                        <option value="${c}" <c:if test="${c == criteria.city}">selected</c:if>>${c}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="filter-group">
                <label class="filter-label">Property Type</label>
                <label class="type-radio-item">
                    <input type="radio" name="type" value=""
                           <c:if test="${empty criteria.type}">checked</c:if>
                           onchange="this.form.submit()">
                    All Types
                </label>
                <c:forEach var="pt" items="${propertyTypes}">
                    <label class="type-radio-item">
                        <input type="radio" name="type" value="${pt}"
                               <c:if test="${pt.name() == criteria.type}">checked</c:if>
                               onchange="this.form.submit()">
                        ${pt}
                    </label>
                </c:forEach>
            </div>

            <div class="filter-group">
                <label class="filter-label">Price Range (₹)</label>
                <div class="price-row">
                    <input type="number" name="minPrice" class="filter-input"
                           value="${criteria.minPrice}" placeholder="Min" min="0">
                    <input type="number" name="maxPrice" class="filter-input"
                           value="${criteria.maxPrice}" placeholder="Max" min="0">
                </div>
            </div>

            <div class="filter-group">
                <label class="filter-label">Bedrooms (Min)</label>
                <div class="bhk-chips">
                    <c:forEach var="bhk" items="${[1,2,3,4,5]}">
                        <label class="bhk-label">
                            <input type="radio" name="bedrooms" value="${bhk}"
                                   <c:if test="${bhk == criteria.bedrooms}">checked</c:if>
                                   onchange="this.form.submit()">
                            <span class="bhk-chip">${bhk}+</span>
                        </label>
                    </c:forEach>
                </div>
            </div>

            <div class="filter-group">
                <label class="filter-label">Furnishing</label>
                <select name="furnishing" class="filter-input" onchange="this.form.submit()">
                    <option value="">Any</option>
                    <c:forEach var="ft" items="${furnishingTypes}">
                        <option value="${ft}"
                                <c:if test="${ft.name() == criteria.furnishing}">selected</c:if>>${ft}</option>
                    </c:forEach>
                </select>
            </div>

            <button type="submit" class="btn-apply">🔍 Apply Filters</button>
            <a href="/search" class="btn-reset">Reset All</a>
        </form>
    </aside>

    <main class="main">
        <c:if test="${not empty activeFilters}">
            <div class="chip-row">
                <c:forEach var="label" items="${activeFilters}">
                    <span class="chip">${label}</span>
                </c:forEach>
                <a href="/search" class="chip-clear">Clear All ×</a>
            </div>
        </c:if>

        <c:if test="${result != null}">
            <div class="results-meta">
                Found <strong>${result.totalCount}</strong> propert<c:choose>
                    <c:when test="${result.totalCount == 1}">y</c:when>
                    <c:otherwise>ies</c:otherwise>
                </c:choose>
                <span class="results-time">in ${result.searchTimeMs}ms</span>
            </div>

            <c:if test="${not empty result.properties and isLoggedIn}">
                <div style="margin-bottom:14px;">
                    <button onclick="showSaveSearchModal()"
                            style="padding:8px 16px;background:#f0f4ff;color:#1a73e8;
                                   border:1.5px solid #1a73e8;border-radius:6px;
                                   font-size:13px;font-weight:600;cursor:pointer;">
                        🔖 Save This Search
                    </button>
                </div>
                
                <div id="saveSearchModal"
                     style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);
                            z-index:500;align-items:center;justify-content:center;">
                    <div style="background:white;border-radius:12px;padding:28px;
                                width:360px;box-shadow:0 8px 40px rgba(0,0,0,0.2);">
                        <h3 style="margin:0 0 16px;color:#1e293b;">🔖 Save Search</h3>
                        <p style="font-size:13px;color:#64748b;margin:0 0 14px;">
                            Give this search a name to find it easily later.
                        </p>
                        <input type="text" id="savedSearchName"
                               placeholder="e.g. 2BHK Apartments in Mumbai"
                               maxlength="100"
                               style="width:100%;padding:10px 12px;border:1px solid #d1d5db;
                                      border-radius:6px;font-size:14px;
                                      margin-bottom:16px;box-sizing:border-box;"/>
                        <div style="display:flex;gap:8px;justify-content:flex-end;">
                            <button type="button" onclick="closeSaveModal()"
                                    style="padding:9px 18px;background:#f1f5f9;color:#374151;
                                           border:none;border-radius:6px;font-size:13px;cursor:pointer;">
                                Cancel
                            </button>
                            <button type="button" onclick="confirmSaveSearch()"
                                    style="padding:9px 18px;background:#1a73e8;color:white;
                                           border:none;border-radius:6px;font-size:13px;
                                           font-weight:600;cursor:pointer;">
                                Save
                            </button>
                        </div>
                    </div>
                </div>
            </c:if>
        </c:if>

        <c:if test="${result != null and not empty result.properties}">
            <div style="display:flex;border:1px solid #d1d5db;border-radius:6px;overflow:hidden;
                        width:fit-content;margin-bottom:16px;">
                <button onclick="switchView('list')" id="listViewBtn"
                    style="padding:8px 16px;background:#1a73e8;color:white;
                           border:none;cursor:pointer;font-size:13px;">
                    &#9776; List
                </button>
                <button onclick="switchView('map')" id="mapViewBtn"
                    style="padding:8px 16px;background:white;color:#374151;
                           border:none;border-left:1px solid #d1d5db;
                           cursor:pointer;font-size:13px;">
                    &#128506; Map
                </button>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${result == null}">
                <div class="empty-state">
                    <div class="icon">🔍</div>
                    <h3>Start Your Search</h3>
                    <p>Use the filters on the left to find your perfect property.</p>
                </div>
            </c:when>
            <c:when test="${empty result.properties}">
                <div class="empty-state">
                    <div class="icon">🏠</div>
                    <h3>No Properties Found</h3>
                    <p>Try adjusting your filters or use different keywords.</p>
                    <a href="/search" class="btn-reset" style="display:inline-block;width:auto;">Clear All Filters</a>
                </div>
            </c:when>
            <c:otherwise>
                <div id="listGrid" class="cards-grid">
                    <c:forEach var="p" items="${result.properties}">
                        <c:set var="p" value="${p}" scope="request" />
                        <jsp:include page="/WEB-INF/views/common/property-card.jsp" />
                    </c:forEach>
                </div>

                <div id="searchMapContainer"
                     style="display:none;height:480px;border-radius:10px;
                            overflow:hidden;margin-bottom:20px;">
                    <div id="searchMap" style="width:100%;height:100%;"></div>
                </div>
            </c:otherwise>
        </c:choose>

        <c:if test="${result != null and result.totalPages > 1}">
            <nav class="pagination" aria-label="Search results pages">
                <c:if test="${result.currentPage > 0}">
                    <a href="/search?page=${result.currentPage - 1}${criteria.toQueryString()}"
                       class="page-link">← Prev</a>
                </c:if>

                <c:forEach begin="0" end="${result.totalPages - 1}" var="pg">
                    <c:choose>
                        <c:when test="${pg == result.currentPage}">
                            <span class="page-link active">${pg + 1}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="/search?page=${pg}${criteria.toQueryString()}"
                               class="page-link">${pg + 1}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:if test="${result.currentPage < result.totalPages - 1}">
                    <a href="/search?page=${result.currentPage + 1}${criteria.toQueryString()}"
                       class="page-link">Next →</a>
                </c:if>
            </nav>
        </c:if>
    </main>
</div>

<div id="searchToast" style="display:none;position:fixed;bottom:28px;left:50%;transform:translateX(-50%);
    padding:13px 26px;border-radius:8px;color:white;font-size:14px;font-weight:600;
    z-index:9999;box-shadow:0 4px 16px rgba(0,0,0,0.2);min-width:220px;text-align:center;"></div>

<script>
    var keywordInput = document.getElementById('keywordInput');
    var dropdown     = document.getElementById('autocompleteDropdown');
    var acTimer;

    if (keywordInput && dropdown) {
        keywordInput.addEventListener('input', function () {
            clearTimeout(acTimer);
            var q = this.value.trim();
            if (q.length < 2) { dropdown.style.display = 'none'; return; }

            acTimer = setTimeout(function() {
                fetch('/search/autocomplete?q=' + encodeURIComponent(q))
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        var items = data.data || [];
                        if (!items.length) { dropdown.style.display = 'none'; return; }
                        var html = '';
                        for (var i = 0; i < items.length; i++) {
                            var s = items[i];
                            var escaped = s.replace(/'/g, "\\'");
                            html += '<div class="ac-item" onclick="selectSuggestion(\'' + escaped + '\')">' + s + '</div>';
                        }
                        dropdown.innerHTML = html;
                        dropdown.style.display = 'block';
                    })
                    .catch(function() { dropdown.style.display = 'none'; });
            }, 250);
        });
    }

    function selectSuggestion(value) {
        if (keywordInput) {
            keywordInput.value = value;
            dropdown.style.display = 'none';
            document.getElementById('searchForm').submit();
        }
    }

    document.addEventListener('click', function(e) {
        if (keywordInput && dropdown && !keywordInput.contains(e.target) && !dropdown.contains(e.target)) {
            dropdown.style.display = 'none';
        }
    });

    if (keywordInput) {
        keywordInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                dropdown.style.display = 'none';
                document.getElementById('searchForm').submit();
            }
        });
    }

    function showToast(message, type) {
        var t = document.getElementById('searchToast');
        if (t) {
            t.textContent = message;
            t.style.background = (type === 'success') ? '#16a34a' : '#dc2626';
            t.style.display = 'block';
            clearTimeout(t._timer);
            t._timer = setTimeout(function() { t.style.display = 'none'; }, 3500);
        }
    }

    function showSaveSearchModal() {
        var modal = document.getElementById('saveSearchModal');
        if (modal) {
            modal.style.display = 'flex';
            var nameInput = document.getElementById('savedSearchName');
            if (nameInput) nameInput.focus();
        }
    }
    
    function closeSaveModal() {
        var modal = document.getElementById('saveSearchModal');
        if (modal) modal.style.display = 'none';
    }
    
    function confirmSaveSearch() {
        var nameInput = document.getElementById('savedSearchName');
        if (!nameInput) return;
        var name = nameInput.value.trim();
        if(!name) {
            nameInput.style.borderColor = '#ef4444';
            return;
        }
        
        var params = new URLSearchParams(window.location.search);
        params.append('name', name);
        
        fetch('/user/saved-searches', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-CSRF-TOKEN': document.querySelector('meta[name="_csrf"]').getAttribute('content')
            },
            body: params.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            closeSaveModal();
            showToast(data.message, 'success');
        })
        .catch(function(err) {
            showToast('Failed to save search', 'error');
        });
    }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
var mapResults = [
  <c:forEach var="vm" items="${mapViewModels}" varStatus="vs">
    {
      id: ${vm.property.id},
      title: '${fn:escapeXml(vm.property.title)}',
      price: ${vm.property.price},
      lat: ${vm.effectiveLat},
      lng: ${vm.effectiveLng}
    }${vs.last ? '' : ','}
  </c:forEach>
];

var searchMap, mapInitialized = false;

function switchView(view) {
  var grid = document.getElementById('listGrid');
  var mapDiv = document.getElementById('searchMapContainer');
  var listBtn = document.getElementById('listViewBtn');
  var mapBtn = document.getElementById('mapViewBtn');
  if (view === 'map') {
    if (grid) grid.style.display = 'none';
    if (mapDiv) mapDiv.style.display = 'block';
    if (listBtn) { listBtn.style.background = 'white'; listBtn.style.color = '#374151'; }
    if (mapBtn) { mapBtn.style.background = '#1a73e8'; mapBtn.style.color = 'white'; }
    if (!mapInitialized) initSearchMap(); else if (searchMap) searchMap.invalidateSize();
  } else {
    if (grid) grid.style.display = 'grid';
    if (mapDiv) mapDiv.style.display = 'none';
    if (listBtn) { listBtn.style.background = '#1a73e8'; listBtn.style.color = 'white'; }
    if (mapBtn) { mapBtn.style.background = 'white'; mapBtn.style.color = '#374151'; }
  }
}

function initSearchMap() {
  if (!mapResults.length) return;
  var mapEl = document.getElementById('searchMap');
  if (!mapEl) return;
  searchMap = L.map('searchMap', { scrollWheelZoom: false });
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
    maxZoom: 19
  }).addTo(searchMap);
  var bounds = [];
  mapResults.forEach(function(p) {
    var pos = [p.lat, p.lng];
    bounds.push(pos);
    var label = p.price >= 10000000
      ? '₹' + (p.price/10000000).toFixed(1) + 'Cr'
      : '₹' + (p.price/100000).toFixed(0) + 'L';
    var priceIcon = L.divIcon({
      className: '',
      html: '<div style="background:#1A73E8;color:white;padding:4px 8px;border-radius:4px;font-size:11px;font-weight:700;white-space:nowrap;box-shadow:0 2px 6px rgba(0,0,0,0.2);">' + label + '</div>',
      iconAnchor: [20, 10],
      popupAnchor: [0, -14]
    });
    L.marker(pos, { icon: priceIcon }).addTo(searchMap).bindPopup(
      '<div style="min-width:170px;padding:4px;"><b style="font-size:13px;">' + p.title + '</b><br>' +
      '<span style="color:#1a73e8;font-weight:700;">' + label + '</span><br>' +
      '<a href="/properties/' + p.id + '" style="color:#1a73e8;font-size:12px;">View Details →</a></div>'
    );
  });
  if (bounds.length) searchMap.fitBounds(bounds, { padding: [30, 30] });
  mapInitialized = true;
}
</script>
</body>
</html>
