<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    String contextPathExc = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Exchange - Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .exchange-badge {
            font-size: 0.7rem;
            background: #dc3545;
            color: #fff;
            padding: 2px 7px;
            border-radius: 20px;
        }
        .exchanged-row td {
            background: #f8f0ff !important;
        }
        .returned-row td {
            background: #fff3cd !important;
        }
        .return-badge {
            font-size: 0.7rem;
            background: #fd7e14;
            color: #fff;
            padding: 2px 7px;
            border-radius: 20px;
        }
        .bill-card {
            border-left: 4px solid #6c63ff;
        }
        .prod-search-input {
            position: relative;
        }
        .autocomplete-list {
            position: absolute;
            z-index: 9999;
            background: #fff;
            border: 1px solid #ccc;
            border-top: none;
            width: 100%;
            max-height: 200px;
            overflow-y: auto;
            list-style: none;
            padding: 0;
            margin: 0;
            box-shadow: 0 4px 8px rgba(0,0,0,.1);
        }
        .autocomplete-list li {
            padding: 8px 12px;
            cursor: pointer;
            font-size: 0.9rem;
        }
        .autocomplete-list li:hover, .autocomplete-list li.active {
            background: #6c63ff;
            color: #fff;
        }
        #billTable thead {
            background: #6c63ff;
            color: #fff;
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid mt-4">
        <h4 class="mb-3"><i class="fas fa-exchange-alt me-2 text-primary"></i>Product Exchange</h4>

        <!-- Bill Search -->
        <div class="card mb-4 bill-card shadow-sm">
            <div class="card-body">
                <div class="row g-2 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Bill Number</label>
                        <div class="input-group">
                            <input type="text" id="billNoInput" class="form-control" placeholder="Enter bill number…" autofocus>
                            <button class="btn btn-primary" id="searchBillBtn">
                                <i class="fas fa-search"></i> Load
                            </button>
                        </div>
                    </div>
                    <div class="col-md-8" id="billSummaryArea"></div>
                </div>
            </div>
        </div>

        <!-- Bill Items Table -->
        <div id="billItemsArea" class="d-none">
            <div class="card shadow-sm">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <span class="fw-semibold">Bill Items</span>
                    <span class="text-muted small" id="billNoDisplay"></span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover mb-0" id="billTable">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Product</th>
                                    <th>Qty</th>
                                    <th>Price</th>
                                    <th>Disc</th>
                                    <th>Total</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="billItemsTbody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Exchange Modal -->
    <div class="modal fade" id="exchangeModal" tabindex="-1" aria-labelledby="exchangeModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="exchangeModalLabel"><i class="fas fa-exchange-alt me-2"></i>Exchange Item</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3 p-3 bg-light rounded">
                        <div class="text-muted small mb-1">Replacing:</div>
                        <div class="fw-semibold" id="oldProductName">-</div>
                        <div class="d-flex gap-3 mt-1">
                            <span class="small">Qty: <strong id="oldQty">-</strong></span>
                            <span class="small">Price: ₹<strong id="oldPrice">-</strong></span>
                            <span class="small">Total: ₹<strong id="oldTotal">-</strong></span>
                        </div>
                    </div>

                    <div class="mb-3 prod-search-input">
                        <label class="form-label fw-semibold">New Product <span class="text-danger">*</span></label>
                        <input type="text" id="newProdSearch" class="form-control" placeholder="Type product name to search…" autocomplete="off">
                        <ul class="autocomplete-list d-none" id="prodAutocompleteList"></ul>
                        <input type="hidden" id="newProdId" value="">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">New Price (₹) <span class="text-danger">*</span></label>
                        <input type="number" id="newPrice" class="form-control" min="0" step="0.01" placeholder="Enter price">
                        <div class="form-text" id="priceDiffHint"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="confirmExchangeBtn">
                        <i class="fas fa-check me-1"></i>Confirm Exchange
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
    const CTX = '<%=contextPathExc%>';
    let currentBillData = null;  // { billId, customerId, items[] }
    let currentDetailId = null;
    let currentOldTotal = 0;
    let currentQty = 0;

    // ── Load bill ─────────────────────────────────────────────
    document.getElementById('searchBillBtn').addEventListener('click', loadBill);
    document.getElementById('billNoInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter') loadBill();
    });

    function loadBill() {
        const billNo = document.getElementById('billNoInput').value.trim();
        if (!billNo) return;

        fetch(CTX + '/admin/Exchange/getBillForExchange.jsp?billNo=' + encodeURIComponent(billNo))
            .then(r => r.json())
            .then(data => {
                if (!data.success) {
                    Swal.fire('Not Found', data.message || 'Bill not found.', 'error');
                    return;
                }
                currentBillData = data;
                renderBill(data);
            })
            .catch(() => Swal.fire('Error', 'Failed to load bill.', 'error'));
    }

    function renderBill(data) {
        // Summary
        document.getElementById('billSummaryArea').innerHTML = `
            <div class="d-flex flex-wrap gap-3">
                <span class="badge bg-secondary fs-6">Customer: ${escHtml(data.cusName)}</span>
                <span class="badge bg-info text-dark fs-6">Total: ₹${data.total}</span>
                <span class="badge bg-success fs-6">Payable: ₹${data.payable}</span>
                <span class="badge bg-warning text-dark fs-6">Date: ${escHtml(data.billDate)}</span>
            </div>`;
        document.getElementById('billNoDisplay').textContent = 'Bill #' + data.billNo;

        const tbody = document.getElementById('billItemsTbody');
        tbody.innerHTML = '';
        data.items.forEach((item, idx) => {
            const exchanged = item.isExchanged == 1;
            const returned  = item.isExchanged == 2;
            const tr = document.createElement('tr');
            if (exchanged) tr.classList.add('exchanged-row');
            if (returned)  tr.classList.add('returned-row');

            let statusBadge;
            if (exchanged) statusBadge = '<span class="exchange-badge">Exchanged</span>';
            else if (returned) statusBadge = '<span class="return-badge">Returned</span>';
            else statusBadge = '<span class="badge bg-success">Active</span>';

            let actionBtns;
            if (exchanged || returned) {
                actionBtns = `<button class="btn btn-sm btn-secondary" disabled><i class="fas fa-ban me-1"></i>${exchanged ? 'Exchanged' : 'Returned'}</button>`;
            } else {
                actionBtns = `
                    <button class="btn btn-sm btn-warning open-return-btn"
                        data-detail-id="${item.detailId}"
                        data-prod-name="${escHtml(item.productName)}"
                        data-qty="${item.qty}"
                        data-total="${item.total}">
                        <i class="fas fa-undo me-1"></i>Return
                    </button>`;
            }

            tr.innerHTML = `
                <td>${idx + 1}</td>
                <td>${escHtml(item.productName)}</td>
                <td>${item.qty}</td>
                <td>₹${item.price}</td>
                <td>₹${item.disc}</td>
                <td>₹${item.total}</td>
                <td>${statusBadge}</td>
                <td>${actionBtns}</td>`;
            tbody.appendChild(tr);
        });

        document.getElementById('billItemsArea').classList.remove('d-none');
        attachExchangeButtons();
        attachReturnButtons();
    }

    function attachExchangeButtons() {
        document.querySelectorAll('.open-exchange-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                currentDetailId = this.dataset.detailId;
                currentOldTotal = parseFloat(this.dataset.total);
                currentQty = parseFloat(this.dataset.qty);

                document.getElementById('oldProductName').textContent = this.dataset.prodName;
                document.getElementById('oldQty').textContent = this.dataset.qty;
                document.getElementById('oldPrice').textContent = this.dataset.price;
                document.getElementById('oldTotal').textContent = this.dataset.total;

                document.getElementById('newProdSearch').value = '';
                document.getElementById('newProdId').value = '';
                document.getElementById('newPrice').value = '';
                document.getElementById('priceDiffHint').textContent = '';
                document.getElementById('prodAutocompleteList').innerHTML = '';
                document.getElementById('prodAutocompleteList').classList.add('d-none');

                new bootstrap.Modal(document.getElementById('exchangeModal')).show();
            });
        });
    }

    // ── Return button handler ──────────────────────────────────
    function attachReturnButtons() {
        document.querySelectorAll('.open-return-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const detailId  = this.dataset.detailId;
                const prodName  = this.dataset.prodName;
                const maxQty    = parseFloat(this.dataset.qty);
                const total     = parseFloat(this.dataset.total);
                const billNo    = document.getElementById('billNoInput').value.trim();

                // Step 1 – ask how many to return
                Swal.fire({
                    title: 'Return Quantity',
                    html: `<div class="mb-2 text-start">
                               <strong>${escHtml(prodName)}</strong><br>
                               <span class="text-muted small">Available qty: ${maxQty} &nbsp;|&nbsp; Total: ₹${total.toFixed(2)}</span>
                           </div>
                           <input id="swal-ret-qty" type="number" class="swal2-input"
                               min="0.001" max="${maxQty}" step="0.001"
                               placeholder="Enter qty to return" value="${maxQty}">`,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Next',
                    cancelButtonText: 'Cancel',
                    preConfirm: () => {
                        const val = parseFloat(document.getElementById('swal-ret-qty').value);
                        if (isNaN(val) || val <= 0) {
                            Swal.showValidationMessage('Please enter a valid quantity greater than 0.');
                            return false;
                        }
                        if (val > maxQty) {
                            Swal.showValidationMessage('Qty cannot exceed available qty (' + maxQty + ').');
                            return false;
                        }
                        return val;
                    }
                }).then(step1 => {
                    if (!step1.isConfirmed) return;
                    const returnQty  = step1.value;
                    const retAmount  = parseFloat(((returnQty / maxQty) * total).toFixed(2));

                    // Step 2 – confirm
                    Swal.fire({
                        title: 'Confirm Return?',
                        html: `Return <strong>${escHtml(prodName)}</strong><br>
                               Qty: <strong>${returnQty}</strong> of ${maxQty}
                               &nbsp;|&nbsp; Amount: ₹<strong>${retAmount.toFixed(2)}</strong><br><br>
                               <span class="text-success">Stock will be restored and customer earns ₹${retAmount.toFixed(2)} exchange points.</span>`,
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonText: 'Yes, Return',
                        confirmButtonColor: '#fd7e14',
                        cancelButtonText: 'Cancel'
                    }).then(result => {
                        if (!result.isConfirmed) return;

                        const params = new URLSearchParams({ billNo, detailId, returnQty });
                        fetch(CTX + '/admin/Exchange/saveReturn.jsp', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: params.toString()
                        })
                        .then(r => r.json())
                        .then(data => {
                            if (data.success) {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Return Successful',
                                    html: data.message,
                                    confirmButtonText: 'OK'
                                }).then(() => loadBill());
                            } else {
                                Swal.fire('Error', data.message || 'Return failed.', 'error');
                            }
                        })
                        .catch(() => Swal.fire('Error', 'Network error.', 'error'));
                    });
                });
            });
        });
    }

    // ── Product Autocomplete ────────────────────────────────────
    let acTimer = null;
    document.getElementById('newProdSearch').addEventListener('input', function() {
        clearTimeout(acTimer);
        const q = this.value.trim();
        if (q.length < 2) {
            document.getElementById('prodAutocompleteList').classList.add('d-none');
            return;
        }
        acTimer = setTimeout(() => {
            fetch(CTX + '/admin/Exchange/searchProductForExchange.jsp?term=' + encodeURIComponent(q))
                .then(r => r.json())
                .then(arr => renderAutocomplete(arr))
                .catch(() => {});
        }, 250);
    });

    function renderAutocomplete(arr) {
        const list = document.getElementById('prodAutocompleteList');
        list.innerHTML = '';
        if (!arr || arr.length === 0) { list.classList.add('d-none'); return; }
        arr.forEach(item => {
            const li = document.createElement('li');
            li.textContent = (item.code ? item.name + ' (' + item.code + ')' : item.name) + ' — ₹' + item.price;
            li.addEventListener('click', () => {
                document.getElementById('newProdSearch').value = item.name;
                document.getElementById('newProdId').value = item.id;
                document.getElementById('newPrice').value = item.price;
                list.classList.add('d-none');
                updatePriceDiff();
            });
            list.appendChild(li);
        });
        list.classList.remove('d-none');
    }

    document.getElementById('newPrice').addEventListener('input', updatePriceDiff);

    function updatePriceDiff() {
        const newPrice = parseFloat(document.getElementById('newPrice').value) || 0;
        const newTotal = newPrice * currentQty;
        const diff = newTotal - currentOldTotal;
        const hint = document.getElementById('priceDiffHint');
        if (newPrice <= 0) { hint.textContent = ''; return; }
        if (diff < 0) {
            hint.innerHTML = `<span class="text-success"><i class="fas fa-arrow-down me-1"></i>Lower by ₹${Math.abs(diff).toFixed(2)} — customer earns exchange points</span>`;
        } else if (diff > 0) {
            hint.innerHTML = `<span class="text-danger"><i class="fas fa-arrow-up me-1"></i>Higher by ₹${diff.toFixed(2)} — bill amount will increase</span>`;
        } else {
            hint.innerHTML = `<span class="text-secondary">Same amount — no change to bill or points</span>`;
        }
    }

    // Close autocomplete on outside click
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.prod-search-input')) {
            document.getElementById('prodAutocompleteList').classList.add('d-none');
        }
    });

    // ── Confirm Exchange ────────────────────────────────────────
    document.getElementById('confirmExchangeBtn').addEventListener('click', function() {
        const newProdId = document.getElementById('newProdId').value.trim();
        const newPrice  = document.getElementById('newPrice').value.trim();
        const billNo    = document.getElementById('billNoInput').value.trim();

        if (!newProdId) { Swal.fire('Validation', 'Please select a product from the list.', 'warning'); return; }
        if (!newPrice || parseFloat(newPrice) <= 0) { Swal.fire('Validation', 'Please enter a valid price.', 'warning'); return; }

        Swal.fire({
            title: 'Confirm Exchange?',
            text: 'This will update the bill and product details. Continue?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Yes, Exchange',
            cancelButtonText: 'Cancel'
        }).then(result => {
            if (!result.isConfirmed) return;

            const params = new URLSearchParams({
                billNo:    billNo,
                detailId:  currentDetailId,
                newProdId: newProdId,
                newPrice:  newPrice
            });

            fetch(CTX + '/admin/Exchange/saveExchange.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    bootstrap.Modal.getInstance(document.getElementById('exchangeModal')).hide();
                    Swal.fire({
                        icon: 'success',
                        title: 'Exchange Successful',
                        html: data.message,
                        confirmButtonText: 'OK'
                    }).then(() => loadBill());
                } else {
                    Swal.fire('Error', data.message || 'Exchange failed.', 'error');
                }
            })
            .catch(() => Swal.fire('Error', 'Network error.', 'error'));
        });
    });

    function escHtml(str) {
        if (!str) return '-';
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
    </script>
</body>
</html>
