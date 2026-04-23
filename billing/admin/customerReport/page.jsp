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
    <title>Customer Analysis Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        :root {
            --sales-color:    #0d6efd;
            --return-color:   #fd7e14;
            --exchange-color: #0dcaf0;
            --points-color:   #198754;
        }
        @media print {
            .no-print { display: none !important; }
            .card { box-shadow: none !important; }
            body { font-size: 11px; }
        }

        /* ── Customer Search ── */
        .cust-search-wrap { position: relative; }
        .cust-ac-list {
            position: absolute; z-index: 9999; background: #fff;
            border: 1px solid #dee2e6; border-top: none;
            width: 100%; max-height: 260px; overflow-y: auto;
            list-style: none; padding: 0; margin: 0;
            box-shadow: 0 6px 16px rgba(0,0,0,.12);
            border-radius: 0 0 6px 6px;
        }
        .cust-ac-list li {
            padding: 9px 14px; cursor: pointer; font-size: .88rem;
            border-bottom: 1px solid #f0f0f0;
        }
        .cust-ac-list li .cust-name { font-weight: 600; }
        .cust-ac-list li .cust-phone { font-size: .78rem; color: #6c757d; }
        .cust-ac-list li:hover, .cust-ac-list li.active {
            background: #0d6efd; color: #fff;
        }
        .cust-ac-list li:hover .cust-phone,
        .cust-ac-list li.active .cust-phone { color: #cfe2ff; }

        /* ── Summary Cards ── */
        .summary-card { border-left: 5px solid; border-radius: 8px; transition: transform .15s; }
        .summary-card:hover { transform: translateY(-2px); }
        .sc-sales    { border-color: var(--sales-color);    background: #e8f0fe; }
        .sc-return   { border-color: var(--return-color);   background: #fff3e0; }
        .sc-exchange { border-color: var(--exchange-color); background: #e0f7fa; }
        .sc-points   { border-color: var(--points-color);   background: #e6f4ea; }
        .sc-value { font-size: 1.5rem; font-weight: 700; }
        .sc-label { font-size: .78rem; text-transform: uppercase; letter-spacing: .05em; opacity: .7; }
        .sc-sub   { font-size: .75rem; color: #6c757d; margin-top: 2px; }

        /* ── Tabs ── */
        .nav-tabs .nav-link { font-weight: 600; font-size: .88rem; }
        .nav-tabs .nav-link.active { border-bottom: 3px solid #0d6efd; }

        /* ── Tables ── */
        .rpt-table thead th { background: #343a40; color: #fff; font-size: .8rem; white-space: nowrap; }
        .rpt-table tbody tr:hover { background: #f8f9fa; }
        .rpt-table td { font-size: .83rem; vertical-align: middle; }
        tfoot td { font-weight: 700; background: #f1f3f5 !important; font-size: .83rem; }

        /* ── Badges ── */
        .badge-bill    { background: #e8f0fe; color: #1a56db; font-size: .75rem; padding: 2px 8px; border-radius: 20px; }
        .badge-product { background: #fff3e0; color: #e65100; font-size: .75rem; padding: 2px 8px; border-radius: 20px; }

        /* ── Points styling ── */
        .pts-credit { color: #198754; font-weight: 600; }
        .pts-debit  { color: #dc3545; font-weight: 600; }

        /* ── Print header ── */
        .print-header { display: none; }
        @media print { .print-header { display: block; text-align: center; margin-bottom: 12px; } }

        /* ── Empty state ── */
        .empty-state { text-align: center; padding: 40px; color: #adb5bd; }
        .empty-state i { font-size: 3rem; display: block; margin-bottom: 10px; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid mt-4 px-4">

        <!-- Page Header -->
        <div class="d-flex align-items-center justify-content-between mb-4 no-print">
            <div>
                <h4 class="mb-0 fw-bold"><i class="fas fa-user me-2 text-primary"></i>Customer Analysis Report</h4>
                <small class="text-muted">Sales, returns, exchanges &amp; loyalty points by customer</small>
            </div>
            <button onclick="window.print()" class="btn btn-outline-secondary btn-sm">
                <i class="fas fa-print me-1"></i>Print
            </button>
        </div>

        <!-- Filter Card -->
        <div class="card shadow-sm mb-4 no-print">
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <!-- Customer Search -->
                    <div class="col-lg-4 col-md-6">
                        <label class="form-label fw-semibold">Customer <span class="text-danger">*</span></label>
                        <div class="cust-search-wrap">
                            <input type="text" id="custSearch" class="form-control"
                                   placeholder="Type name or phone number…" autocomplete="off">
                            <ul class="cust-ac-list d-none" id="custAcList"></ul>
                        </div>
                        <input type="hidden" id="custId" value="">
                        <div id="selectedCustBadge" class="mt-1"></div>
                    </div>
                    <!-- From Date -->
                    <div class="col-lg-2 col-md-3">
                        <label class="form-label fw-semibold">From Date</label>
                        <input type="date" id="fromDate" class="form-control">
                    </div>
                    <!-- To Date -->
                    <div class="col-lg-2 col-md-3">
                        <label class="form-label fw-semibold">To Date</label>
                        <input type="date" id="toDate" class="form-control">
                    </div>
                    <!-- Actions -->
                    <div class="col-lg-4 col-md-12 d-flex gap-2 flex-wrap">
                        <button id="generateBtn" class="btn btn-primary flex-fill" onclick="generateReport()">
                            <i class="fas fa-search me-1"></i>Generate Report
                        </button>
                        <button class="btn btn-outline-secondary" onclick="resetFilter()" title="Reset">
                            <i class="fas fa-undo"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Print Header -->
        <div class="print-header">
            <h5 id="printCustName"></h5>
            <div id="printDateRange" class="text-muted"></div>
        </div>

        <!-- Summary Cards -->
        <div class="row g-3 mb-4" id="summarySection" style="display:none!important">
            <div class="col-6 col-lg-3">
                <div class="card summary-card sc-sales p-3">
                    <div class="sc-label">Total Sales</div>
                    <div class="sc-value text-primary" id="scSalesAmt">₹0</div>
                    <div class="sc-sub"><span id="scSalesCount">0</span> bills | Paid: <span id="scSalesPaid">₹0</span></div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="card summary-card sc-return p-3">
                    <div class="sc-label">Sales Returns</div>
                    <div class="sc-value text-warning" id="scReturnAmt">₹0</div>
                    <div class="sc-sub"><span id="scReturnCount">0</span> items | Qty: <span id="scReturnQty">0</span></div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="card summary-card sc-exchange p-3">
                    <div class="sc-label">Exchanges</div>
                    <div class="sc-value text-info" id="scExchangeCount">0</div>
                    <div class="sc-sub">items exchanged in period</div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="card summary-card sc-points p-3">
                    <div class="sc-label">Exchange Points</div>
                    <div class="sc-value text-success" id="scPointsCurrent">0</div>
                    <div class="sc-sub">Earned: <span id="scPointsEarned">0</span> | Used: <span id="scPointsUsed">0</span></div>
                </div>
            </div>
        </div>

        <!-- Tabs -->
        <div id="reportSection" style="display:none">
            <ul class="nav nav-tabs mb-3" id="rptTabs">
                <li class="nav-item">
                    <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tabSales">
                        <i class="fas fa-receipt me-1 text-primary"></i>Sales
                        <span class="badge bg-primary ms-1" id="badgeSales">0</span>
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tabReturn">
                        <i class="fas fa-undo me-1 text-warning"></i>Returns
                        <span class="badge bg-warning text-dark ms-1" id="badgeReturn">0</span>
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tabExchange">
                        <i class="fas fa-exchange-alt me-1 text-info"></i>Exchanges
                        <span class="badge bg-info text-dark ms-1" id="badgeExchange">0</span>
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tabPoints">
                        <i class="fas fa-coins me-1 text-success"></i>Points Ledger
                        <span class="badge bg-success ms-1" id="badgePoints">0</span>
                    </button>
                </li>
            </ul>

            <div class="tab-content">

                <!-- SALES TAB -->
                <div class="tab-pane fade show active" id="tabSales">
                    <div class="card shadow-sm">
                        <div class="card-body p-2">
                            <div class="table-responsive">
                                <table class="table table-bordered rpt-table mb-0" id="tblSales">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Bill No.</th>
                                            <th>Date</th>
                                            <th class="text-end">Total (₹)</th>
                                            <th class="text-end">Payable (₹)</th>
                                            <th class="text-end">Paid (₹)</th>
                                            <th class="text-end">Balance (₹)</th>
                                            <th>Payment</th>
                                            <th>User</th>
                                        </tr>
                                    </thead>
                                    <tbody id="bodySales"></tbody>
                                    <tfoot id="footSales"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- RETURNS TAB -->
                <div class="tab-pane fade" id="tabReturn">
                    <div class="card shadow-sm">
                        <div class="card-body p-2">
                            <div class="table-responsive">
                                <table class="table table-bordered rpt-table mb-0" id="tblReturn">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Bill No.</th>
                                            <th>Date</th>
                                            <th>Product</th>
                                            <th class="text-end">Qty</th>
                                            <th class="text-end">Price (₹)</th>
                                            <th class="text-end">Amount (₹)</th>
                                            <th>User</th>
                                        </tr>
                                    </thead>
                                    <tbody id="bodyReturn"></tbody>
                                    <tfoot id="footReturn"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- EXCHANGE TAB -->
                <div class="tab-pane fade" id="tabExchange">
                    <div class="card shadow-sm">
                        <div class="card-body p-2">
                            <div class="table-responsive">
                                <table class="table table-bordered rpt-table mb-0" id="tblExchange">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Bill No.</th>
                                            <th>Date</th>
                                            <th>Old Product</th>
                                            <th>New Product</th>
                                            <th>User</th>
                                        </tr>
                                    </thead>
                                    <tbody id="bodyExchange"></tbody>
                                    <tfoot id="footExchange"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- POINTS LEDGER TAB -->
                <div class="tab-pane fade" id="tabPoints">
                    <div class="card shadow-sm">
                        <div class="card-body p-2">
                            <div class="table-responsive">
                                <table class="table table-bordered rpt-table mb-0" id="tblPoints">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Bill No.</th>
                                            <th>Date</th>
                                            <th class="text-end">Opening Pts</th>
                                            <th class="text-end">Change</th>
                                            <th class="text-end">Closing Pts</th>
                                            <th>Notes</th>
                                            <th>User</th>
                                        </tr>
                                    </thead>
                                    <tbody id="bodyPoints"></tbody>
                                    <tfoot id="footPoints"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div><!-- tab-content -->
        </div><!-- reportSection -->

        <!-- Initial placeholder -->
        <div id="placeholder" class="empty-state">
            <i class="fas fa-user-circle text-muted"></i>
            <p class="mb-0">Search for a customer and click <strong>Generate Report</strong></p>
        </div>

    </div><!-- container -->

    <script>
    const ctx = '<%=ctx%>';
    let acTimer = null;
    const custAcList = document.getElementById('custAcList');
    const custSearch = document.getElementById('custSearch');

    // ── Set default dates (first of month → today) ──────────────────────────
    (function() {
        const now = new Date();
        const y = now.getFullYear(), m = String(now.getMonth()+1).padStart(2,'0'), d = String(now.getDate()).padStart(2,'0');
        document.getElementById('toDate').value = `${y}-${m}-${d}`;
        document.getElementById('fromDate').value = `${y}-${m}-01`;
    })();

    // ── Customer Autocomplete ────────────────────────────────────────────────
    custSearch.addEventListener('input', function() {
        clearTimeout(acTimer);
        const q = this.value.trim();
        if (q.length < 2) { hideAcList(); return; }
        acTimer = setTimeout(() => fetchCustomers(q), 280);
    });

    custSearch.addEventListener('keydown', function(e) {
        const items = custAcList.querySelectorAll('li');
        let active = custAcList.querySelector('li.active');
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            if (!active) items[0] && items[0].classList.add('active');
            else { active.classList.remove('active'); const n = active.nextElementSibling; if (n) n.classList.add('active'); }
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (active) { active.classList.remove('active'); const p = active.previousElementSibling; if (p) p.classList.add('active'); }
        } else if (e.key === 'Enter') {
            if (active) { active.click(); e.preventDefault(); }
        } else if (e.key === 'Escape') {
            hideAcList();
        }
    });

    document.addEventListener('click', function(e) {
        if (!e.target.closest('.cust-search-wrap')) hideAcList();
    });

    function fetchCustomers(q) {
        // Detect if query looks like a phone number
        const isPhone = /^\d+$/.test(q);
        const url = isPhone
            ? ctx + '/billing/customerAutocomplete.jsp?phone=' + encodeURIComponent(q)
            : ctx + '/billing/customerAutocomplete.jsp?query=' + encodeURIComponent(q);
        fetch(url).then(r => r.json()).then(data => {
            if (!data || data.length === 0) { hideAcList(); return; }
            custAcList.innerHTML = '';
            data.forEach(function(c) {
                const li = document.createElement('li');
                li.innerHTML = `<span class="cust-name">${escHtml(c.name)}</span>
                                <span class="cust-phone ms-2">${escHtml(c.phone || '')}</span>`;
                li.addEventListener('click', function() {
                    selectCustomer(c);
                });
                custAcList.appendChild(li);
            });
            custAcList.classList.remove('d-none');
        }).catch(() => hideAcList());
    }

    function selectCustomer(c) {
        document.getElementById('custId').value = c.id;
        custSearch.value = c.name + (c.phone ? ' — ' + c.phone : '');
        hideAcList();
        const badge = document.getElementById('selectedCustBadge');
        badge.innerHTML = `<span class="badge bg-success"><i class="fas fa-user me-1"></i>${escHtml(c.name)}</span>
                           ${c.phone ? `<span class="badge bg-secondary ms-1">${escHtml(c.phone)}</span>` : ''}`;
    }

    function hideAcList() { custAcList.classList.add('d-none'); custAcList.innerHTML = ''; }

    // ── Generate Report ──────────────────────────────────────────────────────
    function generateReport() {
        const custId   = document.getElementById('custId').value.trim();
        const fromDate = document.getElementById('fromDate').value;
        const toDate   = document.getElementById('toDate').value;

        if (!custId) { Swal.fire('Select Customer','Please select a customer from the list.','warning'); return; }
        if (!fromDate || !toDate) { Swal.fire('Select Dates','Please choose both From and To dates.','warning'); return; }

        const btn = document.getElementById('generateBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Loading…';

        fetch(ctx + '/admin/customerReport/getData.jsp?customerId=' + encodeURIComponent(custId) +
              '&fromDate=' + encodeURIComponent(fromDate) + '&toDate=' + encodeURIComponent(toDate))
        .then(r => r.json())
        .then(data => {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-search me-1"></i>Generate Report';
            if (data.error) { Swal.fire('Error', data.error, 'error'); return; }
            renderReport(data, fromDate, toDate);
        })
        .catch(err => {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-search me-1"></i>Generate Report';
            Swal.fire('Error', 'Failed to load report.', 'error');
        });
    }

    function renderReport(data, fromDate, toDate) {
        const s  = data.sales;
        const sr = data.salesReturn;
        const ex = data.exchange;
        const ep = data.exchangePoints;

        // Print header
        document.getElementById('printCustName').textContent = custSearch.value;
        document.getElementById('printDateRange').textContent = 'Period: ' + fromDate + ' to ' + toDate;

        // Summary cards
        document.getElementById('scSalesAmt').textContent    = '₹' + fmt(s.totalAmt);
        document.getElementById('scSalesCount').textContent  = s.count;
        document.getElementById('scSalesPaid').textContent   = '₹' + fmt(s.totalPaid);
        document.getElementById('scReturnAmt').textContent   = '₹' + fmt(sr.totalAmt);
        document.getElementById('scReturnCount').textContent = sr.count;
        document.getElementById('scReturnQty').textContent   = fmt(sr.totalQty);
        document.getElementById('scExchangeCount').textContent  = ex.count;
        document.getElementById('scPointsCurrent').textContent  = fmt(ep.currentBalance);
        document.getElementById('scPointsEarned').textContent   = fmt(ep.totalEarned);
        document.getElementById('scPointsUsed').textContent     = fmt(ep.totalUsed);

        // Badges on tabs
        document.getElementById('badgeSales').textContent    = s.count;
        document.getElementById('badgeReturn').textContent   = sr.count;
        document.getElementById('badgeExchange').textContent = ex.count;
        document.getElementById('badgePoints').textContent   = ep.count;

        // ── Sales Table ──
        const bSales = document.getElementById('bodySales');
        bSales.innerHTML = '';
        if (s.rows.length === 0) {
            bSales.innerHTML = emptyRow(9, 'No sales found for this period');
        } else {
            s.rows.forEach(function(r, i) {
                bSales.innerHTML += `<tr>
                    <td>${i+1}</td>
                    <td><span class="badge-bill">${escHtml(r.bill)}</span></td>
                    <td>${escHtml(r.date)}</td>
                    <td class="text-end">${fmt(r.total)}</td>
                    <td class="text-end">${fmt(r.payable)}</td>
                    <td class="text-end">${fmt(r.paid)}</td>
                    <td class="text-end ${r.balance > 0 ? 'text-danger' : ''}">${fmt(r.balance)}</td>
                    <td>${escHtml(r.paymentMode)}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
            });
            document.getElementById('footSales').innerHTML = `<tr>
                <td colspan="3" class="text-end">Totals</td>
                <td class="text-end">${fmt(s.totalAmt)}</td>
                <td class="text-end">${fmt(s.totalPayable)}</td>
                <td class="text-end">${fmt(s.totalPaid)}</td>
                <td class="text-end">${fmt(s.totalBalance)}</td>
                <td colspan="2"></td>
            </tr>`;
        }

        // ── Returns Table ──
        const bReturn = document.getElementById('bodyReturn');
        bReturn.innerHTML = '';
        if (sr.rows.length === 0) {
            bReturn.innerHTML = emptyRow(8, 'No returns found for this period');
        } else {
            sr.rows.forEach(function(r, i) {
                bReturn.innerHTML += `<tr>
                    <td>${i+1}</td>
                    <td><span class="badge-bill">${escHtml(r.bill)}</span></td>
                    <td>${escHtml(r.date)}</td>
                    <td><span class="badge-product">${escHtml(r.product)}</span></td>
                    <td class="text-end">${fmt(r.qty)}</td>
                    <td class="text-end">${fmt(r.price)}</td>
                    <td class="text-end">${fmt(r.total)}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
            });
            document.getElementById('footReturn').innerHTML = `<tr>
                <td colspan="4" class="text-end">Totals</td>
                <td class="text-end">${fmt(sr.totalQty)}</td>
                <td></td>
                <td class="text-end">${fmt(sr.totalAmt)}</td>
                <td></td>
            </tr>`;
        }

        // ── Exchange Table ──
        const bExchange = document.getElementById('bodyExchange');
        bExchange.innerHTML = '';
        if (ex.rows.length === 0) {
            bExchange.innerHTML = emptyRow(6, 'No exchanges found for this period');
        } else {
            ex.rows.forEach(function(r, i) {
                bExchange.innerHTML += `<tr>
                    <td>${i+1}</td>
                    <td><span class="badge-bill">${escHtml(r.bill)}</span></td>
                    <td>${escHtml(r.date)}</td>
                    <td><span class="badge-product">${escHtml(r.oldProd)}</span></td>
                    <td><span class="badge-product" style="background:#e6f4ea;color:#1b5e20">${escHtml(r.newProd)}</span></td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
            });
            document.getElementById('footExchange').innerHTML = `<tr>
                <td colspan="2" class="text-end">Total Exchanges</td>
                <td colspan="4">${ex.count}</td>
            </tr>`;
        }

        // ── Points Ledger ──
        const bPoints = document.getElementById('bodyPoints');
        bPoints.innerHTML = '';
        if (ep.rows.length === 0) {
            bPoints.innerHTML = emptyRow(8, 'No point transactions found for this period');
        } else {
            ep.rows.forEach(function(r, i) {
                const change = parseFloat(r.changePoints);
                const changeHtml = change >= 0
                    ? `<span class="pts-credit">+${fmt(change)}</span>`
                    : `<span class="pts-debit">${fmt(change)}</span>`;
                bPoints.innerHTML += `<tr>
                    <td>${i+1}</td>
                    <td><span class="badge-bill">${escHtml(r.bill)}</span></td>
                    <td>${escHtml(r.date)}</td>
                    <td class="text-end">${fmt(r.openingPoints)}</td>
                    <td class="text-end">${changeHtml}</td>
                    <td class="text-end fw-semibold">${fmt(r.closingPoints)}</td>
                    <td>${escHtml(r.notes)}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
            });
            document.getElementById('footPoints').innerHTML = `<tr>
                <td colspan="4" class="text-end">Totals</td>
                <td class="text-end">
                    <span class="pts-credit">+${fmt(ep.totalEarned)}</span>
                    / <span class="pts-debit">-${fmt(ep.totalUsed)}</span>
                </td>
                <td class="text-end">${fmt(ep.currentBalance)}</td>
                <td colspan="2"></td>
            </tr>`;
        }

        // Show sections
        document.getElementById('summarySection').style.display = '';
        document.getElementById('reportSection').style.display  = '';
        document.getElementById('placeholder').style.display    = 'none';

        // Activate first tab
        const firstTab = document.querySelector('#rptTabs .nav-link');
        if (firstTab) { bootstrap.Tab.getOrCreateInstance(firstTab).show(); }
    }

    function resetFilter() {
        document.getElementById('custId').value = '';
        custSearch.value = '';
        document.getElementById('selectedCustBadge').innerHTML = '';
        document.getElementById('summarySection').style.display = 'none';
        document.getElementById('reportSection').style.display  = 'none';
        document.getElementById('placeholder').style.display    = '';
        const now = new Date();
        const y = now.getFullYear(), m = String(now.getMonth()+1).padStart(2,'0'), d = String(now.getDate()).padStart(2,'0');
        document.getElementById('toDate').value   = `${y}-${m}-${d}`;
        document.getElementById('fromDate').value = `${y}-${m}-01`;
    }

    // ── Helpers ──────────────────────────────────────────────────────────────
    function fmt(n) {
        const v = parseFloat(n);
        if (isNaN(v)) return '0.00';
        return v.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
    }
    function escHtml(s) {
        if (s == null) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }
    function emptyRow(cols, msg) {
        return `<tr><td colspan="${cols}" class="empty-state"><i class="fas fa-inbox"></i>${msg}</td></tr>`;
    }
    </script>
</body>
</html>
