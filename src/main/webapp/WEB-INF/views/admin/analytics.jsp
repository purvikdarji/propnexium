<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <title>Admin Dashboard - Analytics | PropNexium</title>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
                    <link rel="stylesheet" href="/css/admin-shared.css">
                    <style>
                        /* Page-specific styles for Analytics */
                        .main-content {
                            flex: 1;
                            padding: 24px;
                            overflow-y: auto;
                        }

                        .stat-card {
                            background: white;
                            border-radius: 12px;
                            padding: 24px;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
                        }

                        .stat-card h3 {
                            margin: 0 0 16px;
                            color: #1e293b;
                            font-size: 15px;
                        }
                    </style>
                    <!-- Chart.js CDN -->
                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
                </head>

                <body>

                    <div class="admin-wrap">
                        <!-- Sidebar -->
                        <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>

                        <div class="main">
                            <!-- Main Content -->
                            <div class="main-content">

                                <div style="max-width:1400px;margin:0 auto;">

                                    <h1 style="color:#1e293b;font-size:24px;margin:0 0 24px;">
                                        &#128202; Analytics Dashboard
                                    </h1>

                                    <!-- 3 KPI SUMMARY CARDS -->
                                    <div style="display:grid;grid-template-columns:repeat(3,1fr);
                        gap:16px;margin-bottom:28px;">

                                        <!-- Platform Value -->
                                        <div style="background:linear-gradient(135deg,#1a73e8,#42a5f5);
                          border-radius:12px;padding:24px;color:white;">
                                            <div style="font-size:13px;opacity:0.85;margin-bottom:8px;">
                                                &#128176; Total Platform Value
                                            </div>
                                            <div style="font-size:32px;font-weight:800;">
                                                &#8377;${platformValueCr} Cr
                                            </div>
                                            <div style="font-size:12px;opacity:0.7;margin-top:4px;">
                                                Combined value of all listed properties
                                            </div>
                                        </div>

                                        <!-- Inquiry Resolution -->
                                        <div style="background:linear-gradient(135deg,#22c55e,#4ade80);
                          border-radius:12px;padding:24px;color:white;">
                                            <div style="font-size:13px;opacity:0.85;margin-bottom:8px;">
                                                &#9989; Inquiry Resolution Rate
                                            </div>
                                            <div style="font-size:32px;font-weight:800;">
                                                ${resolutionPercent}%
                                            </div>
                                            <div style="font-size:12px;opacity:0.7;margin-top:4px;">
                                                Inquiries replied or closed
                                            </div>
                                        </div>

                                        <!-- Most Searched City -->
                                        <div style="background:linear-gradient(135deg,#f59e0b,#fcd34d);
                          border-radius:12px;padding:24px;color:white;">
                                            <div style="font-size:13px;opacity:0.85;margin-bottom:8px;">
                                                &#128269; Most Searched City (30 days)
                                            </div>
                                            <div style="font-size:32px;font-weight:800;">${mostSearchedCity}</div>
                                            <div style="font-size:12px;opacity:0.7;margin-top:4px;">
                                                Highest search volume this month
                                            </div>
                                        </div>
                                    </div>

                                    <!-- ROW 1: Monthly Listings + Monthly Users (line charts) -->
                                    <div
                                        style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px;">
                                        <div class="stat-card">
                                            <h3>&#128200; Monthly Property Listings (12 Months)</h3>
                                            <div style="position: relative; height: 260px; width: 100%;">
                                                <canvas id="monthlyListingsChart"></canvas>
                                            </div>
                                        </div>

                                        <div class="stat-card">
                                            <h3>&#128101; Monthly User Registrations (12 Months)</h3>
                                            <div style="position: relative; height: 260px; width: 100%;">
                                                <canvas id="monthlyUsersChart"></canvas>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- ROW 2: Type bar + Category doughnut + Inquiry doughnut -->
                                    <div
                                        style="display:grid;grid-template-columns:2fr 1fr 1fr;gap:20px;margin-bottom:20px;">
                                        <div class="stat-card">
                                            <h3>&#127968; Properties by Type</h3>
                                            <div style="position: relative; height: 240px; width: 100%;">
                                                <canvas id="typeBarChart"></canvas>
                                            </div>
                                        </div>

                                        <div class="stat-card">
                                            <h3>&#128260; Buy vs Rent</h3>
                                            <div style="position: relative; height: 240px; width: 100%;">
                                                <canvas id="categoryDoughnut"></canvas>
                                            </div>
                                        </div>

                                        <div class="stat-card">
                                            <h3>&#128233; Inquiry Status</h3>
                                            <div style="position: relative; height: 240px; width: 100%;">
                                                <canvas id="inquiryDoughnut"></canvas>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- ROW 3: Search Cities horizontal bar chart -->
                                    <div class="stat-card" style="margin-bottom:20px;">
                                        <h3>&#127961;&#65039; Most Searched Cities (Last 30 Days)</h3>
                                        <div style="position: relative; height: 260px; width: 100%;">
                                            <canvas id="searchCitiesChart"></canvas>
                                        </div>
                                    </div>

                                    <!-- ROW 4: Top 5 Agents + Most Viewed Properties -->
                                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">

                                        <!-- Top 5 Agents table -->
                                        <div class="stat-card">
                                            <h3>&#127942; Top 5 Agents</h3>
                                            <table style="width:100%;border-collapse:collapse;">
                                                <c:forEach var="agent" items="${topAgents}" varStatus="vs">
                                                    <tr style="border-bottom:1px solid #f1f5f9;">
                                                        <td style="padding:12px 8px;width:36px;">
                                                            <div style="width:28px;height:28px;border-radius:50%;
                          background:${vs.index == 0 ? '#FCD34D' :
                                      vs.index == 1 ? '#CBD5E1' :
                                      vs.index == 2 ? '#FDBA74' : '#E2E8F0'};
                          display:flex;align-items:center;justify-content:center;
                          font-size:12px;font-weight:700;color:#374151;">
                                                                ${vs.index + 1}
                                                            </div>
                                                        </td>
                                                        <td style="padding:12px 8px;">
                                                            <div style="font-size:13px;font-weight:600;color:#1e293b;">
                                                                ${agent.first_name} ${agent.last_name}
                                                            </div>
                                                            <div style="font-size:11px;color:#94a3b8;">${agent.email}
                                                            </div>
                                                        </td>
                                                        <td style="padding:12px 8px;text-align:right;">
                                                            <div style="font-size:13px;font-weight:700;color:#1a73e8;">
                                                                ${agent.listingCount} listings
                                                            </div>
                                                            <div style="font-size:11px;color:#94a3b8;">
                                                                ${agent.totalViews} views
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </table>
                                        </div>

                                        <!-- Most Viewed Properties -->
                                        <div class="stat-card">
                                            <h3>&#128065; Most Viewed Properties</h3>
                                            <c:forEach var="p" items="${mostViewed}" varStatus="vs">
                                                <div style="display:flex;align-items:center;gap:12px;
                              padding:10px 0;border-bottom:1px solid #f1f5f9;">
                                                    <span style="font-size:20px;width:28px;">
                                                        ${vs.index == 0 ? '&#129351;' : vs.index == 1 ? '&#129352;' :
                                                        vs.index == 2 ? '&#129353;' : vs.index + 1}
                                                    </span>
                                                    <div style="flex:1;min-width:0;">
                                                        <div style="font-size:13px;font-weight:600;color:#1e293b;
                                  overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                            <a href="/properties/${p.id}"
                                                                style="color:inherit;text-decoration:none;">${p.title}</a>
                                                        </div>
                                                        <div style="font-size:11px;color:#94a3b8;">${p.city}</div>
                                                    </div>
                                                    <div style="text-align:right;flex-shrink:0;">
                                                        <div style="font-size:13px;font-weight:700;color:#1a73e8;">
                                                            ${p.view_count} views
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Chart.js initialization scripts -->
                    <script>
                        const monthlyListingsData = ${ monthlyListingsJson };
                        const monthlyUsersData = ${ monthlyUsersJson };
                        const typeData = ${ typeDistributionJson };
                        const categoryData = ${ categoryDistributionJson };
                        const inquiryData = ${ inquiryStatusJson };
                        const citiesData = ${ searchCitiesJson };

                        const COLORS = ['#1A73E8', '#22C55E', '#F59E0B', '#EF4444',
                            '#8B5CF6', '#EC4899', '#14B8A6', '#F97316'];

                        // 1. Monthly listings line chart
                        new Chart(document.getElementById('monthlyListingsChart'), {
                            type: 'line',
                            data: {
                                labels: monthlyListingsData.map(d => d.month),
                                datasets: [{
                                    label: 'Listings',
                                    data: monthlyListingsData.map(d => d.count),
                                    borderColor: '#1A73E8',
                                    backgroundColor: 'rgba(26,115,232,0.08)',
                                    tension: 0.4, fill: true, pointRadius: 4
                                }]
                            },
                            options: {
                                maintainAspectRatio: false, plugins: { legend: { display: false } },
                                scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
                            }
                        });

                        // 2. Monthly users line chart
                        new Chart(document.getElementById('monthlyUsersChart'), {
                            type: 'line',
                            data: {
                                labels: monthlyUsersData.map(d => d.month),
                                datasets: [{
                                    label: 'Registrations',
                                    data: monthlyUsersData.map(d => d.count),
                                    borderColor: '#22C55E',
                                    backgroundColor: 'rgba(34,197,94,0.08)',
                                    tension: 0.4, fill: true, pointRadius: 4
                                }]
                            },
                            options: {
                                maintainAspectRatio: false, plugins: { legend: { display: false } },
                                scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
                            }
                        });

                        // 3. Property type vertical bar chart
                        new Chart(document.getElementById('typeBarChart'), {
                            type: 'bar',
                            data: {
                                labels: typeData.map(d => d.type),
                                datasets: [{
                                    label: 'Properties',
                                    data: typeData.map(d => d.count),
                                    backgroundColor: COLORS
                                }]
                            },
                            options: {
                                maintainAspectRatio: false, plugins: { legend: { display: false } },
                                scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
                            }
                        });

                        // 4. Buy vs Rent doughnut
                        new Chart(document.getElementById('categoryDoughnut'), {
                            type: 'doughnut',
                            data: {
                                labels: categoryData.map(d => d.category),
                                datasets: [{
                                    data: categoryData.map(d => d.count),
                                    backgroundColor: ['#1A73E8', '#22C55E']
                                }]
                            },
                            options: { maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } }, cutout: '65%' }
                        });

                        // 5. Inquiry status doughnut
                        new Chart(document.getElementById('inquiryDoughnut'), {
                            type: 'doughnut',
                            data: {
                                labels: inquiryData.map(d => d.status),
                                datasets: [{
                                    data: inquiryData.map(d => d.count),
                                    backgroundColor: ['#F59E0B', '#1A73E8', '#22C55E']
                                }]
                            },
                            options: { maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } }, cutout: '65%' }
                        });

                        // 6. Search cities horizontal bar chart
                        new Chart(document.getElementById('searchCitiesChart'), {
                            type: 'bar',
                            data: {
                                labels: citiesData.map(d => d.city),
                                datasets: [{
                                    label: 'Searches',
                                    data: citiesData.map(d => d.searchCount),
                                    backgroundColor: '#1A73E8'
                                }]
                            },
                            options: {
                                maintainAspectRatio: false,
                                indexAxis: 'y',
                                plugins: { legend: { display: false } },
                                scales: { x: { beginAtZero: true, ticks: { precision: 0 } } }
                            }
                        });
                    </script>
                </body>

                </html>