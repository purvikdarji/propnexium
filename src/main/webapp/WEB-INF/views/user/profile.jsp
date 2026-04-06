<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>My Profile – PropNexium</title>
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
                        max-width: 860px;
                        margin: 0 auto;
                        padding: 30px 20px;
                    }

                    .card {
                        background: white;
                        border-radius: 14px;
                        padding: 30px;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.07);
                        margin-bottom: 24px;
                    }

                    .card h3 {
                        font-size: 18px;
                        margin-bottom: 20px;
                        color: #222;
                        border-left: 4px solid #1a73e8;
                        padding-left: 12px;
                    }

                    .profile-header {
                        display: flex;
                        align-items: center;
                        gap: 24px;
                        margin-bottom: 26px;
                    }

                    .avatar-wrap {
                        position: relative;
                    }

                    .avatar-img {
                        width: 90px;
                        height: 90px;
                        border-radius: 50%;
                        object-fit: cover;
                        border: 3px solid #1a73e8;
                    }

                    .avatar-placeholder {
                        width: 90px;
                        height: 90px;
                        border-radius: 50%;
                        background: linear-gradient(135deg, #1a73e8, #0d47a1);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 36px;
                        font-weight: 700;
                        color: white;
                        border: 3px solid #1a73e8;
                    }

                    .role-badge {
                        display: inline-block;
                        padding: 4px 12px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: 600;
                        text-transform: uppercase;
                        letter-spacing: .5px;
                        background: #e8f0fe;
                        color: #1a73e8;
                        margin-top: 4px;
                    }

                    .form-group {
                        margin-bottom: 18px;
                    }

                    .form-group label {
                        display: block;
                        font-size: 13px;
                        font-weight: 600;
                        color: #555;
                        margin-bottom: 6px;
                    }

                    .form-group input {
                        width: 100%;
                        padding: 10px 14px;
                        border: 1.5px solid #ddd;
                        border-radius: 8px;
                        font-size: 14px;
                        transition: border-color .2s;
                    }

                    .form-group input:focus {
                        outline: none;
                        border-color: #1a73e8;
                    }

                    .form-group input[readonly] {
                        background: #f8f9fa;
                        color: #888;
                        cursor: not-allowed;
                    }

                    .error-msg {
                        color: #dc3545;
                        font-size: 12px;
                        margin-top: 4px;
                    }

                    .btn {
                        padding: 10px 24px;
                        border: none;
                        border-radius: 8px;
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 600;
                        transition: opacity .2s;
                    }

                    .btn:hover {
                        opacity: 0.88;
                    }

                    .btn-primary {
                        background: #1a73e8;
                        color: white;
                    }

                    .btn-warning {
                        background: #ff9800;
                        color: white;
                    }

                    .btn-danger {
                        background: #e53935;
                        color: white;
                    }

                    .alert {
                        padding: 13px 18px;
                        border-radius: 8px;
                        margin-bottom: 18px;
                        font-size: 14px;
                    }

                    .alert-success {
                        background: #d4edda;
                        color: #155724;
                    }

                    .alert-error {
                        background: #f8d7da;
                        color: #721c24;
                    }

                    .two-col {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 16px;
                    }

                    .info-row {
                        display: flex;
                        gap: 30px;
                        font-size: 14px;
                        color: #555;
                    }

                    .info-row span strong {
                        color: #222;
                    }

                    /* picture upload */
                    .picture-upload-form {
                        display: flex;
                        align-items: center;
                        gap: 16px;
                        flex-wrap: wrap;
                    }

                    .file-input-label {
                        display: inline-block;
                        padding: 9px 20px;
                        background: #f0f2f5;
                        border: 1.5px dashed #aaa;
                        border-radius: 8px;
                        cursor: pointer;
                        font-size: 13px;
                        color: #555;
                        transition: border-color .2s;
                    }

                    .file-input-label:hover {
                        border-color: #1a73e8;
                        color: #1a73e8;
                    }

                    #pictureFile {
                        display: none;
                    }
                </style>
            </head>

            <body>

                <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                    <div class="page-wrap">

                        <!-- Flash Messages -->
                        <c:if test="${not empty successMessage}">
                            <div class="alert alert-success">✅ ${successMessage}</div>
                        </c:if>
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-error">❌ ${errorMessage}</div>
                        </c:if>
                        <c:if test="${not empty passwordSuccess}">
                            <div class="alert alert-success">🔒 ${passwordSuccess}</div>
                        </c:if>
                        <c:if test="${not empty passwordError}">
                            <div class="alert alert-error">⚠️ ${passwordError}</div>
                        </c:if>

                        <!-- Profile Header Card -->
                        <div class="card">
                            <div class="profile-header">
                                <div class="avatar-wrap">
                                    <c:choose>
                                        <c:when test="${not empty user.profilePicture}">
                                            <img src="${user.profilePicture}" class="avatar-img" alt="Profile Picture">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="avatar-placeholder">${user.name.charAt(0)}</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div>
                                    <h2 style="font-size:22px;">${user.name}</h2>
                                    <div style="color:#666; font-size:14px; margin:4px 0;">${user.email}</div>
                                    <span class="role-badge">${user.role}</span>
                                    <div class="info-row" style="margin-top:10px;">
                                        <span>📅 Member since <strong>${memberSince}</strong></span>
                                        <c:if test="${not empty user.phone}">
                                            <span>📞 <strong>${user.phone}</strong></span>
                                        </c:if>
                                    </div>
                                </div>
                            </div>

                            <!-- Profile Picture Upload -->
                            <form method="post" action="/user/profile/picture" enctype="multipart/form-data">
                                <h3 style="margin-bottom:14px;">Update Profile Picture</h3>
                                <div class="picture-upload-form">
                                    <label class="file-input-label" for="pictureFile">📁 Choose Image (max 5 MB)</label>
                                    <input type="file" id="pictureFile" name="picture" accept="image/*"
                                        onchange="document.getElementById('fileNameDisplay').textContent = this.files[0]?.name || ''">
                                    <span id="fileNameDisplay" style="font-size:13px; color:#888;"></span>
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <button type="submit" class="btn btn-warning">Upload</button>
                                </div>
                            </form>
                        </div>

                        <!-- Edit Profile -->
                        <div class="card">
                            <h3>Edit Profile</h3>
                            <form method="post" action="/user/profile/update">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                                <!-- Read-only account info -->
                                <div class="form-group">
                                    <label>Email Address</label>
                                    <input type="email" value="${user.email}" readonly>
                                </div>

                                <div class="two-col">
                                    <div class="form-group">
                                        <label for="name">Full Name *</label>
                                        <input type="text" id="name" name="name" value="${updateDto.name}"
                                            placeholder="Your full name" required>
                                        <c:if test="${not empty nameError}">
                                            <div class="error-msg">${nameError}</div>
                                        </c:if>
                                    </div>
                                    <div class="form-group">
                                        <label for="phone">Phone Number</label>
                                        <input type="tel" id="phone" name="phone" value="${updateDto.phone}"
                                            placeholder="10-digit phone (optional)">
                                        <c:if test="${not empty phoneError}">
                                            <div class="error-msg">${phoneError}</div>
                                        </c:if>
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-primary">Save Changes</button>
                            </form>
                        </div>

                        <!-- Change Password -->
                        <div class="card">
                            <h3>Change Password</h3>
                            <form method="post" action="/user/change-password">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <div class="form-group">
                                    <label for="currentPassword">Current Password</label>
                                    <input type="password" id="currentPassword" name="currentPassword"
                                        placeholder="Enter current password" required>
                                </div>
                                <div class="two-col">
                                    <div class="form-group">
                                        <label for="newPassword">New Password</label>
                                        <input type="password" id="newPassword" name="newPassword"
                                            placeholder="Min 8 characters" required minlength="8">
                                    </div>
                                    <div class="form-group">
                                        <label for="confirmNewPassword">Confirm New Password</label>
                                        <input type="password" id="confirmNewPassword" name="confirmNewPassword"
                                            placeholder="Repeat new password" required>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-danger">Change Password</button>
                            </form>
                        </div>

                    </div>

                    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
            </body>

            </html>