<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    String contextPathprerep = request.getContextPath();
    String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());

    // Handle form submit
    String fromDate  = request.getParameter("fromDate");
    String toDate    = request.getParameter("toDate");
    String supIdStr  = request.getParameter("supId");
    int    supplierId = 0;
    Vector returns   = null;
    boolean searched = false;

    if (fromDate != null && toDate != null) {
        searched = true;
        if (supIdStr != null && !supIdStr.isEmpty()) try { supplierId = Integer.parseInt(supIdStr); } catch (Exception e) {}
        try { returns = prod.getPurchaseReturnList(fromDate, toDate, supplierId); } catch (Exception e) { returns = new Vector(); }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Return Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        @media print { .no-print { display: none !important; } }
    </style>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container-fluid mt-3 px-4">
    <h5 class="mb-3 no-print"><i class="fas fa-file-alt me-2 text-warning"></i>Purchase Return Report</h5>

    <!-- Filter Form -->
    <div class="card shadow-sm mb-3 no-print">
        <div class="card-body py-2">
            <form method="get" class="row g-2 align-items-end">
                <div class="col-md-2">
                    <label class="form-label form-label-sm mb-0">From Date</label>
                    <input type="date" name="fromDate" class="form-control form-control-sm"
                           value="<%= fromDate != null ? fromDate : today %>" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label form-label-sm mb-0">To Date</label>
                    <input type="date" name="toDate" class="form-control form-control-sm"
                           value="<%= toDate != null ? toDate : today %>" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label form-label-sm mb-0">Supplier</label>
                    <select name="supId" class="form-select form-select-sm">
                        <option value="0">All Suppliers</option>
                        <% Vector sups = prod.GetSupplier();
                           for (int i = 0; i < sups.size(); i++) {
                               Vector s = (Vector) sups.get(i);
                               int sid = Integer.parseInt(s.elementAt(0).toString());
                               String sname = s.elementAt(1).toString(); %>
                        <option value="<%= sid %>" <%= (sid == supplierId ? "selected" : "") %>><%= sname %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-auto">
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="fas fa-search me-1"></i> Generate
                    </button>
                    <% if (searched && returns != null && !returns.isEmpty()) { %>
                    <button type="button" class="btn btn-outline-secondary btn-sm ms-2" onclick="window.print()">
                        <i class="fas fa-print me-1"></i> Print
                    </button>
                    <% } %>
                </div>
            </form>
        </div>
    </div>

    <!-- Results -->
    <% if (searched) { %>
    <div class="card shadow-sm">
        <div class="card-header py-2 d-flex justify-content-between">
            <span class="fw-semibold">Results: <%= fromDate %> to <%= toDate %></span>
            <span class="text-muted small"><%= returns != null ? returns.size() : 0 %> return(s)</span>
        </div>
        <div class="table-responsive">
            <table class="table table-bordered table-sm mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>#</th>
                        <th>Return No</th>
                        <th>Purchase Bill</th>
                        <th>Supplier</th>
                        <th class="text-end">Return Total</th>
                        <th>Notes</th>
                        <th>Date &amp; Time</th>
                        <th>Entered By</th>
                        <th class="no-print">Details</th>
                    </tr>
                </thead>
                <tbody>
                <%
                double grandReturnTotal = 0;
                if (returns != null && !returns.isEmpty()) {
                    for (int i = 0; i < returns.size(); i++) {
                        Vector r = (Vector) returns.get(i);
                        int    retId      = (Integer) r.elementAt(0);
                        String retNo      = (String)  r.elementAt(1);
                        String prno       = (String)  r.elementAt(3);
                        String supName    = (String)  r.elementAt(4);
                        double retTotal   = (Double)  r.elementAt(5);
                        String retNotes   = r.elementAt(6) != null ? r.elementAt(6).toString() : "—";
                        String retDt      = (String)  r.elementAt(7);
                        String enteredBy  = (String)  r.elementAt(8);
                        grandReturnTotal += retTotal;
                %>
                    <tr>
                        <td><%= i+1 %></td>
                        <td class="fw-semibold text-warning"><%= retNo %></td>
                        <td><%= prno %></td>
                        <td><%= supName %></td>
                        <td class="text-end">₹<%= String.format("%.3f", retTotal) %></td>
                        <td><%= retNotes %></td>
                        <td><%= retDt %></td>
                        <td><%= enteredBy %></td>
                        <td class="no-print">
                            <button class="btn btn-xs btn-outline-info py-0 px-2"
                                    onclick="viewDetails(<%= retId %>, '<%= retNo %>')">
                                <i class="fas fa-eye"></i>
                            </button>
                        </td>
                    </tr>
                <% } %>
                    <tr class="table-warning fw-bold">
                        <td colspan="4" class="text-end">Grand Total:</td>
                        <td class="text-end">₹<%= String.format("%.3f", grandReturnTotal) %></td>
                        <td colspan="4"></td>
                    </tr>
                <% } else { %>
                    <tr><td colspan="9" class="text-center py-4 text-muted">No purchase returns found for the selected period.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>
</div>

<!-- Details Modal -->
<div class="modal fade" id="detailsModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header py-2">
        <h6 class="modal-title" id="detailsModalTitle">Return Details</h6>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body p-0">
        <div class="table-responsive">
          <table class="table table-bordered table-sm mb-0">
            <thead class="table-light">
              <tr><th>#</th><th>Product</th><th class="text-end">Qty</th><th class="text-end">Rate</th><th class="text-end">Total</th></tr>
            </thead>
            <tbody id="detailsTbody"></tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
const CTX = '<%=contextPathprerep%>';

function viewDetails(returnId, returnNo) {
    $.ajax({
        url: CTX + '/product/purchase/purchaseReturn/getReturnDetails.jsp',
        data: { returnId: returnId },
        success: function(res) {
            if (!res.success) { Swal.fire('Error', res.message, 'error'); return; }
            document.getElementById('detailsModalTitle').textContent = 'Details — ' + returnNo;
            let html = '';
            let grand = 0;
            res.items.forEach((item, i) => {
                grand += parseFloat(item.total);
                html += `<tr><td>${i+1}</td><td>${item.product}</td>
                    <td class="text-end">${parseFloat(item.qty).toFixed(3)}</td>
                    <td class="text-end">₹${parseFloat(item.rate).toFixed(3)}</td>
                    <td class="text-end">₹${parseFloat(item.total).toFixed(3)}</td></tr>`;
            });
            html += `<tr class="table-warning fw-bold"><td colspan="4" class="text-end">Total:</td><td class="text-end">₹${grand.toFixed(3)}</td></tr>`;
            document.getElementById('detailsTbody').innerHTML = html;
            new bootstrap.Modal(document.getElementById('detailsModal')).show();
        },
        error: function() { Swal.fire('Error', 'Server error.', 'error'); }
    });
}
</script>
</body>
</html>
