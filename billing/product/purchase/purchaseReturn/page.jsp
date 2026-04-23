<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    String contextPathPre = request.getContextPath();
    // Pre-load purchaseId from query param (when coming from purchaseDetails)
    String preloadPurchaseId = request.getParameter("purchaseId");
    if (preloadPurchaseId == null) preloadPurchaseId = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Return</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .info-label { font-size: .75rem; color: #6c757d; margin-bottom: 0; }
        .return-table th { white-space: nowrap; }
        .qty-input { width: 80px; }
    </style>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container-fluid mt-3 px-4">
    <h5 class="mb-3"><i class="fas fa-undo me-2 text-warning"></i>Purchase Return</h5>

    <!-- Search / Load Purchase -->
    <div class="card shadow-sm mb-3">
        <div class="card-body py-2">
            <div class="row g-2 align-items-end">
                <div class="col-md-3">
                    <label class="form-label form-label-sm mb-0">Purchase Bill No / ID</label>
                    <input type="text" id="purchaseSearch" class="form-control form-control-sm"
                           placeholder="Enter Purchase ID or Bill No" value="<%= preloadPurchaseId %>">
                </div>
                <div class="col-auto">
                    <button class="btn btn-primary btn-sm" onclick="loadPurchase()">
                        <i class="fas fa-search me-1"></i> Load Bill
                    </button>
                </div>
                <div class="col-md-5" id="purchaseInfoPanel" style="display:none;">
                    <div class="border rounded px-3 py-1 bg-light d-flex gap-3 flex-wrap">
                        <span><span class="info-label d-block">Bill No</span><b id="infoHdr_prno">—</b></span>
                        <span><span class="info-label d-block">Invoice No</span><b id="infoHdr_invno">—</b></span>
                        <span><span class="info-label d-block">Invoice Date</span><b id="infoHdr_invdate">—</b></span>
                        <span><span class="info-label d-block">Supplier</span><b id="infoHdr_supplier">—</b></span>
                        <span><span class="info-label d-block">Bill Total</span><b id="infoHdr_total">—</b></span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Return Items Table -->
    <div class="card shadow-sm mb-3" id="returnItemsCard" style="display:none;">
        <div class="card-header py-2 d-flex justify-content-between align-items-center">
            <span class="fw-semibold">Select Items to Return</span>
            <small class="text-muted">Qty must not exceed original purchased quantity</small>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-bordered table-sm mb-0">
                    <thead class="table-light">
                        <tr>
                            <th style="width:40px;"><input type="checkbox" id="selectAll" onclick="toggleSelectAll(this)"></th>
                            <th>#</th>
                            <th>Product</th>
                            <th class="text-end">Orig Qty</th>
                            <th class="text-end">Free</th>
                            <th class="text-end">Returned</th>
                            <th class="text-end">Available</th>
                            <th class="text-end">Rate</th>
                            <th class="text-end">MRP</th>
                            <th class="text-center">Return Qty</th>
                            <th class="text-end">Return Total</th>
                        </tr>
                    </thead>
                    <tbody id="returnItemsTbody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Notes + Save -->
    <div class="card shadow-sm mb-3" id="savePanel" style="display:none;">
        <div class="card-body py-2">
            <div class="row g-2 align-items-end">
                <div class="col-md-5">
                    <label class="form-label form-label-sm mb-0">Notes / Reason</label>
                    <input type="text" id="returnNotes" class="form-control form-control-sm" placeholder="Reason for return (optional)">
                </div>
                <div class="col-md-3">
                    <label class="form-label form-label-sm mb-0">Return Total</label>
                    <input type="text" id="returnGrandTotal" class="form-control form-control-sm text-end fw-bold" readonly>
                </div>
                <div class="col-auto">
                    <button class="btn btn-success btn-sm px-4" onclick="saveReturn()">
                        <i class="fas fa-save me-1"></i> Save Return
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const CTX  = '<%=contextPathPre%>';
let _purchaseId = 0;
let _items = [];

<% if (!preloadPurchaseId.isEmpty()) { %>
window.addEventListener('DOMContentLoaded', () => loadPurchase());
<% } %>

function loadPurchase() {
    const val = document.getElementById('purchaseSearch').value.trim();
    if (!val) { Swal.fire('', 'Enter a Purchase ID or Bill No.', 'warning'); return; }
    $.ajax({
        url: CTX + '/product/purchase/purchaseReturn/getPurchaseForReturn.jsp',
        data: { purchaseId: val },
        success: function(res) {
            if (!res.success) { Swal.fire('Error', res.message, 'error'); return; }
            _purchaseId = res.header.id;
            _items = res.items;
            // Fill header panel
            document.getElementById('infoHdr_prno').textContent     = res.header.prno;
            document.getElementById('infoHdr_invno').textContent    = res.header.invno;
            document.getElementById('infoHdr_invdate').textContent  = res.header.invdate;
            document.getElementById('infoHdr_supplier').textContent = res.header.supplier;
            document.getElementById('infoHdr_total').textContent    = '₹' + parseFloat(res.header.total).toFixed(2);
            document.getElementById('purchaseInfoPanel').style.display = '';

            if (_items.length === 0) {
                Swal.fire('No Items', 'No active (non-cancelled) items found for this purchase.', 'info');
                document.getElementById('returnItemsCard').style.display = 'none';
                document.getElementById('savePanel').style.display = 'none';
                return;
            }
            renderItems();
            document.getElementById('returnItemsCard').style.display = '';
            document.getElementById('savePanel').style.display = '';
        },
        error: function() { Swal.fire('Error', 'Server error loading purchase.', 'error'); }
    });
}

function renderItems() {
    const tbody = document.getElementById('returnItemsTbody');
    tbody.innerHTML = '';
    _items.forEach((item, idx) => {
        const origQty    = parseFloat(item.qty) + parseFloat(item.free);
        const returned   = parseFloat(item.alreadyReturned || 0);
        const available  = parseFloat(item.availableQty || origQty);
        const row = `<tr>
            <td class="text-center"><input type="checkbox" class="row-chk" data-idx="${idx}" onchange="onCheckChange(this)"></td>
            <td>${idx+1}</td>
            <td>${item.product}</td>
            <td class="text-end">${parseFloat(item.qty).toFixed(3)}</td>
            <td class="text-end">${parseFloat(item.free).toFixed(3)}</td>
            <td class="text-end ${returned > 0 ? 'text-danger fw-semibold' : 'text-muted'}">${returned.toFixed(3)}</td>
            <td class="text-end fw-semibold">${available.toFixed(3)}</td>
            <td class="text-end">₹${parseFloat(item.rate).toFixed(3)}</td>
            <td class="text-end">₹${parseFloat(item.mrp).toFixed(3)}</td>
            <td class="text-center">
                <input type="number" step="0.001" min="0.001" max="${available}"
                       class="form-control form-control-sm qty-input return-qty-input text-end"
                       data-idx="${idx}" data-rate="${item.rate}" data-max="${available}"
                       value="${available.toFixed(3)}" disabled
                       oninput="updateTotal(this)">
            </td>
            <td class="text-end fw-semibold row-total" id="rowTotal_${idx}">₹0.000</td>
        </tr>`;
        tbody.insertAdjacentHTML('beforeend', row);
    });
    updateGrandTotal();
}

function onCheckChange(chk) {
    const idx = chk.dataset.idx;
    const qtyInput = document.querySelector(`.return-qty-input[data-idx="${idx}"]`);
    qtyInput.disabled = !chk.checked;
    if (chk.checked) { updateTotal(qtyInput); }
    else { document.getElementById('rowTotal_' + idx).textContent = '₹0.000'; }
    updateGrandTotal();
}

function toggleSelectAll(master) {
    document.querySelectorAll('.row-chk').forEach(chk => {
        chk.checked = master.checked;
        onCheckChange(chk);
    });
}

function updateTotal(input) {
    const idx  = input.dataset.idx;
    const rate = parseFloat(input.dataset.rate);
    const max  = parseFloat(input.dataset.max);
    let qty    = parseFloat(input.value) || 0;
    if (qty > max) { qty = max; input.value = max.toFixed(3); }
    const total = qty * rate;
    document.getElementById('rowTotal_' + idx).textContent = '₹' + total.toFixed(3);
    updateGrandTotal();
}

function updateGrandTotal() {
    let grand = 0;
    document.querySelectorAll('.row-chk:checked').forEach(chk => {
        const idx = chk.dataset.idx;
        const qtyInput = document.querySelector(`.return-qty-input[data-idx="${idx}"]`);
        const rate = parseFloat(qtyInput.dataset.rate);
        grand += (parseFloat(qtyInput.value) || 0) * rate;
    });
    document.getElementById('returnGrandTotal').value = '₹' + grand.toFixed(3);
}

function saveReturn() {
    const checked = document.querySelectorAll('.row-chk:checked');
    if (checked.length === 0) { Swal.fire('', 'Select at least one item to return.', 'warning'); return; }

    let itemsArr = '';
    let valid = true;
    checked.forEach(chk => {
        const idx = chk.dataset.idx;
        const qtyInput = document.querySelector(`.return-qty-input[data-idx="${idx}"]`);
        const qty  = parseFloat(qtyInput.value) || 0;
        const max  = parseFloat(qtyInput.dataset.max);
        const rate = parseFloat(qtyInput.dataset.rate);
        if (qty <= 0 || qty > max) { valid = false; }
        itemsArr += _items[idx].detailId + '<#>' + qty + '<#>' + rate + '<@>';
    });
    if (!valid) { Swal.fire('Validation', 'Return qty must be > 0 and ≤ original qty.', 'warning'); return; }

    const notes = document.getElementById('returnNotes').value.trim();

    Swal.fire({
        title: 'Confirm Return?',
        text: 'Stock will be reduced for returned items. This cannot be undone.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#f0a500',
        confirmButtonText: 'Yes, Save Return'
    }).then(result => {
        if (!result.isConfirmed) return;
        $.ajax({
            url: CTX + '/product/purchase/purchaseReturn/savePurchaseReturn.jsp',
            method: 'POST',
            data: { purchaseId: _purchaseId, itemsArr: itemsArr, notes: notes },
            success: function(res) {
                if (res.success) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Return Saved',
                        html: '<b>' + res.returnNo + '</b><br>' + res.message,
                        confirmButtonText: 'OK'
                    }).then(() => location.reload());
                } else {
                    Swal.fire('Error', res.message, 'error');
                }
            },
            error: function() { Swal.fire('Error', 'Server error.', 'error'); }
        });
    });
}
</script>
</body>
</html>
