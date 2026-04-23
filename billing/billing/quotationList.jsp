<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*, java.text.DecimalFormat"%>

<%
DecimalFormat df = new DecimalFormat("#,##0.00");
Vector quotList = bill.getQuotationList();
%>

<div class="modal fade" id="quotationListModal" tabindex="-1" aria-labelledby="quotationListModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-fullscreen-sm-down">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #a9a8aa 0%, #7f7f7f 100%); color: white;">
                <h5 class="modal-title" id="quotationListModalLabel">
                    <i class="fas fa-clock"></i> Hold Bills
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 0;">
                <% if (quotList == null || quotList.isEmpty()) { %>
                    <div class="alert alert-info m-3">
                        <i class="fas fa-info-circle"></i> No hold bills found.
                    </div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped mb-0">
                            <thead style="background: #f3f4f6; position: sticky; top: 0; z-index: 1;">
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th style="width: 12%;">Quot. No</th>
                                    <th style="width: 18%;">Customer</th>
                                    <th style="width: 12%;">Phone</th>
                                    <th style="width: 10%;" class="text-end">Amount</th>
                                    <th style="width: 10%;">Date</th>
                                    <th style="width: 8%;">Time</th>
                                    <th style="width: 25%;" class="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                int rowNum = 1;
                                for (int i = 0; i < quotList.size(); i++) {
                                    Vector row = (Vector) quotList.get(i);
                                    int quotId = (Integer) row.get(0);
                                    String quotNo = row.get(1).toString();
                                    String cusName = row.get(2) != null ? row.get(2).toString() : "-";
                                    String cusPhn = row.get(3) != null ? row.get(3).toString() : "-";
                                    double payable = (Double) row.get(4);
                                    String date = row.get(5).toString();
                                    String time = row.get(6).toString();
                                %>
                                <tr>
                                    <td><%= rowNum++ %></td>
                                    <td><strong><%= quotNo %></strong></td>
                                    <td><%= cusName %></td>
                                    <td><%= cusPhn %></td>
                                    <td class="text-end"><strong>₹ <%= df.format(payable) %></strong></td>
                                    <td><%= date %></td>
                                    <td><%= time %></td>
                                    <td class="text-center">
                                        <div class="btn-group btn-group-sm" role="group">
                                            <button type="button" class="btn btn-success" 
                                                    onclick="billThisQuotation(<%= quotId %>)"
                                                    title="Convert to Bill">
                                                <i class="fas fa-check"></i> Bill
                                            </button>
                                            <button type="button" class="btn btn-primary" 
                                                    onclick="printSavedQuotationModal(<%= quotId %>)"
                                                    title="Print Quotation">
                                                <i class="fas fa-print"></i> Print
                                            </button>
                                            <button type="button" class="btn btn-danger" 
                                                    onclick="cancelQuotationConfirm(<%= quotId %>, '<%= quotNo %>')"
                                                    title="Cancel Quotation">
                                                <i class="fas fa-times"></i> Cancel
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <%
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script>
function printSavedQuotationModal(quotId) {
    window.open('quotationPrint.jsp?quotId=' + quotId, '_blank');
}

function cancelQuotationConfirm(quotId, quotNo) {
    Swal.fire({
        title: 'Cancel Quotation?',
        text: 'Are you sure you want to cancel quotation ' + quotNo + '?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Yes, Cancel It',
        cancelButtonText: 'No'
    }).then((result) => {
        if (result.isConfirmed) {
            fetch('cancelQuotation.jsp?quotId=' + quotId)
                .then(response => response.text())
                .then(data => {
                    if (data.includes('SUCCESS')) {
                        // Reload immediately to show updated list
                        location.reload();
                    } else {
                        Swal.fire({
                            title: 'Error',
                            text: 'Error cancelling quotation: ' + data,
                            icon: 'error',
                            confirmButtonText: 'OK'
                        });
                    }
                })
                .catch(error => {
                    Swal.fire({
                        title: 'Error',
                        text: 'Error: ' + error,
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                });
        }
    });
}

function billThisQuotation(quotId) {
    // Close the modal first
    $('#quotationListModal').modal('hide');
    
    // Fetch quotation details and load into billing screen
    fetch('getQuotationDetails.jsp?quotId=' + quotId)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Clear current bill
                clearBillTable();
                
                // Load customer details
                document.getElementById('customerName').value = data.customerName || '';
                document.getElementById('customerPhn').value = data.customerPhone || '';
                document.getElementById('customerId').value = data.customerId || '0';
                document.getElementById('finalDiscount').value = data.extraDisc || '0';
                
                // Set quotation ID to track
                currentQuotationId = quotId;
                
                // Load products into bill table
                data.products.forEach(product => {
                    addProductToBillTable(product);
                });
                
                // Update totals
                updateTotals();
                
                Swal.fire({
                    title: 'Quotation Loaded',
                    text: 'You can modify items before saving the bill',
                    icon: 'info',
                    confirmButtonText: 'OK'
                });
            } else {
                Swal.fire({
                    title: 'Error',
                    text: 'Error loading quotation: ' + (data.message || 'Unknown error'),
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
            }
        })
        .catch(error => {
            Swal.fire({
                title: 'Error',
                text: 'Error: ' + error,
                icon: 'error',
                confirmButtonText: 'OK'
            });
        });
}

// Reload modal content when shown to get fresh data
$('#quotationListModal').on('show.bs.modal', function (e) {
    // Check if we need to refresh (e.g., after saving a new quotation)
    if (window.quotationListNeedsRefresh) {
        location.reload();
    }
});
</script>
