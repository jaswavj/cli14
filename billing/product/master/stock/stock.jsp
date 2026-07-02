<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page errorPage="" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>STOCK - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        body { background: #f5f7fa; }
        .table td, .table th { vertical-align: middle; }
        .stock-adjust-form .form-control,
        .stock-adjust-form .form-select {
            font-size: 0.8rem;
            padding: 0.25rem 0.4rem;
        }
        .stock-available {
            font-weight: 600;
            color: #2d3748;
            white-space: nowrap;
        }
        .stock-qty-input::-webkit-outer-spin-button,
        .stock-qty-input::-webkit-inner-spin-button {
            -webkit-appearance: none;
            margin: 0;
        }
        .stock-qty-input[type=number] {
            -moz-appearance: textfield;
            appearance: textfield;
        }
        tr.row-selected {
            background-color: #ebf8ff !important;
        }
        tr.row-selected td:first-child {
            box-shadow: inset 3px 0 0 #3182ce;
        }
        #selectedProductsList {
            font-size: 0.8rem;
            color: #4a5568;
            max-height: 60px;
            overflow-y: auto;
        }
        .selected-chip {
            display: inline-block;
            background: #dbeafe;
            color: #1e40af;
            border-radius: 999px;
            padding: 0.15rem 0.5rem;
            margin: 0.1rem;
            font-size: 0.75rem;
        }
        #selectedModalTable th {
            font-size: 0.8rem;
            white-space: nowrap;
        }
        #selectedModalTable td {
            font-size: 0.85rem;
            vertical-align: middle;
        }
        .action-badge-add {
            background: #d1fae5;
            color: #065f46;
            padding: 0.15rem 0.5rem;
            border-radius: 999px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .action-badge-remove {
            background: #fee2e2;
            color: #991b1b;
            padding: 0.15rem 0.5rem;
            border-radius: 999px;
            font-size: 0.75rem;
            font-weight: 600;
        }
    </style>

    <script>
var stockContextPath = '<%=contextPath%>';

function filterProductRows() {
    const nameTerm = document.getElementById('searchNameInput').value.toLowerCase().trim();
    const codeTerm = document.getElementById('searchCodeInput').value.toLowerCase().trim();
    document.querySelectorAll('#productTable tbody tr[data-product-id]').forEach(function(row) {
        const productName = (row.dataset.name || '').toLowerCase();
        const productCode = (row.dataset.code || '').toLowerCase();
        const nameMatch = !nameTerm || productName.includes(nameTerm);
        const codeMatch = !codeTerm || productCode.includes(codeTerm);
        row.style.display = (nameMatch && codeMatch) ? '' : 'none';
    });
    updateSelectedRows();
}

function applyGlobalDiscType(value) {
    document.querySelectorAll('.row-disc-type').forEach(function(input) {
        input.value = value;
    });
}

function applyGlobalQty(value) {
    document.querySelectorAll('.row-qty').forEach(function(input) {
        input.value = value;
    });
    updateSelectedRows();
}

function applyGlobalNote(value) {
    document.querySelectorAll('.row-note').forEach(function(input) {
        input.value = value;
    });
}

function bindIntegerQtyInput(input, onChange) {
    input.addEventListener('input', function() {
        this.value = this.value.replace(/\D/g, '');
        if (onChange) onChange();
    });
    input.addEventListener('keydown', function(e) {
        if (e.key === '.' || e.key === '-' || e.key === 'e' || e.key === 'E' || e.key === '+') {
            e.preventDefault();
        }
    });
}

function getSelectedRows() {
    const selected = [];
    document.querySelectorAll('#productTable tbody tr[data-product-id]').forEach(function(row) {
        if (row.style.display === 'none') return;
        const qtyInput = row.querySelector('.row-qty');
        const qtyRaw = qtyInput ? qtyInput.value.trim() : '';
        if (/^\d+$/.test(qtyRaw) && parseInt(qtyRaw, 10) > 0) {
            selected.push(row);
        }
    });
    return selected;
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text || '';
    return div.innerHTML;
}

function getActionLabel(value) {
    if (value === '1') return '<span class="action-badge-add">Add</span>';
    if (value === '2') return '<span class="action-badge-remove">Remove</span>';
    return '<span class="text-muted">-</span>';
}

function buildSelectedModalContent() {
    const selected = getSelectedRows();
    const tbody = document.getElementById('selectedModalBody');
    const emptyEl = document.getElementById('selectedModalEmpty');
    const tableWrap = document.getElementById('selectedModalTableWrap');
    const modalCount = document.getElementById('selectedModalCount');

    modalCount.textContent = selected.length;

    if (selected.length === 0) {
        emptyEl.style.display = 'block';
        tableWrap.style.display = 'none';
        tbody.innerHTML = '';
        return;
    }

    emptyEl.style.display = 'none';
    tableWrap.style.display = 'block';

    tbody.innerHTML = selected.map(function(row, index) {
        const discType = row.querySelector('.row-disc-type') ? row.querySelector('.row-disc-type').value : '';
        const qty = row.querySelector('.row-qty') ? row.querySelector('.row-qty').value.trim() : '';
        const note = row.querySelector('.row-note') ? row.querySelector('.row-note').value.trim() : '';
        return '<tr>' +
            '<td>' + (index + 1) + '</td>' +
            '<td>' + escapeHtml(row.dataset.name) + '</td>' +
            '<td>' + escapeHtml(row.dataset.code) + '</td>' +
            '<td class="text-center">' + escapeHtml(row.dataset.curStock) + '</td>' +
            '<td>' + getActionLabel(discType) + '</td>' +
            '<td class="text-center fw-semibold">' + escapeHtml(qty) + '</td>' +
            '<td>' + escapeHtml(note || '-') + '</td>' +
            '</tr>';
    }).join('');
}

function openSelectedModal() {
    const selected = getSelectedRows();
    if (selected.length === 0) {
        alert('Enter qty for at least one product to select it for update.');
        return;
    }

    for (let i = 0; i < selected.length; i++) {
        if (!validateRow(selected[i])) {
            return;
        }
    }

    buildSelectedModalContent();
    const modalEl = document.getElementById('selectedModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();
}

function updateSelectedRows() {
    const selected = getSelectedRows();
    const selectedNames = [];

    document.querySelectorAll('#productTable tbody tr[data-product-id]').forEach(function(row) {
        const qtyInput = row.querySelector('.row-qty');
        const qtyRaw = qtyInput ? qtyInput.value.trim() : '';
        const isSelected = row.style.display !== 'none' && /^\d+$/.test(qtyRaw) && parseInt(qtyRaw, 10) > 0;
        row.classList.toggle('row-selected', isSelected);
        if (isSelected) {
            selectedNames.push(row.dataset.name || 'Product');
        }
    });

    document.getElementById('selectedCount').textContent = selected.length;
    const reviewBtn = document.getElementById('bulkUpdateBtn');
    reviewBtn.disabled = selected.length === 0;

    const listEl = document.getElementById('selectedProductsList');
    if (selectedNames.length === 0) {
        listEl.innerHTML = '<span class="text-muted">No products selected. Enter qty to select.</span>';
    } else {
        listEl.innerHTML = selectedNames.map(function(name) {
            return '<span class="selected-chip">' + escapeHtml(name) + '</span>';
        }).join('') + ' <button type="button" class="btn btn-link btn-sm p-0 ms-1" id="viewSelectedLink">View details</button>';
        document.getElementById('viewSelectedLink').addEventListener('click', openSelectedModal);
    }

    if (document.getElementById('selectedModal').classList.contains('show')) {
        buildSelectedModalContent();
    }
}

function validateRow(row) {
    const discTypeEl = row.querySelector('.row-disc-type');
    const qtyInput = row.querySelector('.row-qty');
    const reasonInput = row.querySelector('.row-note');
    const discType = discTypeEl ? discTypeEl.value : '';
    const qtyRaw = qtyInput ? qtyInput.value.trim() : '';
    const qty = parseInt(qtyRaw, 10);
    const curStock = parseFloat(row.dataset.curStock || '0');
    const reason = reasonInput ? reasonInput.value.trim() : '';
    const productName = row.dataset.name || 'Product';

    if (!discType) {
        alert('Please select Add or Remove for: ' + productName);
        if (discTypeEl) discTypeEl.focus();
        return false;
    }
    if (!/^\d+$/.test(qtyRaw) || qty <= 0) {
        alert('Please enter a whole number qty for: ' + productName);
        if (qtyInput) qtyInput.focus();
        return false;
    }
    if (discType === '2' && qty > curStock) {
        alert('Cannot remove more than available stock (' + curStock + ') for: ' + productName);
        if (qtyInput) qtyInput.focus();
        return false;
    }
    if (!reason) {
        alert('Please enter a note for: ' + productName);
        if (reasonInput) reasonInput.focus();
        return false;
    }
    return true;
}

function submitBulkUpdate() {
    const selected = getSelectedRows();
    if (selected.length === 0) {
        alert('Enter qty for at least one product to select it for update.');
        return;
    }

    for (let i = 0; i < selected.length; i++) {
        if (!validateRow(selected[i])) {
            return;
        }
    }

    const modalEl = document.getElementById('selectedModal');
    const modalInstance = bootstrap.Modal.getInstance(modalEl);
    if (modalInstance) modalInstance.hide();
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = stockContextPath + '/product/master/stock/stockBatch.jsp';

    selected.forEach(function(row) {
        appendHidden(form, 'catId', row.dataset.productId);
        appendHidden(form, 'catName', row.dataset.name);
        appendHidden(form, 'curStock', row.dataset.curStock);
        appendHidden(form, 'proBatch', row.dataset.proBatch);
        appendHidden(form, 'discType', row.querySelector('.row-disc-type').value);
        appendHidden(form, 'discValue', row.querySelector('.row-qty').value.trim());
        appendHidden(form, 'reason', row.querySelector('.row-note').value.trim());
    });

    document.body.appendChild(form);
    form.submit();
}

function appendHidden(form, name, value) {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = name;
    input.value = value;
    form.appendChild(input);
}

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('searchNameInput').addEventListener('input', filterProductRows);
    document.getElementById('searchCodeInput').addEventListener('input', filterProductRows);

    document.getElementById('globalDiscType').addEventListener('change', function() {
        applyGlobalDiscType(this.value);
    });

    document.getElementById('globalQty').addEventListener('input', function() {
        applyGlobalQty(this.value);
    });

    document.getElementById('globalNote').addEventListener('input', function() {
        applyGlobalNote(this.value);
    });

    document.getElementById('bulkUpdateBtn').addEventListener('click', openSelectedModal);
    document.getElementById('modalUpdateBtn').addEventListener('click', submitBulkUpdate);

    bindIntegerQtyInput(document.getElementById('globalQty'));
    document.querySelectorAll('.row-qty').forEach(function(input) {
        bindIntegerQtyInput(input, updateSelectedRows);
    });

    updateSelectedRows();
});
    </script>
</head>
<body>

    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid mt-2" style="max-width: 1600px;">
        <div class="row g-2">
            <div class="col-md-12">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07); border-radius: 8px;">
                    <div class="card-header" style="background: white; border-bottom: 1px solid #f7fafc; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                        <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                            <div>
                                <h6 class="mb-1" style="color: #2d3748; font-weight: 600; font-size: 0.95rem;"><i class="fas fa-boxes me-2"></i>Stock Adjustment</h6>
                                <div class="small text-muted">
                                    Selected: <strong id="selectedCount">0</strong> product(s)
                                </div>
                                <div id="selectedProductsList" class="mt-1"></div>
                            </div>
                            <div class="d-flex flex-wrap align-items-center gap-2" style="max-width: 100%;">
                                <div class="input-group" style="width: 200px; max-width: 100%;">
                                    <span class="input-group-text" style="background: #f8f9fa; border: 1px solid #dee2e6; font-size: 0.8rem;">Name</span>
                                    <input type="text" id="searchNameInput" class="form-control" placeholder="Search..." style="font-size: 0.85rem;">
                                </div>
                                <div class="input-group" style="width: 180px; max-width: 100%;">
                                    <span class="input-group-text" style="background: #f8f9fa; border: 1px solid #dee2e6; font-size: 0.8rem;">Code</span>
                                    <input type="text" id="searchCodeInput" class="form-control" placeholder="Search..." style="font-size: 0.85rem;">
                                </div>
                                <button type="button" id="bulkUpdateBtn" class="btn btn-primary btn-sm" disabled>
                                    <i class="fas fa-list-check me-1"></i>Review Selected
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0; max-height: 700px; overflow-y: auto; overflow-x: auto;">
                        <div class="table-responsive">
                        <table id="productTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; font-size: 0.85rem; min-width: 860px;">
                            <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); position: sticky; top: 0; z-index: 10;">
                                <tr>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 4%;">#</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 24%;"><i class="fas fa-box me-1"></i>Name</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 12%;">Code</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 8%;">Available</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 10%;">
                                        Action
                                        <select id="globalDiscType" class="form-select form-select-sm mt-1" style="font-weight: normal;">
                                            <option value="">Select</option>
                                            <option value="1">Add</option>
                                            <option value="2">Remove</option>
                                        </select>
                                    </th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 8%;">
                                        Qty
                                        <input type="number" step="1" min="1" inputmode="numeric" id="globalQty" class="form-control form-control-sm stock-qty-input mt-1" placeholder="Qty" style="font-weight: normal;">
                                    </th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 22%;">
                                        Note
                                        <input type="text" id="globalNote" class="form-control form-control-sm mt-1" placeholder="Note" style="font-weight: normal;">
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    Vector productList = prod.getAllProductsWithStockReverse();
                                    if (productList != null && productList.size() > 0) {
                                        for (int i = 0; i < productList.size(); i++) {
                                            Vector row = (Vector) productList.get(i);
                                            if (row != null && row.size() > 6) {
                                                String productName = row.elementAt(0).toString();
                                                int productId = Integer.parseInt(row.elementAt(3).toString());
                                                String prodCode = row.elementAt(4).toString();
                                                String currentStock = row.elementAt(5).toString();
                                                int proBatch = Integer.parseInt(row.elementAt(6).toString());
                                                String safeProductName = productName.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                                                String safeProdCode = prodCode.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                                %>
                                <tr style="border-bottom: 1px solid #f1f5f9;"
                                    data-product-id="<%=productId%>"
                                    data-pro-batch="<%=proBatch%>"
                                    data-cur-stock="<%=currentStock%>"
                                    data-name="<%=safeProductName%>"
                                    data-code="<%=safeProdCode%>">
                                    <td style="padding: 0.4rem; color: #718096; border: none;"><%=i+1%></td>
                                    <td style="padding: 0.4rem; color: #2d3748; font-weight: 500; border: none; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%=productName%>"><%=productName%></td>
                                    <td style="padding: 0.4rem; color: #718096; border: none;"><%=prodCode%></td>
                                    <td style="padding: 0.4rem; border: none;">
                                        <span class="stock-available"><%=currentStock%></span>
                                    </td>
                                    <td style="padding: 0.35rem; border: none;">
                                        <select class="form-select form-select-sm row-disc-type">
                                            <option value="">Select</option>
                                            <option value="1">Add</option>
                                            <option value="2">Remove</option>
                                        </select>
                                    </td>
                                    <td style="padding: 0.35rem; border: none;">
                                        <input type="number" step="1" min="1" inputmode="numeric" class="form-control form-control-sm stock-qty-input row-qty" placeholder="Qty">
                                    </td>
                                    <td style="padding: 0.35rem; border: none;">
                                        <input type="text" class="form-control form-control-sm row-note" placeholder="Note">
                                    </td>
                                </tr>
                                <%
                                            }
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="7" class="text-center" style="padding: 2rem; color: #718096; font-size: 0.85rem;">
                                        <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                                        <p class="mb-0">No products found.</p>
                                    </td>
                                </tr>
                                <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='7' class='text-center text-danger' style='font-size: 0.85rem;'>Error loading products: " + e.getMessage() + "</td></tr>");
                                    e.printStackTrace();
                                }
                                %>
                            </tbody>
                        </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="selectedModal" tabindex="-1" aria-labelledby="selectedModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="selectedModalLabel">
                        <i class="fas fa-boxes me-2"></i>Selected Products (<span id="selectedModalCount">0</span>)
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="selectedModalEmpty" class="text-center text-muted py-4">No products selected.</div>
                    <div id="selectedModalTableWrap" style="display: none;">
                        <div class="table-responsive">
                            <table id="selectedModalTable" class="table table-hover table-bordered mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>#</th>
                                        <th>Name</th>
                                        <th>Code</th>
                                        <th class="text-center">Available</th>
                                        <th>Action</th>
                                        <th class="text-center">Qty</th>
                                        <th>Note</th>
                                    </tr>
                                </thead>
                                <tbody id="selectedModalBody"></tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" id="modalUpdateBtn" class="btn btn-primary btn-sm">
                        <i class="fas fa-save me-1"></i>Update Stock
                    </button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
