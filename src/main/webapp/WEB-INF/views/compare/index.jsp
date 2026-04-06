<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Compare Properties | PropNexium</title>
                <style>
                    body {
                        font-family: 'Inter', sans-serif;
                        margin: 0;
                        background: #f8fafc;
                        color: #333;
                    }

                    .page-wrap {
                        min-height: calc(100vh - 80px);
                        padding-bottom: 60px;
                    }

                    .compareRow {
                        border-bottom: 1px solid #f1f5f9;
                    }

                    .compareRowAlt .compareLabel,
                    .compareRowAlt .compareValue {
                        background: #f8fafc;
                    }

                    .compareLabel {
                        padding: 14px 20px;
                        font-size: 13px;
                        font-weight: 600;
                        color: #64748b;
                        background: #f8fafc;
                        border-right: 1px solid #e5e7eb;
                    }

                    .compareValue {
                        padding: 14px 20px;
                        font-size: 14px;
                        color: #1e293b;
                        text-align: center;
                        border-right: 1px solid #e5e7eb;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }
                </style>
            </head>

            <body>

                <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                    <div class="page-wrap">
                        <div style="max-width:1200px;margin:40px auto;padding:0 20px;">

                            <h1 style="color:#1e293b;font-size:24px;margin:0 0 24px;">
                                &#9878; Property Comparison
                            </h1>

                            <!-- COMPARISON TABLE using CSS Grid -->
                            <div style="background:white;border-radius:12px;overflow:hidden;
                    box-shadow:0 2px 16px rgba(0,0,0,0.08);">

                                <!-- HEADER ROW: Property images, titles, prices -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);
                      border-bottom:2px solid #e5e7eb;">

                                    <!-- Empty label cell -->
                                    <div style="background:#f8fafc;padding:20px;
                        border-right:1px solid #e5e7eb;"></div>

                                    <!-- Property header cells -->
                                    <c:forEach var="p" items="${properties}">
                                        <div style="padding:20px;text-align:center;
                          border-right:1px solid #e5e7eb;">
                                            <!-- Primary image thumbnail -->
                                            <c:choose>
                                                <c:when test="${not empty p.images}">
                                                    <img src="${p.images[0].imageUrl}" style="width:100%;height:120px;object-fit:cover;
                                border-radius:8px;margin-bottom:12px;" alt="${p.title}" />
                                                </c:when>
                                                <c:otherwise>
                                                    <div
                                                        style="width:100%;height:120px;background:#e2e8f0;border-radius:8px;margin-bottom:12px;display:flex;align-items:center;justify-content:center;font-size:30px">
                                                        🏢</div>
                                                </c:otherwise>
                                            </c:choose>

                                            <!-- Title -->
                                            <h3 style="margin:0 0 8px;font-size:14px;color:#1e293b;
                           line-height:1.3;">
                                                <a href="/properties/${p.id}"
                                                    style="color:#1a73e8;text-decoration:none;">
                                                    ${p.title}
                                                </a>
                                            </h3>

                                            <!-- Price with BEST badge if lowest -->
                                            <div style="font-size:20px;font-weight:800;
                  color:${p.price.compareTo(minPrice) == 0 ? '#22c55e' : '#1e293b'};">
                                                &#8377;
                                                <fmt:formatNumber value="${p.price}" groupingUsed="true" />
                                                <c:if test="${p.price.compareTo(minPrice) == 0}">
                                                    <span style="display:inline-block;background:#dcfce7;
                                 color:#16a34a;font-size:10px;font-weight:700;
                                 padding:2px 8px;border-radius:10px;
                                 vertical-align:middle;margin-left:4px;">
                                                        BEST
                                                    </span>
                                                </c:if>
                                            </div>

                                            <!-- City -->
                                            <p style="margin:6px 0 0;font-size:12px;color:#94a3b8;">
                                                &#128205; ${p.city}
                                            </p>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- COMPARISON ROWS -->

                                <!-- Row: Property Type -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);" class="compareRow">
                                    <div class="compareLabel">Property Type</div>
                                    <c:forEach var="p" items="${properties}">
                                        <div class="compareValue">${p.type}</div>
                                    </c:forEach>
                                </div>

                                <!-- Row: Category -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);" class="compareRow compareRowAlt">
                                    <div class="compareLabel">Category</div>
                                    <c:forEach var="p" items="${properties}">
                                        <div class="compareValue">${p.category}</div>
                                    </c:forEach>
                                </div>

                                <!-- Row: Bedrooms (🏆 on max) -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);" class="compareRow">
                                    <div class="compareLabel">&#128719; Bedrooms</div>
                                    <c:forEach var="p" items="${properties}">
                                        <c:set var="isMaxBed" value="${p.bedrooms == maxBedrooms}" />
                                        <div class="compareValue" style="background:${isMaxBed ? '#f0fdf4' : 'inherit'};
                                color:${isMaxBed ? '#16a34a' : '#1e293b'};
                                font-weight:${isMaxBed ? '700' : 'normal'};">
                                            ${p.bedrooms}
                                            <c:if test="${isMaxBed}"> <span style="margin-left:5px">🏆</span></c:if>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- Row: Bathrooms -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);" class="compareRow compareRowAlt">
                                    <div class="compareLabel">&#128703; Bathrooms</div>
                                    <c:forEach var="p" items="${properties}">
                                        <div class="compareValue">${p.bathrooms}</div>
                                    </c:forEach>
                                </div>

                                <!-- Row: Area (🏆 on max) -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);" class="compareRow">
                                    <div class="compareLabel">&#128208; Area (sq ft)</div>
                                    <c:forEach var="p" items="${properties}">
                                        <c:set var="isMaxArea"
                                            value="${p.areaSqft != null && p.areaSqft.compareTo(maxArea) == 0}" />
                                        <div class="compareValue" style="background:${isMaxArea ? '#f0fdf4' : 'inherit'};
                                color:${isMaxArea ? '#16a34a' : '#1e293b'};
                                font-weight:${isMaxArea ? '700' : 'normal'};">
                                            <fmt:formatNumber value="${p.areaSqft}" groupingUsed="true" />
                                            <c:if test="${isMaxArea}"> <span style="margin-left:5px">🏆</span></c:if>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- Row: Furnishing -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);" class="compareRow compareRowAlt">
                                    <div class="compareLabel">&#129185; Furnishing</div>
                                    <c:forEach var="p" items="${properties}">
                                        <div class="compareValue">${p.furnishing}</div>
                                    </c:forEach>
                                </div>

                                <!-- Row: Parking -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);" class="compareRow">
                                    <div class="compareLabel">&#128663; Parking</div>
                                    <c:forEach var="p" items="${properties}">
                                        <div class="compareValue">${p.parking}</div>
                                    </c:forEach>
                                </div>

                                <!-- Row: Status -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);" class="compareRow compareRowAlt">
                                    <div class="compareLabel">&#128203; Status</div>
                                    <c:forEach var="p" items="${properties}">
                                        <div class="compareValue">
                                            ${p.status}
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- Row: Amenities -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);" class="compareRow">
                                    <div class="compareLabel">&#10024; Amenities</div>
                                    <c:forEach var="p" items="${properties}">
                                        <div class="compareValue" style="font-size:12px;line-height:1.8;flex-wrap:wrap">
                                            <c:if test="${p.amenities != null}">
                                                <c:if test="${p.amenities.hasGym}"><span
                                                        style="display:inline-block;background:#e8f0fe;color:#1a73e8;padding:2px 8px;border-radius:10px;margin:2px;font-size:11px;">Gym</span>
                                                </c:if>
                                                <c:if test="${p.amenities.hasSwimmingPool}"><span
                                                        style="display:inline-block;background:#e8f0fe;color:#1a73e8;padding:2px 8px;border-radius:10px;margin:2px;font-size:11px;">Swimming
                                                        Pool</span></c:if>
                                                <c:if test="${p.amenities.hasSecurity}"><span
                                                        style="display:inline-block;background:#e8f0fe;color:#1a73e8;padding:2px 8px;border-radius:10px;margin:2px;font-size:11px;">Security</span>
                                                </c:if>
                                                <c:if test="${p.amenities.hasPowerBackup}"><span
                                                        style="display:inline-block;background:#e8f0fe;color:#1a73e8;padding:2px 8px;border-radius:10px;margin:2px;font-size:11px;">Power
                                                        Backup</span></c:if>
                                                <c:if test="${p.amenities.hasClubhouse}"><span
                                                        style="display:inline-block;background:#e8f0fe;color:#1a73e8;padding:2px 8px;border-radius:10px;margin:2px;font-size:11px;">Clubhouse</span>
                                                </c:if>
                                                <c:if test="${p.amenities.hasElevator}"><span
                                                        style="display:inline-block;background:#e8f0fe;color:#1a73e8;padding:2px 8px;border-radius:10px;margin:2px;font-size:11px;">Elevator</span>
                                                </c:if>
                                                <c:if test="${p.amenities.hasPark}"><span
                                                        style="display:inline-block;background:#e8f0fe;color:#1a73e8;padding:2px 8px;border-radius:10px;margin:2px;font-size:11px;">Park</span>
                                                </c:if>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- Row: Action buttons -->
                                <div style="display:grid;
                      grid-template-columns:200px repeat(${properties.size()}, 1fr);
                      border-top:2px solid #e5e7eb;">
                                    <div class="compareLabel">Actions</div>
                                    <c:forEach var="p" items="${properties}">
                                        <div style="padding:16px;text-align:center;
                          border-right:1px solid #e5e7eb;">
                                            <a href="/properties/${p.id}" style="display:inline-block;padding:10px 20px;
                          background:#1a73e8;color:white;text-decoration:none;
                          border-radius:6px;font-size:13px;font-weight:600;">
                                                View Details
                                            </a>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>

                            <!-- Back to search button -->
                            <div style="text-align:center;margin-top:24px;">
                                <a href="/search" style="color:#1a73e8;text-decoration:none;font-size:14px;">
                                    &larr; Back to Search
                                </a>
                            </div>
                        </div>
                    </div>

                    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
            </body>

            </html>