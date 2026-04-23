<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String purchaseId = request.getParameter("id");
%>
<jsp:useBean id="prod" class="product.productBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Details</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .table-wrapper {
            overflow: auto;
        }
        thead th {
            position: sticky;
            top: 0;
            background-color: #f8f9fa;
            z-index: 1;
            box-shadow: 0 2px 2px -1px rgba(0, 0, 0, 0.4);
        }
        .form-label-sm {
            font-size: 0.8rem;
            margin-bottom: 0;
            color: #6c757d;
        }
        .form-control-plaintext {
            padding-top: 0;
            padding-bottom: 0;
            font-weight: 500;
        }
    </style>
</head>
<body style="height: 100vh; overflow: hidden;">
    <div class="container-fluid h-100 d-flex flex-column p-0">
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <%
        if (purchaseId != null && !purchaseId.isEmpty()) {
            try {
                // Get purchase header information
                Vector purchaseHeader = prod.getPurchaseHeaderById(Integer.parseInt(purchaseId));
                if (purchaseHeader != null && !purchaseHeader.isEmpty()) {
                    Vector header = (Vector) purchaseHeader.get(0);
        %>

        <!-- Top Section: Purchase Info -->
        <div class="card m-2 flex-shrink-0">
            <div class="card-body p-2">
                <div class="row g-2">
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Invoice No</label>
                            <span class="fw-bold"><%= header.elementAt(1) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Invoice Date</label>
                            <span class="fw-bold"><%= header.elementAt(2) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Supplier</label>
                            <span class="fw-bold"><%= header.elementAt(9) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Entry Date</label>
                            <span class="fw-bold"><%= header.elementAt(6) %> <%= header.elementAt(7) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Entered By</label>
                            <span class="fw-bold"><%= header.elementAt(8) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Total Amount</label>
                            <span class="fw-bold text-primary">₹<%= header.elementAt(3) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Paid Amount</label>
                            <span class="fw-bold text-success">₹<%= header.elementAt(4) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Balance</label>
                            <span class="fw-bold text-danger">₹<%= header.elementAt(5) %></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Middle Section: Table -->
        <div class="flex-grow-1 overflow-auto px-2">
            <table class="table table-bordered table-sm table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th style="width: 40px;">S.No</th>
                        <th>Product Name</th>
                        <th class="text-end" style="width: 70px;">Pack</th>
                        <th class="text-end" style="width: 70px;">Qty/Pk</th>
                        <th class="text-end" style="width: 70px;">Qty</th>
                        <th class="text-end" style="width: 70px;">Free</th>
                        <th class="text-end" style="width: 100px;">Rate</th>
                        <th class="text-end" style="width: 100px;">MRP</th>
                        <th class="text-end" style="width: 110px;">Total</th>
                        <th class="text-end" style="width: 70px;">GST%</th>
                        <th class="text-end" style="width: 90px;">CGST</th>
                        <th class="text-end" style="width: 90px;">SGST</th>
                        <th class="text-end" style="width: 110px;">Net Amt</th>
                        <th style="width: 160px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Vector purchaseDetails = prod.getPurchaseDetailsForEdit(Integer.parseInt(purchaseId));
                    double totalAmount = 0.0, totalCGST = 0.0, totalSGST = 0.0, grandTotal = 0.0;

                    if (purchaseDetails != null && !purchaseDetails.isEmpty()) {
                        for (int i = 0; i < purchaseDetails.size(); i++) {
                            Vector item = (Vector) purchaseDetails.get(i);
                            int    detId      = (Integer) item.elementAt(0);
                            String prodName   = (String)  item.elementAt(1);
                            double qty        = (Double)  item.elementAt(5);
                            double free       = (Double)  item.elementAt(6);
                            double rate       = (Double)  item.elementAt(7);
                            double mrp        = (Double)  item.elementAt(8);
                            double itemTotal  = (Double)  item.elementAt(9);
                            double tax        = (Double)  item.elementAt(10);
                            double cgst       = (Double)  item.elementAt(11);
                            double sgst       = (Double)  item.elementAt(12);
                            double netAmt     = (Double)  item.elementAt(13);
                            int    cancelled  = (Integer) item.elementAt(14);

                            if (cancelled == 0) { totalAmount += itemTotal; totalCGST += cgst; totalSGST += sgst; grandTotal += netAmt; }
                    %>
                    <tr class="<%= cancelled==1 ? "table-secondary text-decoration-line-through text-muted" : "" %>">
                        <td><%= i+1 %></td>
                        <td><%= prodName %> <% if (cancelled==1) { %><span class="badge bg-danger ms-1">Cancelled</span><% } %></td>
                        <td class="text-end"><%= String.format("%.0f",(Double)item.elementAt(3)) %></td>
                        <td class="text-end"><%= String.format("%.3f",(Double)item.elementAt(4)) %></td>
                        <td class="text-end"><%= String.format("%.3f", qty) %></td>
                        <td class="text-end"><%= String.format("%.3f", free) %></td>
                        <td class="text-end"><%= String.format("%.3f", rate) %></td>
                        <td class="text-end"><%= String.format("%.3f", mrp) %></td>
                        <td class="text-end"><%= String.format("%.3f", itemTotal) %></td>
                        <td class="text-end"><%= String.format("%.2f", tax) %></td>
                        <td class="text-end"><%= String.format("%.3f", cgst) %></td>
                        <td class="text-end"><%= String.format("%.3f", sgst) %></td>
                        <td class="text-end fw-bold"><%= String.format("%.3f", netAmt) %></td>
                        <td class="text-center">
                        <% if (cancelled == 0) { %>
                            <button class="btn btn-xs btn-outline-primary py-0 px-1 me-1"
                                    onclick="openEditModal(<%= detId %>, '<%= purchaseId %>', '<%= prodName.replace("'","\\'"  ) %>', <%= rate %>, <%= mrp %>)"
                                    title="Edit Price"><i class="fas fa-edit"></i> Edit</button>
                            <button class="btn btn-xs btn-outline-danger py-0 px-1"
                                    onclick="cancelItem(<%= detId %>, '<%= purchaseId %>', '<%= prodName.replace("'","\\'"  ) %>')"
                                    title="Cancel Item"><i class="fas fa-ban"></i> Cancel</button>
                        <% } %>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="14" class="text-center py-3">No items found for this purchase.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- Bottom Section: Footer Totals -->
        <div class="card m-2 flex-shrink-0 bg-light">
            <div class="card-body p-2">
                <div class="row align-items-center">
                    <div class="col-auto">
                        <a href="page.jsp" class="btn btn-secondary btn-sm px-4">
                            <i class="fas fa-arrow-left me-1"></i> Back
                        </a>
                        <a href="<%=contextPath%>/product/purchase/purchaseReturn/page.jsp?purchaseId=<%= purchaseId %>" class="btn btn-warning btn-sm px-3 ms-2">
                            <i class="fas fa-undo me-1"></i> Purchase Return
                        </a>
                    </div>
                    <div class="col text-end">
                        <span class="me-3 text-muted">Sub Total: <span class="text-dark fw-bold">₹<%= String.format("%.3f", totalAmount) %></span></span>
                        <span class="me-3 text-muted">CGST: <span class="text-dark fw-bold">₹<%= String.format("%.3f", totalCGST) %></span></span>
                        <span class="me-3 text-muted">SGST: <span class="text-dark fw-bold">₹<%= String.format("%.3f", totalSGST) %></span></span>
                        <span class="ms-2 fs-5">Grand Total: <span class="text-primary fw-bold">₹<%= String.format("%.3f", grandTotal) %></span></span>
                    </div>
                </div>
            </div>
        </div>

        <%
                } else {
        %>
        <div class="container mt-5">
            <div class="alert alert-warning shadow-sm">
                <i class="fas fa-exclamation-triangle me-2"></i> Purchase not found.
                <a href="page.jsp" class="alert-link ms-2">Go Back</a>
            </div>
        </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
        %>
        <div class="container mt-5">
            <div class="alert alert-danger shadow-sm">
                <h5 class="alert-heading"><i class="fas fa-exclamation-circle me-2"></i>Error loading details</h5>
                <p class="mb-0"><%= e.getMessage() %></p>
                <hr>
                <p class="mb-0 small">Purchase ID: <%= purchaseId %></p>
                <a href="page.jsp" class="btn btn-outline-danger btn-sm mt-2">Go Back</a>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <div class="container mt-5">
            <div class="alert alert-warning shadow-sm">
                <i class="fas fa-exclamation-triangle me-2"></i> Invalid purchase ID.
                <a href="page.jsp" class="alert-link ms-2">Go Back</a>
            </div>
        </div>
        <%
        }
        %>
    </div>

<!-- ── Edit Price Modal ─────────────────────────────── -->
<div class="modal fade" id="editPriceModal" tabindex="-1">
  <div class="modal-dialog modal-sm">
    <div class="modal-content">
      <div class="modal-header py-2">
        <h6 class="modal-title"><i class="fas fa-edit me-1"></i> Edit Price</h6>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <p class="mb-2 fw-semibold" id="editProdName"></p>
        <div class="mb-2">
          <label class="form-label form-label-sm mb-0">Rate (Cost)</label>
          <input type="number" step="0.001" min="0.001" id="editRate" class="form-control form-control-sm">
        </div>
        <div class="mb-2">
          <label class="form-label form-label-sm mb-0">MRP</label>
          <input type="number" step="0.001" min="0.001" id="editMrp" class="form-control form-control-sm">
        </div>
        <div class="mb-2">
          <label class="form-label form-label-sm mb-0">Reason</label>
          <input type="text" id="editReason" class="form-control form-control-sm" placeholder="optional">
        </div>
      </div>
      <div class="modal-footer py-1">
        <button class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-primary btn-sm" onclick="submitEditPrice()">Save</button>
      </div>
    </div>
  </div>
</div>

<script>
const CTX = '<%=contextPath%>';
let _editDetailId = 0, _editPurchaseId = 0;

function openEditModal(detailId, purchaseId, prodName, rate, mrp) {
    _editDetailId   = detailId;
    _editPurchaseId = purchaseId;
    document.getElementById('editProdName').textContent = prodName;
    document.getElementById('editRate').value   = rate;
    document.getElementById('editMrp').value    = mrp;
    document.getElementById('editReason').value = '';
    new bootstrap.Modal(document.getElementById('editPriceModal')).show();
}

function submitEditPrice() {
    const rate   = parseFloat(document.getElementById('editRate').value);
    const mrp    = parseFloat(document.getElementById('editMrp').value);
    const reason = document.getElementById('editReason').value.trim();
    if (!rate || rate <= 0 || !mrp || mrp <= 0) {
        Swal.fire('Validation', 'Rate and MRP must be greater than 0.', 'warning');
        return;
    }
    bootstrap.Modal.getInstance(document.getElementById('editPriceModal')).hide();
    $.ajax({
        url: CTX + '/product/purchase/editPurchaseItemPrice.jsp',
        method: 'POST',
        data: { detailId: _editDetailId, purchaseId: _editPurchaseId, newRate: rate, newMrp: mrp, reason: reason },
        success: function(res) {
            if (res.success) {
                Swal.fire({ icon:'success', title:'Updated', text: res.message, timer:1800, showConfirmButton:false })
                    .then(() => location.reload());
            } else {
                Swal.fire('Error', res.message, 'error');
            }
        },
        error: function() { Swal.fire('Error', 'Server error.', 'error'); }
    });
}

function cancelItem(detailId, purchaseId, prodName) {
    Swal.fire({
        title: 'Cancel Item?',
        html: '<b>' + prodName + '</b><br><small class="text-muted">Stock will be reduced. This cannot be undone.</small>' +
              '<br><br><input type="text" id="cancelReason" class="form-control form-control-sm" placeholder="Reason (optional)">',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        confirmButtonText: 'Yes, Cancel It',
        cancelButtonText: 'Back',
        preConfirm: () => document.getElementById('cancelReason').value
    }).then(result => {
        if (!result.isConfirmed) return;
        $.ajax({
            url: CTX + '/product/purchase/cancelPurchaseItem.jsp',
            method: 'POST',
            data: { detailId: detailId, purchaseId: purchaseId, reason: result.value },
            success: function(res) {
                if (res.success) {
                    Swal.fire({ icon:'success', title:'Cancelled', text: res.message, timer:1800, showConfirmButton:false })
                        .then(() => location.reload());
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