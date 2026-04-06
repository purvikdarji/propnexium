<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${agent.agentName} – Performance | PropNexium Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/admin-shared.css">
    <style>
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        @media (max-width: 900px) {
            .kpi-grid { grid-template-columns: repeat(2, 1fr); }
        }
        .kpi-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,.06);
        }
        .kpi-card .kpi-label {
            font-size: 12px;
            color: #64748b;
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: .04em;
        }
        .kpi-card .kpi-value {
            font-size: 28px;
            font-weight: 800;
            color: #1e293b;
        }

        .prop-table th {
            padding: 12px 14px;
            text-align: left;
            font-size: 12px;
            color: #64748b;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .04em;
            border-bottom: 1px solid #e5e7eb;
            background: #f8fafc;
        }
        .prop-table td { padding: 12px 14px; }
        .prop-table tr:last-child td { border-bottom: none; }
    </style>
</head>
<body>
<div class="admin-wrap">
    <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>
    <div class="main">
        <div class="topbar">
            <div>
                <a href="/admin/performance"
                   style="font-size:13px;color:#1a73e8;text-decoration:none;
                          display:inline-flex;align-items:center;gap:4px;margin-bottom:6px;">
                    ← Back to All Agents
                </a>
                <h1>📊 ${agent.agentName}</h1>
                <div style="font-size:14px;color:#64748b;">${agent.email}</div>
            </div>
        </div>
        <div class="content">

            <!-- ── 4 KPI Cards ───────────────────────────────────────────────── -->
            <div class="kpi-grid">
                <!-- Total Listings -->
                <div class="kpi-card" style="border-top:4px solid #1a73e8;">
                    <div class="kpi-label">Total Listings</div>
                    <div class="kpi-value">${agent.totalListings}</div>
                </div>
                <!-- Total Views -->
                <div class="kpi-card" style="border-top:4px solid #22c55e;">
                    <div class="kpi-label">Total Views</div>
                    <div class="kpi-value">${agent.totalViews}</div>
                </div>
                <!-- Response Rate -->
                <div class="kpi-card" style="border-top:4px solid #f59e0b;">
                    <div class="kpi-label">Response Rate</div>
                    <div class="kpi-value"
                         style="color:${agent.responseRate >= 70 ? '#16a34a' :
                                         agent.responseRate >= 40 ? '#d97706' : '#dc2626'};">
                        <fmt:formatNumber value="${agent.responseRate}" maxFractionDigits="0"/>%
                    </div>
                </div>
                <!-- Conversion Rate -->
                <div class="kpi-card" style="border-top:4px solid #8b5cf6;">
                    <div class="kpi-label">Inquiry Conversion</div>
                    <div class="kpi-value">
                        <fmt:formatNumber value="${agent.inquiryConversionRate}" maxFractionDigits="1"/>%
                    </div>
                </div>
            </div>

            <!-- ── Per-property view counts table ─────────────────────────────── -->
            <div style="background:white;border-radius:12px;padding:20px;
                        box-shadow:0 2px 12px rgba(0,0,0,.06);margin-bottom:24px;">
                <h3 style="margin:0 0 16px;color:#1e293b;font-size:16px;">
                    🏠 Property View Counts
                </h3>
                <c:choose>
                    <c:when test="${empty agentProperties}">
                        <p style="color:#94a3b8;text-align:center;padding:32px 0;">
                            This agent has no listings yet.
                        </p>
                    </c:when>
                    <c:otherwise>
                        <table class="prop-table" style="width:100%;border-collapse:collapse;">
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>City</th>
                                    <th>Type</th>
                                    <th style="text-align:center;">Views</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="p" items="${agentProperties}">
                                <tr style="border-bottom:1px solid #f1f5f9;">
                                    <td style="font-size:13px;color:#1e293b;">
                                        <a href="/properties/${p.id}"
                                           style="color:#1a73e8;text-decoration:none;font-weight:500;">
                                            ${p.title}
                                        </a>
                                    </td>
                                    <td style="color:#64748b;font-size:13px;">${p.city}</td>
                                    <td style="color:#64748b;font-size:13px;">${p.type}</td>
                                    <td style="text-align:center;font-weight:700;
                                               color:#1a73e8;font-size:14px;">
                                        ${p.viewCount}
                                    </td>
                                    <td>
                                        <span style="padding:3px 10px;border-radius:12px;
                                                     font-size:11px;font-weight:600;
                                                     background:${p.status.toString() == 'AVAILABLE' ? '#dcfce7' :
                                                                  p.status.toString() == 'SOLD'      ? '#fee2e2' :
                                                                  p.status.toString() == 'RENTED'    ? '#f3e8ff' : '#fef9c3'};
                                                     color:${p.status.toString() == 'AVAILABLE' ? '#16a34a' :
                                                             p.status.toString() == 'SOLD'      ? '#dc2626' :
                                                             p.status.toString() == 'RENTED'    ? '#7e22ce' : '#854d0e'};">
                                            ${p.status}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- ── Chart.js bar chart ─────────────────────────────────────────── -->
            <c:if test="${not empty agentProperties}">
            <div style="background:white;border-radius:12px;padding:24px;
                        box-shadow:0 2px 12px rgba(0,0,0,.06);">
                <h3 style="margin:0 0 16px;color:#1e293b;font-size:16px;">
                    📈 Listing Performance (Views per Property)
                </h3>
                <canvas id="agentPerfChart" height="120"></canvas>
            </div>
            </c:if>

        </div><!-- /content -->
    </div><!-- /main -->
</div><!-- /admin-wrap -->

<c:if test="${not empty agentProperties}">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
(function () {
    var labels = [
        <c:forEach var="p" items="${agentProperties}" varStatus="vs">
        '<c:out value="${fn:substring(p.title, 0, 22)}"/>'${vs.last ? '' : ','}
        </c:forEach>
    ];
    var data = [
        <c:forEach var="p" items="${agentProperties}" varStatus="vs">
        ${p.viewCount}${vs.last ? '' : ','}
        </c:forEach>
    ];

    new Chart(document.getElementById('agentPerfChart'), {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Views',
                data: data,
                backgroundColor: '#1A73E8',
                borderRadius: 4,
                hoverBackgroundColor: '#1557b0'
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        title: function(ctx) { return labels[ctx[0].dataIndex]; }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { precision: 0, color: '#64748b' },
                    grid: { color: '#f1f5f9' }
                },
                x: {
                    ticks: { color: '#64748b', maxRotation: 30 },
                    grid: { display: false }
                }
            }
        }
    });
}());
</script>
</c:if>
</body>
</html>
