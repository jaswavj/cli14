<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    String ctx = request.getContextPath();
    String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Exchange &amp; Return Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        @media print {
            .no-print { display: none !important; }
            .card { border: none !important; box-shadow: none !important; }
            body { font-size: 12px; }
        }
        .type-exchange { background: #e8d5ff; color: #6610f2; font-size: 0.72rem; padding: 2px 8px; border-radius: 20px; white-space: nowrap; }
        .type-return   { background: #ffe8cc; color: #d63d00; font-size: 0.72rem; padding: 2px 8px; border-radius: 20px; white-space: nowrap; }
        #reportTable thead th { background: #4b0082; color: #fff; white-space: nowrap; }
        .summary-card  { border-left: 4px solid; border-radius: 6px; }
        .summary-exchange { border-color: #6610f2; background: #f8f0ff; }
        .summary-return   { border-color: #fd7e14; background: #fff3cd; }
        .summary-points   { border-color: #198754; background: #d1e7dd; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid mt-4 px-4">
        <div class="d-flex align-items-center justify-content-between mb-3 no-print">
            <h4 class="mb-0"><i class="fas fa-file-alt me-2 text-purple"></i>Exchange &amp; Return Report</h4>
            <a href="<%=ctx%>/admin/Exchange/page.jsp" class="btn btn-sm btn-outline-secondary">
                <i class="fas fa-arrow-left me-1"></i>Back to Exchange
            </a>
        </div>

        <!-- ── Filter ───────────────────────────────────────────────────── -->
        <div class="card shadow-sm mb-4 no-print">
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-sm-3">
                        <label class="form-label fw-semibold">From Date</label>
                        <input type="date" id="fromDate" class="form-control" value="<%=today%>">
                    </div>
                    <div class="col-sm-3">
                        <label class="form-label fw-semibold">To Date</label>
                        <input type="date" id="toDate" class="form-control" value="<%=today%>">
                    </div>
                    <div class="col-sm-3">
                        <label class="form-label fw-semibold">Type</label>
                        <select id="typeFilter" class="form-select">
                            <option value="0">All (Exchange + Return)</option>
                            <option value="1">Exchange Only</option>
                            <option value="2">Return Only</option>
                        </select>
                    </div>
                    <div class="col-sm-3 d-flex gap-2">
                        <button id="loadBtn" class="btn btn-primary flex-fill">
                            <i class="fas fa-search me-1"></i>Generate
                        </button>
                        <button onclick="window.print()" class="btn btn-outline-secondary" title="Print">
                            <i class="fas fa-print"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── Summary cards ────────────────────────────────────────────── -->
        <div id="summaryArea" class="row g-3 mb-4 d-none no-print">
            <div class="col-sm-4">
                <div class="card summary-card summary-exchange p-3">
                    <div class="text-muted small">Total Exchanges</div>
                    <div class="fw-bold fs-4" id="sumExchange">0</div>
                </div>
            </div>
            <div class="col-sm-4">
                <div class="card summary-card summary-return p-3">
                    <div class="text-muted small">Total Returns</div>
                    <div class="fw-bold fs-4" id="sumReturn">0</div>
                </div>
            </div>
            <div class="col-sm-4">
                <div class="card summary-card summary-points p-3">
                    <div class="text-muted small">Total Points Given</div>
                    <div class="fw-bold fs-4" id="sumPoints">&#8377;0.00</div>
                </div>
            </div>
        </div>

        <!-- ── Print header (visible only on print) ─────────────────────── -->
        <div class="d-none d-print-block mb-3">
            <h5 class="text-center mb-0">Exchange &amp; Return Report</h5>
            <p class="text-center mb-0 small" id="printDateRange"></p>
        </div>

        <!-- ── Table ─────────────────────────────────────────────────────── -->
        <div class="card shadow-sm">
            <div class="card-body p-0">
                <div id="tableWrap" class="table-responsive d-none">
                    <table class="table table-bordered table-hover mb-0 align-middle" id="reportTable">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Date &amp; Time</th>
                                <th>Bill No</th>
                                <th>Customer</th>
                                <th>Old Product</th>
                                <th>New Product</th>
                                <th>Type</th>
                                <th class="text-end">Points Earned</th>
                                <th>Staff</th>
                            </tr>
                        </thead>
                        <tbody id="reportBody"></tbody>
                    </table>
                </div>
                <div id="emptyMsg" class="text-center text-muted py-5 d-none">
                    <i class="fas fa-inbox fa-2x mb-2 d-block"></i>No records found for the selected range.
                </div>
                <div id="loadingMsg" class="text-center text-muted py-5 d-none">
                    <div class="spinner-border spinner-border-sm me-2"></div>Loading...
                </div>
            </div>
        </div>
    </div>

    <script>
    const CTX = '<%=ctx%>';

    document.getElementById('loadBtn').addEventListener('click', loadReport);

    function loadReport() {
        const fromDate   = document.getElementById('fromDate').value;
        const toDate     = document.getElementById('toDate').value;
        const typeFilter = document.getElementById('typeFilter').value;

        if (!fromDate || !toDate) {
            alert('Please select both dates.');
            return;
        }

        setLoading(true);

        fetch(CTX + '/admin/Exchange/getExchangeReport.jsp?fromDate=' + fromDate
              + '&toDate=' + toDate + '&type=' + typeFilter)
            .then(r => r.json())
            .then(data => {
                setLoading(false);
                if (!data.success) { alert(data.message || 'Error loading report'); return; }
                renderReport(data.rows, fromDate, toDate);
            })
            .catch(() => { setLoading(false); alert('Network error'); });
    }

    function renderReport(rows, fromDate, toDate) {
        const tbody       = document.getElementById('reportBody');
        const tableWrap   = document.getElementById('tableWrap');
        const emptyMsg    = document.getElementById('emptyMsg');
        const summaryArea = document.getElementById('summaryArea');

        tbody.innerHTML = '';

        if (!rows || rows.length === 0) {
            tableWrap.classList.add('d-none');
            summaryArea.classList.add('d-none');
            emptyMsg.classList.remove('d-none');
            return;
        }

        emptyMsg.classList.add('d-none');

        let cntExchange = 0, cntReturn = 0, totalPoints = 0;

        rows.forEach((row, idx) => {
            const isExchange = row.type === 1;
            const tr = document.createElement('tr');
            tr.innerHTML =
                `<td>${idx + 1}</td>` +
                `<td>${row.dt}</td>` +
                `<td><strong>${esc(row.billNo)}</strong></td>` +
                `<td>${esc(row.customer)}</td>` +
                `<td>${esc(row.oldProd)}</td>` +
                `<td>${isExchange ? esc(row.newProd) : '<span class="text-muted">—</span>'}</td>` +
                `<td>${isExchange
                        ? '<span class="type-exchange"><i class="fas fa-exchange-alt me-1"></i>Exchange</span>'
                        : '<span class="type-return"><i class="fas fa-undo me-1"></i>Return</span>'}</td>` +
                `<td class="text-end">₹${parseFloat(row.points).toFixed(2)}</td>` +
                `<td>${esc(row.staff)}</td>`;
            tbody.appendChild(tr);

            if (isExchange) cntExchange++; else cntReturn++;
            totalPoints += parseFloat(row.points) || 0;
        });

        tableWrap.classList.remove('d-none');
        summaryArea.classList.remove('d-none');

        document.getElementById('sumExchange').textContent = cntExchange;
        document.getElementById('sumReturn').textContent   = cntReturn;
        document.getElementById('sumPoints').textContent   = '₹' + totalPoints.toFixed(2);

        // Print header
        document.getElementById('printDateRange').textContent =
            'Period: ' + formatDisplayDate(fromDate) + ' to ' + formatDisplayDate(toDate);
    }

    function setLoading(on) {
        document.getElementById('loadingMsg').classList.toggle('d-none', !on);
        document.getElementById('tableWrap').classList.add('d-none');
        document.getElementById('emptyMsg').classList.add('d-none');
        document.getElementById('loadBtn').disabled = on;
    }

    function esc(str) {
        if (!str) return '-';
        return String(str)
            .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }

    function formatDisplayDate(ymd) {
        if (!ymd) return '';
        const [y, m, d] = ymd.split('-');
        return d + '-' + m + '-' + y;
    }
    </script>
</body>
</html>
