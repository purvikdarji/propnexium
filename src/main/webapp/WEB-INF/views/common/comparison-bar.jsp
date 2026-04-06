<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

            <!-- FIXED COMPARISON BAR (hidden until items added) -->
            <div id="compareBar" style="display:none;position:fixed;bottom:0;left:0;right:0;z-index:500;
           background:#1e293b;padding:12px 24px;
           box-shadow:0 -4px 20px rgba(0,0,0,0.3);">
                <div style="max-width:1200px;margin:0 auto;
              display:flex;align-items:center;gap:12px;flex-wrap:wrap;">

                    <span style="color:#94a3b8;font-size:13px;font-weight:600;
                 white-space:nowrap;">
                        ⚖ Compare:
                    </span>

                    <!-- Property chips container -->
                    <div id="compareChips" style="display:flex;gap:8px;flex:1;flex-wrap:wrap;"></div>

                    <!-- Counter -->
                    <span id="compareCounter" style="color:#94a3b8;font-size:13px;white-space:nowrap;">
                        0/3
                    </span>

                    <!-- Compare Now button (disabled < 2) -->
                    <button id="compareNowBtn" onclick="goCompare()" disabled style="padding:10px 24px;background:#1a73e8;color:white;
             border:none;border-radius:6px;font-size:14px;font-weight:700;
             cursor:pointer;white-space:nowrap;opacity:0.5;
             transition:opacity 0.2s;">
                        Compare Now &rarr;
                    </button>

                    <!-- Clear all -->
                    <button onclick="clearCompare()" style="padding:10px 16px;background:transparent;color:#94a3b8;
             border:1px solid #475569;border-radius:6px;font-size:13px;
             cursor:pointer;">
                        Clear All
                    </button>
                </div>
            </div>

            <script>
                const MAX_COMPARE = 3;

                // Load compare list from sessionStorage on page load
                function getCompareList() {
                    try {
                        return JSON.parse(sessionStorage.getItem('propnexium_compare') || '[]');
                    } catch (e) { return []; }
                }

                function saveCompareList(list) {
                    sessionStorage.setItem('propnexium_compare', JSON.stringify(list));
                }

                function renderCompareBar() {
                    const list = getCompareList();
                    const bar = document.getElementById('compareBar');
                    const chips = document.getElementById('compareChips');
                    const counter = document.getElementById('compareCounter');
                    const btn = document.getElementById('compareNowBtn');

                    if (list.length === 0) {
                        bar.style.display = 'none';
                        return;
                    }

                    bar.style.display = 'flex';
                    counter.textContent = list.length + '/3';

                    // Enable button only at 2+
                    btn.disabled = list.length < 2;
                    btn.style.opacity = list.length >= 2 ? '1' : '0.5';
                    btn.style.cursor = list.length >= 2 ? 'pointer' : 'not-allowed';

                    // Render property chips
                    chips.innerHTML = list.map(item =>
                        '<div style="background:#334155;padding:6px 10px 6px 14px;' +
                        'border-radius:20px;display:flex;align-items:center;gap:8px;">' +
                        '<span style="color:white;font-size:13px;max-width:160px;' +
                        'overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' +
                        item.title + '</span>' +
                        '<button onclick="removeFromCompare(' + item.id + ')" ' +
                        'style="background:transparent;border:none;color:#94a3b8;' +
                        'font-size:16px;cursor:pointer;padding:0;line-height:1;">&#10005;</button>' +
                        '</div>'
                    ).join('');

                    // Update all compare buttons on page
                    updateAllCompareButtons(list);
                }

                function addToCompare(id, title, event) {
                    if (event) event.preventDefault();
                    const list = getCompareList();

                    if (list.find(item => item.id === id)) {
                        if (typeof showToast !== 'undefined') {
                            showToast('Already in compare list', 'info');
                        } else {
                            alert('Already in compare list');
                        }
                        return;
                    }
                    if (list.length >= MAX_COMPARE) {
                        if (typeof showToast !== 'undefined') {
                            showToast('Maximum 3 properties can be compared', 'error');
                        } else {
                            alert('Maximum 3 properties can be compared');
                        }
                        return;
                    }

                    list.push({ id: id, title: title });
                    saveCompareList(list);
                    renderCompareBar();

                    // Visual feedback on button
                    const btn = document.getElementById('compareBtn_' + id);
                    if (btn) {
                        btn.style.background = '#1a73e8';
                        btn.style.color = 'white';
                        btn.textContent = '✓ Added';
                    }

                    if (typeof showToast !== 'undefined') {
                        showToast('"' + title.substring(0, 30) + '..." added to compare', 'success');
                    }
                }

                function removeFromCompare(id) {
                    let list = getCompareList();
                    list = list.filter(item => item.id !== id);
                    saveCompareList(list);
                    renderCompareBar();

                    // Reset button
                    const btn = document.getElementById('compareBtn_' + id);
                    if (btn) {
                        btn.style.background = 'white';
                        btn.style.color = '#1a73e8';
                        // Detail page or card? Need to set text accordingly but we can just use ⚖ Compare
                        if (btn.textContent.includes('This Property')) {
                            btn.innerHTML = '&#9878; Compare This Property';
                        } else {
                            btn.innerHTML = '&#9878; Compare';
                        }
                    }
                }

                function clearCompare() {
                    saveCompareList([]);
                    renderCompareBar();
                }

                function goCompare() {
                    const list = getCompareList();
                    if (list.length < 2) return;
                    const ids = list.map(item => item.id).join(',');
                    window.location = '/compare?ids=' + ids;
                }

                function updateAllCompareButtons(list) {
                    const addedIds = list.map(item => item.id);
                    document.querySelectorAll('[id^="compareBtn_"]').forEach(btn => {
                        const id = parseInt(btn.id.split('_')[1]);
                        if (addedIds.includes(id)) {
                            btn.style.background = '#1a73e8';
                            btn.style.color = 'white';
                            btn.textContent = '✓ Added';
                        } else {
                            btn.style.background = 'white';
                            btn.style.color = '#1a73e8';
                            if (btn.textContent.includes('This Property')) {
                                btn.innerHTML = '&#9878; Compare This Property';
                            } else {
                                btn.innerHTML = '&#9878; Compare';
                            }
                        }
                    });
                }

                // Initialize bar on every page load
                document.addEventListener('DOMContentLoaded', renderCompareBar);
            </script>