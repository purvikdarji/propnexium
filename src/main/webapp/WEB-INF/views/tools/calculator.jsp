<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${_csrf.token}" />
    <meta name="_csrf_header" content="${_csrf.headerName}" />
    <title>Mortgage & Loan Calculator – PropNexium</title>
    <meta name="description" content="Calculate your home loan EMI, check loan eligibility, view amortization schedules and compare bank rates with PropNexium's free mortgage calculator.">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: #f0f4fb; color: #1e293b; min-height: 100vh; }

        .page-hero {
            background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 50%, #1565c0 100%);
            padding: 36px 30px 32px;
            color: white;
            text-align: center;
        }
        .page-hero h1 { font-size: 28px; font-weight: 800; margin-bottom: 6px; letter-spacing: -0.5px; }
        .page-hero p  { font-size: 14px; opacity: 0.85; max-width: 520px; margin: 0 auto; }

        .page-wrap { max-width: 1200px; margin: 0 auto; padding: 28px 24px 60px; }

        /* ── Section tabs ── */
        .section-tabs {
            display: flex; gap: 8px; margin-bottom: 24px;
            background: white; padding: 6px; border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,.08);
        }
        .tab-btn {
            flex: 1; padding: 10px 8px; border: none; border-radius: 8px;
            background: transparent; font-family: inherit; font-size: 13px;
            font-weight: 600; color: #64748b; cursor: pointer;
            transition: all .2s;
        }
        .tab-btn.active {
            background: linear-gradient(135deg, #1a73e8, #0d47a1);
            color: white; box-shadow: 0 2px 8px rgba(26,115,232,.4);
        }
        .tab-btn:hover:not(.active) { background: #f0f4ff; color: #1a73e8; }

        /* ── Two-column calculator grid ── */
        .calc-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            align-items: start;
        }
        @media (max-width: 768px) { .calc-grid { grid-template-columns: 1fr; } }

        /* ── Panels ── */
        .panel {
            background: white; border-radius: 14px;
            padding: 24px; box-shadow: 0 2px 14px rgba(0,0,0,.08);
        }
        .panel-title {
            font-size: 15px; font-weight: 700; color: #1e293b;
            margin-bottom: 20px; padding-bottom: 12px;
            border-bottom: 2px solid #f0f4ff;
            display: flex; align-items: center; gap: 8px;
        }

        /* ── Inputs ── */
        .field { margin-bottom: 18px; }
        .field label {
            display: block; font-size: 12px; font-weight: 600;
            color: #64748b; margin-bottom: 6px; text-transform: uppercase;
            letter-spacing: .4px;
        }
        .field input[type="number"],
        .field input[type="text"] {
            width: 100%; padding: 11px 14px; border: 1.5px solid #e2e8f0;
            border-radius: 8px; font-size: 14px; font-family: inherit;
            outline: none; transition: border-color .2s; color: #1e293b;
            background: #fafbff;
        }
        .field input[type="number"]:focus,
        .field input[type="text"]:focus { border-color: #1a73e8; background: white; }
        .field input[type="number"][readonly] {
            background: #f0f4ff; color: #1a73e8; font-weight: 700;
            border-color: #c7d7fc;
        }

        .field input[type="range"] {
            width: 100%; accent-color: #1a73e8; margin-top: 6px;
            height: 5px; cursor: pointer;
        }
        .slider-row {
            display: flex; justify-content: space-between; align-items: center;
            margin-top: 4px;
        }
        .slider-val {
            font-size: 14px; font-weight: 700; color: #1a73e8;
            background: #eff6ff; padding: 3px 10px; border-radius: 20px;
        }
        .slider-hint { font-size: 11px; color: #94a3b8; }

        /* ── Result Cards ── */
        .result-hero {
            background: linear-gradient(135deg, #1a73e8, #0d47a1);
            border-radius: 12px; padding: 20px; text-align: center;
            color: white; margin-bottom: 16px;
        }
        .result-hero .label { font-size: 12px; font-weight: 500; opacity: 0.85; margin-bottom: 6px; }
        .result-hero .value { font-size: 34px; font-weight: 800; letter-spacing: -1px; }

        .result-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 11px 14px; border-radius: 8px; margin-bottom: 8px;
            background: #f8faff;
        }
        .result-row .rl { font-size: 13px; color: #64748b; font-weight: 500; }
        .result-row .rv { font-size: 14px; font-weight: 700; color: #1e293b; }
        .result-row .rv.red   { color: #ef4444; }
        .result-row .rv.green { color: #22c55e; }
        .result-row .rv.blue  { color: #1a73e8; }

        /* ── result hero colours variants ── */
        .result-hero.green-hero {
            background: linear-gradient(135deg, #22c55e, #15803d);
        }

        /* ── Pie chart ── */
        .chart-wrap { margin-top: 16px; max-width: 220px; margin-left: auto; margin-right: auto; }

        /* ── Eligibility badge ── */
        #eligBadge {
            display: inline-block; padding: 8px 18px; border-radius: 24px;
            font-size: 13px; font-weight: 800; letter-spacing: .3px;
            margin-top: 12px; width: 100%; text-align: center;
            transition: all .3s;
        }

        /* ── Amortization Table ── */
        .amort-table-wrap { overflow-x: auto; margin-top: 4px; }
        table.amort-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        table.amort-table thead th {
            background: #f0f4ff; color: #64748b; font-weight: 700;
            padding: 10px 12px; text-align: center; font-size: 12px;
            text-transform: uppercase; letter-spacing: .4px;
        }
        table.amort-table tbody tr { transition: background .15s; }
        table.amort-table tbody tr:hover { background: #f8faff; }

        #showAllYears {
            margin-top: 14px; width: 100%; padding: 11px;
            border: 1.5px solid #1a73e8; color: #1a73e8;
            background: white; border-radius: 8px; cursor: pointer;
            font-family: inherit; font-size: 13px; font-weight: 700;
            transition: all .2s;
        }
        #showAllYears:hover { background: #eff6ff; }

        /* ── Bank Comparison Table ── */
        .bank-table-wrap { overflow-x: auto; }
        table.bank-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        table.bank-table thead th {
            background: #1a73e8; color: white; font-weight: 700;
            padding: 12px 16px; text-align: left; font-size: 12px;
            text-transform: uppercase; letter-spacing: .4px;
        }
        table.bank-table thead th:first-child { border-radius: 8px 0 0 0; }
        table.bank-table thead th:last-child  { border-radius: 0 8px 0 0; }
        table.bank-table tbody tr { border-bottom: 1px solid #f1f5f9; transition: background .15s; }
        table.bank-table tbody tr:hover { background: #f0f4ff; }
        table.bank-table tbody td { padding: 12px 16px; color: #334155; }
        table.bank-table tbody td:first-child { font-weight: 600; color: #1e293b; }
        .rate-badge {
            display: inline-block; padding: 3px 10px; border-radius: 4px;
            background: #dcfce7; color: #16a34a; font-weight: 700; font-size: 12px;
        }
        .bank-disclaimer {
            font-size: 11px; color: #94a3b8; margin-top: 12px;
            padding: 10px 14px; background: #fffbeb; border-radius: 8px;
            border-left: 3px solid #f59e0b;
        }

        /* ── Section containers ── */
        .section-block { display: none; }
        .section-block.active { display: block; }

        /* ── Full-width layout for amort & bank tables ── */
        .wide-panel {
            grid-column: 1 / -1;
        }

        /* ── Animated number change ── */
        @keyframes pop { 0%{transform:scale(1.1)} 100%{transform:scale(1)} }
        .pop { animation: pop .25s ease; }

        /* breadcrumb */
        .breadcrumb { font-size: 13px; color: #94a3b8; margin-bottom: 20px; }
        .breadcrumb a { color: #1a73e8; text-decoration: none; }
        .breadcrumb a:hover { text-decoration: underline; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/navbar.jsp" %>

<!-- Hero -->
<div class="page-hero">
    <h1>🏦 Mortgage & Loan Calculator</h1>
    <p>Plan your home purchase with EMI estimation, eligibility check, amortization schedule & bank rate comparison</p>
</div>

<div class="page-wrap">
    <div class="breadcrumb">
        <a href="/">Home</a> › <a href="/properties">Properties</a> › Calculator
    </div>

    <!-- Section Tabs -->
    <div class="section-tabs">
        <button class="tab-btn active" onclick="showSection('emi', this)">📊 EMI Calculator</button>
        <button class="tab-btn" onclick="showSection('eligibility', this)">✅ Loan Eligibility</button>
        <button class="tab-btn" onclick="showSection('amortization', this)">📅 Amortization</button>
        <button class="tab-btn" onclick="showSection('banks', this)">🏦 Compare Banks</button>
    </div>

    <!-- ═══════════ SECTION 1: EMI CALCULATOR ═══════════ -->
    <div id="sec-emi" class="section-block active">
        <div class="calc-grid">
            <!-- Left: Inputs -->
            <div class="panel">
                <div class="panel-title">📊 EMI Calculator Inputs</div>

                <div class="field">
                    <label>Property Price (₹)</label>
                    <input type="number" id="propPrice" placeholder="e.g. 5000000" min="0" step="10000"
                           value="<c:choose><c:when test='${not empty param.price}'>${param.price}</c:when><c:otherwise>5000000</c:otherwise></c:choose>">
                    <div style="font-size:11px;color:#94a3b8;margin-top:4px;">Enter amount in Indian Rupees (e.g. 50,00,000 for 50 Lakhs)</div>
                </div>

                <div class="field">
                    <label>Down Payment — <span id="dpPctLbl">20</span>% &nbsp;<span id="downPayAmt" class="slider-val" style="font-size:12px;">₹10,00,000</span></label>
                    <input type="range" id="downPayPct" min="10" max="50" value="20" step="1"
                           oninput="document.getElementById('dpPctLbl').textContent=this.value;updateCalculator()">
                    <div class="slider-row">
                        <span class="slider-hint">10%</span>
                        <span class="slider-hint">50%</span>
                    </div>
                </div>

                <div class="field">
                    <label>Loan Amount (Auto-calculated)</label>
                    <input type="number" id="loanAmtDisplay" readonly placeholder="Auto-calculated">
                </div>

                <div class="field">
                    <label>Interest Rate — <span id="rateLbl">8.5</span>% p.a.</label>
                    <input type="range" id="interestRate" min="6.5" max="15" value="8.5" step="0.1"
                           oninput="document.getElementById('rateLbl').textContent=parseFloat(this.value).toFixed(1);updateCalculator()">
                    <div class="slider-row">
                        <span class="slider-hint">6.5%</span>
                        <span class="slider-hint">15%</span>
                    </div>
                </div>

                <div class="field">
                    <label>Loan Tenure — <span id="tenureLbl">20</span> Years</label>
                    <input type="range" id="tenure" min="5" max="30" value="20" step="1"
                           oninput="document.getElementById('tenureLbl').textContent=this.value;updateCalculator()">
                    <div class="slider-row">
                        <span class="slider-hint">5 yrs</span>
                        <span class="slider-hint">30 yrs</span>
                    </div>
                </div>
            </div>

            <!-- Right: Results -->
            <div class="panel">
                <div class="panel-title">💰 Loan Breakdown</div>

                <div class="result-hero">
                    <div class="label">Monthly EMI</div>
                    <div class="value" id="emiResult">₹0</div>
                </div>

                <div class="result-row">
                    <span class="rl">💙 Principal Amount</span>
                    <span class="rv blue" id="principalAmt">₹0</span>
                </div>
                <div class="result-row">
                    <span class="rl">🔴 Total Interest Payable</span>
                    <span class="rv red" id="totalInterest">₹0</span>
                </div>
                <div class="result-row">
                    <span class="rl" style="font-weight:700;color:#1e293b;">💳 Total Amount Payable</span>
                    <span class="rv" id="totalPayable" style="font-size:15px;">₹0</span>
                </div>
                <div class="result-row">
                    <span class="rl">⬇️ Down Payment</span>
                    <span class="rv green" id="downPayAmtResult">₹0</span>
                </div>

                <div class="chart-wrap">
                    <canvas id="emiPieChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════════ SECTION 2: LOAN ELIGIBILITY ═══════════ -->
    <div id="sec-eligibility" class="section-block">
        <div class="calc-grid">
            <!-- Left -->
            <div class="panel">
                <div class="panel-title">✅ Eligibility Inputs</div>

                <div class="field">
                    <label>Monthly Income (₹)</label>
                    <input type="number" id="monthlyIncome" placeholder="e.g. 80000" min="0" step="1000"
                           oninput="updateEligibility()">
                </div>
                <div class="field">
                    <label>Monthly Existing EMIs (₹)</label>
                    <input type="number" id="existingEmis" placeholder="e.g. 5000 (other loans)" min="0" step="500" value="0"
                           oninput="updateEligibility()">
                    <div style="font-size:11px;color:#94a3b8;margin-top:4px;">Combined EMI of all existing loans currently paying</div>
                </div>
                <div class="field">
                    <label>Interest Rate — <span id="eligRateLbl">8.5</span>% p.a.</label>
                    <input type="range" id="eligRate" min="6.5" max="15" value="8.5" step="0.1"
                           oninput="document.getElementById('eligRateLbl').textContent=parseFloat(this.value).toFixed(1);updateEligibility()">
                    <div class="slider-row">
                        <span class="slider-hint">6.5%</span>
                        <span class="slider-hint">15%</span>
                    </div>
                </div>
                <div class="field">
                    <label>Loan Tenure — <span id="eligTenureLbl">20</span> Years</label>
                    <input type="range" id="eligTenure" min="5" max="30" value="20" step="1"
                           oninput="document.getElementById('eligTenureLbl').textContent=this.value;updateEligibility()">
                    <div class="slider-row">
                        <span class="slider-hint">5 yrs</span>
                        <span class="slider-hint">30 yrs</span>
                    </div>
                </div>
                <div class="field">
                    <label>Target Property Price (₹) — Optional</label>
                    <input type="number" id="targetPrice" placeholder="e.g. 5000000 (to check eligibility)"
                           min="0" step="10000" oninput="updateEligibility()">
                </div>

                <div style="background:#eff6ff;border-radius:8px;padding:14px;font-size:12px;color:#1e40af;border-left:3px solid #1a73e8;">
                    💡 <strong>Formula:</strong> Banks allow max <strong>40%</strong> of net monthly income for all EMIs combined.<br>
                    <code style="font-size:11px;">Max EMI = (Income × 40%) − Existing EMIs</code>
                </div>
            </div>

            <!-- Right -->
            <div class="panel">
                <div class="panel-title">🎯 Eligibility Results</div>

                <div class="result-hero green-hero">
                    <div class="label">Maximum Loan Eligible</div>
                    <div class="value" id="maxLoan">₹0</div>
                </div>

                <div class="result-row">
                    <span class="rl">💰 Max Affordable EMI/month</span>
                    <span class="rv green" id="maxAffordableEMI">₹0</span>
                </div>
                <div class="result-row">
                    <span class="rl">📊 40% of Monthly Income</span>
                    <span class="rv blue" id="fortyPctIncome">₹0</span>
                </div>

                <div id="eligResult" style="margin-top:12px;font-size:13px;color:#64748b;min-height:20px;">
                    Enter your monthly income to calculate eligibility.
                </div>

                <div id="eligBadge" style="background:#f1f5f9;color:#94a3b8;display:none;">
                    Enter Target Price to Check
                </div>

                <!-- Eligibility meter -->
                <div id="eligMeterWrap" style="display:none;margin-top:16px;">
                    <div style="font-size:12px;color:#64748b;margin-bottom:6px;font-weight:600;">Eligibility Coverage</div>
                    <div style="height:10px;background:#f1f5f9;border-radius:20px;overflow:hidden;">
                        <div id="eligMeterBar" style="height:100%;background:linear-gradient(90deg,#22c55e,#15803d);border-radius:20px;transition:width .5s;width:0;"></div>
                    </div>
                    <div style="display:flex;justify-content:space-between;margin-top:4px;">
                        <span style="font-size:11px;color:#94a3b8;">0%</span>
                        <span id="eligMeterPct" style="font-size:12px;font-weight:700;color:#1a73e8;">0%</span>
                        <span style="font-size:11px;color:#94a3b8;">100%+</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════════ SECTION 3: AMORTIZATION ═══════════ -->
    <div id="sec-amortization" class="section-block">
        <div class="panel">
            <div class="panel-title">📅 Year-by-Year Amortization Schedule</div>
            <div style="font-size:12px;color:#94a3b8;margin-bottom:16px;">
                Based on EMI Calculator inputs above — update values there and revisit this tab.
            </div>
            <div class="amort-table-wrap">
                <table class="amort-table" id="amortTable">
                    <thead>
                        <tr>
                            <th>Year</th>
                            <th>Opening Balance</th>
                            <th>Principal Paid</th>
                            <th>Interest Paid</th>
                            <th>Closing Balance</th>
                            <th>% Repaid</th>
                        </tr>
                    </thead>
                    <tbody id="amortBody">
                        <tr><td colspan="6" style="padding:30px;text-align:center;color:#94a3b8;">
                            Go to <strong>EMI Calculator</strong> tab, enter property price, then return here.
                        </td></tr>
                    </tbody>
                </table>
            </div>
            <button id="showAllYears" data-show="false" onclick="toggleShowAllYears()">
                ▼ Show All Years
            </button>
        </div>
    </div>

    <!-- ═══════════ SECTION 4: BANK COMPARISON ═══════════ -->
    <div id="sec-banks" class="section-block">
        <div class="panel">
            <div class="panel-title">🏦 Compare Indian Bank Home Loan Rates</div>
            <div class="bank-table-wrap">
                <table class="bank-table">
                    <thead>
                        <tr>
                            <th>Bank / Lender</th>
                            <th>Approx Rate</th>
                            <th>Processing Fee</th>
                            <th>Max Tenure</th>
                            <th>EMI / ₹10L (20 yrs)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>🏛️ SBI Home Loan</td>
                            <td><span class="rate-badge">8.40% p.a.</span></td>
                            <td>0.35%</td>
                            <td>30 years</td>
                            <td>₹8,612</td>
                        </tr>
                        <tr>
                            <td>🏦 HDFC Bank</td>
                            <td><span class="rate-badge">8.50% p.a.</span></td>
                            <td>0.50%</td>
                            <td>30 years</td>
                            <td>₹8,678</td>
                        </tr>
                        <tr>
                            <td>🏦 ICICI Bank</td>
                            <td><span class="rate-badge">8.75% p.a.</span></td>
                            <td>0.50%</td>
                            <td>30 years</td>
                            <td>₹8,847</td>
                        </tr>
                        <tr>
                            <td>🏛️ LIC Housing Finance</td>
                            <td><span class="rate-badge">8.35% p.a.</span></td>
                            <td>0.25%</td>
                            <td>30 years</td>
                            <td>₹8,579</td>
                        </tr>
                        <tr>
                            <td>🏦 PNB Housing Finance</td>
                            <td><span class="rate-badge">8.50% p.a.</span></td>
                            <td>0.50%</td>
                            <td>25 years</td>
                            <td>₹8,678</td>
                        </tr>
                        <tr>
                            <td>🏛️ Bank of Baroda</td>
                            <td><span class="rate-badge">8.40% p.a.</span></td>
                            <td>0.25%</td>
                            <td>30 years</td>
                            <td>₹8,612</td>
                        </tr>
                        <tr>
                            <td>🏦 Axis Bank</td>
                            <td><span class="rate-badge">8.75% p.a.</span></td>
                            <td>1.00%</td>
                            <td>30 years</td>
                            <td>₹8,847</td>
                        </tr>
                        <tr>
                            <td>🏛️ Kotak Mahindra Bank</td>
                            <td><span class="rate-badge">8.65% p.a.</span></td>
                            <td>0.50%</td>
                            <td>20 years</td>
                            <td>₹8,780</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="bank-disclaimer">
                ⚠️ <strong>Disclaimer:</strong> Rates shown are indicative as of 2025 and subject to change.
                Actual rates depend on credit score, loan amount, and lender discretion.
                Please verify with the bank before applying.
            </div>
        </div>
    </div>

</div><!-- /page-wrap -->

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
/* ═══════════════════════════════════════════════════════
   UTILITY: Indian number format
   ═══════════════════════════════════════════════════════ */
function formatIndian(num) {
    if (!num || isNaN(num)) return '0';
    var n = Math.round(num).toString();
    var lastThree = n.substring(n.length - 3);
    var remaining = n.substring(0, n.length - 3);
    if (remaining !== '') { lastThree = ',' + lastThree; }
    return remaining.replace(/\B(?=(\d{2})+(?!\d))/g, ',') + lastThree;
}

/* ═══════════════════════════════════════════════════════
   CORE: EMI calculation
   ═══════════════════════════════════════════════════════ */
function calculateEMI(principal, annualRate, tenureYears) {
    var months = tenureYears * 12;
    var r = annualRate / 12 / 100;
    if (r === 0) return principal / months;
    if (principal <= 0 || months <= 0) return 0;
    return (principal * r * Math.pow(1 + r, months)) / (Math.pow(1 + r, months) - 1);
}

/* ═══════════════════════════════════════════════════════
   SECTION 1: EMI Calculator – Update all results live
   ═══════════════════════════════════════════════════════ */
function updateCalculator() {
    var price      = parseFloat(document.getElementById('propPrice').value)    || 0;
    var dpPct      = parseFloat(document.getElementById('downPayPct').value)   || 20;
    var rate       = parseFloat(document.getElementById('interestRate').value) || 8.5;
    var tenure     = parseInt(document.getElementById('tenure').value)         || 20;

    var downPayment = price * dpPct / 100;
    var loanAmount  = price - downPayment;
    var months      = tenure * 12;

    var emi          = calculateEMI(loanAmount, rate, tenure);
    var totalPayable = emi * months;
    var totalInterest = totalPayable - loanAmount;

    // Set read-only loan amount display
    document.getElementById('loanAmtDisplay').value = Math.round(loanAmount);

    setTextPop('emiResult',        '₹' + formatIndian(emi));
    setTextPop('totalInterest',    '₹' + formatIndian(totalInterest));
    setTextPop('totalPayable',     '₹' + formatIndian(totalPayable));
    setTextPop('principalAmt',     '₹' + formatIndian(loanAmount));
    setTextPop('downPayAmt',       '₹' + formatIndian(downPayment));
    setTextPop('downPayAmtResult', '₹' + formatIndian(downPayment));

    // Update pie chart
    updatePieChart(loanAmount, totalInterest);

    // Update amortization in background (for amortization tab)
    buildAmortization(loanAmount, rate, tenure);
}

function setTextPop(id, text) {
    var el = document.getElementById(id);
    if (!el) return;
    el.textContent = text;
    el.classList.remove('pop');
    void el.offsetWidth;
    el.classList.add('pop');
}

/* ═══════════════════════════════════════════════════════
   SECTION 2: Loan Eligibility
   ═══════════════════════════════════════════════════════ */
function updateEligibility() {
    var income      = parseFloat(document.getElementById('monthlyIncome').value)  || 0;
    var existingEmi = parseFloat(document.getElementById('existingEmis').value)  || 0;
    var rate        = parseFloat(document.getElementById('eligRate').value)       || 8.5;
    var tenure      = parseInt(document.getElementById('eligTenure').value)       || 20;
    var targetPrice = parseFloat(document.getElementById('targetPrice').value)   || 0;

    var fortyPct = income * 0.40;
    document.getElementById('fortyPctIncome').textContent = '₹' + formatIndian(fortyPct);

    var maxEMI = fortyPct - existingEmi;

    if (income <= 0) {
        document.getElementById('eligResult').innerHTML =
            '<span style="color:#94a3b8;">Enter your monthly income to see results.</span>';
        document.getElementById('maxLoan').textContent = '₹0';
        document.getElementById('maxAffordableEMI').textContent = '₹0';
        document.getElementById('eligBadge').style.display = 'none';
        document.getElementById('eligMeterWrap').style.display = 'none';
        return;
    }

    if (maxEMI <= 0) {
        document.getElementById('eligResult').innerHTML =
            '<span style="color:#dc2626;">⚠️ Existing EMIs exceed 40% of income. Loan not eligible.</span>';
        document.getElementById('maxLoan').textContent = '₹0';
        document.getElementById('maxAffordableEMI').textContent = '₹0';
        document.getElementById('eligBadge').style.display = 'none';
        document.getElementById('eligMeterWrap').style.display = 'none';
        return;
    }

    var r = rate / 12 / 100;
    var n = tenure * 12;
    var emiPerLakh = (r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1) * 100000;
    var maxLoan = (maxEMI / emiPerLakh) * 100000;

    document.getElementById('maxLoan').textContent         = '₹' + formatIndian(maxLoan);
    document.getElementById('maxAffordableEMI').textContent = '₹' + formatIndian(maxEMI);
    document.getElementById('eligResult').innerHTML =
        'Based on your income, you can borrow up to <strong>₹' + formatIndian(maxLoan) +
        '</strong> at ' + parseFloat(document.getElementById('eligRate').value).toFixed(1) +
        '% for ' + document.getElementById('eligTenure').value + ' years.';

    // Target price eligibility badge
    var badge       = document.getElementById('eligBadge');
    var meterWrap   = document.getElementById('eligMeterWrap');
    var meterBar    = document.getElementById('eligMeterBar');
    var meterPct    = document.getElementById('eligMeterPct');

    if (targetPrice > 0) {
        var requiredLoan = targetPrice * 0.80; // assume 20% down payment
        var eligPct      = maxLoan / requiredLoan * 100;
        badge.style.display = 'block';
        meterWrap.style.display = 'block';

        var barWidth = Math.min(100, eligPct).toFixed(1);
        meterBar.style.width = barWidth + '%';
        meterPct.textContent  = eligPct.toFixed(1) + '%';

        if (eligPct >= 100) {
            badge.textContent          = '✓ ELIGIBLE – You qualify for this property!';
            badge.style.background     = '#dcfce7';
            badge.style.color          = '#16a34a';
            meterBar.style.background  = 'linear-gradient(90deg,#22c55e,#15803d)';
        } else if (eligPct >= 70) {
            badge.textContent          = '⚠ PARTIALLY ELIGIBLE – Consider a higher down payment';
            badge.style.background     = '#fef9c3';
            badge.style.color          = '#ca8a04';
            meterBar.style.background  = 'linear-gradient(90deg,#f59e0b,#d97706)';
        } else {
            badge.textContent          = '✗ NOT ELIGIBLE – Loan amount significantly below requirement';
            badge.style.background     = '#fee2e2';
            badge.style.color          = '#dc2626';
            meterBar.style.background  = 'linear-gradient(90deg,#ef4444,#dc2626)';
        }
    } else {
        badge.style.display    = 'none';
        meterWrap.style.display = 'none';
    }
}

/* ═══════════════════════════════════════════════════════
   SECTION 3: Amortization Schedule
   ═══════════════════════════════════════════════════════ */
var _amortPrincipal = 0, _amortRate = 8.5, _amortTenure = 20;

function buildAmortization(principal, annualRate, tenureYears) {
    _amortPrincipal = principal;
    _amortRate      = annualRate;
    _amortTenure    = tenureYears;
    renderAmortization(false);
}

function renderAmortization(showAll) {
    var principal   = _amortPrincipal;
    var annualRate  = _amortRate;
    var tenureYears = _amortTenure;

    var r   = annualRate / 12 / 100;
    var n   = tenureYears * 12;
    var emi = calculateEMI(principal, annualRate, tenureYears);
    var tbody = document.getElementById('amortBody');
    tbody.innerHTML = '';

    if (principal <= 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="padding:30px;text-align:center;color:#94a3b8;">Enter property price in the EMI Calculator tab first.</td></tr>';
        return;
    }

    var balance  = principal;
    var maxYears = showAll ? tenureYears : Math.min(5, tenureYears);

    for (var year = 1; year <= maxYears; year++) {
        var yearPrincipal = 0, yearInterest = 0;
        var openingBalance = balance;

        for (var m = 0; m < 12 && balance > 0.01; m++) {
            var interestPaid  = balance * r;
            var principalPaid = Math.min(emi - interestPaid, balance);
            yearInterest   += interestPaid;
            yearPrincipal  += principalPaid;
            balance        -= principalPaid;
        }
        if (balance < 0) balance = 0;

        var pctPaid = (1 - balance / principal) * 100;
        var row = '<tr style="border-bottom:1px solid #f1f5f9;">' +
            '<td style="padding:10px;text-align:center;font-weight:600;">' + year + '</td>' +
            '<td style="padding:10px;text-align:right;color:#64748b;">₹' + formatIndian(openingBalance) + '</td>' +
            '<td style="padding:10px;text-align:right;color:#1a73e8;font-weight:600;">₹' + formatIndian(yearPrincipal) + '</td>' +
            '<td style="padding:10px;text-align:right;color:#ef4444;font-weight:600;">₹' + formatIndian(yearInterest) + '</td>' +
            '<td style="padding:10px;text-align:right;color:#334155;">₹' + formatIndian(Math.max(0, balance)) + '</td>' +
            '<td style="padding:10px;text-align:center;">' +
                '<span style="background:#dcfce7;color:#16a34a;padding:3px 8px;border-radius:4px;font-size:12px;font-weight:700;">' +
                pctPaid.toFixed(1) + '%</span>' +
            '</td>' +
            '</tr>';
        tbody.innerHTML += row;
    }

    // Update show all button
    var btn = document.getElementById('showAllYears');
    if (showAll || tenureYears <= 5) {
        btn.style.display = 'none';
    } else {
        btn.style.display = 'block';
        btn.setAttribute('data-show', showAll ? 'true' : 'false');
        btn.textContent = showAll ? '▲ Show Less' : '▼ Show All ' + tenureYears + ' Years';
    }
}

function toggleShowAllYears() {
    var btn     = document.getElementById('showAllYears');
    var showAll = btn.getAttribute('data-show') !== 'true';
    btn.setAttribute('data-show', showAll ? 'true' : 'false');
    renderAmortization(showAll);
}

/* ═══════════════════════════════════════════════════════
   PIE CHART (Chart.js doughnut)
   ═══════════════════════════════════════════════════════ */
var pieChart;
function updatePieChart(principal, interest) {
    if (!principal && !interest) return;
    var ctx = document.getElementById('emiPieChart');
    if (!ctx) return;

    if (pieChart) { pieChart.destroy(); }
    pieChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Principal', 'Total Interest'],
            datasets: [{
                data: [Math.max(0, principal), Math.max(0, interest)],
                backgroundColor: ['#1A73E8', '#EF4444'],
                borderWidth: 2,
                borderColor: '#ffffff'
            }]
        },
        options: {
            plugins: {
                legend: { position: 'bottom', labels: { font: { family: 'Inter', size: 12 }, padding: 16 } },
                tooltip: {
                    callbacks: {
                        label: function(ctx) {
                            return ctx.label + ': ₹' + formatIndian(ctx.parsed);
                        }
                    }
                }
            },
            cutout: '62%',
            animation: { animateRotate: true, duration: 600 }
        }
    });
}

/* ═══════════════════════════════════════════════════════
   TAB NAVIGATION
   ═══════════════════════════════════════════════════════ */
function showSection(name, btn) {
    ['emi', 'eligibility', 'amortization', 'banks'].forEach(function(s) {
        document.getElementById('sec-' + s).classList.remove('active');
    });
    document.getElementById('sec-' + name).classList.add('active');

    document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');

    if (name === 'amortization') {
        renderAmortization(document.getElementById('showAllYears').getAttribute('data-show') === 'true');
    }
}

/* ═══════════════════════════════════════════════════════
   INIT
   ═══════════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', function() {
    // Wire up propPrice input
    document.getElementById('propPrice').addEventListener('input', updateCalculator);

    updateCalculator();
    updateEligibility();
});
</script>
</body>
</html>
