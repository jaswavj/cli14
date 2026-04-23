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
    <title>Product Analysis Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        :root {
            --sales-color:    #0d6efd;
            --salesret-color: #fd7e14;
            --purchase-color: #198754;
            --purret-color:   #6f42c1;
            --exchange-color: #0dcaf0;
            --cancel-color:   #dc3545;
            --stockadj-color: #6610f2;
        }
        @media print {
            .no-print { display: none !important; }
            .card { box-shadow: none !important; }
            body { font-size: 11px; }
        }

        /* ── Product Search ── */
        .prod-search-wrap { position: relative; }
        .prod-ac-list {
            position: absolute; z-index: 9999; background: #fff;
            border: 1px solid #dee2e6; border-top: none;
            width: 100%; max-height: 240px; overflow-y: auto;
            list-style: none; padding: 0; margin: 0;
            box-shadow: 0 6px 16px rgba(0,0,0,.12);
            border-radius: 0 0 6px 6px;
        }
        .prod-ac-list li {
            padding: 9px 14px; cursor: pointer; font-size: .88rem;
            border-bottom: 1px solid #f0f0f0;
        }
        .prod-ac-list li:hover, .prod-ac-list li.active {
            background: #0d6efd; color: #fff;
        }

        /* ── Summary Cards ── */
        .summary-card { border-left: 5px solid; border-radius: 8px; transition: transform .15s; }
        .summary-card:hover { transform: translateY(-2px); }
        .sc-sales    { border-color: var(--sales-color);    background: #e8f0fe; }
        .sc-salesret { border-color: var(--salesret-color); background: #fff3e0; }
        .sc-purchase { border-color: var(--purchase-color); background: #e6f4ea; }
        .sc-purret   { border-color: var(--purret-color);   background: #f3e5f5; }
        .sc-exchange { border-color: var(--exchange-color); background: #e0f7fa; }
        .sc-cancel   { border-color: var(--cancel-color);   background: #fdecea; }
        .sc-stockadj { border-color: var(--stockadj-color); background: #f0ebff; }
        .sc-value { font-size: 1.2rem; font-weight: 700; }
        .sc-label { font-size: .72rem; text-transform: uppercase; letter-spacing: .04em; opacity: .7; }
        @media (min-width: 992px) {
            #summaryCards { flex-wrap: nowrap; }
            #summaryCards > .sum-col { flex: 0 0 auto; width: 14.2857%; min-width: 0; }
        }

        /* ── Tabs ── */
        .nav-tabs .nav-link { font-weight: 600; font-size: .88rem; }
        .nav-tabs .nav-link.active { border-bottom: 3px solid #0d6efd; }

        /* ── Tables ── */
        .rpt-table thead th { background: #343a40; color: #fff; font-size: .8rem; white-space: nowrap; }
        .rpt-table tbody tr:hover { background: #f8f9fa; }
        .rpt-table td { font-size: .83rem; vertical-align: middle; }
        .badge-out { background: #fdecea; color: #c62828; font-size: .75rem; padding: 2px 8px; border-radius: 20px; }
        .badge-in  { background: #e6f4ea; color: #1b5e20; font-size: .75rem; padding: 2px 8px; border-radius: 20px; }
        .badge-bill { background: #fdecea; color: #c62828; font-size: .75rem; padding: 2px 8px; border-radius: 20px; }
        .badge-item { background: #fff3e0; color: #e65100; font-size: .75rem; padding: 2px 8px; border-radius: 20px; }

        /* ── Print header ── */
        .print-header { display: none; }
        @media print { .print-header { display: block; text-align: center; margin-bottom: 12px; } }

        /* ── Tfoot totals ── */
        tfoot td { font-weight: 700; background: #f1f3f5 !important; font-size: .83rem; }

        /* ── Empty state ── */
        .empty-state { text-align: center; padding: 40px; color: #adb5bd; }
        .empty-state i { font-size: 3rem; display: block; margin-bottom: 10px; }

        /* ── Profit chip ── */
        .profit-positive { color: #198754; font-weight: 600; }
        .profit-negative { color: #dc3545; font-weight: 600; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid mt-4 px-4">

        <!-- ── Page Header ── -->
        <div class="d-flex align-items-center justify-content-between mb-4 no-print">
            <div>
                <h4 class="mb-0 fw-bold"><i class="fas fa-cube me-2 text-primary"></i>Product Analysis Report</h4>
                <small class="text-muted">Complete sales, purchase, returns, exchanges &amp; cancellations by product</small>
            </div>
            <button onclick="window.print()" class="btn btn-outline-secondary btn-sm">
                <i class="fas fa-print me-1"></i>Print
            </button>
        </div>

        <!-- ── Filter Card ── -->
        <div class="card shadow-sm mb-4 no-print">
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <!-- Product Search -->
                    <div class="col-lg-4 col-md-6">
                        <label class="form-label fw-semibold">Product <span class="text-danger">*</span></label>
                        <div class="prod-search-wrap">
                            <input type="text" id="prodSearch" class="form-control"
                                   placeholder="Type name or code to search…" autocomplete="off">
                            <ul class="prod-ac-list d-none" id="prodAcList"></ul>
                        </div>
                        <input type="hidden" id="prodId" value="">
                        <div id="selectedProdBadge" class="mt-1"></div>
                    </div>
                    <!-- From Date -->
                    <div class="col-lg-2 col-md-3">
                        <label class="form-label fw-semibold">From Date</label>
                        <input type="date" id="fromDate" class="form-control" value="">
                    </div>
                    <!-- To Date -->
                    <div class="col-lg-2 col-md-3">
                        <label class="form-label fw-semibold">To Date</label>
                        <input type="date" id="toDate" class="form-control" value="">
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

        <!-- Print Header (only visible on print) -->
        <div class="print-header">
            <h5 id="printProductName"></h5>
            <div id="printDateRange" class="text-muted"></div>
        </div>

        <!-- ── Loading Spinner ── -->
        <div id="loadingDiv" class="text-center py-5 d-none">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-2 text-muted">Loading report…</p>
        </div>

        <!-- ── Report Area ── -->
        <div id="reportArea" class="d-none">

            <!-- Product Info Banner -->
            <div class="alert alert-primary d-flex align-items-center mb-4" id="productBanner">
                <i class="fas fa-cube me-2 fs-5"></i>
                <div>
                    <strong id="bannerProdName"></strong>
                    <span class="ms-3 text-muted small" id="bannerDateRange"></span>
                </div>
            </div>

            <!-- ── Summary Cards ── -->
            <div class="row g-2 mb-4" id="summaryCards">
                <div class="col-6 col-md-4 sum-col">
                    <div class="card summary-card sc-sales p-2 h-100">
                        <div class="sc-label" style="color:var(--sales-color)"><i class="fas fa-shopping-cart me-1"></i>Sales</div>
                        <div class="sc-value" style="color:var(--sales-color)" id="sc-sales-amt">₹0</div>
                        <div class="text-muted small"><span id="sc-sales-qty">0</span> units · <span id="sc-sales-count">0</span> bills</div>
                    </div>
                </div>
                <div class="col-6 col-md-4 sum-col">
                    <div class="card summary-card sc-salesret p-2 h-100">
                        <div class="sc-label" style="color:var(--salesret-color)"><i class="fas fa-undo-alt me-1"></i>Sales Returns</div>
                        <div class="sc-value" style="color:var(--salesret-color)" id="sc-ret-amt">₹0</div>
                        <div class="text-muted small"><span id="sc-ret-qty">0</span> units · <span id="sc-ret-count">0</span> bills</div>
                    </div>
                </div>
                <div class="col-6 col-md-4 sum-col">
                    <div class="card summary-card sc-purchase p-2 h-100">
                        <div class="sc-label" style="color:var(--purchase-color)"><i class="fas fa-truck me-1"></i>Purchase</div>
                        <div class="sc-value" style="color:var(--purchase-color)" id="sc-pur-amt">₹0</div>
                        <div class="text-muted small"><span id="sc-pur-qty">0</span> units · <span id="sc-pur-count">0</span> entries</div>
                    </div>
                </div>
                <div class="col-6 col-md-4 sum-col">
                    <div class="card summary-card sc-purret p-2 h-100">
                        <div class="sc-label" style="color:var(--purret-color)"><i class="fas fa-truck-loading me-1"></i>Pur. Returns</div>
                        <div class="sc-value" style="color:var(--purret-color)" id="sc-prret-amt">₹0</div>
                        <div class="text-muted small"><span id="sc-prret-qty">0</span> units · <span id="sc-prret-count">0</span> entries</div>
                    </div>
                </div>
                <div class="col-6 col-md-4 sum-col">
                    <div class="card summary-card sc-exchange p-2 h-100">
                        <div class="sc-label" style="color:var(--exchange-color)"><i class="fas fa-exchange-alt me-1"></i>Exchanges</div>
                        <div class="sc-value" style="color:var(--exchange-color)" id="sc-exc-count">0</div>
                        <div class="text-muted small"><span id="sc-exc-out">0</span> out · <span id="sc-exc-in">0</span> in</div>
                    </div>
                </div>
                <div class="col-6 col-md-4 sum-col">
                    <div class="card summary-card sc-cancel p-2 h-100">
                        <div class="sc-label" style="color:var(--cancel-color)"><i class="fas fa-ban me-1"></i>Cancelled</div>
                        <div class="sc-value" style="color:var(--cancel-color)" id="sc-can-amt">₹0</div>
                        <div class="text-muted small"><span id="sc-can-qty">0</span> units · <span id="sc-can-count">0</span> records</div>
                    </div>
                </div>
                <div class="col-6 col-md-4 sum-col">
                    <div class="card summary-card sc-stockadj p-2 h-100">
                        <div class="sc-label" style="color:var(--stockadj-color)"><i class="fas fa-sliders-h me-1"></i>Stock Adj.</div>
                        <div class="sc-value" style="color:var(--stockadj-color)" id="sc-adj-count">0</div>
                        <div class="text-muted small">+<span id="sc-adj-add">0</span> / −<span id="sc-adj-remove">0</span></div>
                    </div>
                </div>
            </div>

            <!-- ── Tabs ── -->
            <ul class="nav nav-tabs mb-3 no-print" id="reportTabs">
                <li class="nav-item">
                    <a class="nav-link active" data-bs-toggle="tab" href="#tabSales">
                        <i class="fas fa-shopping-cart me-1 text-primary"></i>Sales
                        <span class="badge bg-primary ms-1" id="badge-sales">0</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#tabSalesReturn">
                        <i class="fas fa-undo-alt me-1" style="color:var(--salesret-color)"></i>Sales Returns
                        <span class="badge ms-1" style="background:var(--salesret-color)" id="badge-ret">0</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#tabPurchase">
                        <i class="fas fa-truck me-1 text-success"></i>Purchase
                        <span class="badge bg-success ms-1" id="badge-pur">0</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#tabPurchaseReturn">
                        <i class="fas fa-truck-loading me-1" style="color:var(--purret-color)"></i>Pur. Returns
                        <span class="badge ms-1" style="background:var(--purret-color)" id="badge-prret">0</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#tabExchange">
                        <i class="fas fa-exchange-alt me-1" style="color:var(--exchange-color)"></i>Exchanges
                        <span class="badge ms-1" style="background:var(--exchange-color);color:#000" id="badge-exc">0</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#tabStockAdj">
                        <i class="fas fa-sliders-h me-1" style="color:var(--stockadj-color)"></i>Stock Adj.
                        <span class="badge ms-1" style="background:var(--stockadj-color)" id="badge-adj">0</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-bs-toggle="tab" href="#tabCancel">
                        <i class="fas fa-ban me-1 text-danger"></i>Cancelled
                        <span class="badge bg-danger ms-1" id="badge-can">0</span>
                    </a>
                </li>
            </ul>

            <div class="tab-content">

                <!-- ── SALES TAB ── -->
                <div class="tab-pane fade show active" id="tabSales">
                    <div class="card shadow-sm">
                        <div class="card-header d-flex justify-content-between align-items-center py-2">
                            <span class="fw-semibold text-primary"><i class="fas fa-shopping-cart me-1"></i>Sales Details</span>
                            <small class="text-muted" id="sales-subtitle"></small>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 rpt-table" id="salesTable">
                                    <thead><tr>
                                        <th>#</th><th>Bill No</th><th>Date</th><th>Customer</th>
                                        <th class="text-end">Qty</th><th class="text-end">Price</th>
                                        <th class="text-end">Disc%</th><th class="text-end">GST%</th>
                                        <th class="text-end">Amount</th><th class="text-end">Cost</th>
                                        <th class="text-end">Profit</th><th>User</th>
                                    </tr></thead>
                                    <tbody id="salesBody"></tbody>
                                    <tfoot id="salesFoot"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ── SALES RETURNS TAB ── -->
                <div class="tab-pane fade" id="tabSalesReturn">
                    <div class="card shadow-sm">
                        <div class="card-header d-flex justify-content-between align-items-center py-2">
                            <span class="fw-semibold" style="color:var(--salesret-color)"><i class="fas fa-undo-alt me-1"></i>Sales Returns Details</span>
                            <small class="text-muted" id="ret-subtitle"></small>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 rpt-table" id="retTable">
                                    <thead><tr>
                                        <th>#</th><th>Bill No</th><th>Date</th><th>Customer</th>
                                        <th class="text-end">Qty</th><th class="text-end">Price</th>
                                        <th class="text-end">Amount</th><th>User</th>
                                    </tr></thead>
                                    <tbody id="retBody"></tbody>
                                    <tfoot id="retFoot"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ── PURCHASE TAB ── -->
                <div class="tab-pane fade" id="tabPurchase">
                    <div class="card shadow-sm">
                        <div class="card-header d-flex justify-content-between align-items-center py-2">
                            <span class="fw-semibold text-success"><i class="fas fa-truck me-1"></i>Purchase Details</span>
                            <small class="text-muted" id="pur-subtitle"></small>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 rpt-table" id="purTable">
                                    <thead><tr>
                                        <th>#</th><th>PR No</th><th>Invoice No</th><th>Date</th><th>Supplier</th>
                                        <th class="text-end">Qty</th><th class="text-end">Free</th>
                                        <th class="text-end">Rate</th><th class="text-end">MRP</th>
                                        <th class="text-end">Disc%</th><th class="text-end">Tax%</th>
                                        <th class="text-end">Total</th><th class="text-end">Net Amt</th>
                                        <th>User</th>
                                    </tr></thead>
                                    <tbody id="purBody"></tbody>
                                    <tfoot id="purFoot"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ── PURCHASE RETURNS TAB ── -->
                <div class="tab-pane fade" id="tabPurchaseReturn">
                    <div class="card shadow-sm">
                        <div class="card-header d-flex justify-content-between align-items-center py-2">
                            <span class="fw-semibold" style="color:var(--purret-color)"><i class="fas fa-truck-loading me-1"></i>Purchase Returns Details</span>
                            <small class="text-muted" id="prret-subtitle"></small>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 rpt-table" id="prretTable">
                                    <thead><tr>
                                        <th>#</th><th>Return No</th><th>Date</th><th>Supplier</th>
                                        <th class="text-end">Qty</th><th class="text-end">Rate</th>
                                        <th class="text-end">Amount</th><th>Notes</th><th>User</th>
                                    </tr></thead>
                                    <tbody id="prretBody"></tbody>
                                    <tfoot id="prretFoot"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ── EXCHANGE TAB ── -->
                <div class="tab-pane fade" id="tabExchange">
                    <div class="card shadow-sm">
                        <div class="card-header d-flex justify-content-between align-items-center py-2">
                            <span class="fw-semibold" style="color:#0891b2"><i class="fas fa-exchange-alt me-1"></i>Exchange Details</span>
                            <small class="text-muted" id="exc-subtitle"></small>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 rpt-table" id="excTable">
                                    <thead><tr>
                                        <th>#</th><th>Bill No</th><th>Date</th><th>Customer</th>
                                        <th>Old Product</th><th>New Product</th>
                                        <th class="text-center">Direction</th><th>User</th>
                                    </tr></thead>
                                    <tbody id="excBody"></tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ── STOCK ADJUSTMENT TAB ── -->
                <div class="tab-pane fade" id="tabStockAdj">
                    <div class="card shadow-sm">
                        <div class="card-header d-flex justify-content-between align-items-center py-2">
                            <span class="fw-semibold" style="color:var(--stockadj-color)"><i class="fas fa-sliders-h me-1"></i>Stock Adjustment Details</span>
                            <small class="text-muted" id="adj-subtitle"></small>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 rpt-table" id="adjTable">
                                    <thead><tr>
                                        <th>#</th><th>Date</th><th>Time</th>
                                        <th class="text-center">Action</th>
                                        <th class="text-end">Stock</th>
                                        <th>Notes</th><th>User</th>
                                    </tr></thead>
                                    <tbody id="adjBody"></tbody>
                                    <tfoot id="adjFoot"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ── CANCEL TAB ── -->
                <div class="tab-pane fade" id="tabCancel">
                    <div class="card shadow-sm">
                        <div class="card-header d-flex justify-content-between align-items-center py-2">
                            <span class="fw-semibold text-danger"><i class="fas fa-ban me-1"></i>Cancellation Details</span>
                            <small class="text-muted" id="can-subtitle"></small>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 rpt-table" id="canTable">
                                    <thead><tr>
                                        <th>#</th><th>Bill No</th><th>Date</th><th>Customer</th>
                                        <th class="text-end">Qty</th><th class="text-end">Price</th>
                                        <th class="text-end">Amount</th>
                                        <th class="text-center">Type</th><th>User</th>
                                    </tr></thead>
                                    <tbody id="canBody"></tbody>
                                    <tfoot id="canFoot"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div><!-- tab-content -->
        </div><!-- reportArea -->

    </div><!-- container -->

    <script>
    const CTX = '<%=ctx%>';
    let acTimer = null;

    // ── Default dates ────────────────────────────────────────────────────────
    (function() {
        const today = new Date();
        const y = today.getFullYear();
        const m = String(today.getMonth()+1).padStart(2,'0');
        const d = String(today.getDate()).padStart(2,'0');
        const first = y + '-' + m + '-01';
        const todayStr = y + '-' + m + '-' + d;
        document.getElementById('fromDate').value = first;
        document.getElementById('toDate').value   = todayStr;
    })();

    // ── Product Autocomplete ─────────────────────────────────────────────────
    document.getElementById('prodSearch').addEventListener('input', function() {
        clearTimeout(acTimer);
        document.getElementById('prodId').value = '';
        document.getElementById('selectedProdBadge').innerHTML = '';
        const q = this.value.trim();
        if (q.length < 1) { document.getElementById('prodAcList').classList.add('d-none'); return; }
        acTimer = setTimeout(() => {
            fetch(CTX + '/product/purchase/auto_complete.jsp?typeId=1&q=' + encodeURIComponent(q))
                .then(r => r.text())
                .then(data => renderAc(data.trim()))
                .catch(() => {});
        }, 200);
    });

    function renderAc(data) {
        const list = document.getElementById('prodAcList');
        list.innerHTML = '';
        if (!data) { list.classList.add('d-none'); return; }
        const lines = data.split('\n').filter(l => l.trim());
        if (!lines.length) { list.classList.add('d-none'); return; }
        lines.forEach(line => {
            const parts  = line.trim().split('<#>');
            const name   = parts[0] || '';
            const code   = parts[1] || '';
            const li = document.createElement('li');
            li.textContent = code ? name + ' (' + code + ')' : name;
            li.dataset.name = name;
            li.addEventListener('click', () => selectProduct(name, code));
            list.appendChild(li);
        });
        list.classList.remove('d-none');
    }

    function selectProduct(name, code) {
        document.getElementById('prodSearch').value = code ? name + ' (' + code + ')' : name;
        document.getElementById('prodAcList').classList.add('d-none');
        // resolve prodId via details.jsp
        fetch(CTX + '/product/purchase/details.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'status=1&productName=' + encodeURIComponent(name)
        }).then(r => r.text()).then(txt => {
            const parts = txt.trim().split('<#>');
            if (parts.length > 6) {
                document.getElementById('prodId').value = parts[6]; // prodsId
                document.getElementById('selectedProdBadge').innerHTML =
                    '<span class="badge bg-light text-dark border"><i class="fas fa-cube me-1 text-primary"></i>' +
                    escHtml(name) + (code ? ' <span class="text-muted">(' + escHtml(code) + ')</span>' : '') + '</span>';
            }
        }).catch(() => {});
    }

    document.addEventListener('click', e => {
        if (!e.target.closest('.prod-search-wrap'))
            document.getElementById('prodAcList').classList.add('d-none');
    });

    // ── Generate Report ──────────────────────────────────────────────────────
    function generateReport() {
        const prodId   = document.getElementById('prodId').value.trim();
        const fromDate = document.getElementById('fromDate').value.trim();
        const toDate   = document.getElementById('toDate').value.trim();
        const prodName = document.getElementById('prodSearch').value.trim();

        if (!prodId) {
            Swal.fire({ icon:'warning', title:'Select Product', text:'Please select a product from the list.', confirmButtonText:'OK' });
            return;
        }
        if (!fromDate || !toDate) {
            Swal.fire({ icon:'warning', title:'Select Dates', text:'Please fill both From Date and To Date.', confirmButtonText:'OK' });
            return;
        }

        document.getElementById('reportArea').classList.add('d-none');
        document.getElementById('loadingDiv').classList.remove('d-none');
        document.getElementById('generateBtn').disabled = true;

        fetch(CTX + '/admin/productReport/getData.jsp?prodId=' + encodeURIComponent(prodId)
            + '&fromDate=' + encodeURIComponent(fromDate)
            + '&toDate='   + encodeURIComponent(toDate))
        .then(r => r.json())
        .then(data => {
            document.getElementById('loadingDiv').classList.add('d-none');
            document.getElementById('generateBtn').disabled = false;
            if (data.error) {
                Swal.fire({ icon:'error', title:'Error', text: data.error });
                return;
            }
            renderReport(data, prodName, fromDate, toDate);
        })
        .catch(err => {
            document.getElementById('loadingDiv').classList.add('d-none');
            document.getElementById('generateBtn').disabled = false;
            Swal.fire({ icon:'error', title:'Network Error', text: err.toString() });
        });
    }

    // ── Render ───────────────────────────────────────────────────────────────
    function renderReport(data, prodName, fromDate, toDate) {
        const dateLabel = formatDate(fromDate) + ' — ' + formatDate(toDate);

        document.getElementById('printProductName').textContent = 'Product: ' + prodName;
        document.getElementById('printDateRange').textContent   = dateLabel;
        document.getElementById('bannerProdName').textContent   = prodName;
        document.getElementById('bannerDateRange').textContent  = dateLabel;

        const s  = data.sales;
        const sr = data.salesReturn;
        const p  = data.purchase;
        const pr = data.purchaseReturn;
        const ex = data.exchange;
        const ca = data.cancelled;

        // Summary cards
        set('sc-sales-amt',   '₹' + fmt2(s.totalAmt));
        set('sc-sales-qty',   fmt2(s.totalQty));
        set('sc-sales-count', s.count);
        set('sc-ret-amt',     '₹' + fmt2(sr.totalAmt));
        set('sc-ret-qty',     fmt2(sr.totalQty));
        set('sc-ret-count',   sr.count);
        set('sc-pur-amt',     '₹' + fmt2(p.totalAmt));
        set('sc-pur-qty',     fmt2(p.totalQty));
        set('sc-pur-count',   p.count);
        set('sc-prret-amt',   '₹' + fmt2(pr.totalAmt));
        set('sc-prret-qty',   fmt2(pr.totalQty));
        set('sc-prret-count', pr.count);
        set('sc-exc-count',   ex.count);
        set('sc-exc-out',     ex.outCount);
        set('sc-exc-in',      ex.inCount);
        set('sc-can-amt',     '₹' + fmt2(ca.totalAmt));
        set('sc-can-qty',     fmt2(ca.totalQty));
        set('sc-can-count',   ca.count);

        // Badges
        set('badge-sales', s.count);
        set('badge-ret',   sr.count);
        set('badge-pur',   p.count);
        set('badge-prret', pr.count);
        set('badge-exc',   ex.count);
        set('badge-can',   ca.count);

        // ── Sales table ─────────────────────────────────────────────────────
        let sHtml = '', sTotQty = 0, sTotAmt = 0, sTotCost = 0;
        if (s.rows.length === 0) {
            sHtml = emptyRow(12, 'No sales found in this period');
        } else {
            s.rows.forEach((r, i) => {
                const profit = r.total - (r.cost * r.qty);
                const profCls = profit >= 0 ? 'profit-positive' : 'profit-negative';
                sHtml += `<tr>
                    <td>${i+1}</td>
                    <td>${escHtml(r.bill)}</td>
                    <td>${r.date}</td>
                    <td>${escHtml(r.cus)}</td>
                    <td class="text-end">${fmt2(r.qty)}</td>
                    <td class="text-end">₹${fmt2(r.price)}</td>
                    <td class="text-end">${fmt2(r.disc)}%</td>
                    <td class="text-end">${fmt2(r.gst)}%</td>
                    <td class="text-end fw-semibold">₹${fmt2(r.total)}</td>
                    <td class="text-end text-muted">₹${fmt2(r.cost)}</td>
                    <td class="text-end ${profCls}">₹${fmt2(profit)}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
                sTotQty += r.qty; sTotAmt += r.total; sTotCost += (r.cost * r.qty);
            });
        }
        document.getElementById('salesBody').innerHTML = sHtml;
        document.getElementById('salesFoot').innerHTML = s.rows.length > 0 ?
            `<tr><td colspan="4"><strong>Total</strong></td>
             <td class="text-end">${fmt2(sTotQty)}</td>
             <td colspan="3"></td>
             <td class="text-end">₹${fmt2(sTotAmt)}</td>
             <td class="text-end">₹${fmt2(sTotCost)}</td>
             <td class="text-end ${(sTotAmt-sTotCost)>=0?'profit-positive':'profit-negative'}">₹${fmt2(sTotAmt-sTotCost)}</td>
             <td></td></tr>` : '';
        set('sales-subtitle', s.rows.length + ' record(s) | Total: ₹' + fmt2(s.totalAmt));

        // ── Sales Returns table ──────────────────────────────────────────────
        let rHtml = '', rTotQty = 0, rTotAmt = 0;
        if (sr.rows.length === 0) {
            rHtml = emptyRow(8, 'No sales returns found in this period');
        } else {
            sr.rows.forEach((r, i) => {
                rHtml += `<tr>
                    <td>${i+1}</td><td>${escHtml(r.bill)}</td><td>${r.date}</td>
                    <td>${escHtml(r.cus)}</td>
                    <td class="text-end">${fmt2(r.qty)}</td>
                    <td class="text-end">₹${fmt2(r.price)}</td>
                    <td class="text-end fw-semibold" style="color:var(--salesret-color)">₹${fmt2(r.total)}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
                rTotQty += r.qty; rTotAmt += r.total;
            });
        }
        document.getElementById('retBody').innerHTML = rHtml;
        document.getElementById('retFoot').innerHTML = sr.rows.length > 0 ?
            `<tr><td colspan="4"><strong>Total</strong></td>
             <td class="text-end">${fmt2(rTotQty)}</td><td></td>
             <td class="text-end">₹${fmt2(rTotAmt)}</td><td></td></tr>` : '';
        set('ret-subtitle', sr.rows.length + ' record(s) | Total: ₹' + fmt2(sr.totalAmt));

        // ── Purchase table ───────────────────────────────────────────────────
        let pHtml = '', pTotQty = 0, pTotAmt = 0;
        if (p.rows.length === 0) {
            pHtml = emptyRow(14, 'No purchases found in this period');
        } else {
            p.rows.forEach((r, i) => {
                pHtml += `<tr>
                    <td>${i+1}</td><td>${escHtml(r.prno)}</td><td>${escHtml(r.invno)}</td>
                    <td>${r.date}</td><td>${escHtml(r.supplier)}</td>
                    <td class="text-end">${fmt2(r.qty)}</td>
                    <td class="text-end text-muted">${fmt2(r.free)}</td>
                    <td class="text-end">₹${fmt2(r.rate)}</td>
                    <td class="text-end">₹${fmt2(r.mrp)}</td>
                    <td class="text-end">${fmt2(r.disc)}%</td>
                    <td class="text-end">${fmt2(r.tax)}%</td>
                    <td class="text-end">₹${fmt2(r.total)}</td>
                    <td class="text-end fw-semibold text-success">₹${fmt2(r.netamt)}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
                pTotQty += r.qty; pTotAmt += r.netamt;
            });
        }
        document.getElementById('purBody').innerHTML = pHtml;
        document.getElementById('purFoot').innerHTML = p.rows.length > 0 ?
            `<tr><td colspan="5"><strong>Total</strong></td>
             <td class="text-end">${fmt2(pTotQty)}</td>
             <td colspan="6"></td>
             <td class="text-end">₹${fmt2(pTotAmt)}</td><td></td></tr>` : '';
        set('pur-subtitle', p.rows.length + ' record(s) | Net Total: ₹' + fmt2(p.totalAmt));

        // ── Purchase Returns table ───────────────────────────────────────────
        let prHtml = '', prTotQty = 0, prTotAmt = 0;
        if (pr.rows.length === 0) {
            prHtml = emptyRow(9, 'No purchase returns found in this period');
        } else {
            pr.rows.forEach((r, i) => {
                prHtml += `<tr>
                    <td>${i+1}</td><td>${escHtml(r.returnNo)}</td><td>${r.date}</td>
                    <td>${escHtml(r.supplier)}</td>
                    <td class="text-end">${fmt2(r.qty)}</td>
                    <td class="text-end">₹${fmt2(r.rate)}</td>
                    <td class="text-end fw-semibold" style="color:var(--purret-color)">₹${fmt2(r.total)}</td>
                    <td class="text-muted small">${escHtml(r.notes)}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
                prTotQty += r.qty; prTotAmt += r.total;
            });
        }
        document.getElementById('prretBody').innerHTML = prHtml;
        document.getElementById('prretFoot').innerHTML = pr.rows.length > 0 ?
            `<tr><td colspan="4"><strong>Total</strong></td>
             <td class="text-end">${fmt2(prTotQty)}</td><td></td>
             <td class="text-end">₹${fmt2(prTotAmt)}</td><td colspan="2"></td></tr>` : '';
        set('prret-subtitle', pr.rows.length + ' record(s) | Total: ₹' + fmt2(pr.totalAmt));

        // ── Exchange table ───────────────────────────────────────────────────
        let eHtml = '';
        if (ex.rows.length === 0) {
            eHtml = emptyRow(8, 'No exchanges found in this period');
        } else {
            ex.rows.forEach((r, i) => {
                const dirBadge = r.direction === 'Out'
                    ? '<span class="badge-out">⬆ Out (Exchanged Away)</span>'
                    : '<span class="badge-in">⬇ In (Received)</span>';
                eHtml += `<tr>
                    <td>${i+1}</td><td>${escHtml(r.bill)}</td><td>${r.date}</td>
                    <td>${escHtml(r.cus)}</td>
                    <td class="text-muted">${escHtml(r.oldProd)}</td>
                    <td>${escHtml(r.newProd)}</td>
                    <td class="text-center">${dirBadge}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
            });
        }
        document.getElementById('excBody').innerHTML = eHtml;
        set('exc-subtitle', ex.rows.length + ' record(s) | Out: ' + ex.outCount + '  In: ' + ex.inCount);

        // ── Cancel table ─────────────────────────────────────────────────────
        let cHtml = '', cTotQty = 0, cTotAmt = 0;
        if (ca.rows.length === 0) {
            cHtml = emptyRow(9, 'No cancellations found in this period');
        } else {
            ca.rows.forEach((r, i) => {
                const typeBadge = r.cancelType === 'Bill'
                    ? '<span class="badge-bill">Bill</span>'
                    : '<span class="badge-item">Item</span>';
                cHtml += `<tr>
                    <td>${i+1}</td><td>${escHtml(r.bill)}</td><td>${r.date}</td>
                    <td>${escHtml(r.cus)}</td>
                    <td class="text-end">${fmt2(r.qty)}</td>
                    <td class="text-end">₹${fmt2(r.price)}</td>
                    <td class="text-end fw-semibold text-danger">₹${fmt2(r.total)}</td>
                    <td class="text-center">${typeBadge}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
                cTotQty += r.qty; cTotAmt += r.total;
            });
        }
        document.getElementById('canBody').innerHTML = cHtml;
        document.getElementById('canFoot').innerHTML = ca.rows.length > 0 ?
            `<tr><td colspan="4"><strong>Total</strong></td>
             <td class="text-end">${fmt2(cTotQty)}</td><td></td>
             <td class="text-end">₹${fmt2(cTotAmt)}</td><td colspan="2"></td></tr>` : '';
        set('can-subtitle', ca.rows.length + ' record(s) | Total: ₹' + fmt2(ca.totalAmt));

        // ── Stock Adj summary ───────────────────────────────────────────────
        const sa = data.stockAdj;
        set('sc-adj-count',  sa.count);
        set('sc-adj-add',    fmt2(sa.totalAdd));
        set('sc-adj-remove', fmt2(sa.totalRemove));
        set('badge-adj',     sa.count);

        // ── Stock Adjustment table ───────────────────────────────────────────
        const adjTypeLabel = {
            '1': ['badge-in',  'Added'],
            '2': ['badge-out', 'Removed'],
            '3': ['bg-warning text-dark badge', 'Damage'],
            '4': ['bg-info text-dark badge', 'Internal Use']
        };
        let aHtml = '', aTotAdd = 0, aTotRemove = 0;
        if (sa.rows.length === 0) {
            aHtml = emptyRow(7, 'No stock adjustments found in this period');
        } else {
            sa.rows.forEach((r, i) => {
                const [badgeCls, badgeLbl] = adjTypeLabel[r.stockType] || ['badge-out', 'Removed'];
                const stockStr = fmt2(r.stock) + (r.unit ? ' ' + escHtml(r.unit) : '');
                aHtml += `<tr>
                    <td>${i+1}</td>
                    <td>${r.date}</td>
                    <td class="text-muted small">${escHtml(r.time)}</td>
                    <td class="text-center"><span class="${badgeCls}">${badgeLbl}</span></td>
                    <td class="text-end fw-semibold">${stockStr}</td>
                    <td class="text-muted small">${escHtml(r.notes)}</td>
                    <td>${escHtml(r.user)}</td>
                </tr>`;
                if (r.stockType === '1') aTotAdd += r.stock;
                else aTotRemove += r.stock;
            });
        }
        document.getElementById('adjBody').innerHTML = aHtml;
        document.getElementById('adjFoot').innerHTML = sa.rows.length > 0 ?
            `<tr><td colspan="3"><strong>Total</strong></td>
             <td></td>
             <td class="text-end">+${fmt2(aTotAdd)} / &minus;${fmt2(aTotRemove)}</td>
             <td colspan="2"></td></tr>` : '';
        set('adj-subtitle', sa.rows.length + ' record(s) | Added: ' + fmt2(sa.totalAdd) + '  Removed: ' + fmt2(sa.totalRemove));

        document.getElementById('reportArea').classList.remove('d-none');
        document.getElementById('reportArea').scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    // ── Helpers ──────────────────────────────────────────────────────────────
    function set(id, val) { document.getElementById(id).innerHTML = val; }
    function fmt2(n) { return parseFloat(n || 0).toFixed(2); }
    function escHtml(s) {
        if (!s) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }
    function formatDate(d) {
        if (!d) return '';
        const p = d.split('-');
        return p[2] + '/' + p[1] + '/' + p[0];
    }
    function emptyRow(cols, msg) {
        return `<tr><td colspan="${cols}" class="empty-state"><i class="fas fa-inbox"></i>${escHtml(msg)}</td></tr>`;
    }
    function resetFilter() {
        document.getElementById('prodSearch').value = '';
        document.getElementById('prodId').value = '';
        document.getElementById('selectedProdBadge').innerHTML = '';
        document.getElementById('reportArea').classList.add('d-none');
    }

    // Allow Enter key to trigger generate
    document.getElementById('toDate').addEventListener('keydown', e => {
        if (e.key === 'Enter') generateReport();
    });
    </script>
</body>
</html>
