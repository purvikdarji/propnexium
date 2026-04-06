<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Edit Property – PropNexium</title>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
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
                        color: #1e293b;
                        padding-bottom: 50px
                    }

                    a {
                        text-decoration: none
                    }

                    .page-wrap {
                        max-width: 920px;
                        margin: 30px auto;
                        padding: 0 20px
                    }

                    .page-header {
                        margin-bottom: 24px;
                        display: flex;
                        justify-content: space-between;
                        align-items: flex-end
                    }

                    .page-header h2 {
                        font-size: 22px;
                        font-weight: 800;
                        color: #0f172a;
                        margin-bottom: 4px
                    }

                    .page-header p {
                        color: #64748b;
                        font-size: 14px
                    }

                    .card {
                        background: white;
                        border-radius: 12px;
                        padding: 26px;
                        box-shadow: 0 1px 8px rgba(0, 0, 0, .07);
                        margin-bottom: 18px
                    }

                    .card h3 {
                        font-size: 16px;
                        font-weight: 700;
                        color: #1e293b;
                        margin-bottom: 20px;
                        padding-bottom: 12px;
                        border-bottom: 2px solid #f1f5f9
                    }

                    .card h4 {
                        font-size: 14px;
                        font-weight: 600;
                        color: #374151;
                        margin: 0 0 12px
                    }

                    .frow {
                        margin-bottom: 16px
                    }

                    .frow label {
                        display: block;
                        font-size: 13px;
                        font-weight: 600;
                        color: #374151;
                        margin-bottom: 5px
                    }

                    .frow input,
                    .frow textarea,
                    .frow select {
                        width: 100%;
                        padding: 10px 13px;
                        border: 1.5px solid #d1d5db;
                        border-radius: 7px;
                        font-size: 14px;
                        font-family: inherit;
                        background: #fafafa;
                        color: #1e293b;
                        outline: none;
                        transition: border-color .18s
                    }

                    .frow input:focus,
                    .frow textarea:focus,
                    .frow select:focus {
                        border-color: #3b82f6;
                        background: white
                    }

                    .frow textarea {
                        resize: vertical;
                        min-height: 100px
                    }

                    .grid2 {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 16px
                    }

                    .grid3 {
                        display: grid;
                        grid-template-columns: 1fr 1fr 1fr;
                        gap: 16px
                    }

                    .grid4 {
                        display: grid;
                        grid-template-columns: repeat(4, 1fr);
                        gap: 14px
                    }

                    .radio-group {
                        display: flex;
                        gap: 10px
                    }

                    .radio-option {
                        flex: 1;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        padding: 10px 13px;
                        border: 2px solid #d1d5db;
                        border-radius: 7px;
                        cursor: pointer;
                        font-size: 13px
                    }

                    .amenity-grid {
                        display: grid;
                        grid-template-columns: repeat(4, 1fr);
                        gap: 10px;
                        margin-bottom: 22px
                    }

                    .amenity-label {
                        display: flex;
                        align-items: center;
                        gap: 7px;
                        padding: 9px 12px;
                        border: 1.5px solid #e5e7eb;
                        border-radius: 7px;
                        cursor: pointer;
                        font-size: 13px;
                        transition: background .15s
                    }

                    .amenity-label:hover {
                        background: #f0f7ff;
                        border-color: #93c5fd
                    }

                    /* Existing images */
                    .existing-images {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 10px;
                        margin-bottom: 18px
                    }

                    .existing-img {
                        position: relative
                    }

                    .existing-img img {
                        width: 90px;
                        height: 72px;
                        object-fit: cover;
                        border-radius: 7px;
                        border: 2px solid #e5e7eb
                    }

                    .existing-img .primary-tag {
                        position: absolute;
                        bottom: 4px;
                        left: 4px;
                        background: #1a73e8;
                        color: white;
                        font-size: 9px;
                        padding: 2px 5px;
                        border-radius: 3px
                    }

                    .upload-zone {
                        border: 2px dashed #cbd5e1;
                        border-radius: 10px;
                        padding: 24px;
                        text-align: center;
                        background: #f9fafb
                    }

                    .btn-choose {
                        padding: 8px 18px;
                        background: #1a73e8;
                        color: white;
                        border: none;
                        border-radius: 6px;
                        cursor: pointer;
                        font-size: 13px;
                        font-weight: 600
                    }

                    .img-preview {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 10px;
                        margin-top: 14px
                    }

                    .flash-err {
                        background: #fee2e2;
                        color: #dc2626;
                        border-radius: 8px;
                        padding: 13px 18px;
                        margin-bottom: 18px;
                        font-size: 14px
                    }

                    .field-err {
                        color: #dc2626;
                        font-size: 12px;
                        margin-top: 3px;
                        display: block
                    }

                    .action-bar {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        padding-top: 4px
                    }

                    .btn-cancel {
                        padding: 11px 24px;
                        border: 1.5px solid #d1d5db;
                        border-radius: 7px;
                        color: #374151;
                        font-size: 14px;
                        font-weight: 600
                    }

                    .btn-submit {
                        padding: 12px 34px;
                        background: linear-gradient(135deg, #1a73e8, #1557b0);
                        color: white;
                        border: none;
                        border-radius: 7px;
                        font-size: 15px;
                        font-weight: 700;
                        cursor: pointer;
                        transition: opacity .2s
                    }

                    .btn-submit:hover {
                        opacity: .88
                    }

                    .status-badge {
                        display: inline-block;
                        padding: 4px 12px;
                        border-radius: 12px;
                        font-size: 12px;
                        font-weight: 700
                    }

                    .status-UNDER_REVIEW {
                        background: #fef9c3;
                        color: #854d0e
                    }

                    .status-AVAILABLE {
                        background: #dcfce7;
                        color: #166534
                    }

                    .status-REJECTED {
                        background: #fee2e2;
                        color: #dc2626
                    }
                </style>
            </head>

            <body>
                <div class="page-wrap">

                    <div class="page-header">
                        <div>
                            <h2>Edit Property</h2>
                            <p>${property.title}</p>
                        </div>
                        <div>
                            Status: <span class="status-badge status-${property.status}">${property.status}</span>
                        </div>
                    </div>

                    <c:if test="${not empty errorMessage}">
                        <div class="flash-err">&#9888; ${errorMessage}</div>
                    </c:if>

                    <form:form method="POST" action="/agent/properties/${property.id}/edit" modelAttribute="propertyDto"
                        enctype="multipart/form-data">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                        <!-- SECTION 1 -->
                        <div class="card">
                            <h3>1. Basic Information</h3>
                            <div class="frow">
                                <label for="title">Property Title *</label>
                                <form:input path="title" id="title" />
                                <form:errors path="title" cssClass="field-err" />
                            </div>
                            <div class="frow">
                                <label for="description">Description</label>
                                <form:textarea path="description" id="description" rows="5" />
                                <form:errors path="description" cssClass="field-err" />
                            </div>
                            <div class="grid2">
                                <div class="frow">
                                    <label for="type">Property Type *</label>
                                    <form:select path="type" id="type">
                                        <form:option value="" label="-- Select Type --" />
                                        <c:forEach var="t" items="${propertyTypes}">
                                            <form:option value="${t}" label="${t}" />
                                        </c:forEach>
                                    </form:select>
                                    <form:errors path="type" cssClass="field-err" />
                                </div>
                                <div class="frow">
                                    <label>Category *</label>
                                    <div class="radio-group">
                                        <label class="radio-option">
                                            <form:radiobutton path="category" value="BUY" /> For Sale (Buy)
                                        </label>
                                        <label class="radio-option">
                                            <form:radiobutton path="category" value="RENT" /> For Rent
                                        </label>
                                    </div>
                                    <form:errors path="category" cssClass="field-err" />
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 2 -->
                        <div class="card">
                            <h3>2. Pricing</h3>
                            <div class="grid3">
                                <div class="frow">
                                    <label for="price">Price (&#8377;) *</label>
                                    <form:input path="price" id="price" type="number" />
                                    <form:errors path="price" cssClass="field-err" />
                                </div>
                                <div class="frow">
                                    <label for="maintenanceCharge">Maintenance (&#8377;/mo)</label>
                                    <form:input path="maintenanceCharge" id="maintenanceCharge" type="number" />
                                </div>
                                <div class="frow" style="display:flex;align-items:flex-end;padding-bottom:2px">
                                    <label
                                        style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:14px">
                                        <form:checkbox path="priceNegotiable" /> Price is Negotiable
                                    </label>
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 3 -->
                        <div class="card">
                            <h3>3. Property Details</h3>
                            <div class="grid4" style="margin-bottom:14px">
                                <div class="frow">
                                    <label for="bedrooms">Bedrooms</label>
                                    <form:input path="bedrooms" id="bedrooms" type="number" min="0" max="20" />
                                </div>
                                <div class="frow">
                                    <label for="bathrooms">Bathrooms</label>
                                    <form:input path="bathrooms" id="bathrooms" type="number" min="0" max="20" />
                                </div>
                                <div class="frow">
                                    <label for="balconies">Balconies</label>
                                    <form:input path="balconies" id="balconies" type="number" min="0" max="10" />
                                </div>
                                <div class="frow">
                                    <label for="areaSqft">Area (sqft)</label>
                                    <form:input path="areaSqft" id="areaSqft" type="number" />
                                </div>
                            </div>
                            <div class="grid3">
                                <div class="frow">
                                    <label for="furnishing">Furnishing</label>
                                    <form:select path="furnishing" id="furnishing">
                                        <form:option value="" label="Select Furnishing" />
                                        <c:forEach var="f" items="${furnishings}">
                                            <form:option value="${f}" label="${f}" />
                                        </c:forEach>
                                    </form:select>
                                </div>
                                <div class="frow">
                                    <label for="parking">Parking</label>
                                    <form:select path="parking" id="parking">
                                        <form:option value="" label="Select Parking" />
                                        <c:forEach var="p" items="${parkingOptions}">
                                            <form:option value="${p}" label="${p}" />
                                        </c:forEach>
                                    </form:select>
                                </div>
                                <div class="frow">
                                    <label for="facing">Facing</label>
                                    <form:select path="facing" id="facing">
                                        <form:option value="" label="Select Facing" />
                                        <c:forEach var="f" items="${facingOptions}">
                                            <form:option value="${f}" label="${f}" />
                                        </c:forEach>
                                    </form:select>
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 4 -->
                        <div class="card">
                            <h3>4. Location</h3>
                            <div class="grid2" style="margin-bottom:14px">
                                <div class="frow">
                                    <label for="city">City *</label>
                                    <form:select path="city" id="city">
                                        <form:option value="" label="-- Select City --" />
                                        <c:forEach var="ct" items="${cities}">
                                            <form:option value="${ct}" label="${ct}" />
                                        </c:forEach>
                                    </form:select>
                                    <form:errors path="city" cssClass="field-err" />
                                </div>
                                <div class="frow">
                                    <label for="state">State</label>
                                    <form:input path="state" id="state" />
                                </div>
                            </div>
                            <div style="display:grid;grid-template-columns:2fr 1fr;gap:16px">
                                <div class="frow">
                                    <label for="location">Address / Locality *</label>
                                    <form:input path="location" id="location" />
                                    <form:errors path="location" cssClass="field-err" />
                                </div>
                                <div class="frow">
                                    <label for="pincode">Pincode</label>
                                    <form:input path="pincode" id="pincode" />
                                    <form:errors path="pincode" cssClass="field-err" />
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 5 -->
                        <div class="card">
                            <h3>5. Amenities &amp; Images</h3>

                            <h4>Amenities</h4>
                            <div class="amenity-grid">
                                <label class="amenity-label">
                                    <form:checkbox path="hasGym" /> Gym
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasSwimmingPool" /> Swimming Pool
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasSecurity" /> 24x7 Security
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasLift" /> Lift/Elevator
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasPowerBackup" /> Power Backup
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasClubHouse" /> Club House
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasChildrenPlayArea" /> Children Play Area
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasGarden" /> Garden
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasIntercom" /> Intercom
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasRainwaterHarvesting" /> Rainwater Harvesting
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasWasteManagement" /> Waste Management
                                </label>
                                <label class="amenity-label">
                                    <form:checkbox path="hasVisitorParking" /> Visitor Parking
                                </label>
                            </div>

                            <!-- Existing images -->
                            <c:if test="${not empty property.images}">
                                <h4 style="margin-bottom:10px">Current Images</h4>
                                <div class="existing-images">
                                    <c:forEach var="img" items="${property.images}">
                                        <div class="existing-img">
                                            <img src="${img.imageUrl}" alt="Property image">
                                            <c:if test="${img.isPrimary}"><span class="primary-tag">Primary</span>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>

                            <h4>Add More Images <span style="color:#94a3b8;font-weight:400">(appended, not
                                    replaced)</span></h4>
                            <div class="upload-zone">
                                <div style="font-size:36px;margin-bottom:8px">📷</div>
                                <p style="font-size:13px;color:#64748b;margin:0 0 12px">Click to choose additional
                                    images</p>
                                <input type="file" name="images" multiple accept="image/*" id="imageInput"
                                    style="display:none" onchange="previewImages(this)">
                                <button type="button" class="btn-choose"
                                    onclick="document.getElementById('imageInput').click()">
                                    Choose Images
                                </button>
                                <p style="font-size:11px;color:#94a3b8;margin-top:8px">JPG, PNG, WEBP – max 5 MB each
                                </p>
                            </div>
                            <div class="img-preview" id="imagePreview"></div>
                        </div>

                        <!-- Submit / Cancel -->
                        <div class="action-bar">
                            <a href="/agent/properties" class="btn-cancel">← Cancel</a>
                            <button type="submit" class="btn-submit">Save Changes</button>
                        </div>

                    </form:form>
                </div>

                <script>
                    function previewImages(input) {
                        const preview = document.getElementById('imagePreview');
                        preview.innerHTML = '';
                        Array.from(input.files).slice(0, 10).forEach((file, i) => {
                            const reader = new FileReader();
                            reader.onload = e => {
                                const div = document.createElement('div');
                                div.style.cssText = 'position:relative;display:inline-block';
                                div.innerHTML = '<img src="' + e.target.result + '" style="width:100px;height:80px;object-fit:cover;border-radius:7px;border:2px solid #e5e7eb">';
                                preview.appendChild(div);
                            };
                            reader.readAsDataURL(file);
                        });
                    }
                </script>
            </body>

            </html>