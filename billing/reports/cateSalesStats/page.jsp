<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Category Sales Statistics</title>
    <%@ include file="/assets/common/head.jsp" %>
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        :root {
            --clr-fast:   #16a34a;
            --clr-mid:    #d97706;
            --clr-slow:   #dc2626;
            --clr-zero:   #9ca3af;
        }

        /* ── Summary bar ── */
        .kpi-bar { display: flex; gap: 1rem; flex-wrap: wrap; margin-bottom: 1.4rem; }
        .kpi { flex: 1 1 160px; background: #fff; border-radius: 10px;
               padding: 14px 18px; box-shadow: 0 2px 8px rgba(0,0,0,.07);
               border-top: 4px solid; }
        .kpi.k1 { border-color: #6366f1; }
        .kpi.k2 { border-color: #0ea5e9; }
        .kpi.k3 { border-color: #10b981; }
        .kpi.k4 { border-color: #f59e0b; }
        .kpi-val { font-size: 1.6rem; font-weight: 700; line-height: 1.1; }
        .kpi-lbl { font-size: .72rem; text-transform: uppercase; letter-spacing: .05em; color: #6b7280; margin-top: 4px; }

        /* ── Speed badge ── */
        .speed-fast { background: #dcfce7; color: var(--clr-fast); font-size: .72rem; padding: 2px 8px; border-radius: 20px; font-weight: 600; }
        .speed-mid  { background: #fef3c7; color: var(--clr-mid);  font-size: .72rem; padding: 2px 8px; border-radius: 20px; font-weight: 600; }
        .speed-slow { background: #fee2e2; color: var(--clr-slow); font-size: .72rem; padding: 2px 8px; border-radius: 20px; font-weight: 600; }
        .speed-zero { background: #f3f4f6; color: var(--clr-zero); font-size: .72rem; padding: 2px 8px; border-radius: 20px; font-weight: 600; }

        /* ── Share bar ── */
        .share-bar { height: 8px; border-radius: 4px; background: #e0e7ff; overflow: hidden; }
        .share-fill { height: 100%; border-radius: 4px; background: linear-gradient(90deg, #6366f1, #0ea5e9); transition: width .5s; }

        /* ── Category table ── */
        #cateTable thead th { background: #1e293b; color: #fff; font-size: .78rem; white-space: nowrap; vertical-align: middle; }
        #cateTable tbody td { font-size: .83rem; vertical-align: middle; }
        #cateTable tbody tr:hover { background: #f8fafc; }
        .rank-badge { display: inline-block; width: 24px; height: 24px; border-radius: 50%; line-height: 24px; text-align: center; font-size: .72rem; font-weight: 700; background: #e0e7ff; color: #4338ca; }
        .rank-1 { background: #fef3c7; color: #92400e; }
        .rank-2 { background: #f1f5f9; color: #334155; }
        .rank-3 { background: #fce7f3; color: #9d174d; }

        /* ── Detail panel ── */
        .detail-panel { background: #f8fafc; border-top: 2px solid #e2e8f0; }
        .detail-table thead th { background: #334155; color: #fff; font-size: .76rem; white-space: nowrap; }
        .detail-table tbody td { font-size: .8rem; vertical-align: middle; }
        .detail-table tbody tr:hover { background: #f0f9ff; }

        /* ── Chart card ── */
        .chart-card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,.08); }

        /* ── Sort arrows ── */
        .sortable { cursor: pointer; user-select: none; }
        .sortable:hover { background: #374151 !important; }
        .sort-icon { font-size: .65rem; opacity: .6; margin-left: 3px; }

        /* ── Legend ── */
        .legend-wrap { display: flex; gap: 12px; flex-wrap: wrap; align-items: center; font-size: .78rem; }
        .legend-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 4px; }

        @media print {
            .no-print { display: none !important; }
            .kpi { box-shadow: none; border: 1px solid #e5e7eb; }
        }
    </style>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container-fluid mt-4 px-4">

    <!-- Page header -->
    <div class="d-flex align-items-center justify-content-between mb-3 no-print">
        <div>
            <h4 class="mb-0 fw-bold"><i class="fas fa-layer-group me-2 text-primary"></i>Category Sales Statistics</h4>
            <small class="text-muted">Analyse which categories are moving fast or slow</small>
        </div>
        <button onclick="window.print()" class="btn btn-outline-secondary btn-sm">
            <i class="fas fa-print me-1"></i>Print
        </button>
    </div>

    <!-- Filter -->
    <div class="card shadow-sm mb-4 no-print">
        <div class="card-body">
            <div class="row g-2 align-items-end">
                <div class="col-auto">
                    <label class="form-label fw-semibold mb-1">From</label>
                    <input type="date" id="fromDate" class="form-control form-control-sm">
                </div>
                <div class="col-auto">
                    <label class="form-label fw-semibold mb-1">To</label>
                    <input type="date" id="toDate" class="form-control form-control-sm">
                </div>
                <div class="col-auto d-flex gap-2">
                    <button id="loadBtn" class="btn btn-primary btn-sm px-4" onclick="loadReport()">
                        <i class="fas fa-search me-1"></i>Load
                    </button>
                    <div class="btn-group btn-group-sm no-print">
                        <button class="btn btn-outline-secondary" onclick="setRange('today')">Today</button>
                        <button class="btn btn-outline-secondary" onclick="setRange('week')">7d</button>
                        <button class="btn btn-outline-secondary" onclick="setRange('month')">Month</button>
                    </div>
                </div>
                <div class="col-auto ms-auto no-print">
                    <div class="legend-wrap">
                        <span><span class="legend-dot" style="background:var(--clr-fast)"></span>Fast mover (top 33%)</span>
                        <span><span class="legend-dot" style="background:var(--clr-mid)"></span>Mid</span>
                        <span><span class="legend-dot" style="background:var(--clr-slow)"></span>Slow</span>
                        <span><span class="legend-dot" style="background:var(--clr-zero)"></span>No sales</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Loading -->
    <div id="loadingDiv" class="text-center py-5 d-none">
        <div class="spinner-border text-primary"></div>
        <p class="text-muted mt-2">Fetching data…</p>
    </div>

    <!-- Main report area -->
    <div id="reportArea" class="d-none">

        <!-- KPI Summary bar -->
        <div class="kpi-bar" id="kpiBar">
            <div class="kpi k1">
                <div class="kpi-val" id="kpi-cats">—</div>
                <div class="kpi-lbl"><i class="fas fa-layer-group me-1"></i>Total Categories</div>
            </div>
            <div class="kpi k2">
                <div class="kpi-val" id="kpi-active">—</div>
                <div class="kpi-lbl"><i class="fas fa-bolt me-1"></i>Active Categories</div>
            </div>
            <div class="kpi k3">
                <div class="kpi-val" id="kpi-amt">—</div>
                <div class="kpi-lbl"><i class="fas fa-rupee-sign me-1"></i>Total Revenue</div>
            </div>
            <div class="kpi k4">
                <div class="kpi-val" id="kpi-qty">—</div>
                <div class="kpi-lbl"><i class="fas fa-boxes me-1"></i>Total Qty Sold</div>
            </div>
        </div>

        <!-- Chart + sort controls -->
        <div class="row g-3 mb-3 no-print">
            <div class="col-lg-8">
                <div class="chart-card">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <span class="fw-semibold text-secondary small">TOP CATEGORIES BY REVENUE</span>
                        <div class="btn-group btn-group-sm">
                            <button class="btn btn-outline-primary active" id="chartAmtBtn" onclick="switchChart('amt')">Amount</button>
                            <button class="btn btn-outline-primary"         id="chartQtyBtn" onclick="switchChart('qty')">Qty</button>
                        </div>
                    </div>
                    <canvas id="cateChart" height="220"></canvas>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="chart-card h-100">
                    <div class="fw-semibold text-secondary small mb-3">REVENUE SHARE</div>
                    <canvas id="pieChart" height="220"></canvas>
                </div>
            </div>
        </div>

        <!-- Table sort controls -->
        <div class="d-flex align-items-center gap-2 mb-2 no-print">
            <span class="text-muted small fw-semibold">Sort by:</span>
            <div class="btn-group btn-group-sm">
                <button class="btn btn-outline-secondary active" onclick="sortTable('amt')">Amount</button>
                <button class="btn btn-outline-secondary" onclick="sortTable('qty')">Qty</button>
                <button class="btn btn-outline-secondary" onclick="sortTable('bills')">Bills</button>
                <button class="btn btn-outline-secondary" onclick="sortTable('name')">Name</button>
            </div>
            <div class="ms-auto no-print">
                <input type="text" id="tableSearch" class="form-control form-control-sm" placeholder="Search category…" style="width:200px" oninput="filterTable(this.value)">
            </div>
        </div>

        <!-- Category table -->
        <div class="card shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="cateTable">
                        <thead>
                            <tr>
                                <th style="width:40px">#</th>
                                <th>Category</th>
                                <th class="text-end">Revenue (₹)</th>
                                <th class="text-end">Qty Sold</th>
                                <th class="text-end">Bills</th>
                                <th class="text-end">Products</th>
                                <th>Top Product</th>
                                <th style="width:160px">Share</th>
                                <th class="text-center">Speed</th>
                                <th class="text-center no-print">Details</th>
                            </tr>
                        </thead>
                        <tbody id="cateBody"></tbody>
                    </table>
                </div>
            </div>
        </div>

    </div><!-- /reportArea -->
</div>

<script>
const CTX = '<%=ctx%>';
let allRows = [];       // raw category data
let grandAmt = 0;
let chartInst = null;
let pieInst   = null;
let sortKey   = 'amt';
let openCatId = null;

// ── Date init ─────────────────────────────────────────────────────────────
(function() {
    const d = new Date();
    const pad = n => String(n).padStart(2,'0');
    const toStr = dt => dt.getFullYear() + '-' + pad(dt.getMonth()+1) + '-' + pad(dt.getDate());
    document.getElementById('toDate').value = toStr(d);
    const first = new Date(d.getFullYear(), d.getMonth(), 1);
    document.getElementById('fromDate').value = toStr(first);
})();

function setRange(r) {
    const d = new Date();
    const pad = n => String(n).padStart(2,'0');
    const toStr = dt => dt.getFullYear() + '-' + pad(dt.getMonth()+1) + '-' + pad(dt.getDate());
    document.getElementById('toDate').value = toStr(d);
    if (r === 'today') {
        document.getElementById('fromDate').value = toStr(d);
    } else if (r === 'week') {
        const w = new Date(d); w.setDate(w.getDate() - 6);
        document.getElementById('fromDate').value = toStr(w);
    } else {
        const first = new Date(d.getFullYear(), d.getMonth(), 1);
        document.getElementById('fromDate').value = toStr(first);
    }
    loadReport();
}

// ── Load report ───────────────────────────────────────────────────────────
function loadReport() {
    const from = document.getElementById('fromDate').value;
    const to   = document.getElementById('toDate').value;
    if (!from || !to) { Swal.fire('Select Dates', 'Please fill both From and To dates.', 'warning'); return; }

    document.getElementById('reportArea').classList.add('d-none');
    document.getElementById('loadingDiv').classList.remove('d-none');
    document.getElementById('loadBtn').disabled = true;
    openCatId = null;

    fetch(CTX + '/reports/cateSalesStats/getData.jsp?fromDate=' + encodeURIComponent(from) + '&toDate=' + encodeURIComponent(to))
        .then(r => r.json())
        .then(data => {
            document.getElementById('loadingDiv').classList.add('d-none');
            document.getElementById('loadBtn').disabled = false;
            if (data.error) { Swal.fire('Error', data.error, 'error'); return; }
            allRows  = data.categories || [];
            grandAmt = data.grandAmt  || 0;
            renderKPIs(data);
            renderTable(allRows);
            renderCharts(allRows);
            document.getElementById('reportArea').classList.remove('d-none');
        })
        .catch(err => {
            document.getElementById('loadingDiv').classList.add('d-none');
            document.getElementById('loadBtn').disabled = false;
            Swal.fire('Error', 'Network error: ' + err, 'error');
        });
}

// ── KPIs ─────────────────────────────────────────────────────────────────
function renderKPIs(data) {
    document.getElementById('kpi-cats').textContent   = data.totalCats;
    document.getElementById('kpi-active').textContent = data.activeCats;
    document.getElementById('kpi-amt').textContent    = '₹' + fmt2(data.grandAmt);
    document.getElementById('kpi-qty').textContent    = fmt2(data.grandQty);
}

// ── Determine speed tier ─────────────────────────────────────────────────
function speedTier(rows, row) {
    const active = rows.filter(r => r.totalAmt > 0);
    if (row.totalAmt <= 0) return 'zero';
    if (active.length === 0) return 'zero';
    const threshold33 = active[Math.floor(active.length * 0.33)]?.totalAmt ?? 0;
    const threshold66 = active[Math.floor(active.length * 0.66)]?.totalAmt ?? 0;
    if (row.totalAmt >= threshold33) return 'fast';
    if (row.totalAmt >= threshold66) return 'mid';
    return 'slow';
}

function speedBadge(tier) {
    const map = { fast: ['speed-fast','🚀 Fast'], mid: ['speed-mid','⚡ Mid'], slow: ['speed-slow','🐢 Slow'], zero: ['speed-zero','— No Sales'] };
    const [cls, label] = map[tier];
    return `<span class="${cls}">${label}</span>`;
}

// ── Render table ──────────────────────────────────────────────────────────
let sortedRows = [];

function sortTable(key) {
    sortKey = key;
    document.querySelectorAll('.btn-group .btn').forEach(b => b.classList.remove('active'));
    event && event.target && event.target.classList.add('active');
    renderTable(sortedRows.length ? sortedRows : allRows);
}

function filterTable(q) {
    const term = q.toLowerCase();
    const filtered = allRows.filter(r => r.catName.toLowerCase().includes(term));
    renderTable(filtered);
}

function renderTable(rows) {
    // Sort
    const sorted = [...rows];
    if (sortKey === 'amt')   sorted.sort((a,b) => b.totalAmt - a.totalAmt);
    if (sortKey === 'qty')   sorted.sort((a,b) => b.totalQty - a.totalQty);
    if (sortKey === 'bills') sorted.sort((a,b) => b.billCount - a.billCount);
    if (sortKey === 'name')  sorted.sort((a,b) => a.catName.localeCompare(b.catName));
    sortedRows = sorted;

    const tbody = document.getElementById('cateBody');
    tbody.innerHTML = '';

    sorted.forEach((row, idx) => {
        const rank  = idx + 1;
        const share = grandAmt > 0 ? (row.totalAmt / grandAmt * 100) : 0;
        const tier  = speedTier(sorted.filter(r => r.totalAmt > 0), row);
        const rankCls = rank <= 3 ? ` rank-${rank}` : '';

        const tr = document.createElement('tr');
        tr.id = 'row-' + row.catId;
        tr.innerHTML = `
            <td><span class="rank-badge${rankCls}">${rank}</span></td>
            <td class="fw-semibold">${escHtml(row.catName)}</td>
            <td class="text-end fw-semibold text-primary">₹${fmt2(row.totalAmt)}</td>
            <td class="text-end">${fmt2(row.totalQty)}</td>
            <td class="text-end">${row.billCount}</td>
            <td class="text-end">${row.productCount}</td>
            <td class="text-muted small">${escHtml(row.topProduct) || '—'}</td>
            <td>
                <div class="share-bar">
                    <div class="share-fill" style="width:${share.toFixed(1)}%"></div>
                </div>
                <div class="small text-muted mt-1">${share.toFixed(1)}%</div>
            </td>
            <td class="text-center">${speedBadge(tier)}</td>
            <td class="text-center no-print">
                <button class="btn btn-sm btn-outline-primary py-0 px-2 det-btn" data-cat-id="${row.catId}" data-cat-name="${escHtml(row.catName)}" onclick="toggleDetail(this)">
                    <i class="fas fa-chevron-down"></i>
                </button>
            </td>`;
        tbody.appendChild(tr);

        // Detail row placeholder
        const detTr = document.createElement('tr');
        detTr.id = 'detail-' + row.catId;
        detTr.classList.add('d-none', 'detail-panel');
        detTr.innerHTML = `<td colspan="10" class="p-0"><div id="detail-content-${row.catId}" class="p-3"></div></td>`;
        tbody.appendChild(detTr);
    });
}

// ── Detail drill-down ─────────────────────────────────────────────────────
function toggleDetail(btn) {
    const catId   = btn.dataset.catId;
    const catName = btn.dataset.catName;
    const detRow  = document.getElementById('detail-' + catId);
    const icon    = btn.querySelector('i');

    if (!detRow.classList.contains('d-none')) {
        detRow.classList.add('d-none');
        icon.className = 'fas fa-chevron-down';
        openCatId = null;
        return;
    }

    // Close any other open detail
    if (openCatId) {
        document.getElementById('detail-' + openCatId)?.classList.add('d-none');
        const oldBtn = document.querySelector(`[data-cat-id="${openCatId}"] i`);
        if (oldBtn) oldBtn.className = 'fas fa-chevron-down';
    }
    openCatId = catId;
    icon.className = 'fas fa-spinner fa-spin';

    const from = document.getElementById('fromDate').value;
    const to   = document.getElementById('toDate').value;

    fetch(CTX + '/reports/cateSalesStats/getData.jsp?fromDate=' + encodeURIComponent(from)
        + '&toDate=' + encodeURIComponent(to)
        + '&catId='  + encodeURIComponent(catId))
        .then(r => r.json())
        .then(data => {
            icon.className = 'fas fa-chevron-up';
            const prods = data.products || [];
            const content = document.getElementById('detail-content-' + catId);

            if (prods.length === 0) {
                content.innerHTML = `<p class="text-muted mb-0">No sales recorded for <strong>${escHtml(catName)}</strong> in this period.</p>`;
            } else {
                let rows = '';
                let totAmt = 0, totQty = 0;
                prods.forEach((p, i) => {
                    totAmt += p.totalAmt;
                    totQty += p.totalQty;
                    const pShare = data.products.reduce((s, x) => s + x.totalAmt, 0);
                    const pPct   = pShare > 0 ? (p.totalAmt / pShare * 100).toFixed(1) : 0;
                    rows += `<tr>
                        <td>${i+1}</td>
                        <td class="fw-semibold">${escHtml(p.productName)}</td>
                        <td class="text-end">₹${fmt2(p.avgPrice)}</td>
                        <td class="text-end">${fmt2(p.totalQty)}</td>
                        <td class="text-end fw-semibold text-primary">₹${fmt2(p.totalAmt)}</td>
                        <td class="text-end">${p.billCount}</td>
                        <td>
                            <div class="share-bar"><div class="share-fill" style="width:${pPct}%"></div></div>
                            <div class="small text-muted">${pPct}%</div>
                        </td>
                    </tr>`;
                });
                content.innerHTML = `
                    <div class="fw-semibold text-primary mb-2">
                        <i class="fas fa-tag me-1"></i>${escHtml(catName)} — Product Breakdown
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover table-sm mb-0 detail-table">
                            <thead><tr>
                                <th>#</th><th>Product</th>
                                <th class="text-end">Avg Price</th>
                                <th class="text-end">Qty Sold</th>
                                <th class="text-end">Revenue</th>
                                <th class="text-end">Bills</th>
                                <th style="width:120px">Share</th>
                            </tr></thead>
                            <tbody>${rows}</tbody>
                            <tfoot><tr style="background:#e2e8f0">
                                <td colspan="3"><strong>Total</strong></td>
                                <td class="text-end"><strong>${fmt2(totQty)}</strong></td>
                                <td class="text-end text-primary"><strong>₹${fmt2(totAmt)}</strong></td>
                                <td colspan="2"></td>
                            </tr></tfoot>
                        </table>
                    </div>`;
            }
            detRow.classList.remove('d-none');
        })
        .catch(() => {
            icon.className = 'fas fa-chevron-down';
            Swal.fire('Error', 'Failed to load product details.', 'error');
        });
}

// ── Charts ────────────────────────────────────────────────────────────────
const PALETTE = [
    '#6366f1','#0ea5e9','#10b981','#f59e0b','#ef4444',
    '#8b5cf6','#14b8a6','#f97316','#ec4899','#84cc16',
    '#06b6d4','#a855f7','#22c55e','#fb923c','#e879f9'
];

function renderCharts(rows) {
    const top = [...rows].sort((a,b) => b.totalAmt - a.totalAmt).slice(0, 12);
    const labels  = top.map(r => r.catName);
    const amtData = top.map(r => r.totalAmt);
    const qtyData = top.map(r => r.totalQty);

    // Bar chart
    if (chartInst) chartInst.destroy();
    chartInst = new Chart(document.getElementById('cateChart'), {
        type: 'bar',
        data: {
            labels,
            datasets: [{
                label: 'Revenue (₹)',
                data: amtData,
                backgroundColor: PALETTE,
                borderRadius: 6,
                borderSkipped: false
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false },
                tooltip: { callbacks: { label: ctx => ' ₹' + fmt2(ctx.parsed.y) } } },
            scales: {
                y: { ticks: { callback: v => '₹' + fmt2(v) }, grid: { color: '#f1f5f9' } },
                x: { ticks: { font: { size: 11 } } }
            }
        }
    });
    chartInst._amtData = amtData;
    chartInst._qtyData = qtyData;
    chartInst._labels  = labels;

    // Pie chart
    if (pieInst) pieInst.destroy();
    pieInst = new Chart(document.getElementById('pieChart'), {
        type: 'doughnut',
        data: {
            labels,
            datasets: [{ data: amtData, backgroundColor: PALETTE, hoverOffset: 8 }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { position: 'bottom', labels: { font: { size: 10 }, boxWidth: 12 } },
                tooltip: { callbacks: { label: ctx => ctx.label + ': ₹' + fmt2(ctx.parsed) } }
            }
        }
    });
}

function switchChart(mode) {
    if (!chartInst) return;
    document.getElementById('chartAmtBtn').classList.toggle('active', mode === 'amt');
    document.getElementById('chartQtyBtn').classList.toggle('active', mode === 'qty');
    if (mode === 'amt') {
        chartInst.data.datasets[0].label = 'Revenue (₹)';
        chartInst.data.datasets[0].data  = chartInst._amtData;
        chartInst.options.scales.y.ticks.callback = v => '₹' + fmt2(v);
        chartInst.options.plugins.tooltip.callbacks.label = ctx => ' ₹' + fmt2(ctx.parsed.y);
    } else {
        chartInst.data.datasets[0].label = 'Qty Sold';
        chartInst.data.datasets[0].data  = chartInst._qtyData;
        chartInst.options.scales.y.ticks.callback = v => v;
        chartInst.options.plugins.tooltip.callbacks.label = ctx => ' ' + fmt2(ctx.parsed.y);
    }
    chartInst.update();
}

// ── Helpers ───────────────────────────────────────────────────────────────
function fmt2(n) { return parseFloat(n || 0).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }
function escHtml(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

// Auto-load on Enter in date fields
document.getElementById('toDate').addEventListener('keydown', e => { if (e.key === 'Enter') loadReport(); });
document.getElementById('fromDate').addEventListener('keydown', e => { if (e.key === 'Enter') loadReport(); });
</script>
</body>
</html>
