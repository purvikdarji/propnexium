<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"    uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>List New Property – PropNexium</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:'Inter',sans-serif;background:#f8fafc;color:#1e293b;padding-bottom:50px}
    a{text-decoration:none}
    .page-wrap{max-width:920px;margin:30px auto;padding:0 20px}
    .page-header{margin-bottom:24px}
    .page-header h2{font-size:22px;font-weight:800;color:#0f172a;margin-bottom:4px}
    .page-header p{color:#64748b;font-size:14px}
    /* Progress bar */
    .steps{display:flex;border-radius:8px;overflow:hidden;margin-bottom:28px}
    .step{flex:1;padding:10px 6px;text-align:center;font-size:12px;font-weight:700;
          background:#1a73e8;color:white;border-right:1px solid rgba(255,255,255,.25)}
    .step:last-child{border-right:none}
    /* Cards */
    .card{background:white;border-radius:12px;padding:26px;
          box-shadow:0 1px 8px rgba(0,0,0,.07);margin-bottom:18px}
    .card h3{font-size:16px;font-weight:700;color:#1e293b;margin-bottom:20px;
             padding-bottom:12px;border-bottom:2px solid #f1f5f9}
    .card h4{font-size:14px;font-weight:600;color:#374151;margin:0 0 12px}
    /* Form elements */
    .frow{margin-bottom:16px}
    .frow label{display:block;font-size:13px;font-weight:600;color:#374151;margin-bottom:5px}
    .frow input,.frow textarea,.frow select{
      width:100%;padding:10px 13px;border:1.5px solid #d1d5db;border-radius:7px;
      font-size:14px;font-family:inherit;background:#fafafa;color:#1e293b;outline:none;
      transition:border-color .18s}
    .frow input:focus,.frow textarea:focus,.frow select:focus{border-color:#3b82f6;background:white}
    .frow textarea{resize:vertical;min-height:100px}
    .grid2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
    .grid3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px}
    .grid4{display:grid;grid-template-columns:repeat(4,1fr);gap:14px}
    /* Radio buttons (category) */
    .radio-group{display:flex;gap:10px}
    .radio-option{flex:1;display:flex;align-items:center;gap:8px;
                  padding:10px 13px;border:2px solid #d1d5db;border-radius:7px;cursor:pointer;font-size:13px}
    /* Amenities */
    .amenity-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:22px}
    .amenity-label{display:flex;align-items:center;gap:7px;padding:9px 12px;
                   border:1.5px solid #e5e7eb;border-radius:7px;cursor:pointer;font-size:13px;
                   transition:background .15s,border-color .15s}
    .amenity-label:hover{background:#f0f7ff;border-color:#93c5fd}
    /* Upload zone */
    .upload-zone{border:2px dashed #cbd5e1;border-radius:10px;padding:28px;
                 text-align:center;background:#f9fafb}
    .upload-icon{font-size:38px;margin-bottom:8px}
    .upload-zone p{font-size:13px;color:#64748b;margin:0 0 14px}
    .btn-choose{padding:8px 18px;background:#1a73e8;color:white;border:none;
                border-radius:6px;cursor:pointer;font-size:13px;font-weight:600}
    .upload-hint{font-size:11px;color:#94a3b8;margin-top:8px}
    .img-preview{display:flex;flex-wrap:wrap;gap:10px;margin-top:14px}
    /* Flash */
    .flash-err{background:#fee2e2;color:#dc2626;border-radius:8px;
               padding:13px 18px;margin-bottom:18px;font-size:14px}
    .field-err{color:#dc2626;font-size:12px;margin-top:3px;display:block}
    /* Action bar */
    .action-bar{display:flex;justify-content:space-between;align-items:center;padding-top:4px}
    .btn-cancel{padding:11px 24px;border:1.5px solid #d1d5db;border-radius:7px;
                color:#374151;font-size:14px;font-weight:600}
    .btn-submit{padding:12px 34px;background:linear-gradient(135deg,#1a73e8,#1557b0);
                color:white;border:none;border-radius:7px;font-size:15px;font-weight:700;
                cursor:pointer;transition:opacity .2s}
    .btn-submit:hover{opacity:.88}
  </style>
</head>
<body>
<div class="page-wrap">

  <!-- Header -->
  <div class="page-header">
    <h2>List New Property</h2>
    <p>Fill all sections and submit for admin review. Your listing will go live after approval.</p>
  </div>

  <!-- Step progress -->
  <div class="steps">
    <div class="step">1. Basic Info</div>
    <div class="step">2. Pricing</div>
    <div class="step">3. Details</div>
    <div class="step">4. Location</div>
    <div class="step">5. Amenities &amp; Images</div>
  </div>

  <!-- Flash error -->
  <c:if test="${not empty errorMessage}">
    <div class="flash-err">&#9888; ${errorMessage}</div>
  </c:if>

  <form:form method="POST" action="/agent/properties/add"
             modelAttribute="propertyDto" enctype="multipart/form-data">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

    <!-- ── SECTION 1: BASIC INFO ── -->
    <div class="card">
      <h3>1. Basic Information</h3>
      <div class="frow">
        <label for="title">Property Title *</label>
        <form:input path="title" id="title" placeholder="e.g. Spacious 3BHK Apartment in Bandra"/>
        <form:errors path="title" cssClass="field-err"/>
      </div>
      <div class="frow">
        <label for="description">Description</label>
        <form:textarea path="description" id="description" rows="5"
          placeholder="Describe the property — nearby landmarks, unique features, society name..."/>
        <form:errors path="description" cssClass="field-err"/>
      </div>
      <div class="grid2">
        <div class="frow">
          <label for="type">Property Type *</label>
          <form:select path="type" id="type">
            <form:option value="" label="-- Select Type --"/>
            <c:forEach var="t" items="${propertyTypes}">
              <form:option value="${t}" label="${t}"/>
            </c:forEach>
          </form:select>
          <form:errors path="type" cssClass="field-err"/>
        </div>
        <div class="frow">
          <label>Category *</label>
          <div class="radio-group">
            <label class="radio-option">
              <form:radiobutton path="category" value="BUY"/> For Sale (Buy)
            </label>
            <label class="radio-option">
              <form:radiobutton path="category" value="RENT"/> For Rent
            </label>
          </div>
          <form:errors path="category" cssClass="field-err"/>
        </div>
      </div>
    </div>

    <!-- ── SECTION 2: PRICING ── -->
    <div class="card">
      <h3>2. Pricing</h3>
      <div class="grid3">
        <div class="frow">
          <label for="price">Price (&#8377;) *</label>
          <form:input path="price" id="price" type="number" placeholder="e.g. 5000000"/>
          <form:errors path="price" cssClass="field-err"/>
        </div>
        <div class="frow">
          <label for="maintenanceCharge">Maintenance (&#8377;/mo)</label>
          <form:input path="maintenanceCharge" id="maintenanceCharge" type="number" placeholder="Optional"/>
        </div>
        <div class="frow" style="display:flex;align-items:flex-end;padding-bottom:2px">
          <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:14px">
            <form:checkbox path="priceNegotiable"/> Price is Negotiable
          </label>
        </div>
      </div>
    </div>

    <!-- ── SECTION 3: PROPERTY DETAILS ── -->
    <div class="card">
      <h3>3. Property Details</h3>
      <div class="grid4" style="margin-bottom:14px">
        <div class="frow">
          <label for="bedrooms">Bedrooms</label>
          <form:input path="bedrooms" id="bedrooms" type="number" min="0" max="20" placeholder="0"/>
        </div>
        <div class="frow">
          <label for="bathrooms">Bathrooms</label>
          <form:input path="bathrooms" id="bathrooms" type="number" min="0" max="20" placeholder="0"/>
        </div>
        <div class="frow">
          <label for="balconies">Balconies</label>
          <form:input path="balconies" id="balconies" type="number" min="0" max="10" placeholder="0"/>
        </div>
        <div class="frow">
          <label for="areaInput">Total Area</label>
          <div style="display:flex;gap:8px;align-items:center">
            <input type="number" id="areaInput" name="areaInputRaw" placeholder="e.g. 1200"
                   style="flex:1;padding:10px 13px;border:1.5px solid #d1d5db;border-radius:7px;
                          font-size:14px;font-family:inherit;background:#fafafa;color:#1e293b;
                          outline:none;transition:border-color .18s"
                   oninput="convertToSqft()">
            <select id="areaUnitSelect" onchange="convertToSqft()"
                    style="padding:10px 10px;border:1.5px solid #d1d5db;border-radius:7px;
                           font-size:13px;font-family:inherit;background:white;color:#1e293b;
                           outline:none;cursor:pointer;min-width:130px">
              <option value="SQFT">sq ft</option>
              <option value="SQMT">sq mt</option>
              <option value="SQYD">sq yd</option>
              <option value="BIGHA_NORTH">Bigha (North)</option>
              <option value="BIGHA_GUJARAT">Bigha (Gujarat)</option>
              <option value="GUNTHA">Guntha</option>
              <option value="GUNTA">Gunta</option>
              <option value="CENT">Cent</option>
              <option value="CENT_TN">Cent (TN)</option>
              <option value="GROUND">Ground</option>
              <option value="ANKANAM">Ankanam</option>
              <option value="KATHA_BIHAR">Katha (Bihar)</option>
              <option value="KATHA_WB">Katha (WB/UP)</option>
              <option value="BISWA">Biswa</option>
              <option value="ACRE">Acre</option>
              <option value="HECTARE">Hectare</option>
            </select>
          </div>
          <!-- Hidden field stores the sq ft value sent to the server -->
          <input type="hidden" id="areaHidden" name="areaSqft">
          <span id="sqftEquiv" style="display:none;color:#64748b;font-size:12px;margin-top:5px;display:block"></span>
        </div>
      </div>
      <div class="grid3">
        <div class="frow">
          <label for="furnishing">Furnishing</label>
          <form:select path="furnishing" id="furnishing">
            <form:option value="" label="Select Furnishing"/>
            <c:forEach var="f" items="${furnishings}">
              <form:option value="${f}" label="${f}"/>
            </c:forEach>
          </form:select>
        </div>
        <div class="frow">
          <label for="parking">Parking</label>
          <form:select path="parking" id="parking">
            <form:option value="" label="Select Parking"/>
            <c:forEach var="p" items="${parkingOptions}">
              <form:option value="${p}" label="${p}"/>
            </c:forEach>
          </form:select>
        </div>
        <div class="frow">
          <label for="facing">Facing</label>
          <form:select path="facing" id="facing">
            <form:option value="" label="Select Facing"/>
            <c:forEach var="f" items="${facingOptions}">
              <form:option value="${f}" label="${f}"/>
            </c:forEach>
          </form:select>
        </div>
      </div>
    </div>

    <!-- ── SECTION 4: LOCATION ── -->
    <div class="card">
      <h3>4. Location</h3>
      <div class="grid2" style="margin-bottom:14px">
        <div class="frow">
          <label for="city">City *</label>
          <form:select path="city" id="city">
            <form:option value="" label="-- Select City --"/>
            <c:forEach var="ct" items="${cities}">
              <form:option value="${ct}" label="${ct}"/>
            </c:forEach>
          </form:select>
          <form:errors path="city" cssClass="field-err"/>
        </div>
        <div class="frow">
          <label for="state">State</label>
          <form:input path="state" id="state" placeholder="e.g. Maharashtra"/>
        </div>
      </div>
      <div style="display:grid;grid-template-columns:2fr 1fr;gap:16px">
        <div class="frow">
          <label for="location">Address / Locality *</label>
          <form:input path="location" id="location" placeholder="e.g. Bandra West, Near Linking Road"/>
          <form:errors path="location" cssClass="field-err"/>
        </div>
        <div class="frow">
          <label for="pincode">Pincode</label>
          <form:input path="pincode" id="pincode" placeholder="6-digit pincode"/>
          <form:errors path="pincode" cssClass="field-err"/>
        </div>
      </div>

      <!-- Hidden lat/lng (saved with form) -->
      <input type="hidden" name="latitude"  id="latInput" value="${propertyDto.latitude}"/>
      <input type="hidden" name="longitude" id="lngInput" value="${propertyDto.longitude}"/>

      <!-- Geocode button -->
      <button type="button" onclick="geocodeAddress()"
        style="margin-top:12px;padding:10px 20px;background:#f1f5f9;
               color:#374151;border:1px solid #d1d5db;border-radius:6px;
               font-size:13px;font-weight:600;cursor:pointer;">
        &#128205; Locate on Map
      </button>
      <div id="geocodeStatus" style="font-size:12px;color:#64748b;margin-top:6px;"></div>

      <!-- Map preview (hidden until geocoded) -->
      <div id="addPropertyMap"
           style="display:none;width:100%;height:260px;border-radius:8px;
                  border:1px solid #e5e7eb;margin-top:12px;"></div>
    </div>

    <!-- ── SECTION 5: AMENITIES & IMAGES ── -->
    <div class="card">
      <h3>5. Amenities &amp; Images</h3>

      <h4>Amenities Available</h4>
      <div class="amenity-grid">
        <label class="amenity-label"><form:checkbox path="hasGym"/> Gym</label>
        <label class="amenity-label"><form:checkbox path="hasSwimmingPool"/> Swimming Pool</label>
        <label class="amenity-label"><form:checkbox path="hasSecurity"/> 24x7 Security</label>
        <label class="amenity-label"><form:checkbox path="hasLift"/> Lift/Elevator</label>
        <label class="amenity-label"><form:checkbox path="hasPowerBackup"/> Power Backup</label>
        <label class="amenity-label"><form:checkbox path="hasClubHouse"/> Club House</label>
        <label class="amenity-label"><form:checkbox path="hasChildrenPlayArea"/> Children Play Area</label>
        <label class="amenity-label"><form:checkbox path="hasGarden"/> Garden</label>
        <label class="amenity-label"><form:checkbox path="hasIntercom"/> Intercom</label>
        <label class="amenity-label"><form:checkbox path="hasRainwaterHarvesting"/> Rainwater Harvesting</label>
        <label class="amenity-label"><form:checkbox path="hasWasteManagement"/> Waste Management</label>
        <label class="amenity-label"><form:checkbox path="hasVisitorParking"/> Visitor Parking</label>
      </div>

      <h4>Property Images <span style="color:#94a3b8;font-weight:400">(up to 10, max 5 MB each)</span></h4>
      <div class="upload-zone">
        <div class="upload-icon">📷</div>
        <p>Drag &amp; drop images here, or click to browse</p>
        <input type="file" name="images" multiple accept="image/*"
               id="imageInput" style="display:none" onchange="previewImages(this)">
        <button type="button" class="btn-choose" onclick="document.getElementById('imageInput').click()">
          Choose Images
        </button>
        <p class="upload-hint">JPG, PNG, WEBP | Max 5 MB each</p>
      </div>
      <div class="img-preview" id="imagePreview"></div>
    </div>

    <!-- Submit / Cancel -->
    <div class="action-bar">
      <a href="/agent/properties" class="btn-cancel">← Cancel</a>
      <button type="submit" class="btn-submit">Submit for Review →</button>
    </div>

  </form:form>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
/* ── Area Unit Converter Widget ────────────────────────────────── */
function convertToSqft() {
  var val  = parseFloat(document.getElementById('areaInput').value);
  var unit = document.getElementById('areaUnitSelect').value;
  var equiv = document.getElementById('sqftEquiv');
  var hidden = document.getElementById('areaHidden');

  if (!val || isNaN(val) || val <= 0 || !unit) {
    equiv.style.display = 'none';
    hidden.value = '';
    return;
  }

  if (unit === 'SQFT') {
    hidden.value = val;
    equiv.textContent = '= ' + val.toLocaleString('en-IN') + ' sq ft (stored)';
    equiv.style.display = 'block';
    return;
  }

  fetch('/api/v1/convert-area?value=' + val + '&fromUnit=' + unit + '&toUnit=SQFT')
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data && data.data) {
        var sqft = data.data.result;
        hidden.value = sqft;
        equiv.textContent = '= ' + parseFloat(sqft).toLocaleString('en-IN') + ' sq ft (stored for DB)';
        equiv.style.display = 'block';
        equiv.style.color = '#16a34a';
      }
    })
    .catch(function() { equiv.textContent = 'Conversion error.'; equiv.style.display = 'block'; });
}
</script>
<script>
function previewImages(input) {
  const preview = document.getElementById('imagePreview');
  preview.innerHTML = '';
  Array.from(input.files).slice(0, 10).forEach((file, i) => {
    const reader = new FileReader();
    reader.onload = e => {
      const div = document.createElement('div');
      div.style.cssText = 'position:relative;display:inline-block';
      div.innerHTML =
        '<img src="' + e.target.result + '" style="width:100px;height:80px;object-fit:cover;border-radius:7px;border:2px solid #e5e7eb">' +
        (i === 0 ? '<span style="position:absolute;bottom:4px;left:4px;background:#1a73e8;color:white;font-size:10px;padding:2px 6px;border-radius:3px">Primary</span>' : '');
      preview.appendChild(div);
    };
    reader.readAsDataURL(file);
  });
}

var addMap, addMarker;

function geocodeAddress() {
  var city = (document.getElementById('city') ? document.getElementById('city').value : '').trim();
  var address = (document.getElementById('location') ? document.getElementById('location').value : '').trim();
  var status = document.getElementById('geocodeStatus');

  if (!city && !address) {
    status.textContent = 'Please enter city or address first.';
    status.style.color = '#ef4444';
    return;
  }

  status.textContent = '&#128269; Finding location...';
  status.style.color = '#64748b';

  var query = address + ' ' + city + ' India';

  fetch('https://nominatim.openstreetmap.org/search?format=json&limit=1&q=' + encodeURIComponent(query),
        { headers: { 'Accept-Language': 'en' } })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (!data || !data.length) {
        status.textContent = '\u26a0\ufe0f Location not found. Try a more specific address.';
        status.style.color = '#ef4444';
        return;
      }
      var lat = parseFloat(data[0].lat);
      var lng = parseFloat(data[0].lon);
      document.getElementById('latInput').value = lat.toFixed(6);
      document.getElementById('lngInput').value = lng.toFixed(6);
      status.textContent = '\u2713 Location found: ' + data[0].display_name.substring(0, 80) + '...';
      status.style.color = '#16a34a';
      showAddPropertyMap(lat, lng);
    })
    .catch(function() {
      status.textContent = 'Geocoding failed. Please try again.';
      status.style.color = '#ef4444';
    });
}

function showAddPropertyMap(lat, lng) {
  var mapDiv = document.getElementById('addPropertyMap');
  mapDiv.style.display = 'block';

  if (!addMap) {
    addMap = L.map('addPropertyMap');
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(addMap);
  }

  addMap.setView([lat, lng], 15);

  if (addMarker) addMap.removeLayer(addMarker);
  addMarker = L.marker([lat, lng], { draggable: true })
    .addTo(addMap)
    .bindPopup('<div style="font-size:12px;">Drag to set exact location</div>')
    .openPopup();

  addMarker.on('dragend', function(e) {
    var pos = e.target.getLatLng();
    document.getElementById('latInput').value = pos.lat.toFixed(6);
    document.getElementById('lngInput').value = pos.lng.toFixed(6);
    document.getElementById('geocodeStatus').textContent =
      '\u2713 Position updated: ' + pos.lat.toFixed(4) + ', ' + pos.lng.toFixed(4);
  });

  setTimeout(function() { addMap.invalidateSize(); }, 100);
}
</script>
</body>
</html>
