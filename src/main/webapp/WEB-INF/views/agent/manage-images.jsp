<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Manage Images – ${property.title} | PropNexium</title>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <meta name="_csrf" content="${_csrf.token}" />
                <meta name="_csrf_header" content="${_csrf.headerName}" />
                <style>
                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0
                    }

                    body {
                        font-family: 'Inter', sans-serif;
                        background: #f8fafc;
                        color: #1e293b;
                    }

                    a {
                        text-decoration: none;
                    }

                    .top-bar {
                        background: linear-gradient(135deg, #1a73e8, #0d47a1);
                        padding: 14px 32px;
                        display: flex;
                        align-items: center;
                        gap: 20px;
                    }

                    .top-bar a.logo {
                        color: white;
                        font-size: 20px;
                        font-weight: 800;
                        letter-spacing: -0.5px;
                    }

                    .top-bar .back-link {
                        color: rgba(255, 255, 255, 0.85);
                        font-size: 14px;
                        font-weight: 500;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        margin-left: auto;
                    }

                    .top-bar .back-link:hover {
                        color: white;
                    }

                    .page-header {
                        background: white;
                        border-bottom: 1px solid #e2e8f0;
                        padding: 24px 32px;
                    }

                    .page-header h1 {
                        font-size: 22px;
                        font-weight: 700;
                        color: #1e293b;
                        margin-bottom: 4px;
                    }

                    .page-header p {
                        font-size: 14px;
                        color: #64748b;
                    }

                    .container {
                        max-width: 1100px;
                        margin: 0 auto;
                        padding: 28px 24px;
                    }

                    /* Upload card */
                    .upload-card {
                        background: white;
                        border-radius: 12px;
                        padding: 28px;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
                        border: 1px solid #e2e8f0;
                        margin-bottom: 28px;
                    }

                    .card-title {
                        font-size: 16px;
                        font-weight: 700;
                        color: #1e293b;
                        margin-bottom: 18px;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .drop-zone {
                        border: 2px dashed #c7d7fc;
                        border-radius: 10px;
                        background: #f0f4ff;
                        padding: 36px 20px;
                        text-align: center;
                        cursor: pointer;
                        transition: border-color 0.2s, background 0.2s;
                    }

                    .drop-zone:hover,
                    .drop-zone.drag-over {
                        border-color: #1a73e8;
                        background: #e8f0fd;
                    }

                    .drop-zone input[type=file] {
                        display: none;
                    }

                    .drop-zone .icon {
                        font-size: 40px;
                        margin-bottom: 10px;
                    }

                    .drop-zone p {
                        color: #475569;
                        font-size: 14px;
                        margin-bottom: 4px;
                    }

                    .drop-zone small {
                        color: #94a3b8;
                        font-size: 12px;
                    }

                    .drop-zone .browse-btn {
                        display: inline-block;
                        margin-top: 12px;
                        padding: 10px 22px;
                        background: #1a73e8;
                        color: white;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 600;
                        cursor: pointer;
                        border: none;
                        transition: background 0.2s;
                    }

                    .drop-zone .browse-btn:hover {
                        background: #155dc9;
                    }

                    .preview-strip {
                        display: flex;
                        gap: 10px;
                        flex-wrap: wrap;
                        margin-top: 16px;
                    }

                    .preview-strip .prev-thumb {
                        width: 80px;
                        height: 80px;
                        object-fit: cover;
                        border-radius: 7px;
                        border: 2px solid #c7d7fc;
                    }

                    .upload-progress {
                        display: none;
                        margin-top: 14px;
                    }

                    .progress-bar-bg {
                        background: #e2e8f0;
                        border-radius: 6px;
                        height: 8px;
                    }

                    .progress-bar-fill {
                        background: #1a73e8;
                        height: 100%;
                        border-radius: 6px;
                        width: 0;
                        transition: width 0.3s;
                    }

                    .upload-status {
                        font-size: 13px;
                        color: #64748b;
                        margin-top: 6px;
                    }

                    .upload-action-btn {
                        margin-top: 16px;
                        padding: 11px 28px;
                        background: #1a73e8;
                        color: white;
                        border: none;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: background 0.2s;
                    }

                    .upload-action-btn:hover {
                        background: #155dc9;
                    }

                    .upload-action-btn:disabled {
                        background: #94a3b8;
                        cursor: not-allowed;
                    }

                    /* Image grid */
                    .images-card {
                        background: white;
                        border-radius: 12px;
                        padding: 28px;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
                        border: 1px solid #e2e8f0;
                    }

                    .image-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
                        gap: 16px;
                        margin-top: 18px;
                    }

                    .image-card {
                        border-radius: 10px;
                        overflow: hidden;
                        border: 2px solid #e2e8f0;
                        background: white;
                        transition: box-shadow 0.2s, border-color 0.2s;
                    }

                    .image-card.primary {
                        border-color: #1a73e8;
                        box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.12);
                    }

                    .image-card:hover {
                        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.1);
                    }

                    .image-card .img-wrapper {
                        position: relative;
                    }

                    .image-card img {
                        width: 100%;
                        height: 145px;
                        object-fit: cover;
                        display: block;
                    }

                    .primary-badge {
                        position: absolute;
                        top: 7px;
                        left: 7px;
                        background: #1a73e8;
                        color: white;
                        font-size: 10px;
                        font-weight: 700;
                        padding: 3px 8px;
                        border-radius: 5px;
                        letter-spacing: 0.3px;
                        text-transform: uppercase;
                    }

                    .card-actions {
                        padding: 10px;
                        display: flex;
                        flex-direction: column;
                        gap: 7px;
                    }

                    .btn-primary-set,
                    .btn-delete {
                        width: 100%;
                        padding: 7px;
                        border-radius: 6px;
                        font-size: 12px;
                        font-weight: 600;
                        cursor: pointer;
                        border: 1px solid;
                        transition: opacity 0.2s;
                    }

                    .btn-primary-set {
                        background: #f0f4ff;
                        color: #1a73e8;
                        border-color: #1a73e8;
                    }

                    .btn-primary-set:hover {
                        background: #e0e9ff;
                    }

                    .btn-delete {
                        background: #fff5f5;
                        color: #dc2626;
                        border-color: #dc2626;
                    }

                    .btn-delete:hover {
                        background: #fee2e2;
                    }

                    .btn-delete:disabled,
                    .btn-primary-set:disabled {
                        opacity: 0.5;
                        cursor: not-allowed;
                    }

                    .empty-state {
                        text-align: center;
                        padding: 50px 20px;
                        color: #94a3b8;
                    }

                    .empty-state .icon {
                        font-size: 56px;
                        margin-bottom: 12px;
                    }

                    .empty-state p {
                        font-size: 15px;
                        font-weight: 500;
                        color: #64748b;
                    }

                    .empty-state small {
                        font-size: 13px;
                    }

                    /* Toast */
                    #toast {
                        position: fixed;
                        bottom: 24px;
                        right: 24px;
                        background: #28a745;
                        color: white;
                        padding: 12px 22px;
                        border-radius: 9px;
                        font-size: 14px;
                        font-weight: 600;
                        display: none;
                        z-index: 9999;
                        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
                        animation: slideUp 0.3s ease;
                    }

                    @keyframes slideUp {
                        from {
                            transform: translateY(20px);
                            opacity: 0;
                        }

                        to {
                            transform: translateY(0);
                            opacity: 1;
                        }
                    }
                </style>
            </head>

            <body>

                <!-- ── Top Bar ── -->
                <div class="top-bar">
                    <a href="/" class="logo">🏠 PropNexium</a>
                    <a href="/agent/properties" class="back-link">← Back to My Properties</a>
                </div>

                <!-- ── Page Header ── -->
                <div class="page-header">
                    <h1>📷 Manage Images</h1>
                    <p>${property.title} &nbsp;·&nbsp; ${property.city} &nbsp;·&nbsp; ${property.type}</p>
                </div>

                <div class="container">

                    <!-- ── Upload Section ── -->
                    <div class="upload-card">
                        <div class="card-title">📤 Upload New Images</div>

                        <div class="drop-zone" id="dropZone" onclick="document.getElementById('fileInput').click()">
                            <input type="file" id="fileInput" multiple accept="image/*"
                                onchange="handleFileSelect(this.files)">
                            <div class="icon">📁</div>
                            <p>Drag &amp; drop images here or click to browse</p>
                            <small>JPG, PNG, WEBP — up to 5MB each</small><br>
                            <button class="browse-btn" type="button">Choose Files</button>
                        </div>

                        <div class="preview-strip" id="previewStrip"></div>

                        <div class="upload-progress" id="uploadProgress">
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill" id="progressFill"></div>
                            </div>
                            <div class="upload-status" id="uploadStatus">Uploading...</div>
                        </div>

                        <button class="upload-action-btn" id="uploadBtn" onclick="uploadImages()" disabled>
                            ⬆️ Upload Images
                        </button>
                    </div>

                    <!-- ── Current Images Grid ── -->
                    <div class="images-card">
                        <div class="card-title">🖼️ Current Images
                            <span style="margin-left:auto;font-size:13px;font-weight:500;color:#64748b;">
                                <c:out value="${fn:length(images)}" /> image(s)
                            </span>
                        </div>

                        <c:choose>
                            <c:when test="${empty images}">
                                <div class="empty-state">
                                    <div class="icon">📷</div>
                                    <p>No images yet</p>
                                    <small>Upload images above to get started.</small>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="image-grid" id="imageGrid">
                                    <c:forEach var="img" items="${images}">
                                        <div class="image-card ${img.isPrimary ? 'primary' : ''}" id="card-${img.id}"
                                            data-image-id="${img.id}">
                                            <div class="img-wrapper">
                                                <img src="${img.imageUrl}" alt="Property Image" loading="lazy">
                                                <c:if test="${img.isPrimary}">
                                                    <div class="primary-badge">★ Primary</div>
                                                </c:if>
                                            </div>
                                            <div class="card-actions">
                                                <c:if test="${!img.isPrimary}">
                                                    <button class="btn-primary-set"
                                                        onclick="setPrimary(${img.id}, ${property.id}, this)">
                                                        ⭐ Set as Primary
                                                    </button>
                                                </c:if>
                                                <button class="btn-delete"
                                                    onclick="deleteImage(${img.id}, ${property.id}, this)">
                                                    🗑 Delete
                                                </button>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Toast -->
                <div id="toast"></div>

                <script>
                    const CSRF_TOKEN = document.querySelector('meta[name="_csrf"]').getAttribute('content');
                    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]').getAttribute('content');
                    const PROPERTY_ID = ${ property.id };

                    let selectedFiles = [];

                    // ─── Drag & Drop ──────────────────────────────────────────────────────────
                    const dropZone = document.getElementById('dropZone');
                    dropZone.addEventListener('dragover', e => { e.preventDefault(); dropZone.classList.add('drag-over'); });
                    dropZone.addEventListener('dragleave', () => dropZone.classList.remove('drag-over'));
                    dropZone.addEventListener('drop', e => {
                        e.preventDefault();
                        dropZone.classList.remove('drag-over');
                        handleFileSelect(e.dataTransfer.files);
                    });

                    function handleFileSelect(files) {
                        selectedFiles = Array.from(files);
                        const strip = document.getElementById('previewStrip');
                        strip.innerHTML = '';
                        selectedFiles.forEach(file => {
                            const reader = new FileReader();
                            reader.onload = e => {
                                const img = document.createElement('img');
                                img.src = e.target.result;
                                img.className = 'prev-thumb';
                                strip.appendChild(img);
                            };
                            reader.readAsDataURL(file);
                        });
                        document.getElementById('uploadBtn').disabled = selectedFiles.length === 0;
                    }

                    // ─── Upload ───────────────────────────────────────────────────────────────
                    function uploadImages() {
                        if (selectedFiles.length === 0) return;

                        const btn = document.getElementById('uploadBtn');
                        btn.disabled = true;
                        btn.textContent = 'Uploading…';

                        const formData = new FormData();
                        selectedFiles.forEach(f => formData.append('images', f));

                        const progressDiv = document.getElementById('uploadProgress');
                        progressDiv.style.display = 'block';

                        // XHR for progress
                        const xhr = new XMLHttpRequest();
                        xhr.open('POST', '/api/v1/properties/' + PROPERTY_ID + '/images');
                        xhr.setRequestHeader(CSRF_HEADER, CSRF_TOKEN);

                        xhr.upload.addEventListener('progress', e => {
                            if (e.lengthComputable) {
                                const pct = Math.round((e.loaded / e.total) * 100);
                                document.getElementById('progressFill').style.width = pct + '%';
                                document.getElementById('uploadStatus').textContent = 'Uploading ' + pct + '%…';
                            }
                        });

                        xhr.onload = () => {
                            progressDiv.style.display = 'none';
                            btn.textContent = '⬆️ Upload Images';
                            if (xhr.status === 201) {
                                showToast('✅ Images uploaded successfully!', 'success');
                                setTimeout(() => location.reload(), 1200);
                            } else {
                                try {
                                    const res = JSON.parse(xhr.responseText);
                                    showToast('❌ ' + (res.message || 'Upload failed'), 'error');
                                } catch (e) {
                                    showToast('❌ Upload failed (' + xhr.status + ')', 'error');
                                }
                                btn.disabled = false;
                            }
                        };

                        xhr.onerror = () => {
                            progressDiv.style.display = 'none';
                            btn.textContent = '⬆️ Upload Images';
                            btn.disabled = false;
                            showToast('❌ Network error during upload.', 'error');
                        };

                        xhr.send(formData);
                    }

                    // ─── Set Primary ──────────────────────────────────────────────────────────
                    function setPrimary(imageId, propertyId, btn) {
                        btn.disabled = true;
                        btn.textContent = 'Setting…';

                        fetch('/api/v1/properties/' + propertyId + '/images/' + imageId + '/set-primary', {
                            method: 'PATCH',
                            headers: { [CSRF_HEADER]: CSRF_TOKEN }
                        })
                            .then(r => r.json())
                            .then(data => {
                                if (data.success) {
                                    showToast('✅ Primary image updated!', 'success');
                                    setTimeout(() => location.reload(), 900);
                                } else {
                                    showToast('❌ ' + (data.message || 'Failed to set primary'), 'error');
                                    btn.disabled = false;
                                    btn.textContent = '⭐ Set as Primary';
                                }
                            })
                            .catch(() => {
                                showToast('❌ Network error. Please try again.', 'error');
                                btn.disabled = false;
                                btn.textContent = '⭐ Set as Primary';
                            });
                    }

                    // ─── Delete ───────────────────────────────────────────────────────────────
                    function deleteImage(imageId, propertyId, btn) {
                        if (!confirm('Are you sure you want to delete this image? This cannot be undone.')) return;

                        btn.disabled = true;
                        btn.textContent = 'Deleting…';

                        fetch('/api/v1/properties/' + propertyId + '/images/' + imageId, {
                            method: 'DELETE',
                            headers: { [CSRF_HEADER]: CSRF_TOKEN }
                        })
                            .then(r => r.json())
                            .then(data => {
                                if (data.success) {
                                    const card = document.getElementById('card-' + imageId);
                                    card.style.transition = 'opacity 0.3s, transform 0.3s';
                                    card.style.opacity = '0';
                                    card.style.transform = 'scale(0.9)';
                                    setTimeout(() => { card.remove(); }, 320);
                                    showToast('🗑 Image deleted successfully.', 'success');
                                } else {
                                    showToast('❌ ' + (data.message || 'Delete failed'), 'error');
                                    btn.disabled = false;
                                    btn.textContent = '🗑 Delete';
                                }
                            })
                            .catch(() => {
                                showToast('❌ Network error. Please try again.', 'error');
                                btn.disabled = false;
                                btn.textContent = '🗑 Delete';
                            });
                    }

                    // ─── Toast ────────────────────────────────────────────────────────────────
                    function showToast(message, type) {
                        const t = document.getElementById('toast');
                        t.textContent = message;
                        t.style.background = type === 'success' ? '#16a34a' : '#dc2626';
                        t.style.display = 'block';
                        clearTimeout(t._timer);
                        t._timer = setTimeout(() => t.style.display = 'none', 3500);
                    }
                </script>
            </body>

            </html>