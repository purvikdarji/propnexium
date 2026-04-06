<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Agent Profile – PropNexium</title>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                        rel="stylesheet">
                    <style>
                        * {
                            box-sizing: border-box;
                            margin: 0;
                            padding: 0
                        }

                        body {
                            font-family: 'Inter', sans-serif;
                            background: #f8fafc;
                            color: #1e293b
                        }

                        a {
                            text-decoration: none
                        }

                        /* ── Layout ── */
                        .wrap {
                            display: flex;
                            min-height: 100vh
                        }

                        /* ── Sidebar (reuse from dashboard) ── */
                        .sidebar {
                            width: 230px;
                            background: #0f172a;
                            flex-shrink: 0;
                            display: flex;
                            flex-direction: column
                        }

                        .sidebar-profile {
                            text-align: center;
                            padding: 20px 12px 18px;
                            border-bottom: 1px solid #1e293b
                        }

                        .avatar-circle {
                            width: 62px;
                            height: 62px;
                            border-radius: 50%;
                            background: linear-gradient(135deg, #1a73e8, #6366f1);
                            margin: 0 auto;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 24px;
                            font-weight: 800;
                            color: white;
                        }

                        .avatar-circle img {
                            width: 62px;
                            height: 62px;
                            border-radius: 50%;
                            object-fit: cover
                        }

                        .agent-name {
                            color: white;
                            font-weight: 700;
                            font-size: 14px;
                            margin-top: 10px
                        }

                        .agency-name {
                            color: #64748b;
                            font-size: 12px;
                            margin-top: 3px
                        }

                        .sidebar-label {
                            padding: 14px 20px 5px;
                            color: #475569;
                            font-size: 10px;
                            font-weight: 700;
                            text-transform: uppercase;
                            letter-spacing: 1.2px
                        }

                        .sidebar a {
                            display: flex;
                            align-items: center;
                            gap: 10px;
                            padding: 11px 20px;
                            color: #94a3b8;
                            font-size: 14px;
                            font-weight: 500;
                            transition: background .15s, color .15s
                        }

                        .sidebar a:hover {
                            background: #1e293b;
                            color: #f1f5f9
                        }

                        .sidebar a.active {
                            background: #1e3a5f;
                            color: #60a5fa;
                            border-left: 3px solid #3b82f6
                        }

                        .notif-pill {
                            margin-left: auto;
                            padding: 2px 7px;
                            border-radius: 10px;
                            font-size: 11px;
                            font-weight: 700;
                            color: white
                        }

                        .pill-amber {
                            background: #f59e0b
                        }

                        .pill-red {
                            background: #ef4444
                        }

                        .sidebar-foot {
                            margin-top: auto;
                            border-top: 1px solid #1e293b;
                            padding: 12px 20px
                        }

                        .sidebar-foot a {
                            color: #475569;
                            font-size: 13px
                        }

                        /* ── Main ── */
                        .main {
                            flex: 1;
                            display: flex;
                            flex-direction: column
                        }

                        .topbar {
                            background: white;
                            padding: 14px 28px;
                            border-bottom: 1px solid #e2e8f0;
                            display: flex;
                            justify-content: space-between;
                            align-items: center
                        }

                        .topbar h1 {
                            font-size: 20px;
                            font-weight: 700
                        }

                        .content {
                            padding: 26px 28px
                        }

                        /* ── Profile page 2-col ── */
                        .profile-grid {
                            display: grid;
                            grid-template-columns: 35% 1fr;
                            gap: 22px;
                            align-items: start
                        }

                        /* ── Left: Summary card ── */
                        .summary-card {
                            background: white;
                            border-radius: 14px;
                            padding: 28px;
                            box-shadow: 0 1px 8px rgba(0, 0, 0, .07);
                            text-align: center;
                        }

                        .sum-avatar {
                            width: 80px;
                            height: 80px;
                            border-radius: 50%;
                            background: linear-gradient(135deg, #1a73e8, #6366f1);
                            margin: 0 auto 14px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 32px;
                            font-weight: 800;
                            color: white;
                        }

                        .sum-avatar img {
                            width: 80px;
                            height: 80px;
                            border-radius: 50%;
                            object-fit: cover
                        }

                        .sum-name {
                            font-size: 20px;
                            font-weight: 700;
                            color: #1e293b
                        }

                        .sum-email {
                            font-size: 13px;
                            color: #64748b;
                            margin: 4px 0 14px
                        }

                        .sum-rating {
                            font-size: 22px;
                            margin-bottom: 4px
                        }

                        .sum-rating-val {
                            color: #94a3b8;
                            font-size: 13px;
                            margin-bottom: 16px
                        }

                        .sum-stat {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 11px 0;
                            border-top: 1px solid #f1f5f9;
                            text-align: left;
                        }

                        .sum-stat-label {
                            font-size: 13px;
                            color: #64748b
                        }

                        .sum-stat-value {
                            font-size: 14px;
                            font-weight: 700;
                            color: #1e293b
                        }

                        .btn-view-profile {
                            display: block;
                            margin-top: 18px;
                            padding: 10px;
                            background: #f1f5f9;
                            border-radius: 8px;
                            color: #334155;
                            font-size: 14px;
                            font-weight: 600;
                            transition: background .2s;
                        }

                        .btn-view-profile:hover {
                            background: #e2e8f0
                        }

                        /* ── Right: Edit form + upload ── */
                        .edit-card {
                            background: white;
                            border-radius: 14px;
                            padding: 28px;
                            box-shadow: 0 1px 8px rgba(0, 0, 0, .07);
                        }

                        .edit-card h2 {
                            font-size: 18px;
                            font-weight: 700;
                            color: #1e293b;
                            margin-bottom: 22px;
                            padding-bottom: 14px;
                            border-bottom: 1px solid #f1f5f9
                        }

                        .form-row {
                            margin-bottom: 18px
                        }

                        .form-row label {
                            display: block;
                            font-size: 13px;
                            font-weight: 600;
                            color: #374151;
                            margin-bottom: 6px
                        }

                        .form-row input,
                        .form-row textarea,
                        .form-row select {
                            width: 100%;
                            padding: 10px 14px;
                            border: 1.5px solid #e2e8f0;
                            border-radius: 8px;
                            font-size: 14px;
                            font-family: inherit;
                            outline: none;
                            transition: border-color .2s;
                            background: #fafafa;
                            color: #1e293b;
                        }

                        .form-row input:focus,
                        .form-row textarea:focus {
                            border-color: #3b82f6;
                            background: white
                        }

                        .form-row textarea {
                            resize: vertical;
                            min-height: 110px
                        }

                        .form-2col {
                            display: grid;
                            grid-template-columns: 1fr 1fr;
                            gap: 16px
                        }

                        .field-error {
                            color: #ef4444;
                            font-size: 12px;
                            margin-top: 4px
                        }

                        .char-counter {
                            float: right;
                            font-size: 11px;
                            color: #94a3b8
                        }

                        .btn-save {
                            padding: 11px 28px;
                            background: linear-gradient(135deg, #1a73e8, #1557b0);
                            color: white;
                            border: none;
                            border-radius: 8px;
                            font-size: 15px;
                            font-weight: 700;
                            cursor: pointer;
                            font-family: inherit;
                            transition: opacity .2s;
                        }

                        .btn-save:hover {
                            opacity: .88
                        }

                        /* ── Upload section ── */
                        .upload-card {
                            background: white;
                            border-radius: 14px;
                            padding: 22px 28px;
                            box-shadow: 0 1px 8px rgba(0, 0, 0, .07);
                            margin-top: 18px;
                        }

                        .upload-card h3 {
                            font-size: 15px;
                            font-weight: 700;
                            color: #1e293b;
                            margin-bottom: 14px
                        }

                        .upload-zone {
                            border: 2px dashed #cbd5e1;
                            border-radius: 10px;
                            padding: 22px;
                            text-align: center;
                            color: #94a3b8;
                        }

                        .upload-zone input[type=file] {
                            margin: 10px auto 0;
                            display: block;
                            font-size: 13px
                        }

                        .btn-upload {
                            margin-top: 12px;
                            padding: 9px 22px;
                            background: #475569;
                            color: white;
                            border: none;
                            border-radius: 7px;
                            font-size: 14px;
                            font-weight: 600;
                            cursor: pointer;
                            font-family: inherit;
                            transition: background .2s;
                        }

                        .btn-upload:hover {
                            background: #334155
                        }

                        /* ── Flash ── */
                        .flash-success {
                            padding: 12px 18px;
                            border-radius: 8px;
                            margin-bottom: 18px;
                            font-size: 14px;
                            font-weight: 500;
                            background: #dcfce7;
                            color: #166534
                        }

                        .flash-error {
                            padding: 12px 18px;
                            border-radius: 8px;
                            margin-bottom: 18px;
                            font-size: 14px;
                            font-weight: 500;
                            background: #fee2e2;
                            color: #dc2626
                        }
                    </style>
                </head>

                <body>
                    <div class="wrap">

                        <!-- ══ SIDEBAR ══ -->
                        <aside class="sidebar">
                            <div class="sidebar-profile">
                                <c:choose>
                                    <c:when test="${not empty agent.profilePicture}">
                                        <div class="avatar-circle"><img src="${agent.profilePicture}"
                                                alt="${agent.name}"></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="avatar-circle">${agent.name.charAt(0)}</div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="agent-name">${agent.name}</div>
                                <c:if test="${not empty profile.agencyName}">
                                    <div class="agency-name">${profile.agencyName}</div>
                                </c:if>
                            </div>

                            <div class="sidebar-label">Agent Panel</div>
                            <a href="/agent/dashboard">📊 Dashboard</a>
                            <a href="/agent/properties">
                                🏠 My Properties
                                <c:if test="${pendingListings > 0}"><span
                                        class="notif-pill pill-amber">${pendingListings}</span></c:if>
                            </a>
                            <a href="/agent/properties/add">➕ Add Property</a>
                            <a href="/agent/inquiries">
                                💬 Inquiries
                                <c:if test="${pendingInquiries > 0}"><span
                                        class="notif-pill pill-red">${pendingInquiries}</span></c:if>
                            </a>
                            <a href="/agent/bookings">📅 Manage Visits</a>
                            <a href="/user/notifications">🔔 Notifications</a>
                            <a href="/agent/profile" class="active">👤 Agent Profile</a>
                            <div class="sidebar-foot"><a href="/">← View Site</a></div>
                        </aside>

                        <!-- ══ MAIN ══ -->
                        <div class="main">
                            <div class="topbar">
                                <h1>👤 Agent Profile</h1>
                                <a href="/agent/dashboard" style="font-size:13px;color:#64748b">← Back to Dashboard</a>
                            </div>

                            <div class="content">

                                <c:if test="${not empty successMessage}">
                                    <div class="flash-success">✅ ${successMessage}</div>
                                </c:if>
                                <c:if test="${not empty errorMessage}">
                                    <div class="flash-error">❌ ${errorMessage}</div>
                                </c:if>

                                <div class="profile-grid">

                                    <!-- ─── Left: Summary Card ─── -->
                                    <div>
                                        <div class="summary-card">
                                            <div class="sum-avatar">
                                                <c:choose>
                                                    <c:when test="${not empty agent.profilePicture}">
                                                        <img src="${agent.profilePicture}" alt="${agent.name}">
                                                    </c:when>
                                                    <c:otherwise>${agent.name.charAt(0)}</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="sum-name">${agent.name}</div>
                                            <div class="sum-email">${agent.email}</div>

                                            <!-- Rating Stars -->
                                            <c:choose>
                                                <c:when
                                                    test="${profile != null && profile.rating != null && profile.rating > 0}">
                                                    <div class="sum-rating">
                                                        <c:set var="r" value="${profile.rating}" />
                                                        <c:forEach begin="1" end="5" var="i">
                                                            <c:choose>
                                                                <c:when test="${i <= r}">⭐</c:when>
                                                                <c:otherwise>☆</c:otherwise>
                                                            </c:choose>
                                                        </c:forEach>
                                                    </div>
                                                    <div class="sum-rating-val">${profile.rating} / 5.0</div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="sum-rating">☆☆☆☆☆</div>
                                                    <div class="sum-rating-val">No ratings yet</div>
                                                </c:otherwise>
                                            </c:choose>

                                            <!-- Stats -->
                                            <div class="sum-stat">
                                                <span class="sum-stat-label">Total Listings</span>
                                                <span class="sum-stat-value">${totalListings}</span>
                                            </div>
                                            <c:if test="${profile != null}">
                                                <div class="sum-stat">
                                                    <span class="sum-stat-label">Experience</span>
                                                    <span class="sum-stat-value">
                                                        <c:choose>
                                                            <c:when
                                                                test="${profile.experienceYears != null && profile.experienceYears > 0}">
                                                                ${profile.experienceYears} yr<c:if
                                                                    test="${profile.experienceYears != 1}">s</c:if>
                                                            </c:when>
                                                            <c:otherwise>—</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                                <div class="sum-stat">
                                                    <span class="sum-stat-label">Agency</span>
                                                    <span class="sum-stat-value">
                                                        <c:choose>
                                                            <c:when test="${not empty profile.agencyName}">
                                                                ${profile.agencyName}</c:when>
                                                            <c:otherwise>—</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </c:if>
                                            <div class="sum-stat">
                                                <span class="sum-stat-label">Member Since</span>
                                                <span class="sum-stat-value">
                                                    ${agent.createdAt.dayOfMonth}/${agent.createdAt.monthValue}/${agent.createdAt.year}
                                                </span>
                                            </div>
                                            <a href="/properties?agentId=${agent.id}" class="btn-view-profile">View
                                                Public Profile →</a>
                                        </div>
                                    </div>

                                    <!-- ─── Right: Edit Form + Upload ─── -->
                                    <div>
                                        <div class="edit-card">
                                            <h2>✏️ Edit Professional Information</h2>
                                            <form action="/agent/profile/update" method="POST">
                                                <input type="hidden" name="${_csrf.parameterName}"
                                                    value="${_csrf.token}" />

                                                <div class="form-2col">
                                                    <div class="form-row">
                                                        <label for="agencyName">Agency Name</label>
                                                        <input type="text" id="agencyName" name="agencyName"
                                                            value="${profileDto.agencyName}"
                                                            placeholder="e.g. BlueStar Realty">
                                                    </div>
                                                    <div class="form-row">
                                                        <label for="licenseNumber">License Number</label>
                                                        <input type="text" id="licenseNumber" name="licenseNumber"
                                                            value="${profileDto.licenseNumber}"
                                                            placeholder="e.g. REA-12345">
                                                    </div>
                                                </div>

                                                <div class="form-2col">
                                                    <div class="form-row">
                                                        <label for="experienceYears">Years of Experience</label>
                                                        <input type="number" id="experienceYears" name="experienceYears"
                                                            value="${profileDto.experienceYears}" min="0" max="50"
                                                            placeholder="e.g. 5">
                                                    </div>
                                                    <div class="form-row">
                                                        <label for="website">Website / LinkedIn URL</label>
                                                        <input type="url" id="website" name="website"
                                                            value="${profileDto.website}" placeholder="https://...">
                                                    </div>
                                                </div>

                                                <div class="form-row">
                                                    <label for="bio">
                                                        Professional Bio
                                                        <span class="char-counter" id="bioCounter">0 / 1000</span>
                                                    </label>
                                                    <textarea id="bio" name="bio" maxlength="1000"
                                                        placeholder="Tell buyers about your experience, specialties, and approach…"
                                                        oninput="updateCounter()">${profileDto.bio}</textarea>
                                                </div>

                                                <button type="submit" class="btn-save">💾 Save Profile</button>
                                            </form>
                                        </div>

                                        <!-- ── Profile Picture Upload ── -->
                                        <div class="upload-card">
                                            <h3>📷 Profile Picture</h3>
                                            <form action="/agent/profile/picture" method="POST"
                                                enctype="multipart/form-data">
                                                <input type="hidden" name="${_csrf.parameterName}"
                                                    value="${_csrf.token}" />
                                                <div class="upload-zone">
                                                    <div style="font-size:32px;margin-bottom:8px">🖼️</div>
                                                    <div style="font-size:14px;color:#475569;font-weight:500">
                                                        Upload a professional photo
                                                    </div>
                                                    <div style="font-size:12px;margin-top:4px">JPG, PNG — max 2 MB</div>
                                                    <input type="file" name="file" id="profilePicFile" accept="image/*"
                                                        onchange="previewImage(this)">
                                                </div>
                                                <c:if test="${not empty agent.profilePicture}">
                                                    <div style="text-align:center;margin-top:10px">
                                                        <img id="imgPreview" src="${agent.profilePicture}" style="width:60px;height:60px;border-radius:50%;object-fit:cover;
                              border:2px solid #e2e8f0">
                                                    </div>
                                                </c:if>
                                                <c:if test="${empty agent.profilePicture}">
                                                    <div style="text-align:center;margin-top:10px">
                                                        <img id="imgPreview" style="width:60px;height:60px;border-radius:50%;object-fit:cover;
                              border:2px solid #e2e8f0;display:none">
                                                    </div>
                                                </c:if>
                                                <div style="text-align:center">
                                                    <button type="submit" class="btn-upload">Upload Photo</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>

                                </div><!-- /profile-grid -->
                            </div><!-- /content -->
                        </div><!-- /main -->
                    </div><!-- /wrap -->

                    <script>
                        // Bio character counter
                        function updateCounter() {
                            const ta = document.getElementById('bio');
                            const count = document.getElementById('bioCounter');
                            count.textContent = ta.value.length + ' / 1000';
                        }
                        // Run on load to fill counter if pre-filled
                        updateCounter();

                        // Image preview
                        function previewImage(input) {
                            if (input.files && input.files[0]) {
                                const reader = new FileReader();
                                reader.onload = e => {
                                    const img = document.getElementById('imgPreview');
                                    img.src = e.target.result;
                                    img.style.display = 'block';
                                };
                                reader.readAsDataURL(input.files[0]);
                            }
                        }
                    </script>
                </body>

                </html>