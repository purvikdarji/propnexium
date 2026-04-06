<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agent Performance – Admin | PropNexium</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/admin-shared.css">
    <style>
        .perf-table th {
            padding: 14px 16px;
            text-align: left;
            font-size: 12px;
            color: #64748b;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .04em;
            border-bottom: 1px solid #e5e7eb;
            background: #f8fafc;
            white-space: nowrap;
        }
        .perf-table td { padding: 14px 16px; }
        .perf-table tr:last-child td { border-bottom: none; }

        .stat-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
        }

        .view-btn {
            padding: 6px 14px;
            background: #e8f0fe;
            color: #1a73e8;
            text-decoration: none;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            transition: background .2s;
        }
        .view-btn:hover { background: #c7d7f9; }

        /* Summary stat cards at top */
        .summary-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .sum-card {
            background: white;
            border-radius: 10px;
            padding: 18px 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,.06);
        }
        .sum-card .label { font-size: 12px; color: #64748b; margin-bottom: 6px; }
        .sum-card .value { font-size: 24px; font-weight: 800; color: #1e293b; }
    </style>
</head>
<body>
<div class="admin-wrap">
    <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>
    <div class="main">
        <div class="topbar">
            <h1>👥 Agent Performance</h1>
            <div style="font-size:14px;color:#64748b;">${agents.size()} agents tracked</div>
        </div>
        <div class="content">

            <!-- Performance Table -->
            <div style="background:white;border-radius:12px;overflow:hidden;
                        box-shadow:0 2px 12px rgba(0,0,0,.06);">
                <table class="perf-table" style="width:100%;border-collapse:collapse;">
                    <thead>
                        <tr>
                            <th>Agent</th>
                            <th style="text-align:center;">Listings</th>
                            <th style="text-align:center;">Total Views</th>
                            <th style="text-align:center;">Inquiries</th>
                            <th style="text-align:center;">Avg Views/Listing</th>
                            <th style="min-width:180px;">Response Rate</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty agents}">
                                <tr>
                                    <td colspan="7"
                                        style="text-align:center;padding:48px;color:#94a3b8;font-size:14px;">
                                        No agents found.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="a" items="${agents}" varStatus="vs">
                                <tr style="border-bottom:1px solid #f1f5f9;
                                           background:${vs.index % 2 == 0 ? 'white' : '#fafafa'};">
                                    <td>
                                        <div style="font-size:14px;font-weight:600;color:#1e293b;">
                                            ${a.agentName}
                                        </div>
                                        <div style="font-size:12px;color:#94a3b8;margin-top:2px;">
                                            ${a.email}
                                        </div>
                                    </td>
                                    <td style="text-align:center;font-weight:700;color:#1a73e8;font-size:16px;">
                                        ${a.totalListings}
                                    </td>
                                    <td style="text-align:center;font-size:14px;color:#475569;">
                                        ${a.totalViews}
                                    </td>
                                    <td style="text-align:center;font-size:14px;color:#475569;">
                                        ${a.totalInquiries}
                                    </td>
                                    <td style="text-align:center;font-size:14px;color:#475569;">
                                        <fmt:formatNumber value="${a.avgViewsPerListing}" maxFractionDigits="1"/>
                                    </td>
                                    <td style="min-width:180px;">
                                        <div style="display:flex;align-items:center;gap:8px;">
                                            <div style="flex:1;background:#e5e7eb;border-radius:10px;
                                                        height:8px;overflow:hidden;">
                                                <div class="perfBar"
                                                     data-width="${a.responseRate}"
                                                     style="height:100%;border-radius:10px;width:0%;
                                                            transition:width 1s ease;
                                                            background:${a.responseRate >= 70 ? '#22c55e' :
                                                                         a.responseRate >= 40 ? '#f59e0b' : '#ef4444'};">
                                                </div>
                                            </div>
                                            <span style="font-size:12px;font-weight:700;white-space:nowrap;
                                                         color:${a.responseRate >= 70 ? '#16a34a' :
                                                                  a.responseRate >= 40 ? '#d97706' : '#dc2626'};">
                                                <fmt:formatNumber value="${a.responseRate}" maxFractionDigits="0"/>%
                                            </span>
                                        </div>
                                    </td>
                                    <td>
                                        <a href="/admin/performance/${a.agentId}" class="view-btn">
                                            View Detail
                                        </a>
                                    </td>
                                </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

        </div><!-- /content -->
    </div><!-- /main -->
</div><!-- /admin-wrap -->

<!-- ── Trending Search Analytics ──────────────────────────────────────────── -->
<div style="margin:0 24px 32px;background:white;border-radius:12px;padding:32px;
            box-shadow:0 4px 20px rgba(0,0,0,.04); display: flex; flex-wrap: wrap; gap: 40px;">
    
    <!-- Left Column: Trending Tags -->
    <div style="flex: 1; min-width: 300px;">
        <h3 style="margin:0 0 20px;color:#0f172a;font-size:16px;font-weight:700;display:flex;align-items:center;gap:8px;">
            <span style="font-size:18px;">🔥</span> Trending Searches (Last 30 Days)
        </h3>
        <c:choose>
            <c:when test="${empty trendingSearches}">
                <div style="padding:24px;background:#f8fafc;border-radius:8px;border:1px dashed #cbd5e1;text-align:center;">
                    <p style="color:#64748b;font-size:13px;margin:0;">No search data available yet.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="display:flex;flex-wrap:wrap;gap:10px;">
                    <c:forEach var="t" items="${trendingSearches}">
                        <div style="padding:8px 16px;border-radius:30px;font-size:13px;
                                     font-weight:600;background:#f1f5f9;color:#334155;
                                     white-space:nowrap;border:1px solid #e2e8f0;
                                     box-shadow:0 1px 2px rgba(0,0,0,0.02);
                                     transition:all 0.2s ease; cursor:default;"
                             onmouseover="this.style.background='#e8f0fe';this.style.borderColor='#bfdbfe';this.style.color='#1d4ed8';this.style.transform='translateY(-1px)';"
                             onmouseout="this.style.background='#f1f5f9';this.style.borderColor='#e2e8f0';this.style.color='#334155';this.style.transform='translateY(0)';">
                            ${t.city}<c:if test="${not empty t.type}"> <span style="color:#94a3b8;margin:0 4px;">&bull;</span> ${t.type}</c:if>
                            <span style="color:#94a3b8;margin:0 4px;">&bull;</span> <strong style="color:#1e293b;font-weight:800;">${t.searchCount}</strong>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Right Column: Distribution Chart -->
    <div style="width: 320px; background:#f8fafc; padding:24px; border-radius:12px; border:1px solid #f1f5f9;">
        <h3 style="margin:0 0 20px;color:#0f172a;font-size:15px;font-weight:700;text-align:center;">
            📊 Search Result Distribution
        </h3>
        <div style="position:relative; width:100%; height:220px; display:flex; justify-content:center;">
            <canvas id="resultDistChart"></canvas>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    // ── Animate performance bars ───────────────────────────────────────────
    document.querySelectorAll('.perfBar').forEach(function (bar) {
        var target = parseFloat(bar.getAttribute('data-width')) || 0;
        target = Math.min(100, Math.max(0, target));
        bar.style.width = '0%';
        setTimeout(function () { bar.style.width = target + '%'; }, 200);
    });
});
</script>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
(function() {
    try {
        var dist = ${resultDistributionJson};
        var canvas = document.getElementById('resultDistChart');
        if (!canvas) return;
        new Chart(canvas, {
            type: 'doughnut',
            data: {
                labels: ['No Results', '1–5', '6–20', '21–50', '50+'],
                datasets: [{
                    data: [
                        Number(dist.noResults)      || 0,
                        Number(dist.oneToFive)      || 0,
                        Number(dist.sixToTwenty)    || 0,
                        Number(dist.twentyToFifty)  || 0,
                        Number(dist.fiftyPlus)      || 0
                    ],
                    backgroundColor: [
                        '#ef4444','#f59e0b','#1a73e8','#22c55e','#8b5cf6'
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                plugins: {
                    legend: { position: 'right' }
                },
                cutout: '60%'
            }
        });
    } catch(e) {
        console.warn('Chart.js init failed:', e);
    }
}());
</script>
</body>
</html>

