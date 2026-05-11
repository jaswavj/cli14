<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="poBean" class="product.purchaseOrderBean" />
<jsp:useBean id="prodBean" class="product.productBean" />
<%
    // Check if receiving goods from PO
    int poId = 0;
    String mode = "standalone";
    Vector poHeader = null;
    Vector poItems = null;
    Vector advancePayment = null;
    double advancePaid = 0;
    double advanceBalance = 0;
    Vector categories = new Vector();
    Vector brands = new Vector();
    Vector units = new Vector();
    
    String poIdParam = request.getParameter("poId");
    if (poIdParam != null && !poIdParam.isEmpty()) {
        try {
            poId = Integer.parseInt(poIdParam);
            mode = "from-po";
            
            // Load PO header and pending items
            poHeader = poBean.getPOHeader(poId);
            Vector result = poBean.getPOPendingItems(poId);
            
            if (result.size() > 1) {
                poItems = (Vector) result.get(1); // Items are at index 1
            } else {
                poId = 0;
                mode = "standalone";
            }
            
            // Load advance payment if exists
            if (poId > 0) {
                advancePayment = poBean.getPOAdvancePayment(poId);
                if (advancePayment.size() >= 3) {
                    advancePaid = (Double) advancePayment.get(1);
                    advanceBalance = (Double) advancePayment.get(2);
                }
            }
        } catch (Exception e) {
            poId = 0;
            mode = "standalone";
            out.println("<!-- Error loading PO: " + e.getMessage() + " -->");
        }
    }

    try {
        categories = prodBean.getCategoryName();
        brands = prodBean.getBrandsName();
        units = prodBean.getUnits();
    } catch (Exception e) {
        out.println("<!-- Error loading product modal data: " + e.getMessage() + " -->");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Item - Billing App</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<style>
    /* Table wrapper for horizontal scroll */
    .table-wrapper {
        overflow-x: auto;
        overflow-y: auto;
        min-height: 280px;
        max-height: calc(100vh - 500px);
    }
    
    /* Fixed Table Layout */
    .table-fixed-layout {
        min-width: 1400px;
        table-layout: fixed;
        width: 100%;
    }

    /* Column Width Definitions */
    .table-fixed-layout th:nth-child(1), .table-fixed-layout td:nth-child(1) { width: 50px; }
    .table-fixed-layout th:nth-child(2), .table-fixed-layout td:nth-child(2) { width: 50px; }
    .table-fixed-layout th:nth-child(3), .table-fixed-layout td:nth-child(3) { width: 240px; }
    .table-fixed-layout th:nth-child(4), .table-fixed-layout td:nth-child(4) { width: 60px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .table-fixed-layout th:nth-child(5), .table-fixed-layout td:nth-child(5) { width: 60px; }
    .table-fixed-layout th:nth-child(6), .table-fixed-layout td:nth-child(6) { width: 100px; }
    .table-fixed-layout th:nth-child(7), .table-fixed-layout td:nth-child(7) { width: 100px; }
    .table-fixed-layout th:nth-child(8), .table-fixed-layout td:nth-child(8) { width: 60px; }
    .table-fixed-layout th:nth-child(9), .table-fixed-layout td:nth-child(9) { width: 80px; }
    .table-fixed-layout th:nth-child(10), .table-fixed-layout td:nth-child(10) { width: 80px; }
    .table-fixed-layout th:nth-child(11), .table-fixed-layout td:nth-child(11) { width: 60px; }
    .table-fixed-layout th:nth-child(12), .table-fixed-layout td:nth-child(12) { width: 60px; }
    .table-fixed-layout th:nth-child(13), .table-fixed-layout td:nth-child(13) { width: 90px; }
    .table-fixed-layout th:nth-child(14), .table-fixed-layout td:nth-child(14) { width: 90px; }
    .table-fixed-layout th:nth-child(15), .table-fixed-layout td:nth-child(15) { width: 90px; }
    .table-fixed-layout th:nth-child(16), .table-fixed-layout td:nth-child(16) { width: 100px; }
    .table-fixed-layout th:nth-child(17), .table-fixed-layout td:nth-child(17) { width: 90px; }

    /* Hide Pack and Qty/Pk columns (direct Qty entry mode) */
    .table-fixed-layout th:nth-child(5),
    .table-fixed-layout td:nth-child(5),
    .table-fixed-layout th:nth-child(6),
    .table-fixed-layout td:nth-child(6) {
        display: none;
    }
</style>
<body style="height: 100vh; overflow: hidden;" onload="Load();loadPOItems()">

    <div class="container-fluid h-100 d-flex flex-column">
        <!-- Navbar -->
        <%@ include file="/assets/navbar/navbar.jsp" %>
        
        <input type="hidden" id="_proAddRowCount" name="_proAddRowCount" value="0">
        <input type="hidden" id="_proDelRowCount" name="_proDelRowCount" value="0">
        <input type="hidden" id="poId" name="poId" value="<%= poId %>">
        <input type="hidden" id="mode" name="mode" value="<%= mode %>">
        <input type="hidden" id="advancePaid" name="advancePaid" value="<%= advancePaid %>">
        <% if (mode.equals("from-po") && poHeader != null) { %>
        <input type="hidden" id="supplierIdFromPO" value="<%= poHeader.get(10) %>">
        <% } %>

        <!-- Supplier Details (Top) -->
        <div class="card flex-shrink-0 my-1">
            <div class="card-body py-2">
                <% if (mode.equals("from-po")) { %>
                <div class="alert alert-info mb-2 py-1">
                    <i class="fas fa-truck me-2"></i>
                    <strong>Receiving Goods from PO:</strong> <%= poHeader != null ? poHeader.get(0).toString() : "" %>
                </div>
                <% } %>
                <div class="row g-1">
                    <div class="col-md-3">
                        <div class="input-outline">
                            <select class="form-select" name="supplier" id="supplier" onchange="setPaymentTypeBasedOnGst();">
                                <option value="0">Select Supplier</option>
                                <!-- Populated by JS -->
                            </select>
                            
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="input-outline">
                            <input type="text" class="form-control" id="invoiceNo" name="invoiceNo">
                            <label>Invoice No.</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="input-outline">
                            <input type="date" class="form-control" id="invoiceDate" name="invoiceDate" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                            <label>Invoice Date</label>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Product Table (Middle - Flexible) -->
        <div class="m-0 flex-grow-1 table-wrapper">
            <table class="table table-bordered table-sm mb-0 table-fixed-layout">
                <thead>
                    <tr>
                        <th>Add</th>
                        <th>Del</th>
                        <th>Item Name</th>
                        <th>History</th>
                        <th>Pack</th>
                        <th>Qty/Pk</th>
                        <th>Qty</th>
                        <th>Free</th>
                        <th>Cost</th>
                        <th>MRP</th>
                        <th>Disc%</th>
                        <th>Tax%</th>
                        <th>Cost Tot</th>
                        <th>MRP Tot</th>
                        <th>Tax Tot</th>
                        <th>Net Tot</th>
                        <th>Unit Cost</th>
                    </tr>
                </thead>
                <tbody id="productTable">
                    <!-- Rows added by JS -->
                </tbody>
                <tfoot style="background-color: #f8f9fa;">
                    <tr>
                        <td colspan="12" class="text-end fw-bold pe-2">Summary Total:</td>
                        <td id="sumCostTotal" class="fw-bold">0.00</td>
                        <td id="sumMrpTotal" class="fw-bold">0.00</td>
                        <td id="sumTaxTotal" class="fw-bold">0.00</td>
                        <td id="sumNetTotal" class="fw-bold">0.00</td>
                        <td colspan="3"></td>
                    </tr>
                </tfoot>
            </table>
        </div>

        <!-- Payment Details (Bottom) -->
        <div class="card flex-shrink-0 my-1">
            <div class="card-body py-2">
                <% if (mode.equals("from-po") && advancePaid > 0) { %>
                <div class="alert alert-success mb-2 py-1">
                    <i class="fas fa-info-circle me-2"></i>
                    <strong>Advance Paid:</strong> ₹<%= String.format("%.3f", advancePaid) %> | 
                    <strong>Remaining:</strong> ₹<%= String.format("%.3f", advanceBalance) %>
                </div>
                <% } %>
                <div class="row g-1">
                    <div class="col-md-2">
                        <div class="input-outline">
                            <select class="form-select" id="payType" name="payType">
                                <option value="0">Select Payment Type</option>
                                <!-- Populated by JS -->
                            </select>
                            
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="input-outline">
                            <select class="form-select" id="bank" name="bank">
                                <option value="0">Select Mode</option>
                            </select>
                           
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="input-outline">
                            <input type="number" class="form-control bg-light" id="grandTotal" name="grandTotal" step="0.001" readonly value="0.00">
                            <label>Total Amount</label>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="input-outline">
                            <input type="number" class="form-control" id="paidAmount" name="paidAmount" step="0.001" value="0.00">
                            <label>Paid Now</label>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="input-outline">
                            <input type="number" class="form-control" id="extraDisc" name="extraDisc" step="0.001" value="0.00">
                            <label>Extra Discount</label>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="input-outline">
                            <input type="number" class="form-control bg-light" id="balanceAmount" name="balanceAmount" step="0.001" readonly value="0.00">
                            <label>Balance</label>
                        </div>
                    </div>
                </div>
                <div class="row g-1 mt-1">
                    <div class="col-md-2">
                        <button type="button" class="btn btn-outline-primary w-100 h-100" onclick="openAddProductModal()">
                            <i class="fas fa-plus me-2"></i>Add Product
                        </button>
                    </div>
                    <div class="col-md-2">
                        <button type="button" class="btn btn-outline-violet w-100 h-100" id="saveBtn" onclick="savePurchaseBill()">
                            <i class="fas fa-save me-2"></i>Save
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Product Modal -->
    <div class="modal fade" id="addProductModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-box-open me-2"></i>Add Product</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-2">
                        <div class="col-md-6">
                            <label class="form-label">Category <span class="text-danger">*</span></label>
                            <select class="form-select" id="modalCategoryId">
                                <option value="">Select Category</option>
                                <% for (int i = 0; i < categories.size(); i++) {
                                    Vector cat = (Vector) categories.get(i);
                                    String catName = cat.get(0).toString();
                                    String catId = cat.get(1).toString();
                                %>
                                <option value="<%=catId%>"><%=catName%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Brand <span class="text-danger">*</span></label>
                            <select class="form-select" id="modalBrandId">
                                <option value="">Select Brand</option>
                                <% for (int i = 0; i < brands.size(); i++) {
                                    Vector brand = (Vector) brands.get(i);
                                    String brandName = brand.get(0).toString();
                                    String brandId = brand.get(1).toString();
                                %>
                                <option value="<%=brandId%>"><%=brandName%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label">Product Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="modalProductName" placeholder="Enter product name">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Product Code</label>
                            <input type="text" class="form-control" id="modalProductCode" placeholder="Enter code">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Unit <span class="text-danger">*</span></label>
                            <select class="form-select" id="modalUnitId">
                                <option value="">Select Unit</option>
                                <% for (int i = 0; i < units.size(); i++) {
                                    Vector unit = (Vector) units.get(i);
                                    String unitName = unit.get(0).toString();
                                    String unitId = unit.get(1).toString();
                                    String selectedUnit = (unitName.equalsIgnoreCase("Nos") || unitName.equalsIgnoreCase("PCS")) ? "selected" : "";
                                %>
                                <option value="<%=unitId%>" <%=selectedUnit%>><%=unitName%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Cost <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="modalCost" min="0" step="0.001" value="0">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">MRP <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="modalMrp" min="0" step="0.001" value="0">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">GST %</label>
                            <input type="number" class="form-control" id="modalGst" min="0" step="1" value="0">
                        </div>
                        <div class="col-md-8">
                            <label class="form-label">HSN</label>
                            <input type="text" class="form-control" id="modalHsn" placeholder="Optional HSN">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="saveNewProductBtn" onclick="saveProductFromModal()">
                        <i class="fas fa-check me-1"></i>Save Product
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Purchase History Modal -->
    <div class="modal fade" id="purchaseHistoryModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Last 6 Purchase History</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="historyContent">
                        <div class="text-center">
                            <div class="spinner-border" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        var contextPath = '<%=contextPath%>';
    </script>
    <script src="<%=contextPath%>/product/purchase/purchase.js"></script>
    <script>
        // Set payment type based on supplier GST status
        function setPaymentTypeBasedOnGst() {
            var supplier = $('#supplier').val();
            
            if (!supplier || supplier == '0') {
                return;
            }
            
            // Fetch supplier GST status
            $.ajax({
                type: 'POST',
                url: 'details.jsp',
                data: { 
                    status: 7,
                    supplierId: supplier 
                },
                success: function(result) {
                    var isGst = parseInt(result.trim());
                    
                    if (isGst === 1) {
                        // GST registered - auto-select Bank (assuming Bank is id=2)
                        $('#payType').val('2');
                    } else {
                        // Not GST registered - auto-select Cash (id=1)
                        $('#payType').val('1');
                    }
                    
                    // Trigger change event to enable/disable bank dropdown
                    $('#payType').trigger('change');
                }
            });
        }
        
        // Fix for table header gradient issue if present
        document.addEventListener("DOMContentLoaded", function() {
            setTimeout(function() {
                document.querySelectorAll("table thead th").forEach(th => {
                    th.style.removeProperty("background-color");
                    th.style.removeProperty("color");
                    th.style.removeProperty("background");
                });
            }, 100);
        });
        
        // Function to load PO items into table
        function loadPOItems() {
            var mode = $('#mode').val();
            
            if (mode === 'from-po') {
                // Load items from PO
                <% if (poItems != null && poItems.size() > 0) { %>
                var poItems = [];
                <% for (int i = 0; i < poItems.size(); i++) { 
                    Vector item = (Vector) poItems.get(i);
                %>
                poItems.push({
                    name: '<%= item.get(0).toString().replace("'", "\\'") %>',
                    pack: <%= item.get(12) %>,
                    qtyperpack: <%= item.get(13) %>,
                    free: <%= item.get(14) %>,
                    cost: <%= item.get(3) %>,
                    mrp: <%= item.get(7) %>,
                    disc: <%= item.get(15) %>,
                    tax: <%= item.get(11) %>,
                    productId: <%= item.get(9) %>,
                    poDetailId: <%= item.get(8) %>,
                    pendingQty: <%= item.get(6) %>
                });
                <% } %>
                
                // Populate rows
                for (var i = 0; i < poItems.length; i++) {
                    addProductRowFromPO(i, poItems[i]);
                }
                
                // Focus on invoice field instead
                $('#invoiceNo').focus();
                <% } %>
            } else {
                // Standalone mode - add one empty row
                addProductRow(event, 0);
            }
        }
        
        // Function to add a pre-filled row from PO data
        function addProductRowFromPO(rowIndex, itemData) {
            var proRowCount = rowIndex;
            
            // Escape double quotes in product name to prevent attribute breaking
            var escapedName = itemData.name.replace(/"/g, '&quot;');
            
            $("#productTable").append("<tr id='_productTableRow_" + proRowCount + "'>"
                + "<td class='text-center'><button type='button' class='btn btn-sm btn-success' id='_addProcRow_" + proRowCount + "' onclick='addProductRow();' disabled><i class='fas fa-plus'></i></button></td>"
                + "<td class='text-center'><button type='button' class='btn btn-sm btn-danger' id='_delProcRow_" + proRowCount + "' onclick='deleteProductRow(this);'><i class='fas fa-trash'></i></button></td>"
                + '<td><input type="text" class="form-control form-control-sm" id="_productName_' + proRowCount + '" name="_productName_' + proRowCount + '" value="' + escapedName + '" readonly></td>'
                + "<td class='text-center'><button type='button' class='btn btn-sm btn-info' id='_historyBtn_" + proRowCount + "' onclick='viewPurchaseHistory(" + proRowCount + ");'><i class='fas fa-history'></i></button></td>"
                + "<td><input type='text' class='form-control form-control-sm' id='_pack_" + proRowCount + "' name='_pack_" + proRowCount + "' value='" + itemData.pack + "' readonly></td>"
                + "<td><input type='text' class='form-control form-control-sm' id='_qtyperpack_" + proRowCount + "' name='_qtyperpack_" + proRowCount + "' value='" + itemData.qtyperpack + "' readonly></td>"
                + "<td><div class='d-flex flex-column'><div class='d-flex align-items-center gap-1'><input type='text' class='form-control form-control-sm' id='_totqty_" + proRowCount + "' name='_totqty_" + proRowCount + "' value='" + itemData.pendingQty + "' onkeyup='calculateRow(" + proRowCount + ");'><span class='text-muted small' id='_totunit_" + proRowCount + "'></span></div><small class='text-primary' id='_convtotqty_" + proRowCount + "'></small></div></td>"
                + "<td><input type='text' class='form-control form-control-sm' id='_freeqty_" + proRowCount + "' name='_freeqty_" + proRowCount + "' value='" + itemData.free + "' onkeyup='calculateRow(" + proRowCount + ");'></td>"
                + "<td><div class='d-flex flex-column'><input type='text' class='form-control form-control-sm' id='_cost_" + proRowCount + "' name='_cost_" + proRowCount + "' value='" + itemData.cost + "' onkeyup='calculateRow(" + proRowCount + ");'><small class='text-info' id='_costperconv_" + proRowCount + "'></small></div></td>"
                + "<td><div class='d-flex flex-column'><input type='text' class='form-control form-control-sm' id='_mrp_" + proRowCount + "' name='_mrp_" + proRowCount + "' value='" + itemData.mrp + "' onkeyup='calculateRow(" + proRowCount + ");'><small class='text-info' id='_mrpperconv_" + proRowCount + "'></small></div></td>"
                + "<td><input type='text' class='form-control form-control-sm' id='_disc_" + proRowCount + "' name='_disc_" + proRowCount + "' value='" + itemData.disc + "' onkeyup='calculateRow(" + proRowCount + ");'></td>"
                + "<td><input type='text' class='form-control form-control-sm' id='_tax_" + proRowCount + "' name='_tax_" + proRowCount + "' value='" + itemData.tax + "' onkeyup='calculateRow(" + proRowCount + ");'></td>"
                + "<td><label id='_costtotal_" + proRowCount + "'>0.00</label></td>"
                + "<td><label id='_mrptotal_" + proRowCount + "'>0.00</label></td>"
                + "<td><label id='_taxtotal_" + proRowCount + "'>0.00</label></td>"
                + "<td><label id='_nettotal_" + proRowCount + "'>0.00</label></td>"
                + "<td><label id='_unitcost_" + proRowCount + "'>0.00</label></td>"
                + "<input type='hidden' id='_productId_" + proRowCount + "' value='" + itemData.productId + "'>"
                + "<input type='hidden' id='_poDetailId_" + proRowCount + "' value='" + itemData.poDetailId + "'>"
                + "<input type='hidden' id='_pendingQty_" + proRowCount + "' value='" + itemData.pendingQty + "'>"
                + "</tr>");
            
            $('#_proAddRowCount').val(proRowCount);
            $('#_proDelRowCount').val(proRowCount + 1);
            
            // Calculate row totals
            calculateRow(proRowCount);
            // Fetch conversion data for this PO item
            fetchConversionData(proRowCount, itemData.name);
        }

        // Fetch conversion unit data for a pre-filled product row (PO items)
        function fetchConversionData(rowIndex, productName) {
            $.ajax({
                type: "POST",
                url: contextPath + "/product/purchase/details.jsp",
                data: { status: 1, productName: productName },
                success: function (_result) {
                    var resArr = _result.trim().split("<#>");
                    if (resArr.length > 1) {
                        var unitName = (resArr.length > 10) ? resArr[10] : '';
                        var convertionUnit = (resArr.length > 11) ? resArr[11].trim() : '';
                        var convertionCalc = (resArr.length > 12) ? parseFloat(resArr[12]) || 1 : 1;
                        $('#_productName_' + rowIndex).data('unitName', unitName);
                        $('#_productName_' + rowIndex).data('convertionUnit', convertionUnit);
                        $('#_productName_' + rowIndex).data('convertionCalc', convertionCalc);
                        if (unitName) {
                            $('#_qtyunit_' + rowIndex).text(unitName);
                            $('#_totunit_' + rowIndex).text(unitName);
                        }
                        calculateRow(rowIndex);
                    }
                }
            });
        }
    </script>
</body>
</html>
