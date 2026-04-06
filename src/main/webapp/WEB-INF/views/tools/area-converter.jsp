<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Area Unit Converter – PropNexium</title>
  <meta name="description" content="Convert between sq ft, sq mt, Bigha, Gunta, Cent and 20+ Indian area units with our free tool. State-specific local unit support for Gujarat, Maharashtra, UP and more.">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', sans-serif; background: #f0f4fb; color: #1e293b; min-height: 100vh; }

    /* ── Hero ─────────────────────────────────────────────── */
    .page-hero {
      background: linear-gradient(135deg, #0f4c8a 0%, #1a73e8 55%, #2196f3 100%);
      padding: 44px 24px 40px;
      text-align: center;
      color: white;
      position: relative;
      overflow: hidden;
    }
    .page-hero::before {
      content: '';
      position: absolute; inset: 0;
      background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.04'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
    }
    .page-hero h1 { font-size: 30px; font-weight: 800; margin-bottom: 8px; letter-spacing: -0.5px; position: relative; }
    .page-hero p  { font-size: 15px; opacity: 0.88; max-width: 540px; margin: 0 auto; position: relative; line-height: 1.55; }
    .hero-badge {
      display: inline-flex; align-items: center; gap: 6px;
      background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.3);
      border-radius: 20px; padding: 5px 14px; font-size: 12px; font-weight: 600;
      margin-bottom: 14px; position: relative;
    }

    /* ── Layout ───────────────────────────────────────────── */
    .page-wrap { max-width: 760px; margin: 0 auto; padding: 32px 20px 60px; }
    .breadcrumb { font-size: 13px; color: #94a3b8; margin-bottom: 24px; }
    .breadcrumb a { color: #1a73e8; text-decoration: none; }
    .breadcrumb a:hover { text-decoration: underline; }

    /* ── Converter Card ───────────────────────────────────── */
    .conv-card {
      background: white; border-radius: 18px;
      box-shadow: 0 4px 24px rgba(0,0,0,.1);
      overflow: hidden; margin-bottom: 24px;
    }
    .conv-card-head {
      background: linear-gradient(135deg, #f0f7ff, #e8f0fe);
      padding: 20px 28px 18px; border-bottom: 1px solid #e2e8f0;
    }
    .conv-card-head h2 { font-size: 16px; font-weight: 700; color: #1e293b; }
    .conv-card-head p  { font-size: 12px; color: #64748b; margin-top: 2px; }
    .conv-card-body  { padding: 28px; }

    /* ── State selector ───────────────────────────────────── */
    .state-row {
      display: flex; align-items: center; gap: 12px;
      background: #f8faff; border: 1px solid #e2e8f0;
      border-radius: 10px; padding: 14px 18px; margin-bottom: 22px;
    }
    .state-icon { font-size: 20px; }
    .state-row label { font-size: 13px; font-weight: 600; color: #475569; white-space: nowrap; }
    .state-row select {
      flex: 1; padding: 8px 12px; border: 1.5px solid #d1d5db; border-radius: 7px;
      font-size: 13px; font-family: inherit; background: white; color: #1e293b;
      outline: none; cursor: pointer; transition: border-color .18s;
    }
    .state-row select:focus { border-color: #1a73e8; }

    /* ── Conversion row ───────────────────────────────────── */
    .conv-row {
      display: grid; grid-template-columns: 1fr auto 1fr; gap: 14px;
      align-items: end; margin-bottom: 20px;
    }
    @media (max-width: 560px) { .conv-row { grid-template-columns: 1fr; } }
    .conv-equals { font-size: 22px; font-weight: 800; color: #1a73e8; text-align: center; padding-bottom: 6px; }
    .field-group label {
      display: block; font-size: 11px; font-weight: 700; color: #64748b;
      text-transform: uppercase; letter-spacing: .5px; margin-bottom: 6px;
    }
    .field-group input[type="number"] {
      width: 100%; padding: 12px 14px; border: 1.5px solid #d1d5db; border-radius: 9px;
      font-size: 16px; font-weight: 600; font-family: inherit; color: #1e293b;
      background: #fafbff; outline: none; transition: border-color .18s, box-shadow .18s;
    }
    .field-group input[type="number"]:focus {
      border-color: #1a73e8; box-shadow: 0 0 0 3px rgba(26,115,232,.12); background: white;
    }
    .field-group select {
      width: 100%; padding: 10px 12px; border: 1.5px solid #d1d5db; border-radius: 9px;
      font-size: 14px; font-family: inherit; color: #1e293b; background: white;
      outline: none; cursor: pointer; transition: border-color .18s; margin-top: 8px;
    }
    .field-group select:focus { border-color: #1a73e8; }

    /* Swap button */
    .swap-btn {
      width: 42px; height: 42px; border-radius: 50%;
      border: 2px solid #e2e8f0; background: white;
      display: flex; align-items: center; justify-content: center;
      cursor: pointer; font-size: 16px; margin: 0 auto 6px;
      transition: all .2s; color: #1a73e8;
    }
    .swap-btn:hover { background: #eff6ff; border-color: #1a73e8; transform: rotate(180deg); }

    /* Convert button */
    .btn-convert {
      width: 100%; padding: 14px; border: none; border-radius: 10px;
      background: linear-gradient(135deg, #1a73e8, #0d47a1);
      color: white; font-size: 16px; font-weight: 700; font-family: inherit;
      cursor: pointer; transition: opacity .2s, transform .15s;
      box-shadow: 0 4px 14px rgba(26,115,232,.35);
      display: flex; align-items: center; justify-content: center; gap: 8px;
    }
    .btn-convert:hover { opacity: .92; transform: translateY(-1px); }
    .btn-convert:active { transform: translateY(0); }

    /* ── Result card ──────────────────────────────────────── */
    #resultCard {
      display: none;
      background: linear-gradient(135deg, #0f4c8a 0%, #1a73e8 100%);
      border-radius: 14px; padding: 24px 28px; margin-top: 22px; color: white;
    }
    .result-main {
      font-size: 22px; font-weight: 800; margin-bottom: 6px; letter-spacing: -0.5px;
    }
    .result-sub { font-size: 13px; opacity: 0.8; margin-bottom: 18px; }
    .result-pills { display: flex; flex-wrap: wrap; gap: 10px; }
    .result-pill {
      background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25);
      border-radius: 8px; padding: 10px 16px; font-size: 13px; font-weight: 600;
      min-width: 140px;
    }
    .result-pill .pill-label { font-size: 10px; font-weight: 500; opacity: 0.75; margin-bottom: 3px; text-transform: uppercase; letter-spacing: .4px; }
    .result-pill .pill-val   { font-size: 16px; font-weight: 800; }

    /* Copy button */
    .btn-copy-result {
      display: inline-flex; align-items: center; gap: 6px;
      background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3);
      color: white; border-radius: 6px; padding: 6px 14px; font-size: 12px;
      font-weight: 600; cursor: pointer; margin-top: 14px; font-family: inherit;
      transition: background .2s;
    }
    .btn-copy-result:hover { background: rgba(255,255,255,0.3); }

    /* ── Quick Reference Table ────────────────────────────── */
    .ref-card {
      background: white; border-radius: 16px;
      box-shadow: 0 2px 16px rgba(0,0,0,.08);
      overflow: hidden; margin-bottom: 24px;
    }
    .ref-card-head {
      background: linear-gradient(135deg, #1e293b, #334155);
      padding: 18px 24px; color: white;
    }
    .ref-card-head h2 { font-size: 15px; font-weight: 700; }
    .ref-card-head p  { font-size: 12px; opacity: 0.7; margin-top: 2px; }
    .ref-table-wrap { overflow-x: auto; }
    table.ref-table { width: 100%; border-collapse: collapse; font-size: 13px; }
    table.ref-table thead th {
      background: #f8faff; color: #64748b; font-weight: 700; font-size: 11px;
      text-transform: uppercase; letter-spacing: .5px;
      padding: 12px 16px; text-align: right; border-bottom: 2px solid #e2e8f0;
    }
    table.ref-table thead th:first-child { text-align: left; }
    table.ref-table tbody tr { border-bottom: 1px solid #f1f5f9; transition: background .15s; }
    table.ref-table tbody tr:hover { background: #f8faff; }
    table.ref-table tbody td { padding: 12px 16px; text-align: right; color: #334155; }
    table.ref-table tbody td:first-child {
      text-align: left; font-weight: 600; color: #1e293b; white-space: nowrap;
    }
    .unit-tag {
      display: inline-block; background: #eff6ff; color: #1a73e8;
      border-radius: 4px; padding: 2px 8px; font-size: 11px; font-weight: 700;
      margin-left: 6px;
    }

    /* ── Info box ─────────────────────────────────────────── */
    .info-box {
      background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px;
      padding: 14px 18px; font-size: 13px; color: #92400e; margin-bottom: 22px;
      display: flex; gap: 10px; align-items: flex-start;
    }
    .info-box svg { flex-shrink: 0; margin-top: 1px; }

    /* ── Animations ───────────────────────────────────────── */
    @keyframes slideIn {
      from { opacity: 0; transform: translateY(12px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    .slide-in { animation: slideIn .3s ease forwards; }

    @keyframes pulse-border {
      0%, 100% { box-shadow: 0 0 0 0 rgba(26,115,232,.4); }
      50%       { box-shadow: 0 0 0 6px rgba(26,115,232,0); }
    }
    .input-flash { animation: pulse-border .5s ease; }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/navbar.jsp" %>

<!-- Hero -->
<div class="page-hero">
  <h1>&#128207; Area Unit Converter</h1>
  <p>Convert between sq ft, sq mt, Bigha, Gunta, Cent and 20+ Indian area units — with state-specific local unit support</p>
</div>

<div class="page-wrap">
  <div class="breadcrumb">
    <a href="/">Home</a> &#8250; <a href="/tools/area-converter">Area Converter</a>
  </div>

  <!-- Info -->
  <div class="info-box">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <span>Select your <strong>state</strong> to load region-specific units like Bigha, Katha, Guntha, Ankanam and more. Units are filtered by state by default.</span>
  </div>

  <!-- Main Converter Card -->
  <div class="conv-card">
    <div class="conv-card-head">
      <h2>&#9654;&#65038; Live Converter</h2>
      <p>Results update as you type — no page reload needed</p>
    </div>
    <div class="conv-card-body">

      <!-- State Selector -->
      <div class="state-row">
        <span class="state-icon">&#127988;</span>
        <label for="stateSelect">State</label>
        <select id="stateSelect" onchange="loadStateUnits()">
          <option value="">All Units (no state filter)</option>
          <c:forEach var="s" items="${states}">
            <option value="${s}">${s}</option>
          </c:forEach>
        </select>
      </div>

      <!-- Conversion Inputs -->
      <div class="conv-row">
        <!-- FROM -->
        <div class="field-group">
          <label for="areaValue">Value</label>
          <input type="number" id="areaValue" placeholder="e.g. 100" min="0" step="any"
                 oninput="liveConvert()">
          <select id="fromUnit" onchange="liveConvert()">
            <option value="SQMT">sq mt</option>
            <option value="SQFT">sq ft</option>
            <option value="SQYD">sq yd</option>
            <option value="ACRE">Acre</option>
            <option value="HECTARE">Hectare</option>
          </select>
        </div>

        <!-- Swap / Equals -->
        <div style="text-align:center">
          <button class="swap-btn" onclick="swapUnits()" title="Swap units">&#8646;</button>
          <div class="conv-equals">=</div>
        </div>

        <!-- TO -->
        <div class="field-group">
          <label for="resultDisplay">Result</label>
          <input type="number" id="resultDisplay" placeholder="—" readonly
                 style="background:#f0f7ff;color:#1a73e8;font-weight:800;border-color:#c7d7fc;">
          <select id="toUnit" onchange="liveConvert()">
            <option value="SQFT">sq ft</option>
            <option value="SQMT">sq mt</option>
            <option value="SQYD">sq yd</option>
            <option value="ACRE">Acre</option>
            <option value="HECTARE">Hectare</option>
          </select>
        </div>
      </div>

      <!-- Convert button -->
      <button class="btn-convert" id="convertBtn" onclick="convertArea()">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><polyline points="1 4 1 10 7 10"/><polyline points="23 20 23 14 17 14"/><path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4l-4.64 4.36A9 9 0 0 1 3.51 15"/></svg>
        Convert
      </button>

      <!-- Result Card -->
      <div id="resultCard">
        <div class="result-main" id="resultMainText">—</div>
        <div class="result-sub" id="resultSubText">Also equivalent to:</div>
        <div class="result-pills">
          <div class="result-pill">
            <div class="pill-label">Square Feet</div>
            <div class="pill-val" id="inSqft">—</div>
          </div>
          <div class="result-pill">
            <div class="pill-label">Square Meters</div>
            <div class="pill-val" id="inSqmt">—</div>
          </div>
          <div class="result-pill">
            <div class="pill-label">Acres</div>
            <div class="pill-val" id="inAcre">—</div>
          </div>
        </div>
        <button class="btn-copy-result" onclick="copyResult()">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
          <span id="copyBtnText">Copy Result</span>
        </button>
      </div>

    </div><!-- /conv-card-body -->
  </div><!-- /conv-card -->

  <!-- Quick Reference Table -->
  <div class="ref-card">
    <div class="ref-card-head">
      <h2>&#128218; Common Area Conversions — Quick Reference</h2>
      <p>Standard conversion values for 1 unit of each measure</p>
    </div>
    <div class="ref-table-wrap">
      <table class="ref-table">
        <thead>
          <tr>
            <th>Unit <span style="font-weight:400;opacity:.6">(1 unit)</span></th>
            <th>Sq Ft</th>
            <th>Sq Mt</th>
            <th>Acres</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>1 Sq Foot <span class="unit-tag">Universal</span></td>
            <td>1</td>
            <td>0.0929</td>
            <td>0.000023</td>
          </tr>
          <tr>
            <td>1 Sq Meter <span class="unit-tag">Universal</span></td>
            <td>10.764</td>
            <td>1</td>
            <td>0.000247</td>
          </tr>
          <tr>
            <td>1 Sq Yard <span class="unit-tag">Universal</span></td>
            <td>9</td>
            <td>0.836</td>
            <td>0.000207</td>
          </tr>
          <tr>
            <td>1 Acre <span class="unit-tag">Universal</span></td>
            <td>43,560</td>
            <td>4,047</td>
            <td>1</td>
          </tr>
          <tr>
            <td>1 Hectare <span class="unit-tag">Universal</span></td>
            <td>1,07,639</td>
            <td>10,000</td>
            <td>2.471</td>
          </tr>
          <tr>
            <td>1 Bigha (North) <span class="unit-tag">UP/Bihar/RJ</span></td>
            <td>27,000</td>
            <td>2,508.4</td>
            <td>0.620</td>
          </tr>
          <tr>
            <td>1 Bigha (Gujarat) <span class="unit-tag">GJ/RJ</span></td>
            <td>17,424</td>
            <td>1,618.7</td>
            <td>0.400</td>
          </tr>
          <tr>
            <td>1 Biswa <span class="unit-tag">North India</span></td>
            <td>1,350</td>
            <td>125.4</td>
            <td>0.031</td>
          </tr>
          <tr>
            <td>1 Katha (Bihar) <span class="unit-tag">Bihar</span></td>
            <td>1,361</td>
            <td>126.5</td>
            <td>0.031</td>
          </tr>
          <tr>
            <td>1 Katha (WB/UP) <span class="unit-tag">WB/UP</span></td>
            <td>720</td>
            <td>66.9</td>
            <td>0.017</td>
          </tr>
          <tr>
            <td>1 Guntha <span class="unit-tag">Maharashtra</span></td>
            <td>1,089</td>
            <td>101.2</td>
            <td>0.025</td>
          </tr>
          <tr>
            <td>1 Are <span class="unit-tag">Maharashtra</span></td>
            <td>1,076.4</td>
            <td>100</td>
            <td>0.025</td>
          </tr>
          <tr>
            <td>1 Ankanam <span class="unit-tag">Karnataka/AP</span></td>
            <td>72</td>
            <td>6.69</td>
            <td>0.0017</td>
          </tr>
          <tr>
            <td>1 Gunta <span class="unit-tag">South India</span></td>
            <td>1,089</td>
            <td>101.2</td>
            <td>0.025</td>
          </tr>
          <tr>
            <td>1 Cent <span class="unit-tag">South India</span></td>
            <td>435.6</td>
            <td>40.5</td>
            <td>0.01</td>
          </tr>
          <tr>
            <td>1 Ground <span class="unit-tag">TN/KL/KA</span></td>
            <td>2,400</td>
            <td>222.9</td>
            <td>0.055</td>
          </tr>
          <tr>
            <td>1 Kuzhi <span class="unit-tag">Tamil Nadu</span></td>
            <td>144</td>
            <td>13.4</td>
            <td>0.003</td>
          </tr>
          <tr>
            <td>1 Vigha <span class="unit-tag">Gujarat</span></td>
            <td>17,424</td>
            <td>1,618.7</td>
            <td>0.400</td>
          </tr>
          <tr>
            <td>1 Vara <span class="unit-tag">Gujarat</span></td>
            <td>9</td>
            <td>0.836</td>
            <td>0.000207</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

</div><!-- /page-wrap -->

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
/* ═══════════════════════════════════════════════════════════════
   Area Unit Converter — JavaScript
   ═══════════════════════════════════════════════════════════════ */

// Default full unit list (shown when no state selected)
var DEFAULT_UNITS = [
  {key:'SQFT',        name:'sq ft'},
  {key:'SQMT',        name:'sq mt'},
  {key:'SQYD',        name:'sq yd'},
  {key:'ACRE',        name:'Acre'},
  {key:'HECTARE',     name:'Hectare'},
  {key:'BIGHA_NORTH', name:'Bigha (North)'},
  {key:'BISWA',       name:'Biswa'},
  {key:'KATHA_BIHAR', name:'Katha (Bihar)'},
  {key:'KATHA_WB',    name:'Katha (WB/UP)'},
  {key:'BIGHA_GUJARAT',name:'Bigha (Gujarat)'},
  {key:'VIGHA',       name:'Vigha'},
  {key:'VARA',        name:'Vara (Guj)'},
  {key:'GUNTHA',      name:'Guntha'},
  {key:'ARE',         name:'Are'},
  {key:'ANKANAM',     name:'Ankanam'},
  {key:'CENT',        name:'Cent'},
  {key:'GROUND',      name:'Ground'},
  {key:'GUNTA',       name:'Gunta'},
  {key:'CENT_TN',     name:'Cent (TN)'},
  {key:'KUZHI',       name:'Kuzhi'}
];

// ── Load state units ─────────────────────────────────────────
function loadStateUnits() {
  var state = document.getElementById('stateSelect').value;
  if (!state) {
    populateUnitDropdowns(DEFAULT_UNITS);
    return;
  }
  fetch('/api/v1/area-units-for-state?state=' + encodeURIComponent(state))
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data && data.data) {
        populateUnitDropdowns(data.data);
      }
    })
    .catch(function() { populateUnitDropdowns(DEFAULT_UNITS); });
}

function populateUnitDropdowns(units) {
  var fromSel = document.getElementById('fromUnit');
  var toSel   = document.getElementById('toUnit');
  var fromVal = fromSel.value;
  var toVal   = toSel.value;

  var opts = units.map(function(u) {
    return '<option value="' + u.key + '">' + u.name + '</option>';
  }).join('');

  fromSel.innerHTML = opts;
  toSel.innerHTML   = opts;

  // Try to preserve existing values, otherwise use smart defaults
  if (fromSel.querySelector('option[value="' + fromVal + '"]')) {
    fromSel.value = fromVal;
  } else {
    fromSel.value = units.find(function(u) { return u.key === 'SQMT'; }) ? 'SQMT' : units[0].key;
  }
  if (toSel.querySelector('option[value="' + toVal + '"]')) {
    toSel.value = toVal;
  } else {
    toSel.value = units.find(function(u) { return u.key === 'SQFT'; }) ? 'SQFT' : units[Math.min(1, units.length-1)].key;
  }

  liveConvert();
}

// ── Live convert (as you type) ────────────────────────────────
var _liveTimer;
function liveConvert() {
  clearTimeout(_liveTimer);
  _liveTimer = setTimeout(function() {
    var val = parseFloat(document.getElementById('areaValue').value);
    if (!val || isNaN(val) || val <= 0) {
      document.getElementById('resultDisplay').value = '';
      return;
    }
    var from = document.getElementById('fromUnit').value;
    var to   = document.getElementById('toUnit').value;
    doFetchConvert(val, from, to, function(data) {
      document.getElementById('resultDisplay').value = data.result;
    });
  }, 300);
}

// ── Full convert (button click) ───────────────────────────────
function convertArea() {
  var val  = parseFloat(document.getElementById('areaValue').value);
  var from = document.getElementById('fromUnit').value;
  var to   = document.getElementById('toUnit').value;

  if (!val || isNaN(val) || val <= 0) {
    flashInput('areaValue');
    return;
  }
  if (!from || !to) return;

  var btn = document.getElementById('convertBtn');
  btn.disabled = true;
  btn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" style="animation:spin .8s linear infinite"><polyline points="1 4 1 10 7 10"/><polyline points="23 20 23 14 17 14"/><path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4l-4.64 4.36A9 9 0 0 1 3.51 15"/></svg> Converting...';

  doFetchConvert(val, from, to, function(data) {
    btn.disabled = false;
    btn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><polyline points="1 4 1 10 7 10"/><polyline points="23 20 23 14 17 14"/><path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4l-4.64 4.36A9 9 0 0 1 3.51 15"/></svg> Convert';

    var fromName = document.getElementById('fromUnit').options[document.getElementById('fromUnit').selectedIndex].text;
    var toName   = document.getElementById('toUnit').options[document.getElementById('toUnit').selectedIndex].text;

    document.getElementById('resultDisplay').value = data.result;
    document.getElementById('resultMainText').textContent =
      formatNum(val) + ' ' + fromName + ' = ' + formatNum(data.result) + ' ' + toName;
    document.getElementById('resultSubText').textContent = 'Also equivalent to:';
    document.getElementById('inSqft').textContent = formatNum(data.inSqft) + ' sq ft';
    document.getElementById('inSqmt').textContent = formatNum(data.inSqmt) + ' sq mt';
    document.getElementById('inAcre').textContent = data.inAcre + ' Acres';

    var card = document.getElementById('resultCard');
    card.style.display = 'block';
    card.classList.remove('slide-in');
    void card.offsetWidth;
    card.classList.add('slide-in');
  });
}

function doFetchConvert(val, from, to, callback) {
  fetch('/api/v1/convert-area?value=' + val + '&fromUnit=' + from + '&toUnit=' + to)
    .then(function(r) { return r.json(); })
    .then(function(resp) {
      if (resp && resp.data) callback(resp.data);
    })
    .catch(function(e) { console.error('Conversion error', e); });
}

// ── Swap units ────────────────────────────────────────────────
function swapUnits() {
  var from = document.getElementById('fromUnit');
  var to   = document.getElementById('toUnit');
  var tmp  = from.value;
  from.value = to.value;
  to.value   = tmp;
  liveConvert();
}

// ── Copy result ───────────────────────────────────────────────
function copyResult() {
  var txt = document.getElementById('resultMainText').textContent;
  if (!txt || txt === '—') return;
  navigator.clipboard.writeText(txt).then(function() {
    var btn = document.getElementById('copyBtnText');
    btn.textContent = '✓ Copied!';
    setTimeout(function() { btn.textContent = 'Copy Result'; }, 2000);
  });
}

// ── Helpers ───────────────────────────────────────────────────
function formatNum(n) {
  if (n == null || isNaN(n)) return '—';
  var num = parseFloat(n);
  if (num >= 1000) return num.toLocaleString('en-IN');
  return num % 1 === 0 ? num.toString() : num.toFixed(4).replace(/\.?0+$/, '');
}

function flashInput(id) {
  var el = document.getElementById(id);
  el.classList.remove('input-flash');
  void el.offsetWidth;
  el.classList.add('input-flash');
  el.focus();
}

// ── Spin animation for button ─────────────────────────────────
var style = document.createElement('style');
style.textContent = '@keyframes spin { from{transform:rotate(0)} to{transform:rotate(360deg)} }';
document.head.appendChild(style);

// Init
document.addEventListener('DOMContentLoaded', function() {
  populateUnitDropdowns(DEFAULT_UNITS);
  // Set smart defaults
  document.getElementById('fromUnit').value = 'SQMT';
  document.getElementById('toUnit').value   = 'SQFT';
});
</script>
</body>
</html>
