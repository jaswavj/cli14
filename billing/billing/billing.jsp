<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.*, javax.servlet.http.*" %>
        <jsp:useBean id="prod" class="product.productBean" />
        <jsp:useBean id="userBn" class="user.userBean" />
        <% 
        String contextPaths = request.getContextPath();
        Integer uid=(Integer) session.getAttribute("userId"); //out.print(uid);
        Vector attenderList = prod.getActiveAttenders();
        int userDiscPer = (uid != null) ? userBn.getUserDiscPer(uid) : 100;
        %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <title>Billing - Billing App</title>
                <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
                <jsp:include page="/assets/common/head.jsp" />
                <style>
                    .billing-table thead th,
                    .billing-table tbody td {
                        padding: 0.35rem 0.5rem !important;
                        vertical-align: middle;
                    }

                    .billing-table .discount-rs,
                    .billing-table .discount-pct {
                        height: 30px;
                        min-height: 30px;
                        padding: 2px 8px;
                        margin: 0 !important;
                    }
                </style>
            </head>

<body class="billing-page-body">
    <div class="container-fluid billing-container">                    <!-- Navbar -->
                    <jsp:include page="/assets/navbar/navbar.jsp" />

                        <!-- Top Inputs -->
                        <div class="card flex-shrink-0 my-1">
                            <div class="card-body">
                                
                                <div class="row g-1 mb-1">
                                    <div class="col-2 input-outline"><input type="text" id="customerName"
                                            class="form-control" placeholder="" autocomplete="off"><label> Customer Name </label>
                                            <input type="hidden" id="customerId" value="0">
                                            <input type="hidden" id="customerCreditLimit" value="0">
                                            <input type="hidden" id="customerExchangePoint" value="0">
                                            <input type="hidden" id="exchangePointUsed" value="0">
                                    </div>
                                    <div class="col-2 input-outline"><input type="text" id="customerPhn" placeholder=""
                                            class="form-control" autocomplete="off"><label> Customer ph no </label>
                                    </div>
                                    <div class="col-2">
                                        <select id="attenderId" class="form-select">
                                            <option value="0">Select Attender</option>
                                            <%
                                            if (attenderList != null && attenderList.size() > 0) {
                                                for (int i = 0; i < attenderList.size(); i++) {
                                                    Vector row = (Vector) attenderList.elementAt(i);
                                                    int id = (Integer) row.get(0);
                                                    String name = row.get(1).toString();
                                                    String code = row.get(2) != null ? row.get(2).toString() : "";
                                            %>
                                            <option value="<%=id%>"><%=name%><%=!code.isEmpty() ? " (" + code + ")" : ""%></option>
                                            <%
                                                }
                                            }
                                            %>
                                        </select>
                                    </div>
                                    <!--div class="col-auto">
                                        <button class="btn btn-outline-primary btn-sm" onclick="window.location.href='../cafeOrder/order/page.jsp'" title="Order">
                                            <i class="fa-solid fa-plus"></i>
                                        </button>
                                    </div>
                                    <div class="col-auto">
                                        <button class="btn btn-outline-success btn-sm" onclick="showOrderList()" title="Order List">
                                            <i class="fa-solid fa-utensils"></i>
                                        </button>
                                    </div-->
                                    <div class="col-2">
                                        <button class="btn btn-outline-violet btn-sm w-100" data-bs-toggle="modal" data-bs-target="#quotationListModal">
                                            <i class="fa-solid fa-clock"></i> HOLD LIST
                                        </button>
                                    </div>
                                    <!-- Hidden default values -->
                                    <input type="hidden" id="isTaxBill" value="1" />
                                    <input type="hidden" id="isCommission" value="0" />

                                    
                                    
                                </div>
                                <!-- Exchange Point Banner -->
                                <div id="exchangePointBanner" class="alert alert-success alert-dismissible d-none py-1 px-3 mb-1" role="alert" style="font-size:0.85rem;">
                                    <i class="fas fa-coins me-1"></i>
                                    <strong>Exchange Points Available: ₹<span id="exchangePointValue">0</span></strong>
                                    &nbsp;
                                    <button type="button" class="btn btn-sm btn-success py-0 px-2" onclick="applyExchangePointDiscount()" style="font-size:0.8rem;">
                                        <i class="fas fa-tag me-1"></i>Use as Discount
                                    </button>
                                    <button type="button" class="btn-close py-2" onclick="dismissExchangePointBanner()" aria-label="Close"></button>
                                </div>
                                <div class="row g-1">
                                    <div class="col-2 input-outline"><input type="text" id="productCode"
                                            class="form-control" placeholder=""><label> Code </label></div>
                                    <div class="col-2 input-outline"><input type="text" id="productName"
                                            name="productName" class="form-control" placeholder=""><label>
                                            Item Name<%//=head3%>
                                        </label></div>
                                    <div class="col-1">
                                        <select id="productUnit" class="form-select" disabled>
                                            <option value="">Unit</option>
                                            <option value="gram">Gram</option>
                                        </select>
                                        <input type="hidden" id="productUnitId" value="">
                                        <input type="hidden" id="productUnitName" value="">
                                        <input type="hidden" id="productConvertionUnit" value="">
                                    </div>
                                    <div class="col-2 input-outline"><input type="number" id="productQty"
                                            class="form-control" placeholder="" value="1" min="1"><label id="qtyLabel"> Qty </label>
                                    </div>
                                    <div class="col-2 input-outline"><input type="number" id="productPrice"
                                            class="form-control" placeholder="" min="0" disabled><label> Price </label></div>
                                    <div class="col-1 input-outline"><input type="text" id="productDiscount"
                                            class="form-control only-numbers" placeholder="" value="0"
                                            oninput="setDefaultValue(this);"><label> Disc</label></div>
                                    <div class="col-1 ms-auto">
                                        <div class="row">
                                            <button class="btn btn-outline-violet btn-sm" onclick="addProduct()">
                                                <i class="fa-regular fas fa-plus-square"></i> Add
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Scrollable Table -->
                        <div class="m-0 flex-grow-1 table-container-responsive" style="display: flex; flex-direction: column; border: 1px solid #dee2e6; border-radius: 4px; overflow: hidden;">
                            <table class="table table-bordered table-sm mb-0 billing-table" style="display: flex; flex-direction: column; height: 100%;">
                                <thead style="display: block; border-bottom: 2px solid #dee2e6; flex-shrink: 0;">
                                    <tr style="display: table; width: 100%; table-layout: fixed;">
                                        <th style="width: 5%;">#</th>
                                        <th style="width: 10%;">Code</th>
                                        <th style="width: 15%;">
                                            Item Name<%//=head3%>
                                        </th>
                                        <th style="width: 8%;">Qty</th>
                                        <th style="width: 10%;">Price</th>
                                        <th style="width: 8%;">Disc RS</th>
                                        <th style="width: 8%;">Disc %</th>
                                        <th style="width: 10%;">Total</th>
                                        <th style="width: 15%;">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="billBody" style="display: block; overflow-y: auto; flex-grow: 1;">
                                    <!-- Rows go here -->
                                    <!-- Empty rows to maintain minimum 5 row height -->
                                    <tr class="empty-row" style="display: table; width: 100%; table-layout: fixed;"><td style="width: 5%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td></tr>
                                    <tr class="empty-row" style="display: table; width: 100%; table-layout: fixed;"><td style="width: 5%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td></tr>
                                    <tr class="empty-row" style="display: table; width: 100%; table-layout: fixed;"><td style="width: 5%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td></tr>
                                    <tr class="empty-row" style="display: table; width: 100%; table-layout: fixed;"><td style="width: 5%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td></tr>
                                    <tr class="empty-row" style="display: table; width: 100%; table-layout: fixed;"><td style="width: 5%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td></tr>
                                </tbody>
                            </table>
                        </div>

                        <!-- Fixed Totals -->
                        <div class="card flex-shrink-0 my-1">
                            <div class="card-body ">

                                <div class="row g-1 mb-1">
                                    <div class="col-6 col-md-4 col-lg">
                                        <div class="input-outline">
                                            <input type="text" class="form-control only-numbers red-text"
                                                id="priceTotal" value="0" readonly>
                                            <label>Price Total</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-4 col-lg">
                                        <div class="input-outline">
                                            <input type="text" class="form-control only-numbers red-text"
                                                id="discountTotal" value="0" readonly>
                                            <label>Discount</label>
                                        </div>
                                    </div>

                                    <div class="col-6 col-md-4 col-lg">
                                        <div class="input-outline">
                                            <input type="text" class="form-control only-numbers red-text"
                                                id="grandTotal" value="0" readonly>
                                            <label>Grand Total</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-4 col-lg">
                                        <div class="input-outline">
                                            <input type="text" class="form-control only-numbers red-text"
                                                id="finalDiscount" value="0"
                                                oninput="setDefaultValue(this); updatePayableAmount();">
                                            <label>ExtraDisc</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-4 col-lg">
                                        <div class="input-outline">
                                            <input type="text" class="form-control only-numbers red-text" style="font-weight: bold; font-size: 1.25rem;"
                                                id="payableAmount" value="0" readonly>
                                            <label>Payable</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-4 col-lg">
                                        <div>
                                            <select name="mode" id="mode" class="form-select" required>
                                                <option value="1">Cash</option>
                                                <option value="2">Bank</option>
                                                <option value="3">Mixed</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-4 col-lg">
                                        <div>
                                            <select name="type" id="type" class="form-select" required>
                                                <option value="1">UPI</option>
                                                <option value="2">Debit Card</option>
                                                <option value="3">Credit card</option>
                                                <option value="4">Net Banking</option>
                                                <option value="5">Wallet</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-4 col-lg">
                                        <div class="input-outline">
                                            <input type="text" class="form-control only-numbers red-text" id="paid"
                                                value="0">
                                            <label>Cash Paid</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-4 col-lg">
                                        <div class="input-outline">
                                            <input type="text" class="form-control only-numbers red-text"
                                                id="bankPaid" value="0">
                                            <label>Bank paid</label>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-4 col-lg">
                                        <div class="input-outline">
                                            <input type="text" class="form-control only-numbers red-text"
                                                id="balance" value="0">
                                            <label>Balance</label>
                                        </div>
                                    </div>
                                </div>
                                        <div class="row g-2 mt-1">
                                            <div class="col-12 col-md-6 col-lg">
                                                <button id="saveBillBtn" class="btn btn-outline-violet btn-sm w-100"
                                                    onclick="saveBill()">
                                                    <i class="fa-regular fa-floppy-disk"></i> SAVE BILL
                                                </button>
                                            </div>

                                            

                                            <div class="col-12 col-md-6 col-lg">
                                                <button class="btn btn-outline-violet btn-sm w-100" onclick="printBill()" title="Direct print to thermal printer">
                                                    <i class="fa-solid fa-print"></i> PRINT
                                                </button>
                                            </div>
                                            <div class="col-12 col-md-6 col-lg" id="quotationBtnDiv">
                                                <button class="btn btn-outline-violet btn-sm w-100" onclick="saveQuotation()">
                                                    <i class="fa-solid fa-clock"></i> HOLD
                                                </button>
                                            </div>

                                            <div class="col-12 col-md-6 col-lg" id="quotationPrintBtnDiv" style="display: none;">
                                                <button class="btn btn-outline-violet btn-sm w-100" onclick="printSavedQuotation()">
                                                    <i class="fa-solid fa-print"></i> PRINT HOLD
                                                </button>
                                            </div>



                                            <div class="col-12 col-md-6 col-lg">
                                                <button type="button" class="btn btn-sm btn-outline-violet w-100"
                                                    onclick="newBill()">
                                                    <i class="fa-regular fas fa fa-refresh"></i> NEW BILL
                                                </button>
                                            </div>

                                            <div class="col-12 col-md-6 col-lg">
                                                <button class="btn btn-outline-violet btn-sm w-100"
                                                    data-bs-toggle="modal" data-bs-target="#duplicateBillModal">
                                                    <i class="fa-solid fa fa-copy"></i> DUPLICATE
                                                </button>
                                            </div>

                                            <div class="col-12 col-md-6 col-lg-auto ms-lg-auto">
                                                <div class="d-flex align-items-center justify-content-center p-2 border rounded bg-light h-100">
                                                    <div id="billNoSpan" class="fs-6 fw-bold text-danger"></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </div>
                            <!-- Modals -->
                            <%@ include file="duplicateBillModal.jsp" %>
                            <%@ include file="quotationList.jsp" %>

                            <!-- Product Picker Modal (duplicate code) -->
                            <div class="modal fade" id="productPickerModal" tabindex="-1" aria-labelledby="productPickerModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered">
                                    <div class="modal-content">
                                        <div class="modal-header bg-primary text-white py-2">
                                            <h6 class="modal-title mb-0" id="productPickerModalLabel">
                                                <i class="fa-solid fa-layer-group me-2"></i>Multiple products found — pick one
                                            </h6>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body p-2">
                                            <div id="productPickerList" class="list-group list-group-flush"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Order List Modal -->
                            <div class="modal fade" id="orderListModal" tabindex="-1" aria-labelledby="orderListModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-fullscreen-sm-down">
                                    <div class="modal-content">
                                        <div class="modal-header bg-success text-white">
                                            <h5 class="modal-title" id="orderListModalLabel">
                                                <i class="fas fa-utensils me-2"></i>Pending Orders
                                            </h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body p-2 p-md-3">
                                            <div id="orderListSpinner" class="text-center" style="display: none;">
                                                <div class="spinner-border text-success" role="status">
                                                    <span class="visually-hidden">Loading...</span>
                                                </div>
                                            </div>
                                            <div id="orderListContent">
                                                <!-- Desktop View -->
                                                <div class="d-none d-md-block">
                                                    <div class="table-responsive">
                                                        <table class="table table-bordered table-hover table-sm">
                                                            <thead class="table-light">
                                                                <tr>
                                                                    <th>Order No</th>
                                                                    <th>Table</th>
                                                                    <th>Date</th>
                                                                    <th>Time</th>
                                                                    <th>Status</th>
                                                                    <th>Actions</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody id="orderListTableBody">
                                                                <!-- Orders will be loaded here -->
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                                
                                                <!-- Mobile View (Cards) -->
                                                <div class="d-md-none" id="orderListCardsBody">
                                                    <!-- Orders will be loaded here as cards -->
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Available Cheques Modal -->
                            <div class="modal fade" id="availableChequesModal" tabindex="-1" aria-labelledby="availableChequesModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header bg-primary text-white">
                                            <h5 class="modal-title" id="availableChequesModalLabel">
                                                <i class="fas fa-money-check-alt me-2"></i>Available Cheques for <span id="chequeCustomerName"></span>
                                            </h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div id="chequeLoadingSpinner" class="text-center" style="display: none;">
                                                <div class="spinner-border text-primary" role="status">
                                                    <span class="visually-hidden">Loading...</span>
                                                </div>
                                            </div>
                                            <div id="chequeContent">
                                                <div class="table-responsive">
                                                    <table class="table table-bordered table-hover table-sm">
                                                        <thead class="table-light">
                                                            <tr>
                                                                <th>#</th>
                                                                <th>Cheque Number</th>
                                                                <th>Cheque entry Date</th>
                                                                <th>Bank Name</th>
                                                                
                                                                <th>Status</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody id="chequeTableBody">
                                                            <tr>
                                                                <td colspan="6" class="text-center text-muted">No cheques available</td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Product History Modal -->
                            <div class="modal fade" id="productHistoryModal" tabindex="-1" aria-labelledby="productHistoryModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-fullscreen-sm-down">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="productHistoryModalLabel">Last 6 Bills for <span id="historyProductName"></span></h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div id="historyLoadingSpinner" class="text-center" style="display: none;">
                                                <div class="spinner-border text-primary" role="status">
                                                    <span class="visually-hidden">Loading...</span>
                                                </div>
                                            </div>
                                            <div id="historyContent" class="table-responsive">
                                                <table class="table table-bordered table-sm">
                                                    <thead>
                                                        <tr>
                                                            <th>Bill No</th>
                                                            <th>Date</th>
                                                            <th>Time</th>
                                                            <th>Customer</th>
                                                            <th>Qty</th>
                                                            <th>Price</th>
                                                            <th>Discount</th>
                                                            <th>Total</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="historyTableBody">
                                                        <tr>
                                                            <td colspan="8" class="text-center">No history available</td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                                <!--modals-->
                                <script>
                                    var contextPath = '<%=contextPaths%>';
                                    var userMaxDiscPer = <%=userDiscPer%>;
                                </script>
                                <script src="bluetoothPrinter.js"></script>
                                <script src="billing.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Focus productCode on fresh page load
            setTimeout(function() {
                const pc = document.getElementById('productCode');
                if (pc) pc.focus();
            }, 150);

            setTimeout(function() {
                document.querySelectorAll("table thead th").forEach(th => {
                    th.style.removeProperty("background-color");
                    th.style.removeProperty("color");
                    th.style.removeProperty("background");
                });
                 document.querySelectorAll("table thead").forEach(th => {
                    th.style.removeProperty("background-color");
                    th.style.removeProperty("color");
                    th.style.removeProperty("background");
                });
            }, 100);
            
            // Auto-close sidebar and enter fullscreen when clicking on input fields
            const productCodeInput = document.getElementById('productCode');
            const productNameInput = document.getElementById('productName');
            const sidebar = document.getElementById('sidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay');
            const body = document.body;
            
            function isMobile() {
                return window.innerWidth <= 768;
            }
            
            function closeSidebar() {
                if (sidebar && sidebarOverlay) {
                    if (isMobile()) {
                        sidebar.classList.remove('show');
                        sidebarOverlay.classList.remove('show');
                        body.classList.remove('sidebar-open');
                    } else {
                        if (!sidebar.classList.contains('hidden')) {
                            sidebar.classList.add('hidden');
                            body.classList.add('sidebar-hidden');
                        }
                    }
                }
            }
            
            function enterFullscreen() {
                const elem = document.documentElement;
                if (!document.fullscreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement) {
                    if (elem.requestFullscreen) {
                        elem.requestFullscreen().catch(err => {
                            console.log('Fullscreen request failed:', err);
                        });
                    } else if (elem.webkitRequestFullscreen) { // Safari
                        elem.webkitRequestFullscreen();
                    } else if (elem.msRequestFullscreen) { // IE11
                        elem.msRequestFullscreen();
                    }
                }
            }
            
            function closeSidebarAndFullscreen() {
                closeSidebar();
                enterFullscreen();
            }
            
            // Add focus event listeners to auto-close sidebar only
            if (productCodeInput) {
                productCodeInput.addEventListener('focus', closeSidebar);
            }
            if (productNameInput) {
                productNameInput.addEventListener('focus', closeSidebar);
            }
            
            // Press Escape to exit fullscreen (browser default)
            document.addEventListener('fullscreenchange', function() {
                if (!document.fullscreenElement) {
                    console.log('Exited fullscreen mode');
                }
            });
            
            // Ctrl+S keyboard shortcut to save bill
            document.addEventListener('keydown', function(event) {
                // Check for Ctrl+S (Windows/Linux) or Cmd+S (Mac)
                if ((event.ctrlKey || event.metaKey) && event.key === 's') {
                    event.preventDefault(); // Prevent browser's default save dialog
                    
                    // Trigger save bill function
                    const saveBillBtn = document.getElementById('saveBillBtn');
                    if (saveBillBtn && !saveBillBtn.disabled) {
                        saveBill();
                    }
                }
            });
        });
    </script>    <style>
        /* Price Category Button Styling */
        .btn-outline-primary.btn-sm {
            background-color: #fcf2ff !important; /* Light violet background */
            color: #8b20ac !important; /* Violet text for non-selected */
            border-color: #8b20ac !important;
        }
        
        .btn-check:checked + .btn-outline-primary.btn-sm {
            background-color: #8b20ac !important; /* Violet background for selected */
            color: white !important; /* White text for selected */
            border-color: #8B5CF6 !important;
        }
        
        .btn-outline-primary.btn-sm:hover {
            background-color: #8b20ac !important; /* Slightly darker violet on hover */
            color: rgb(255, 255, 255) !important;
        }
        
        .btn-check:checked + .btn-outline-primary.btn-sm:hover {
            background-color: #7C3AED !important; /* Darker violet for selected hover */
            color: white !important;
        }
        
        /* Desktop view - fixed height, no scroll on body */
        @media (min-width: 769px) {
            .billing-page-body {
                height: 100vh;
                overflow: hidden;
            }
            
            .billing-container {
                height: 100%;
                display: flex;
                flex-direction: column;
            }
            
            .table-container-responsive {
                overflow-x: hidden;
            }
        }
        
        /* Mobile view - allow scrolling, flexible height */
        @media (max-width: 768px) {
            .billing-page-body {
                height: auto;
                overflow-y: auto;
                overflow-x: hidden;
            }
            
            .billing-container {
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }
            
            .table-container-responsive {
                overflow-x: auto !important;
                -webkit-overflow-scrolling: touch;
                min-height: 200px;
                max-height: 50vh;
            }
            
            .billing-table {
                min-width: 800px;
            }
            
            .billing-table thead tr,
            .billing-table tbody tr,
            .billing-table tbody tr.empty-row {
                min-width: 800px;
            }
            
            /* Ensure table section is visible */
            .flex-grow-1 {
                flex-grow: 0 !important;
            }
            
            /* Make cards stack properly */
            .card {
                margin-bottom: 0.5rem !important;
            }
        }
    </style></body>

            </html>