<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Change Payment Type</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3 class="mb-4"><i class="fas fa-exchange-alt me-2"></i>Change Payment Type</h3>

        <!-- Bill Number Search -->
        <div class="card shadow-sm mb-4" style="max-width: 480px;">
            <div class="card-body">
                <label class="form-label fw-bold">Enter Bill No</label>
                <div class="input-group">
                    <input type="text" id="billNoInput" class="form-control"
                           placeholder="e.g. 26-52" autocomplete="off">
                    <button class="btn btn-primary" id="searchBtn" onclick="searchBill()">
                        <i class="fas fa-search"></i> Search
                    </button>
                </div>
                <div class="form-text text-muted">Enter the bill display number and press Search or Enter.</div>
            </div>
        </div>
    </div>

    <!-- Bill Detail / Edit Modal -->
    <div class="modal fade" id="billDetailModal" tabindex="-1" aria-labelledby="billDetailModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="billDetailModalLabel">
                        <i class="fas fa-file-invoice me-2"></i>Bill Details &mdash; <span id="modalBillNo"></span>
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <!-- Hidden bill id -->
                    <input type="hidden" id="hiddenBillId">
                    <input type="hidden" id="hiddenPayable">

                    <!-- Summary Table -->
                    <table class="table table-bordered table-sm mb-3">
                        <tbody>
                            <tr>
                                <th class="table-light" style="width:18%">Bill No</th>
                                <td id="detBillNo"></td>
                                <th class="table-light" style="width:12%">Date</th>
                                <td id="detDate"></td>
                            </tr>
                            <tr>
                                <th class="table-light">Customer</th>
                                <td id="detCus"></td>
                                <th class="table-light">Payable</th>
                                <td id="detPayable"></td>
                            </tr>
                        </tbody>
                    </table>

                    <hr>
                    <h6 class="text-primary mb-3"><i class="fas fa-money-bill-wave me-1"></i>Edit Payment</h6>

                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Cash Amount</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-money-bill"></i></span>
                                <input type="number" id="cashAmount" class="form-control"
                                       step="0.001" min="0" placeholder="0.000">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Bank Amount</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-university"></i></span>
                                <input type="number" id="bankAmount" class="form-control"
                                       step="0.001" min="0" placeholder="0.000"
                                       oninput="onBankAmountChange()">
                            </div>
                        </div>
                        <div class="col-md-4" id="bankTypeContainer">
                            <label class="form-label fw-bold">Bank / Payment Mode</label>
                            <select id="bankMode" class="form-select">
                                <option value="1">UPI</option>
                                <option value="2">Debit Card</option>
                                <option value="3">Credit Card</option>
                                <option value="4">Net Banking</option>
                                <option value="5">Wallet</option>
                            </select>
                        </div>
                    </div>

                    <div class="alert alert-info mt-3 mb-0 py-2 small" id="paymentModeInfo">
                        <i class="fas fa-info-circle me-1"></i>
                        <span id="paymentModeText"></span>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times me-1"></i>Cancel
                    </button>
                    <button type="button" class="btn btn-primary" onclick="updatePayment()">
                        <i class="fas fa-save me-1"></i>Update Payment
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
    (function () {
        /* ---- Search ---- */
        function searchBill() {
            var billNo = document.getElementById('billNoInput').value.trim();
            if (!billNo) {
                Swal.fire({ icon: 'warning', title: 'Required', text: 'Please enter a bill number.' });
                return;
            }
            var btn = document.getElementById('searchBtn');
            btn.disabled = true;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Searching...';

            $.ajax({
                url: 'getBillPayment.jsp',
                data: { billNo: billNo },
                type: 'GET',
                dataType: 'json',
                success: function (data) {
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fas fa-search"></i> Search';
                    if (!data.success) {
                        Swal.fire({ icon: 'warning', title: 'Not Found', text: data.message });
                        return;
                    }
                    populateModal(data);
                    new bootstrap.Modal(document.getElementById('billDetailModal')).show();
                },
                error: function () {
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fas fa-search"></i> Search';
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to fetch bill details. Please try again.' });
                }
            });
        }

        function populateModal(data) {
            document.getElementById('hiddenBillId').value   = data.billId;
            document.getElementById('hiddenPayable').value  = data.payable;
            document.getElementById('modalBillNo').textContent = data.billNo;
            document.getElementById('detBillNo').textContent   = data.billNo;
            document.getElementById('detDate').textContent     = data.date;
            document.getElementById('detCus').textContent      = data.cusName || '-';
            document.getElementById('detPayable').textContent  = parseFloat(data.payable).toFixed(3);
            document.getElementById('cashAmount').value        = parseFloat(data.cash).toFixed(3);
            document.getElementById('bankAmount').value        = parseFloat(data.bank).toFixed(3);

            var bm = parseInt(data.paymentType);
            if (bm > 0) document.getElementById('bankMode').value = bm;

            onBankAmountChange();
        }

        function onBankAmountChange() {
            var bank = parseFloat(document.getElementById('bankAmount').value) || 0;
            var cash = parseFloat(document.getElementById('cashAmount').value) || 0;
            var sel  = document.getElementById('bankMode');
            var cont = document.getElementById('bankTypeContainer');

            if (bank > 0) {
                sel.disabled      = false;
                cont.style.opacity = '1';
            } else {
                sel.disabled      = true;
                cont.style.opacity = '0.45';
            }

            /* Update mode info label */
            var modeText = '';
            if (cash > 0 && bank > 0)       modeText = 'Mode: Mixed (Cash + Bank)';
            else if (bank > 0)              modeText = 'Mode: Bank / Digital only';
            else if (cash > 0)              modeText = 'Mode: Cash only';
            else                            modeText = 'No payment amount entered.';
            document.getElementById('paymentModeText').textContent = modeText;
        }

        function updatePayment() {
            var billId   = document.getElementById('hiddenBillId').value;
            var cash     = parseFloat(document.getElementById('cashAmount').value) || 0;
            var bank     = parseFloat(document.getElementById('bankAmount').value) || 0;
            var bankMode = document.getElementById('bankMode').value;
            var payable  = parseFloat(document.getElementById('hiddenPayable').value) || 0;

            if (cash < 0 || bank < 0) {
                Swal.fire({ icon: 'error', title: 'Invalid', text: 'Amounts cannot be negative.' });
                return;
            }
            if (cash === 0 && bank === 0) {
                Swal.fire({ icon: 'warning', title: 'Required', text: 'At least one payment amount must be greater than zero.' });
                return;
            }

            var total = Math.round((cash + bank) * 1000) / 1000;
            var expectedPayable = Math.round(payable * 1000) / 1000;
            if (total !== expectedPayable) {
                Swal.fire({
                    icon: 'error',
                    title: 'Amount Mismatch',
                    html: 'Cash + Bank must equal the Payable amount.<br>' +
                          '<b>Cash:</b> ' + cash.toFixed(3) + ' + <b>Bank:</b> ' + bank.toFixed(3) +
                          ' = <b>' + total.toFixed(3) + '</b><br>' +
                          '<b>Payable:</b> ' + expectedPayable.toFixed(3)
                });
                return;
            }

            Swal.fire({
                title: 'Confirm Update',
                html: 'Update payment type for Bill <strong>' + document.getElementById('modalBillNo').textContent + '</strong>?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Update',
                cancelButtonText: 'Cancel'
            }).then(function (result) {
                if (!result.isConfirmed) return;

                $.ajax({
                    url: 'updatePaymentType.jsp',
                    type: 'POST',
                    data: { billId: billId, cash: cash, bank: bank, bankMode: bankMode },
                    success: function (res) {
                        res = res.trim();
                        if (res === 'OK') {
                            bootstrap.Modal.getInstance(document.getElementById('billDetailModal')).hide();
                            Swal.fire({ icon: 'success', title: 'Updated', text: 'Payment type updated successfully.' });
                            document.getElementById('billNoInput').value = '';
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error', text: res });
                        }
                    },
                    error: function () {
                        Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to update payment. Please try again.' });
                    }
                });
            });
        }

        /* Expose to global scope for onclick attributes */
        window.searchBill   = searchBill;
        window.onBankAmountChange = onBankAmountChange;
        window.updatePayment = updatePayment;

        /* Enter key in bill no input */
        document.getElementById('billNoInput').addEventListener('keypress', function (e) {
            if (e.key === 'Enter') searchBill();
        });
    })();
    </script>
</body>
</html>
