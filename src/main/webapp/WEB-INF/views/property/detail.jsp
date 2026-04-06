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
                    <title>${property.title} – PropNexium</title>
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

                        .page-wrap {
                            max-width: 1200px;
                            margin: 0 auto;
                            padding: 28px 24px 60px
                        }

                        /* ── Breadcrumb ── */
                        .breadcrumb {
                            font-size: 13px;
                            color: #888;
                            margin-bottom: 18px
                        }

                        .breadcrumb a {
                            color: #1a73e8;
                            text-decoration: none
                        }

                        .breadcrumb a:hover {
                            text-decoration: underline
                        }

                        /* ── Layout ── */
                        .layout {
                            display: grid;
                            grid-template-columns: 1fr 360px;
                            gap: 28px;
                            align-items: start
                        }

                        /* ── Gallery ── */
                        .gallery {
                            background: white;
                            border-radius: 14px;
                            overflow: hidden;
                            margin-bottom: 22px;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, .07)
                        }

                        .gallery-main {
                            height: 420px;
                            background: linear-gradient(135deg, #e8eeff, #c7d7fc);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 80px;
                            position: relative;
                            overflow: hidden;
                            cursor: pointer;
                        }

                        .gallery-main img {
                            width: 100%;
                            height: 100%;
                            object-fit: cover;
                            display: block
                        }

                        .gallery-thumbs {
                            display: flex;
                            gap: 6px;
                            padding: 10px;
                            overflow-x: auto
                        }

                        .thumb-item {
                            flex-shrink: 0;
                            width: 80px;
                            height: 60px;
                            border-radius: 8px;
                            overflow: hidden;
                            cursor: pointer;
                            border: 2px solid transparent;
                            transition: border-color .2s;
                            background: #eee;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }

                        .thumb-item.active {
                            border-color: #1a73e8
                        }

                        .thumb-item img {
                            width: 100%;
                            height: 100%;
                            object-fit: cover
                        }

                        /* ── Property Card ── */
                        .info-card {
                            background: white;
                            border-radius: 14px;
                            padding: 24px;
                            margin-bottom: 22px;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, .07)
                        }

                        .property-title {
                            font-size: 24px;
                            font-weight: 700;
                            margin-bottom: 8px;
                            line-height: 1.3
                        }

                        .property-price {
                            font-size: 28px;
                            font-weight: 700;
                            color: #1a73e8;
                            margin-bottom: 6px;
                            display: flex;
                            align-items: baseline;
                            gap: 10px;
                        }

                        .property-price .neg {
                            font-size: 13px;
                            color: #28a745;
                            font-weight: 500
                        }

                        .property-loc {
                            color: #666;
                            font-size: 14px;
                            margin-bottom: 16px
                        }

                        /* ── Details Grid ── */
                        .details-grid {
                            display: grid;
                            grid-template-columns: repeat(4, 1fr);
                            gap: 12px;
                            margin-bottom: 20px;
                        }

                        .detail-cell {
                            background: #f8f9ff;
                            border-radius: 10px;
                            padding: 14px;
                            text-align: center;
                        }

                        .detail-cell .label {
                            font-size: 11px;
                            color: #888;
                            font-weight: 500;
                            text-transform: uppercase;
                            letter-spacing: .5px;
                            margin-bottom: 6px
                        }

                        .detail-cell .value {
                            font-size: 15px;
                            font-weight: 600;
                            color: #222
                        }

                        /* ── Section Header ── */
                        .section-head {
                            font-size: 17px;
                            font-weight: 700;
                            color: #222;
                            margin-bottom: 14px;
                            padding-bottom: 10px;
                            border-bottom: 2px solid #f0f2f5;
                        }

                        /* ── Description ── */
                        .description {
                            color: #444;
                            font-size: 14px;
                            line-height: 1.8;
                            white-space: pre-wrap
                        }

                        /* ── Amenities Grid ── */
                        .amenity-grid {
                            display: grid;
                            grid-template-columns: repeat(3, 1fr);
                            gap: 10px;
                        }

                        .amenity-item {
                            display: flex;
                            align-items: center;
                            gap: 8px;
                            padding: 10px 14px;
                            border-radius: 8px;
                            font-size: 13px;
                            font-weight: 500;
                        }

                        .amenity-item.has {
                            background: #e8f5e9;
                            color: #2e7d32
                        }

                        .amenity-item.has-not {
                            background: #fafafa;
                            color: #aaa
                        }

                        .amenity-icon {
                            font-size: 18px;
                            width: 24px;
                            text-align: center
                        }

                        /* ── Agent Card ── */
                        .agent-card {
                            display: flex;
                            align-items: center;
                            gap: 16px;
                            padding: 18px;
                            background: #f0f4ff;
                            border-radius: 12px;
                            margin-top: 4px;
                        }

                        .agent-avatar {
                            width: 52px;
                            height: 52px;
                            border-radius: 50%;
                            background: linear-gradient(135deg, #1a73e8, #0d47a1);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 22px;
                            font-weight: 700;
                            color: white;
                            flex-shrink: 0;
                        }

                        .agent-name {
                            font-size: 15px;
                            font-weight: 600
                        }

                        .agent-role {
                            font-size: 12px;
                            color: #666;
                            margin-top: 2px
                        }

                        /* ── Similar Properties ── */
                        .similar-grid {
                            display: grid;
                            grid-template-columns: repeat(2, 1fr);
                            gap: 14px;
                        }

                        .sim-card {
                            background: white;
                            border-radius: 12px;
                            overflow: hidden;
                            box-shadow: 0 2px 10px rgba(0, 0, 0, .07);
                            transition: transform .2s, box-shadow .2s;
                        }

                        .sim-card:hover {
                            transform: translateY(-3px);
                            box-shadow: 0 8px 22px rgba(0, 0, 0, .12)
                        }

                        .sim-img {
                            height: 120px;
                            background: linear-gradient(135deg, #e8eeff, #c7d7fc);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 36px;
                            overflow: hidden
                        }

                        .sim-img img {
                            width: 100%;
                            height: 100%;
                            object-fit: cover
                        }

                        .sim-body {
                            padding: 12px
                        }

                        .sim-title {
                            font-size: 13px;
                            font-weight: 600;
                            margin-bottom: 4px;
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap
                        }

                        .sim-price {
                            color: #1a73e8;
                            font-size: 14px;
                            font-weight: 700;
                            margin-bottom: 4px
                        }

                        .sim-loc {
                            color: #888;
                            font-size: 12px;
                            margin-bottom: 8px
                        }

                        .sim-link {
                            display: inline-block;
                            padding: 6px 12px;
                            background: #1a73e8;
                            color: white;
                            border-radius: 6px;
                            text-decoration: none;
                            font-size: 12px;
                            font-weight: 600;
                        }

                        /* ── RIGHT SIDEBAR ── */
                        .sidebar {
                            position: sticky;
                            top: 90px
                        }

                        /* Inquiry Card */
                        .inquiry-card {
                            background: white;
                            border-radius: 14px;
                            padding: 22px;
                            margin-bottom: 18px;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, .07);
                        }

                        .inquiry-card h3 {
                            font-size: 17px;
                            font-weight: 700;
                            margin-bottom: 16px;
                            color: #222
                        }

                        .form-group {
                            margin-bottom: 14px
                        }

                        .form-group label {
                            display: block;
                            font-size: 12px;
                            font-weight: 600;
                            color: #555;
                            margin-bottom: 5px;
                            text-transform: uppercase;
                            letter-spacing: .4px
                        }

                        .form-group input,
                        .form-group textarea {
                            width: 100%;
                            padding: 10px 13px;
                            border: 1.5px solid #ddd;
                            border-radius: 8px;
                            font-size: 14px;
                            font-family: inherit;
                            outline: none;
                            transition: border-color .2s;
                        }

                        .form-group input:focus,
                        .form-group textarea:focus {
                            border-color: #1a73e8
                        }

                        .form-group textarea {
                            resize: vertical;
                            min-height: 90px
                        }

                        .btn-submit {
                            width: 100%;
                            padding: 12px;
                            background: #1a73e8;
                            color: white;
                            border: none;
                            border-radius: 8px;
                            cursor: pointer;
                            font-size: 15px;
                            font-weight: 600;
                            font-family: inherit;
                            transition: opacity .2s;
                        }

                        .btn-submit:hover {
                            opacity: .88
                        }

                        /* Quick Stats Card */
                        .stats-card {
                            background: white;
                            border-radius: 14px;
                            padding: 18px;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, .07);
                        }

                        .stat-row {
                            display: flex;
                            align-items: center;
                            justify-content: space-between;
                            padding: 10px 0;
                            border-bottom: 1px solid #f0f2f5;
                            font-size: 14px;
                        }

                        .stat-row:last-child {
                            border-bottom: none
                        }

                        .stat-label {
                            color: #888
                        }

                        .stat-val {
                            font-weight: 600;
                            color: #222
                        }

                        /* Wishlist Button (detail) */
                        #wishlistBtn {
                            width: 100%;
                            padding: 11px;
                            border-radius: 8px;
                            cursor: pointer;
                            font-size: 15px;
                            font-weight: 600;
                            font-family: inherit;
                            margin-top: 10px;
                            transition: all .2s;
                        }

                        /* Toast */
                        #toast {
                            position: fixed;
                            bottom: 30px;
                            right: 30px;
                            padding: 13px 22px;
                            border-radius: 9px;
                            font-size: 14px;
                            font-weight: 600;
                            color: white;
                            z-index: 9999;
                            box-shadow: 0 4px 20px rgba(0, 0, 0, .2);
                            display: none;
                            animation: slideIn .3s ease;
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
                    </style>
                </head>

                <body>
                    <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                        <div class="page-wrap">

                            <!-- Breadcrumb -->
                            <div class="breadcrumb">
                                <a href="/">Home</a> › <a href="/properties">Properties</a> › ${property.title}
                            </div>

                            <div class="layout">

                                <!-- ══════════ LEFT COLUMN ══════════ -->
                                <div class="left-col">

                                    <!-- Gallery -->
                                    <div class="gallery">
                                        <div class="gallery-main" id="mainImg">
                                            <c:choose>
                                                <c:when test="${not empty property.images}">
                                                    <img id="mainImgEl" src="${property.images[0].imageUrl}"
                                                        alt="${property.title}">
                                                </c:when>
                                                <c:otherwise>🏠</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <c:if test="${not empty property.images}">
                                            <div class="gallery-thumbs">
                                                <c:forEach var="img" items="${property.images}" varStatus="st">
                                                    <div class="thumb-item ${st.first ? 'active' : ''}"
                                                        onclick="changeImg('${img.imageUrl}', this)">
                                                        <img src="${img.imageUrl}" alt="Image ${st.index + 1}">
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                    </div>

                                    <!-- Title & Price -->
                                    <div class="info-card">
                                        <div class="property-title">${property.title}</div>
                                        <div class="property-price">
                                            ₹
                                            <fmt:formatNumber value="${property.price}" groupingUsed="true" />
                                            <c:if test="${property.priceNegotiable}">
                                                <span class="neg">(Negotiable)</span>
                                            </c:if>
                                        </div>
                                        <div class="property-loc">
                                            📍 <c:if test="${not empty property.location}">${property.location}, </c:if>
                                            ${property.city}
                                            <c:if test="${not empty property.state}">, ${property.state}</c:if>
                                            <c:if test="${not empty property.pincode}"> – ${property.pincode}</c:if>
                                        </div>

                                        <!-- Key Details Grid -->
                                        <div class="section-head">Property Details</div>
                                        <div class="details-grid">
                                            <div class="detail-cell">
                                                <div class="label">Type</div>
                                                <div class="value">${property.type}</div>
                                            </div>
                                            <div class="detail-cell">
                                                <div class="label">Category</div>
                                                <div class="value">${property.category}</div>
                                            </div>
                                            <div class="detail-cell">
                                                <div class="label">Bedrooms</div>
                                                <div class="value">
                                                    <c:choose>
                                                        <c:when test="${property.bedrooms > 0}">${property.bedrooms} BHK
                                                        </c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="detail-cell">
                                                <div class="label">Bathrooms</div>
                                                <div class="value">
                                                    <c:choose>
                                                        <c:when test="${property.bathrooms > 0}">${property.bathrooms}
                                                        </c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="detail-cell">
                                                <div class="label">Area</div>
                                                <div class="value">
                                                    <c:choose>
                                                        <c:when test="${property.areaSqft != null}">
                                                            <fmt:formatNumber value="${property.areaSqft}"
                                                                maxFractionDigits="0" /> sqft
                                                        </c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="detail-cell">
                                                <div class="label">Floor</div>
                                                <div class="value">
                                                    <c:choose>
                                                        <c:when test="${property.floorNumber != null}">
                                                            ${property.floorNumber}<c:if
                                                                test="${property.totalFloors != null}">
                                                                /${property.totalFloors}</c:if>
                                                        </c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="detail-cell">
                                                <div class="label">Furnishing</div>
                                                <div class="value">
                                                    <c:choose>
                                                        <c:when test="${property.furnishing == 'FULLY_FURNISHED'}">Fully
                                                        </c:when>
                                                        <c:when test="${property.furnishing == 'SEMI_FURNISHED'}">Semi
                                                        </c:when>
                                                        <c:otherwise>Unfurnished</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="detail-cell">
                                                <div class="label">Year Built</div>
                                                <div class="value">
                                                    <c:choose>
                                                        <c:when test="${property.yearBuilt != null}">
                                                            ${property.yearBuilt}</c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Facing & Parking -->
                                        <c:if test="${property.facing != null || property.parking != 'NONE'}">
                                            <div
                                                style="display:flex;gap:12px;margin-bottom:16px;font-size:13px;color:#555;flex-wrap:wrap">
                                                <c:if test="${property.facing != null}">
                                                    <span>🧭 Facing: <strong>${property.facing}</strong></span>
                                                </c:if>
                                                <c:if test="${property.parking != null && property.parking != 'NONE'}">
                                                    <span>🅿️ Parking: <strong>${property.parking}</strong></span>
                                                </c:if>
                                                <c:if test="${property.balconies > 0}">
                                                    <span>🌅 Balconies: <strong>${property.balconies}</strong></span>
                                                </c:if>
                                                <c:if test="${property.maintenanceCharge != null}">
                                                    <span>🔧 Maintenance: <strong>₹
                                                            <fmt:formatNumber value="${property.maintenanceCharge}"
                                                                maxFractionDigits="0" />/mo
                                                        </strong></span>
                                                </c:if>
                                            </div>
                                        </c:if>
                                    </div>

                                    <!-- Description -->
                                    <c:if test="${not empty property.description}">
                                        <div class="info-card">
                                            <div class="section-head">About this Property</div>
                                            <div class="description">${property.description}</div>
                                        </div>
                                    </c:if>

                                    <!-- Amenities -->
                                    <c:if test="${property.amenities != null}">
                                        <div class="info-card">
                                            <div class="section-head">Amenities</div>
                                            <div class="amenity-grid">
                                                <div
                                                    class="amenity-item ${property.amenities.hasGym ? 'has' : 'has-not'}">
                                                    <span class="amenity-icon">${property.amenities.hasGym ? '✅' :
                                                        '❌'}</span> Gym
                                                </div>
                                                <div
                                                    class="amenity-item ${property.amenities.hasSwimmingPool ? 'has' : 'has-not'}">
                                                    <span class="amenity-icon">${property.amenities.hasSwimmingPool ?
                                                        '✅' : '❌'}</span> Swimming Pool
                                                </div>
                                                <div
                                                    class="amenity-item ${property.amenities.hasSecurity ? 'has' : 'has-not'}">
                                                    <span class="amenity-icon">${property.amenities.hasSecurity ? '✅' :
                                                        '❌'}</span> Security
                                                </div>
                                                <div
                                                    class="amenity-item ${property.amenities.hasLift ? 'has' : 'has-not'}">
                                                    <span class="amenity-icon">${property.amenities.hasLift ? '✅' :
                                                        '❌'}</span> Lift / Elevator
                                                </div>
                                                <div
                                                    class="amenity-item ${property.amenities.hasPowerBackup ? 'has' : 'has-not'}">
                                                    <span class="amenity-icon">${property.amenities.hasPowerBackup ? '✅'
                                                        : '❌'}</span> Power Backup
                                                </div>
                                                <div
                                                    class="amenity-item ${property.amenities.hasClubHouse ? 'has' : 'has-not'}">
                                                    <span class="amenity-icon">${property.amenities.hasClubHouse ? '✅' :
                                                        '❌'}</span> Club House
                                                </div>
                                                <div
                                                    class="amenity-item ${property.amenities.hasChildrenPlayArea ? 'has' : 'has-not'}">
    <span class="amenity-icon">${property.amenities.hasChildrenPlayArea ? '✅' : '❌'}</span> Children Play Area
</div>
</div>
</div>
</c:if>

                                    <%-- ── Location Map ── --%>
                                    <div style="background:white;border-radius:10px;padding:25px;
                                                box-shadow:0 2px 12px rgba(0,0,0,0.07);margin-top:25px;">
                                        <h3 style="margin:0 0 16px;color:#1e293b;font-size:16px;">📍 Location on Map</h3>
                                        <div id="propertyMap"
                                             style="width:100%;height:300px;border-radius:8px;
                                                    border:1px solid #e5e7eb;"></div>
                                        <p style="margin:8px 0 0;font-size:12px;color:#94a3b8;">
                                            📍 <c:if test="${not empty property.location}">${property.location}, </c:if>${property.city}<c:if test="${not empty property.state}">, ${property.state}</c:if>
                                        </p>
                                    </div>

                                </div><!-- /left-col -->


                                <!-- ══════════ RIGHT SIDEBAR ══════════ -->
                                <div class="sidebar">

                                    <!-- Report Property Button -->
                                    <c:if test="${not empty pageContext.request.userPrincipal}">
                                    <div style="text-align:right; margin-bottom:12px;">
                                      <button onclick="showReportModal()"
                                        style="background:transparent;border:none;color:#ef4444;
                                               font-size:13px;font-weight:600;cursor:pointer;text-decoration:underline;padding:0;
                                               display:inline-flex;align-items:center;gap:4px;">
                                        🚩 Report This Property
                                      </button>
                                    </div>
                                    
                                    <!-- Report Modal -->
                                    <div id="reportModal"
                                         style="display:none;position:fixed;inset:0;
                                                background:rgba(0,0,0,0.5);z-index:9999;
                                                align-items:center;justify-content:center;">
                                      <div style="background:white;border-radius:12px;padding:28px;
                                                  width:400px;box-shadow:0 8px 40px rgba(0,0,0,0.2);text-align:left;">
                                        <h3 style="margin:0 0 16px;color:#1e293b;font-size:18px;">🚩 Report Property</h3>
                                        <label style="display:block;font-size:13px;color:#64748b;font-weight:600;
                                                      margin-bottom:6px;">Reason</label>
                                        <select id="reportReason"
                                          style="width:100%;padding:9px 12px;border:1px solid #d1d5db;
                                                 border-radius:6px;font-size:14px;margin-bottom:12px;background:white;font-family:inherit;">
                                          <option value="">Select a reason</option>
                                          <option value="Inappropriate Content">Inappropriate Content</option>
                                          <option value="Wrong Information">Wrong Information</option>
                                          <option value="Duplicate Listing">Duplicate Listing</option>
                                          <option value="Suspected Scam">Suspected Scam</option>
                                        </select>
                                        <label style="display:block;font-size:13px;color:#64748b;font-weight:600;
                                                      margin-bottom:6px;">Additional Details (optional)</label>
                                        <textarea id="reportDescription"
                                          placeholder="Describe the issue in detail..."
                                          style="width:100%;padding:9px 12px;border:1px solid #d1d5db;font-family:inherit;
                                                 border-radius:6px;font-size:14px;resize:vertical;
                                                 height:90px;box-sizing:border-box;margin-bottom:20px;">
                                        </textarea>
                                        <div style="display:flex;gap:10px;justify-content:flex-end;">
                                          <button onclick="closeReportModal()"
                                            style="padding:9px 18px;background:#f1f5f9;color:#374151;
                                                   border:none;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit;">
                                            Cancel
                                          </button>
                                          <button onclick="submitReport(${property.id})"
                                            style="padding:9px 18px;background:#dc2626;color:white;
                                                   border:none;border-radius:8px;font-size:14px;
                                                   font-weight:600;cursor:pointer;font-family:inherit;">
                                            Submit Report
                                          </button>
                                        </div>
                                      </div>
                                    </div>
                                    </c:if>

                                    <!-- Quick Stats -->
                                    <div class="stats-card" style="margin-bottom:18px">
                                        <div class="stat-row">
                                            <span class="stat-label">👁️ Views</span>
                                            <span class="stat-val">${property.viewCount}</span>
                                        </div>
                                        <div class="stat-row">
                                            <span class="stat-label">📅 Listed</span>
                                            <span class="stat-val">
                                                ${property.createdAt.dayOfMonth}/${property.createdAt.monthValue}/${property.createdAt.year}
                                            </span>
                                        </div>
                                        <div class="stat-row">
                                            <span class="stat-label">🏷️ Status</span>
                                            <span class="stat-val">${property.status}</span>
                                        </div>
                                        <c:if test="${property.possessionDate != null}">
                                            <div class="stat-row">
                                                <span class="stat-label">🗝️
                                                    Possession</span>
                                                <span class="stat-val">${property.possessionDate}</span>
                                            </div>
                                        </c:if>

                                        <!-- Wishlist Button -->
                                        <button id="wishlistBtn" onclick="toggleWishlist(${property.id}, this)" style="background:${isInWishlist ? '#e8f5e9' : '#fff'};
                 border:1.5px solid ${isInWishlist ? '#28a745' : '#ddd'};
                 color:${isInWishlist ? '#28a745' : '#666'};">
                                            ${isInWishlist ? '❤️ Saved' : '🤍 Save
                                            Property'}
                                        </button>

                                        <a href="/pdf/property/${property.id}" style="display:flex;align-items:center;justify-content:center;gap:8px;
                                                    width:100%;padding:12px;background:#dc2626;color:white;
                                                    text-decoration:none;border-radius:8px;font-size:14px;
                                                    font-weight:600;margin-top:10px;" target="_blank">
                                            📄 Download PDF Report
                                        </a>
                                        
                                        <c:if test="${not empty pageContext.request.userPrincipal}">
                                            <c:choose>
                                                <c:when test="${isOwner}">
                                                    <button disabled style="display:flex;align-items:center;justify-content:center;gap:8px;width:100%;padding:12px;background:#e2e8f0;color:#94a3b8;border:none;border-radius:8px;font-size:14px;font-weight:600;margin-top:10px;cursor:not-allowed;">
                                                        🏠 Your Listed Property
                                                    </button>
                                                </c:when>
                                                <c:when test="${hasBookedVisits}">
                                                    <a href="/user/bookings" style="display:flex;align-items:center;justify-content:center;gap:8px;width:100%;padding:12px;background:#1a73e8;color:white;text-decoration:none;border-radius:8px;font-size:14px;font-weight:600;margin-top:10px;">
                                                        ✅ Visit Scheduled
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="/properties/${property.id}/book" style="display:flex;align-items:center;justify-content:center;gap:8px;width:100%;padding:12px;background:#22c55e;color:white;text-decoration:none;border-radius:8px;font-size:14px;font-weight:600;margin-top:10px;">
                                                        📅 Book a Site Visit
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                        <c:if test="${empty pageContext.request.userPrincipal}">
                                        <a href="/auth/login"
                                           style="display:flex;align-items:center;justify-content:center;
                                                  gap:8px;width:100%;padding:12px;background:#22c55e;
                                                  color:white;text-decoration:none;border-radius:8px;
                                                  font-size:14px;font-weight:600;margin-top:10px;">
                                          📅 Login to Book a Site Visit
                                        </a>
                                        </c:if>

                                        <button onclick="addToCompare(${property.id}, '${property.title}', event)"
                                            id="compareBtn_${property.id}" style="width:100%;padding:11px;background:white;color:#1a73e8;
                                                       border:1.5px solid #1a73e8;border-radius:8px;font-size:14px;
                                                       font-weight:600;cursor:pointer;margin-top:8px;">
                                            &#9878; Compare This Property
                                        </button>
                                    <!-- ── Agent Info & Ratings ── -->
                                    <div style="background:white;border-radius:14px;padding:22px;margin-bottom:18px;box-shadow:0 2px 12px rgba(0,0,0,0.07);">
                                        <h3 style="font-size:16px;font-weight:700;margin-bottom:15px;color:#222;display:flex;align-items:center;gap:8px;">
                                            👤 Property Agent
                                        </h3>
                                        <div style="display:flex;align-items:center;gap:14px;margin-bottom:18px;">
                                            <c:choose>
                                                <c:when test="${not empty property.agent.profilePicture}">
                                                    <img src="${property.agent.profilePicture}" style="width:52px;height:52px;border-radius:50%;object-fit:cover;border:2px solid #f0f4ff;">
                                                </c:when>
                                                <c:otherwise>
                                                    <div style="width:52px;height:52px;border-radius:50%;background:linear-gradient(135deg, #1a73e8, #0d47a1);display:flex;align-items:center;justify-content:center;color:white;font-weight:700;font-size:20px;">
                                                        ${property.agent.name.charAt(0)}
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div>
                                                <div style="font-weight:700;color:#1e293b;font-size:15px;">${property.agent.name}</div>
                                                <div style="font-size:12px;color:#64748b;margin-top:2px;">Certified PropNexium Agent</div>
                                            </div>
                                        </div>
                                        
                                        <div style="background:#f8faff;border-radius:10px;padding:14px;margin-bottom:18px;border:1px solid #eef2ff;">
                                            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;">
                                                <span style="font-size:12px;color:#64748b;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;">Avg Rating</span>
                                                <span style="font-weight:800;color:#1a73e8;font-size:15px;">
                                                    <fmt:formatNumber value="${not empty agentAvgRating ? agentAvgRating : 0}" maxFractionDigits="1" /> / 5.0
                                                </span>
                                            </div>
                                            <div style="display:flex;align-items:center;gap:3px;">
                                                <c:forEach begin="1" end="5" var="star">
                                                    <span style="font-size:18px;color:${star <= (not empty agentAvgRating ? agentAvgRating : 0) ? '#fbbf24' : '#e2e8f0'};">★</span>
                                                </c:forEach>
                                                <span style="font-size:12px;color:#94a3b8;margin-left:6px;font-weight:500;">(${not empty agentReviewCount ? agentReviewCount : 0} reviews)</span>
                                            </div>
                                        </div>

                                        <a href="/agents/${property.agent.id}" style="display:block;width:100%;text-align:center;padding:12px;background:white;color:#1a73e8;border:1.5px solid #1a73e8;text-decoration:none;border-radius:8px;font-size:13px;font-weight:700;transition:all 0.2s;box-sizing:border-box;" onmouseover="this.style.background='#f0f7ff'" onmouseout="this.style.background='white'">
                                            View Profile & Submit Review
                                        </a>
                                    </div>

                                    <!-- ── Inquiry Form ── -->
                                    <div class="inquiry-card">
                                        <h3>📨 Contact Agent</h3>
                                        <form id="inquiryForm" onsubmit="submitInquiry(event, ${property.id})">
                                            <div class="form-group">
                                                <label>Your Name *</label>
                                                <input type="text" name="name" placeholder="Full name" required
                                                    value="${currentUserName}">
                                            </div>
                                            <div class="form-group">
                                                <label>Email Address *</label>
                                                <input type="email" name="email" placeholder="your@email.com" required
                                                    value="${currentUserEmail}">
                                            </div>
                                            <div class="form-group">
                                                <label>Phone Number</label>
                                                <input type="tel" name="phone" placeholder="10-digit number"
                                                    value="${currentUserPhone}">
                                            </div>
                                            <div class="form-group">
                                                <label>Message *</label>
                                                <textarea name="message"
                                                    placeholder="I'm interested in this property. Please contact me."
                                                    required>I'm interested in this property. Please get in touch with me.</textarea>
                                            </div>
                                            <button type="submit" class="btn-submit">Send
                                                Inquiry 🚀</button>
                                        </form>
                                    </div>

                                    <!-- Social Share Section -->
                                    <div style="margin-top:20px;padding-top:20px;
                                                border-top:1px solid #f1f5f9;">
                                        <p style="font-size:11px;color:#94a3b8;margin:0 0 10px;
                                                  font-weight:700;text-transform:uppercase;
                                                  letter-spacing:0.5px;">
                                            Share this property
                                        </p>
                                        <div style="display:flex;gap:8px;flex-wrap:wrap;">

                                            <!-- WhatsApp -->
                                            <a id="whatsappShare" href="#" target="_blank" style="display:flex;align-items:center;gap:6px;padding:9px 16px;
                                                      background:#25D366;color:white;text-decoration:none;
                                                      border-radius:6px;font-size:13px;font-weight:600;">
                                                📱 WhatsApp
                                            </a>

                                            <!-- Copy Link -->
                                            <button onclick="copyPropertyLink()" type="button" style="display:flex;align-items:center;gap:6px;padding:9px 16px;
                                                     background:#f1f5f9;color:#374151;border:none;
                                                     border-radius:6px;font-size:13px;font-weight:600;
                                                     cursor:pointer;">
                                                🔗 Copy Link
                                            </button>

                                            <!-- Email a Friend -->
                                            <a id="emailShare" href="#" target="_blank" style="display:flex;align-items:center;gap:6px;padding:9px 16px;
                                                      background:#f1f5f9;color:#374151;text-decoration:none;
                                                      border-radius:6px;font-size:13px;font-weight:600;">
                                                ✉️ Email
                                            </a>
                                        </div>
                                    </div>
                                </div><!-- /sidebar -->
                            </div><!-- /layout -->
                        </div><!-- /page-wrap -->

                        <%@ include file="/WEB-INF/views/common/footer.jsp" %>

                            <!-- Toast -->
                            <div id="toast"></div>

                            <script>
                                const CSRF_TOKEN = document.querySelector("meta[name='_csrf']").getAttribute("content");
                                const CSRF_HEADER = document.querySelector("meta[name='_csrf_header']").getAttribute("content");

                                // ─── Gallery ───────────────────────────────────────────────────────────────
                                function changeImg(src, thumbEl) {
                                    const main = document.getElementById('mainImgEl');
                                    if (main) main.src = src;
                                    document.querySelectorAll('.thumb-item').forEach(t => t.classList.remove('active'));
                                    thumbEl.classList.add('active');
                                }

                                // ─── Toast ─────────────────────────────────────────────────────────────────
                                // ─── Inquiry Submission ─────────────────────────────────────────────────────
                                function submitInquiry(event, propertyId) {
                                    event.preventDefault();
                                    const form = document.getElementById('inquiryForm');
                                    const btn = form.querySelector('.btn-submit');
                                    btn.textContent = 'Sending…';
                                    btn.disabled = true;

                                    const payload = {
                                        name: form.name.value,
                                        email: form.email.value,
                                        phone: form.phone.value,
                                        message: form.message.value
                                    };

                                    fetch('/api/v1/inquiries/property/' + propertyId, {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/json',
                                            [CSRF_HEADER]: CSRF_TOKEN
                                        },
                                        body: JSON.stringify(payload)
                                    })
                                        .then(res => res.json())
                                        .then(data => {
                                            if (data.success) {
                                                showToast('✅ Inquiry sent! Agent will contact you soon.', 'success');
                                                form.message.value = '';
                                            } else {
                                                showToast('❌ ' + (data.message || 'Failed to send. Try again.'), 'error');
                                            }
                                        })
                                        .catch(() => showToast('❌ Network error. Please try again.', 'error'))
                                        .finally(() => {
                                            btn.textContent = 'Send Inquiry 🚀';
                                            btn.disabled = false;
                                        });
                                }

                                // ─── EMI Calculator ──────────────────────────────────────────────────────────
                                function calculateEMI() {
                                    var P = parseFloat(document.getElementById('loanAmount').value) || 0;
                                    var annualRate = parseFloat(document.getElementById('interestRate').value) || 8.5;
                                    var years = parseInt(document.getElementById('loanTenure').value) || 20;
                                    var r = annualRate / 12 / 100;
                                    var n = years * 12;
                                    var emi = (r > 0 && n > 0 && P > 0) ? P * r * Math.pow(1 + r, n) / (Math.pow(1 + r, n) - 1) : 0;
                                    var total = emi * n;
                                    var interest = total - P;
                                    var pPct = total > 0 ? (P / total * 100) : 0;
                                    function fmt(v) { return '\u20B9' + Math.round(v).toLocaleString('en-IN'); }
                                    document.getElementById('emiResult').textContent = fmt(emi);
                                    document.getElementById('principalDisplay').textContent = fmt(P);
                                    document.getElementById('interestDisplay').textContent = fmt(Math.max(0, interest));
                                    document.getElementById('totalDisplay').textContent = fmt(total);
                                    document.getElementById('principalBar').style.width = pPct + '%';
                                    document.getElementById('interestBar').style.width = (100 - pPct) + '%';
                                    document.getElementById('loanSlider').value = P;
                                }
                                window.addEventListener('load', calculateEMI);

                                // ─── Report Property Modal ─────────────────────────────────────────────────
                                function showReportModal() {
                                    document.getElementById('reportModal').style.display = 'flex';
                                }

                                function closeReportModal() {
                                    document.getElementById('reportModal').style.display = 'none';
                                    document.getElementById('reportReason').value = '';
                                    document.getElementById('reportDescription').value = '';
                                }

                                function submitReport(propertyId) {
                                    const reason = document.getElementById('reportReason').value;
                                    const description = document.getElementById('reportDescription').value;

                                    if (!reason) {
                                        showToast('Please select a reason for reporting', 'error');
                                        return;
                                    }

                                    const payload = new URLSearchParams();
                                    payload.append('reason', reason);
                                    if (description) payload.append('description', description);

                                    fetch('/properties/' + propertyId + '/report', {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded',
                                            [CSRF_HEADER]: CSRF_TOKEN
                                        },
                                        body: payload.toString()
                                    })
                                    .then(res => {
                                        if (res.status === 401 || res.status === 403) {
                                            throw new Error('Please login to report this property');
                                        }
                                        return res.json();
                                    })
                                    .then(data => {
                                        if (data && data.success) {
                                            closeReportModal();
                                            showToast('✅ ' + data.message, 'success');
                                        } else {
                                            showToast('❌ ' + (data ? data.message : 'Error submitting report'), 'error');
                                        }
                                    })
                                    .catch(err => {
                                        showToast('❌ ' + err.message, 'error');
                                    });
                                }

                                // ─── Social Share ────────────────────────────────────────────────────────────
                                (function () {
                                    // Build the full current page URL
                                    var pageUrl = window.location.href;

                                    // Property info from server (EL expressions)
                                    var propTitle = '${property.title}';
                                    var propPrice = '${property.price}';
                                    var propCity = '${property.city}';

                                    // WhatsApp: pre-filled message with title, price, city, and URL
                                    var waText = propTitle + ' - \u20B9' + propPrice +
                                        ' | ' + propCity +
                                        '\n' + pageUrl;
                                    document.getElementById('whatsappShare').href =
                                        'https://wa.me/?text=' + encodeURIComponent(waText);

                                    // Email a Friend: subject = property title, body = URL
                                    var emailSubject = 'Check out this property: ' + propTitle;
                                    var emailBody = 'Hi,\n\nI found this property on PropNexium and thought you might be interested:\n\n' +
                                        propTitle + '\nPrice: \u20B9' + propPrice +
                                        ' | ' + propCity +
                                        '\n\nView here: ' + pageUrl +
                                        '\n\nRegards';
                                    document.getElementById('emailShare').href =
                                        'https://mail.google.com/mail/?view=cm&fs=1&tf=1&su=' + encodeURIComponent(emailSubject) +
                                        '&body=' + encodeURIComponent(emailBody);
                                })();

                                // Copy Link with Clipboard API and textarea fallback
                                function copyPropertyLink() {
                                    var url = window.location.href;

                                    if (navigator.clipboard && navigator.clipboard.writeText) {
                                        navigator.clipboard.writeText(url).then(function () {
                                            showCopyToast();
                                        }).catch(function () {
                                            fallbackCopy(url);
                                        });
                                    } else {
                                        fallbackCopy(url);
                                    }
                                }

                                function fallbackCopy(text) {
                                    var temp = document.createElement('textarea');
                                    temp.value = text;
                                    temp.style.position = 'fixed';
                                    temp.style.opacity = '0';
                                    document.body.appendChild(temp);
                                    temp.focus();
                                    temp.select();
                                    try {
                                        document.execCommand('copy');
                                        showCopyToast();
                                    } catch (e) {
                                        alert('Copy this link manually:\n' + text);
                                    }
                                    document.body.removeChild(temp);
                                }

                                function showCopyToast() {
                                    // Reuse existing showToast if available, else create inline toast
                                    if (typeof showToast === 'function') {
                                        showToast('Link copied to clipboard!', 'success');
                                        return;
                                    }

                                    var toast = document.createElement('div');
                                    toast.textContent = '✓ Link copied to clipboard!';
                                    toast.style.cssText =
                                        'position:fixed;bottom:80px;left:50%;transform:translateX(-50%);' +
                                        'background:#1e293b;color:white;padding:12px 24px;border-radius:8px;' +
                                        'font-size:14px;font-weight:600;z-index:9999;' +
                                        'box-shadow:0 4px 16px rgba(0,0,0,0.2);' +
                                        'animation:fadeInUp 0.3s ease;';
                                    document.body.appendChild(toast);

                                    setTimeout(function () {
                                        toast.style.opacity = '0';
                                        toast.style.transition = 'opacity 0.3s';
                                        setTimeout(function () {
                                            document.body.removeChild(toast);
                                        }, 300);
                                    }, 2500);
                                }
                            </script>

                            <!-- Price trend Chart.js initialization -->
                            <c:if test="${not empty priceHistory}">
                            <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js">
                            </script>
                            <script>
                            const priceHistory = [
                              <c:forEach var="ph" items="${priceHistory}" varStatus="vs">
                                {
                                  date: '${ph.changedDate.dayOfMonth} ${ph.changedDate.month.toString().substring(0,1)}${ph.changedDate.month.toString().substring(1,3).toLowerCase()} ${ph.changedDate.year.toString().substring(2)}',
                                  price: ${ph.newPrice}
                                }${vs.last ? '' : ','}
                              </c:forEach>
                            ];
                            
                            // Prepend current price as last point
                            priceHistory.push({
                              date: 'Now',
                              price: ${property.price}
                            });
                            
                            new Chart(document.getElementById('priceTrendChart'), {
                              type: 'line',
                              data: {
                                labels: priceHistory.map(d => d.date),
                                datasets: [{
                                  label: 'Price (₹)',
                                  data: priceHistory.map(d => d.price),
                                  borderColor: '#1A73E8',
                                  backgroundColor: 'rgba(26,115,232,0.08)',
                                  tension: 0.4,
                                  fill: true,
                                  pointRadius: 5,
                                  pointBackgroundColor: '#1A73E8'
                                }]
                              },
                              options: {
                                plugins: { legend: { display: false } },
                                scales: {
                                  y: {
                                    beginAtZero: false,
                                    ticks: {
                                      callback: function(value) {
                                        // Format as ₹L (lakhs)
                                        return '₹' + (value / 100000).toFixed(0) + 'L';
                                      }
                                    }
                                  }
                                }
                              }
                            });
                            </script>
                            </c:if>

                             <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
                             <script>
                             // Compact EMI Calculator Logic
                             function formatIndian(num) {
                                 let res = num.toString().split('.')[0];
                                 if (res.length > 3) {
                                     let lastThree = res.substring(res.length - 3);
                                     let otherNumbers = res.substring(0, res.length - 3);
                                     otherNumbers = otherNumbers.replace(/\B(?=(\d{2})+(?!\d))/g, ",");
                                     return otherNumbers + ',' + lastThree;
                                 }
                                 return res;
                             }

                             function updateQuickEmi() {
                                 const price = ${property.price};
                                 const rate = parseFloat(document.getElementById('qRate').value);
                                 const years = parseInt(document.getElementById('qTenure').value);

                                 document.getElementById('qRateDisplay').innerText = rate;
                                 document.getElementById('qRateVal').innerText = rate + '%';
                                 document.getElementById('qTenureDisplay').innerText = years;
                                 document.getElementById('qTenureVal').innerText = years + ' yrs';

                                 const downPayment = price * 0.20; // 20% down
                                 const principal = price - downPayment;
                                 const r = rate / 12 / 100;
                                 const n = years * 12;
                                 
                                 const emi = (principal * r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1);
                                 const totalInterest = (emi * n) - principal;

                                 const quickEmiElem = document.getElementById('quickEmi');
                                 if (quickEmiElem) {
                                     quickEmiElem.innerHTML = '&#8377;' + formatIndian(Math.round(emi));
                                     document.getElementById('qPrincipal').innerHTML = '&#8377;' + formatIndian(Math.round(principal));
                                     document.getElementById('qInterest').innerHTML = '&#8377;' + formatIndian(Math.round(totalInterest));
                                     document.getElementById('qDownPay').innerHTML = '&#8377;' + formatIndian(Math.round(downPayment));

                                     const total = principal + totalInterest;
                                     document.getElementById('qPrincipalBar').style.width = ((principal / total) * 100) + '%';
                                     document.getElementById('qInterestBar').style.width = ((totalInterest / total) * 100) + '%';
                                 }
                             }
                             
                             document.addEventListener('DOMContentLoaded', updateQuickEmi);

                             (function() {
                               var lat = ${propertyLat};
                               var lng = ${propertyLng};
                               var nearby = ${nearbyMapDataJson};
                               var map = L.map('propertyMap', { center: [lat, lng], zoom: 13, scrollWheelZoom: false });
                               L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: 'OpenStreetMap contributors', maxZoom: 19 }).addTo(map);
                               var blueIcon = L.divIcon({ className: '', html: '<div style="width:18px;height:18px;background:#1A73E8;border:3px solid white;border-radius:50%;box-shadow:0 2px 8px rgba(26,115,232,0.5);"></div>', iconSize: [18,18], iconAnchor: [9,9], popupAnchor: [0,-12] });
                               var orangeIcon = L.divIcon({ className: '', html: '<div style="width:14px;height:14px;background:#F59E0B;border:2px solid white;border-radius:50%;box-shadow:0 2px 6px rgba(245,158,11,0.4);"></div>', iconSize: [14,14], iconAnchor: [7,7], popupAnchor: [0,-10] });
                               L.marker([lat, lng], { icon: blueIcon }).addTo(map).bindPopup('<div style="min-width:160px;padding:4px;"><b>${property.title}</b><br><span style="color:#1a73e8;font-weight:700;">&#8377;${property.price}</span></div>').openPopup();
                               nearby.forEach(function(np) { L.marker([np.lat,np.lng],{icon:orangeIcon}).addTo(map).bindPopup('<div style="min-width:150px;padding:4px;"><b>'+np.title+'</b><br><span style="color:#1a73e8;font-weight:700;">&#8377;'+Number(np.price).toLocaleString('en-IN')+'</span><br><a href="/properties/'+np.id+'" style="color:#1a73e8;font-size:12px;">View &#8594;</a></div>'); });
                             })();
                             </script>
                </body>

                </html>