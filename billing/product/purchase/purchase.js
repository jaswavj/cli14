// Enable/disable bank based on payType selection
$('#payType').on('change', function() {
    var payTypeVal = $('#payType').val();
    if (payTypeVal !== '0' && payTypeVal !== '1') {
        $('#bank').prop('disabled', false);
    } else {
        $('#bank').val('0').prop('disabled', true);
    }
});

// On page load, set bank disabled if payType is '0' or '1'
$(document).ready(function() {
    var payTypeVal = $('#payType').val();
    if (payTypeVal === '0' || payTypeVal === '1') {
        $('#bank').val('0').prop('disabled', true);
    } else {
        $('#bank').prop('disabled', false);
    }
});
function Load() {
  	
  	var status = 0;
    var param = 'status=' + status;
	
    $.ajax({
        type: "POST",
        url: contextPath + "/product/purchase/details.jsp",
        data: param,
        success: function (result) {
		var res	= result.trim().split('<@>');
	//$("#supplier").empty();
 	///////////////////Supplier
        //$("<option value='0'>Select Supplier Name</option>").appendTo("#supplier");
        if (parseFloat(res.length) > 1) {
            for (var i = 0; i < parseFloat(res.length) - 1; i++) {
                var arr1 = res[i].split("<#>");
                $("<option value='" + parseInt(arr1[0]) + "'>" + arr1[1] + "</option>").appendTo("#supplier");
            }
        }
        
        // If loading from PO, pre-select supplier and disable
        var mode = $('#mode').val();
        if (mode === 'from-po') {
            var supplierIdFromPO = $('#supplierIdFromPO').val();
            if (supplierIdFromPO && supplierIdFromPO !== '0') {
                $('#supplier').val(supplierIdFromPO).prop('disabled', true);
            }
        }
    //////////////////
    },
    });
 ///////////////////////PaymeType
    var status = 2;
    var param = 'status=' + status;
    
    $.ajax({
        type: "POST",
        url: contextPath + "/product/purchase/details.jsp",
        data: param,
        success: function (result) {
            var res = result.trim().split('<@>');
            if (parseFloat(res.length) > 1) {
                for (var i = 0; i < parseFloat(res.length) - 1; i++) {
                    var arr1 = res[i].split("<#>");
                    $("<option value='" + parseInt(arr1[0]) + "'>" + arr1[1] + "</option>").appendTo("#payType");
                }
            }
            $('#payType').val('1'); // Auto-select Cash
            $('#payType').trigger('change'); // Trigger change to update bank field
        },
    });
    ///////////////////////Bank Details (from prod_bill_payment_type)
    var status = 6;
    var param = 'status=' + status;
    
    $.ajax({
        type: "POST",
        url: contextPath + "/product/purchase/details.jsp",
        data: param,
        success: function (result) {
            var res = result.trim().split('<@>');
            $("<option value='0'>Select Bank Name</option>").appendTo("#bank");
            if (parseFloat(res.length) > 1) {
                for (var i = 0; i < parseFloat(res.length) - 1; i++) {
                    var arr1 = res[i].split("<#>");
                    $("<option value='" + parseInt(arr1[0]) + "'>" + arr1[1] + "</option>").appendTo("#bank");
                }
            }
        },
    });
    ///////////////////////    
}
/////////////////////////////
function formatProductDisplayName(name, code) {
    var cleanName = (name || '').trim();
    var cleanCode = (code || '').trim();
    return cleanCode ? cleanName + ' (' + cleanCode + ')' : cleanName;
}

function extractProductName(displayValue) {
    var text = (displayValue || '').trim();
    // Strip trailing " (CODE)" when present and keep original name for saving/query.
    return text.replace(/\s*\([^()]*\)\s*$/, '').trim();
}

function toggleCostMrpByProductValidity(rowIndex, isValidProduct) {
    $('#_cost_' + rowIndex).prop('disabled', !isValidProduct);
    $('#_mrp_' + rowIndex).prop('disabled', !isValidProduct);
}

/////////////////////////////
function autoComplete(event, str, str1) {
	var unicode = event.keyCode ? event.keyCode : event.charCode;

	if (unicode != 38 && unicode != 40) {
		if (str1 == 1) {
            var $productInput = $("#_productName_" + str);
            $productInput.autocomplete({
				source: function (request, response) {
					$.ajax({
						url: contextPath + "/product/purchase/auto_complete.jsp",
						data: {
							typeId: str1,
							q: request.term
						},
						dataType: "text",
						success: function (data) {
							if (data) {
								var suggestions = data.split("\n").map(function (item) {
									var trimmed = item.trim();
									if (trimmed.length === 0) return null;
									var parts = trimmed.split("<#>");
									var name = parts[0] || trimmed;
									var code = parts[1] || "";
									return {
										label: code ? name + " (" + code + ")" : name,
                                        value: name,
                                        productCode: code
									};
								}).filter(function (item) {
									return item !== null;
								});
								if (suggestions.length > 0) {
									response(suggestions);
								} else {
									response([{label: 'No Product Found', value: ''}]);
									$(".ui-menu-item:contains('No Product Found')")
										.css('color', 'red')
										.css('pointer-events', 'none')
										.addClass('no-select');
								}
							}
						},
						error: function (xhr, status, error) {
							console.error("Autocomplete error:", status, error);
							response([]);
						}
					});
				},
				minLength: 1,
				select: function(event, ui) {
                    $(this).val(ui.item.label || formatProductDisplayName(ui.item.value, ui.item.productCode));
                    $(this).data('selectedProductName', ui.item.value || '');
                    $(this).data('selectedProductCode', ui.item.productCode || '');
					return false;
				},
				change: function(event, ui) {
                    if (ui.item) {
                        $(this).data('selectedProductName', ui.item.value || '');
                        $(this).data('selectedProductCode', ui.item.productCode || '');
                        return;
                    }
					if (!ui.item && $(this).val().trim() !== '') {
						Swal.fire({
							title: 'Invalid Product',
							text: 'Please select a valid product from the list.',
							icon: 'warning',
							confirmButtonText: 'OK'
						});
						$(this).val('');
                        $(this).data('selectedProductName', '');
                        $(this).data('selectedProductCode', '');
                        toggleCostMrpByProductValidity(str, false);
                        $('#_cost_' + str).val('0.00');
                        $('#_mrp_' + str).val('0.00');
					}
				}
			});

            $productInput.off('input.purchaseCodeSync').on('input.purchaseCodeSync', function() {
                var selectedName = $(this).data('selectedProductName') || '';
                var selectedCode = $(this).data('selectedProductCode') || '';
                if (!selectedCode && !selectedName) {
                    return;
                }
                var expectedDisplay = formatProductDisplayName(selectedName, selectedCode);
                if ($(this).val().trim() === '' || $(this).val().trim() !== expectedDisplay) {
                    $(this).data('selectedProductName', '');
                    $(this).data('selectedProductCode', '');
                    toggleCostMrpByProductValidity(str, false);
                }
            });
			
			// Add keydown handler for Tab key to select first item
            $productInput.off('keydown.purchaseSelectTab').on('keydown.purchaseSelectTab', function(e) {
				if (e.keyCode === 9) { // Tab key
					var autocomplete = $(this).data('ui-autocomplete');
					if (autocomplete && autocomplete.menu.element.is(':visible')) {
						e.preventDefault();
						// Select the first item
						var firstItem = autocomplete.menu.element.find('.ui-menu-item:first');
						if (firstItem.length) {
							autocomplete.menu.focus(e, firstItem);
							autocomplete.menu.select(e);
						}
					}
				}
			});
		}
	}

	return false;
}

/////////////////////////////
function getProductDetails(str, str1) {
    var rawInput = $('#_productName_' + str).val();
    var productName = extractProductName(rawInput);
    var productCode = $('#_productName_' + str).data('selectedProductCode') || '';

    if (!productName) {
        toggleCostMrpByProductValidity(str, false);
        return;
    }

    var status = 1;
    var param = 'status=' + status + '&productName=' + encodeURIComponent(productName.trim()) + '&productCode=' + encodeURIComponent(productCode);

    $.ajax({
        type: "POST",
        url: contextPath + "/product/purchase/details.jsp",
        data: param,
        success: function (_result) {
            var resArr = _result.trim().split("<#>");
            if (resArr.length > 1) {		        
                var resolvedName = (resArr[0] || '').trim();
                $('#_productName_' + str).data('selectedProductName', resolvedName);
                $('#_productName_' + str).data('selectedProductCode', productCode);
                $('#_productName_' + str).val(formatProductDisplayName(resolvedName, productCode));
                $('#_cost_' + str).val(resArr[4]);
                $('#_mrp_' + str).val(resArr[5]);
                toggleCostMrpByProductValidity(str, true);
                if (resArr.length > 13 && resArr[13].trim() !== '') {
                    $('#_tax_' + str).val(resArr[13].trim());
                }
                var unitName = (resArr.length > 10) ? resArr[10] : '';
                $('#_productName_' + str).data('unitName', unitName);
                // Show unit next to Qty/Pk and Total fields
                if (unitName) {
                    $('#_qtyunit_' + str).text(unitName);
                    $('#_totunit_' + str).text(unitName);
                } else {
                    $('#_qtyunit_' + str).text('');
                    $('#_totunit_' + str).text('');
                }
                // Store conversion data
                var convertionUnit = (resArr.length > 11) ? resArr[11].trim() : '';
                var convertionCalc = (resArr.length > 12) ? parseFloat(resArr[12]) || 1 : 1;
                $('#_productName_' + str).data('convertionUnit', convertionUnit);
                $('#_productName_' + str).data('convertionCalc', convertionCalc);
                calculateRow(str);
            } else {
                toggleCostMrpByProductValidity(str, false);
                $('#_cost_' + str).val('0.00');
                $('#_mrp_' + str).val('0.00');
            }
        },
        error: function () {
            toggleCostMrpByProductValidity(str, false);
        }
    });
}

//////////////////////////////////
function addProductRow(event, str) {
    var unicode = 0;
    if (str == 1)
        unicode = event.keyCode ? event.keyCode : event.charCode;
    else
        unicode = 13;

    if (parseFloat(unicode) == 13) {
        var proRowCount = parseFloat($('#_proAddRowCount').val());
        var proDelRowCount = parseFloat($('#_proDelRowCount').val());

        // Optional: Capture values if needed
        if (proRowCount >= 0) {
            for (var i = 0; i <= proRowCount; i++) {
                if ($('#_productTableRow_' + i).length) {
                    var _productName = $('#_productName_' + i).val();
                    var _pack = $('#_pack_' + i).val();
                    var _qtyperpack = $('#_qtyperpack_' + i).val();
                    var _totqty = $('#_totqty_' + i).val();
                    var _freeqty = $('#_freeqty_' + i).val();                  
                    var _cost = $('#_cost_' + i).val();
                    var _mrp = $('#_mrp_' + i).val();
                    var _disc = $('#_disc_' + i).val();
                    var _tax = $('#_tax_' + i).val();
                    var _taxtotal = $('#_taxtotal_' + i).text();
                    var _unitcost = $('#_unitcost_' + i).text();

                    // Optionally do something with these values
                    //console.log(_productName + " added");
                }
            }
        }

        proRowCount++;
        proDelRowCount++;

        $("#productTable").append("<tr id='_productTableRow_" + proRowCount + "'>"
            + "<td class='text-center'><button type='button' class='btn btn-sm btn-success' id='_addProcRow_" + proRowCount + "' name='_addProcRow_" + proRowCount + "'  onclick='addProductRow();' disabled><i class='fas fa-plus'></i></button></td>"
            + "<td class='text-center'><button type='button' class='btn btn-sm btn-danger' id='_delProcRow_" + proRowCount + "' name='_delProcRow_" + proRowCount + "' onclick='deleteProductRow(this);'><i class='fas fa-trash'></i></button></td>"
            + "<td ><input type='text' class='form-control form-control-sm' id='_productName_" + proRowCount + "' name='_productName_" + proRowCount + "' placeholder='Product' onfocus='setActiveProductRow(" + proRowCount + ");autoComplete(event," + proRowCount + ",1);' onblur='getProductDetails(" + proRowCount + ",1);calculateRow(" + proRowCount + ");enableAddButton(" + proRowCount + ");'></td>"            + "<td class='text-center'><button type='button' class='btn btn-sm btn-info' id='_historyBtn_" + proRowCount + "' onclick='viewPurchaseHistory(" + proRowCount + ");'><i class='fas fa-history'></i></button></td>"            + "<td ><input type='text' class='form-control form-control-sm' id='_pack_" + proRowCount + "' name='_pack_" + proRowCount + "' placeholder='0' value='0' readonly></td>"
            + "<td ><div class='d-flex align-items-center gap-1'><input type='text' class='form-control form-control-sm' id='_qtyperpack_" + proRowCount + "' name='_qtyperpack_" + proRowCount + "' placeholder='0' value='0' readonly><span class='text-muted small' id='_qtyunit_" + proRowCount + "'></span></div></td>"
            + "<td ><div class='d-flex flex-column'><div class='d-flex align-items-center gap-1'><input type='text' class='form-control form-control-sm' id='_totqty_" + proRowCount + "' name='_totqty_" + proRowCount + "' placeholder='qty' value='0' onkeyup='calculateRow(" + proRowCount + ");'><span class='text-muted small' id='_totunit_" + proRowCount + "'></span></div><small class='text-primary' id='_convtotqty_" + proRowCount + "'></small></div></td>"
            + "<td ><input type='text' class='form-control form-control-sm' id='_freeqty_" + proRowCount + "' name='_freeqty_" + proRowCount + "' placeholder='Color' value='0' onkeyup='calculateRow(" + proRowCount + ");'></td>"
            + "<td ><div class='d-flex flex-column'><input type='text' class='form-control form-control-sm' id='_cost_" + proRowCount + "' name='_cost_" + proRowCount + "' placeholder='Cost' value='0.00' onkeyup='calculateRow(" + proRowCount + ");' disabled><small class='text-info' id='_costperconv_" + proRowCount + "'></small></div></td>"
            + "<td ><div class='d-flex flex-column'><input type='text' class='form-control form-control-sm' id='_mrp_" + proRowCount + "' name='_mrp_" + proRowCount + "' placeholder='Mrp' value='0.00' onkeyup='calculateRow(" + proRowCount + ");' disabled><small class='text-info' id='_mrpperconv_" + proRowCount + "'></small></div></td>"
            + "<td ><input type='text' class='form-control form-control-sm' id='_disc_" + proRowCount + "' name='_disc_" + proRowCount + "' placeholder='Disc' value='0' onkeyup='calculateRow(" + proRowCount + ");'></td>"
            + "<td ><input type='text' class='form-control form-control-sm' id='_tax_" + proRowCount + "' name='_tax_" + proRowCount + "' placeholder='Tax' value='0' onkeyup='calculateRow(" + proRowCount + ");'></td>"
            + "<td ><label id='_costtotal_" + proRowCount + "' name='costtotal" + proRowCount + "'>0.00</label></td>"
            + "<td ><label id='_mrptotal_" + proRowCount + "' name='_mrptotal_" + proRowCount + "'>0.00</label></td>"
            + "<td ><label id='_taxtotal_" + proRowCount + "' name='_taxtotal_" + proRowCount + "'>0.00</label></td>"
            + "<td ><label id='_nettotal_" + proRowCount + "' name='_nettotal_" + proRowCount + "'>0.00</label></td>"
            + "<td ><label id='_unitcost_" + proRowCount + "' name='_unitcost_" + proRowCount + "'>0.00</label></td>"
            + "</tr>");
            
        $('#_productTableRow_' + proRowCount).removeAttr('style'); // Remove any inline styles
        $('#_productName_' + proRowCount).focus();
        $('#_proAddRowCount').val(proRowCount);
        $('#_proDelRowCount').val(proDelRowCount);
    }
    
}
///////////////////////////////
function setActiveProductRow(rowIndex) {
    window.activeProductRowIndex = rowIndex;
}

///////////////////////////////
function openAddProductModal() {
    $('#modalProductName').val('');
    $('#modalProductCode').val('');
    $('#modalHsn').val('');
    $('#modalCost').val('0');
    $('#modalMrp').val('0');
    $('#modalGst').val('0');
    $('#saveNewProductBtn').prop('disabled', false);
    var modal = new bootstrap.Modal(document.getElementById('addProductModal'));
    modal.show();
    setTimeout(function() {
        $('#modalProductName').focus();
    }, 200);
}

///////////////////////////////
function getTargetRowForNewProduct() {
    var activeRow = parseInt(window.activeProductRowIndex, 10);
    if (!isNaN(activeRow) && $('#_productName_' + activeRow).length && !$('#_productName_' + activeRow).prop('readonly')) {
        return activeRow;
    }

    var proRowCount = parseFloat($('#_proAddRowCount').val()) || 0;
    for (var i = 0; i <= proRowCount; i++) {
        if ($('#_productName_' + i).length && !$('#_productName_' + i).prop('readonly')) {
            return i;
        }
    }

    addProductRow(null, 0);
    return parseInt($('#_proAddRowCount').val(), 10);
}

///////////////////////////////
function saveProductFromModal() {
    var productName = ($('#modalProductName').val() || '').trim();
    var productCode = ($('#modalProductCode').val() || '').trim();
    var categoryId = $('#modalCategoryId').val();
    var brandId = $('#modalBrandId').val();
    var unitId = $('#modalUnitId').val();
    var cost = parseFloat($('#modalCost').val()) || 0;
    var mrp = parseFloat($('#modalMrp').val()) || 0;
    var gst = parseInt($('#modalGst').val(), 10);
    var hsn = ($('#modalHsn').val() || '').trim();

    if (!productName) {
        Swal.fire({ title: 'Validation Error', text: 'Product name is required.', icon: 'warning', confirmButtonText: 'OK' });
        $('#modalProductName').focus();
        return;
    }
    if (!categoryId || !brandId || !unitId) {
        Swal.fire({ title: 'Validation Error', text: 'Select category, brand and unit.', icon: 'warning', confirmButtonText: 'OK' });
        return;
    }
    if (cost < 0 || mrp < 0) {
        Swal.fire({ title: 'Validation Error', text: 'Cost and MRP must be valid.', icon: 'warning', confirmButtonText: 'OK' });
        return;
    }
    if (isNaN(gst) || gst < 0) {
        gst = 0;
    }

    $('#saveNewProductBtn').prop('disabled', true);

    $.ajax({
        type: 'POST',
        url: contextPath + '/product/purchase/details.jsp',
        data: {
            status: 8,
            productName: productName,
            productCode: productCode,
            categoryId: categoryId,
            brandId: brandId,
            unitId: unitId,
            hsn: hsn,
            cost: cost,
            mrp: mrp,
            gst: gst
        },
        success: function (response) {
            var parts = (response || '').trim().split('<#>');
            if (parts[0] === 'SUCCESS') {
                var createdName = parts.length > 1 ? parts[1] : productName;
                var createdCode = parts.length > 2 ? parts[2] : productCode;
                var targetRow = getTargetRowForNewProduct();
                var $input = $('#_productName_' + targetRow);

                $input.data('selectedProductName', createdName);
                $input.data('selectedProductCode', createdCode);
                $input.val(formatProductDisplayName(createdName, createdCode));
                setActiveProductRow(targetRow);
                getProductDetails(targetRow, 1);
                enableAddButton(targetRow);

                var modalEl = document.getElementById('addProductModal');
                bootstrap.Modal.getInstance(modalEl).hide();
                $('#_pack_' + targetRow).focus();

                Swal.fire({ title: 'Success', text: 'Product added successfully.', icon: 'success', confirmButtonText: 'OK' });
            } else {
                var msg = parts.length > 1 ? parts[1] : 'Failed to add product.';
                Swal.fire({ title: 'Error', text: msg, icon: 'error', confirmButtonText: 'OK' });
                $('#saveNewProductBtn').prop('disabled', false);
            }
        },
        error: function () {
            Swal.fire({ title: 'Error', text: 'Failed to add product.', icon: 'error', confirmButtonText: 'OK' });
            $('#saveNewProductBtn').prop('disabled', false);
        }
    });
}
///////////////////////////////
function viewPurchaseHistory(rowIndex) {
    var productName = extractProductName($('#_productName_' + rowIndex).val());
    
    if (!productName || productName.trim() == '') {
        Swal.fire({
            title: 'Product Required',
            text: 'Please select a product first.',
            icon: 'warning',
            confirmButtonText: 'OK'
        });
        $('#_productName_' + rowIndex).focus();
        return;
    }
    
    // Show modal
    var modal = new bootstrap.Modal(document.getElementById('purchaseHistoryModal'));
    modal.show();
    
    // Fetch history
    $.ajax({
        type: 'POST',
        url: contextPath + '/product/purchase/details.jsp',
        data: {
            status: 5,
            productName: productName
        },
        success: function(response) {
            $('#historyContent').html(response);
        },
        error: function() {
            $('#historyContent').html('<div class="alert alert-danger">Error loading purchase history</div>');
        }
    });
}
///////////////////////////////
function enableAddButton(rowIndex) {
    var productName = $('#_productName_' + rowIndex).val();
    if (productName && productName.trim() !== '') {
        $('#_addProcRow_' + rowIndex).prop('disabled', false);
    } else {
        $('#_addProcRow_' + rowIndex).prop('disabled', true);
    }
}
///////////////////////////////
function deleteProductRow(str) {

	var proDelRowCount= parseFloat($('#_proDelRowCount').val());

	if (proDelRowCount > 1) {
		$(str).closest('tr').remove();
		invDelRowCount--;
		$('#_proDelRowCount').val(proDelRowCount);
	}
}

////////////////////////////
// Calculate totals for a single product row
function calculateRow(rowIndex) {
    // Quantity is entered directly in Qty field.
    var qty = parseFloat($('#_totqty_' + rowIndex).val()) || 0;
    var free = parseFloat($('#_freeqty_' + rowIndex).val()) || 0;
    var cost = parseFloat($('#_cost_' + rowIndex).val()) || 0;
    var mrp = parseFloat($('#_mrp_' + rowIndex).val()) || 0;
    var disc = parseFloat($('#_disc_' + rowIndex).val()) || 0;
    var tax = parseFloat($('#_tax_' + rowIndex).val()) || 0;

    if (qty < 0) qty = 0;
    $('#_totqty_' + rowIndex).val(qty);

    // Calculate cost total
    var costTotal = qty * cost;
    // Discount amount
    var discAmt = costTotal * (disc / 100);
    // Tax amount
    var taxAmt = (costTotal - discAmt) * (tax / 100);
    // Net total
    var netTotal = costTotal - discAmt + taxAmt;
    // MRP total
    var mrpTotal = qty * mrp;
    // Unit price
    var unitPrice = (qty + free) > 0 ? netTotal / (qty + free) : 0;

    // Update labels
    $('#_costtotal_' + rowIndex).text(costTotal.toFixed(3));
    $('#_mrptotal_' + rowIndex).text(mrpTotal.toFixed(3));
    $('#_taxtotal_' + rowIndex).text(taxAmt.toFixed(3));
    $('#_nettotal_' + rowIndex).text(netTotal.toFixed(3));
    $('#_unitcost_' + rowIndex).text(unitPrice.toFixed(3));

    // Conversion unit display
    var convertionUnit = $('#_productName_' + rowIndex).data('convertionUnit') || '';
    var convertionCalc = parseFloat($('#_productName_' + rowIndex).data('convertionCalc')) || 1;
    if (convertionUnit && convertionCalc > 1) {
        var convQty = qty * convertionCalc;
        $('#_convtotqty_' + rowIndex).text('= ' + convQty.toFixed(2) + ' ' + convertionUnit);
        $('#_costperconv_' + rowIndex).text('/' + convertionUnit + ':' + (cost / convertionCalc).toFixed(3));
        $('#_mrpperconv_' + rowIndex).text('/' + convertionUnit + ':' + (mrp / convertionCalc).toFixed(3));
    } else {
        $('#_convtotqty_' + rowIndex).text('');
        $('#_costperconv_' + rowIndex).text('');
        $('#_mrpperconv_' + rowIndex).text('');
    }

    // Recalculate grand total
    calculateGrandTotal();
}

// Calculate grand total and update payment fields
function calculateGrandTotal() {
    var sumCostTotal = 0, sumMrpTotal = 0, sumTaxTotal = 0, sumNetTotal = 0;
    $('#productTable tr').each(function() {
        var rowId = $(this).attr('id');
        if (rowId) {
            var idx = rowId.split('_').pop();
            var cost = parseFloat($('#_costtotal_' + idx).text()) || 0;
            var mrp = parseFloat($('#_mrptotal_' + idx).text()) || 0;
            var tax = parseFloat($('#_taxtotal_' + idx).text()) || 0;
            var net = parseFloat($('#_nettotal_' + idx).text()) || 0;
            sumCostTotal += cost;
            sumMrpTotal += mrp;
            sumTaxTotal += tax;
            sumNetTotal += net;
        }
    });

    // Update summary fields in table footer
    $('#sumCostTotal').text(sumCostTotal.toFixed(3));
    $('#sumMrpTotal').text(sumMrpTotal.toFixed(3));
    $('#sumTaxTotal').text(sumTaxTotal.toFixed(3));
    $('#sumNetTotal').text(sumNetTotal.toFixed(3));

    // Extra discount
    var extraDisc = parseFloat($('#extraDisc').val()) || 0;
    var grandTotal = sumNetTotal - extraDisc;
    var paidAmount = parseFloat($('#paidAmount').val()) || 0;
    var advancePaid = parseFloat($('#advancePaid').val()) || 0;
    
    // Calculate balance: grand total - paid now - advance paid
    var balance = grandTotal - paidAmount - advancePaid;

    $('#grandTotal').val(grandTotal.toFixed(3));
    $('#balanceAmount').val(balance.toFixed(3));
}

// Recalculate totals when payment fields change
$('#paidAmount, #extraDisc').on('input', function() {
    calculateGrandTotal();
});
//////////////////////////
function savePurchaseBill()
{
    var btn = $('#saveBtn');
    var invArr = '';
    var payArr = '';
    var prodArr= '';

    var supplier    = $('#supplier').val() || '0';
    var invoiceNo   = $('#invoiceNo').val();
    var invoiceDate = $('#invoiceDate').val();
    var offer       = $('#offer').val() || '';
    var offerDate   = $('#offerDate').val() || '';
    var lrNo        = $('#lrNo').val() || '';
    var lrDate      = $('#lrDate').val() || '';
    var lrName      = $('#lrName').val() || '';
    var payType     = $('#payType').val() || '0';
    var bank        = $('#bank').val() || '0';
    var paidAmount  = parseFloat($('#paidAmount').val()) || 0;
    var extraDisc   = parseFloat($('#extraDisc').val()) || 0;
    var grandTotal  = parseFloat($('#grandTotal').val()) || 0;
    var balanceAmount= parseFloat($('#balanceAmount').val()) || 0;

    if (supplier == '0') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please select supplier name.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#supplier').focus();
        return false;
    }
    
    // Proceed with purchase save
    btn.prop('disabled', true);
    proceedWithPurchaseSave();
}

function proceedWithPurchaseSave() {
    var btn = $('#saveBtn');
    var invArr = '';
    var payArr = '';
    var prodArr= '';

    var supplier    = $('#supplier').val() || '0';
    var invoiceNo   = $('#invoiceNo').val();
    var invoiceDate = $('#invoiceDate').val();
    var offer       = $('#offer').val() || '';
    var offerDate   = $('#offerDate').val() || '';
    var lrNo        = $('#lrNo').val() || '';
    var lrDate      = $('#lrDate').val() || '';
    var lrName      = $('#lrName').val() || '';
    var payType     = $('#payType').val() || '0';
    var bank        = $('#bank').val() || '0';
    var paidAmount  = parseFloat($('#paidAmount').val()) || 0;
    var extraDisc   = parseFloat($('#extraDisc').val()) || 0;
    var grandTotal  = parseFloat($('#grandTotal').val()) || 0;
    var balanceAmount= parseFloat($('#balanceAmount').val()) || 0;
    
    if (invoiceNo.trim() == '') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please enter invoice number.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#invoiceNo').focus();
        btn.prop('disabled', false);
        return false;
    }
    if (invoiceDate.trim() == '') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please select invoice date.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#invoiceDate').focus();
        btn.prop('disabled', false);
        return false;
    }
    if (payType == '0') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please select payment mode.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#payType').focus();
        btn.prop('disabled', false);
        return false;
    }
    if (payType != '0' && payType != '1' && bank == '0') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please select payment mode (Bank details).',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#bank').focus();
        btn.prop('disabled', false);
        return false;
    }
    if (paidAmount >= 1) {
        if (payType != '1' && bank == '0') {
            Swal.fire({
                title: 'Validation Error',
                
                icon: 'error',
                confirmButtonText: 'OK'
            });
            $('#bank').focus();
            btn.prop('disabled', false);
            return false;
        }
    }
    if (grandTotal <= 0) {
        Swal.fire({
            title: 'Validation Error',
            text: 'Grand total must be greater than zero.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        return false;
    } 
    if (paidAmount < 0) {
        Swal.fire({
            title: 'Validation Error',
            text: 'Paid amount cannot be negative.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#paidAmount').focus();
        return false;
    }
    if (balanceAmount < 0) {
        Swal.fire({
            title: 'Validation Error',
            text: 'Balance amount cannot be negative.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#paidAmount').focus();
        return false;
    }
    btn.prop('disabled', true);

    var proRowCount = parseFloat($('#_proAddRowCount').val());
    var mode = $('#mode').val() || 'standalone';
    
    if(proRowCount < 0) { 
        Swal.fire({
            title: 'Validation Error',
            text: 'Please add at least one product.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        btn.prop('disabled', false);
        return false;
    }
    
    if(proRowCount >=0) { 
        for (var i = 0; i <= proRowCount; i++) {
            if ($('#_productTableRow_' + i).length) {
                var _productName = $('#_productName_' + i).val().trim();
                _productName = extractProductName(_productName);
                var _pack = parseFloat($('#_pack_' + i).val()) || 0;
                var _qtyperpack = parseFloat($('#_qtyperpack_' + i).val()) || 0;
                var _totqty = parseFloat($('#_totqty_' + i).val()) || 0;
                var _freeqty = parseFloat($('#_freeqty_' + i).val()) || 0;                  
                var _cost = parseFloat($('#_cost_' + i).val()) || 0;
                var _mrp = parseFloat($('#_mrp_' + i).val()) || 0;
                var _disc = parseFloat($('#_disc_' + i).val()) || 0;
                var _tax = parseFloat($('#_tax_' + i).val()) || 0;
                var _poDetailId = $('#_poDetailId_' + i).val() || '0';
                var _pendingQty = parseFloat($('#_pendingQty_' + i).val()) || 0;
                
                // Skip products with 0 quantity
                if (_totqty <= 0) {
                    continue;
                }
                
                // Skip if product name is empty
                if (_productName == '') {
                    continue;
                }
                
                // Validate MRP is filled
                if (_mrp <= 0) {
                    Swal.fire({
                        title: 'Validation Error',
                        text: 'Product "' + _productName + '" - Please enter MRP (Maximum Retail Price).',
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                    $('#_mrp_' + i).focus();
                    btn.prop('disabled', false);
                    return false;
                }
                
                // Validate pending quantity for PO items
                if (mode === 'from-po' && _poDetailId !== '0' && _pendingQty > 0) {
                    if (_totqty > _pendingQty) {
                        Swal.fire({
                            title: 'Validation Error',
                            text: 'Product "' + _productName + '" - Cannot receive ' + _totqty + ' units. Pending quantity is only ' + _pendingQty + ' units.',
                            icon: 'error',
                            confirmButtonText: 'OK'
                        });
                        btn.prop('disabled', false);
                        return false;
                    }
                }

                // Add product to array
                var _convertionCalc = parseFloat($('#_productName_' + i).data('convertionCalc')) || 1;
                prodArr += _productName + '<#>' + _pack + '<#>' + _qtyperpack + '<#>' + _totqty + '<#>' + _freeqty + '<#>' + _cost + '<#>' + _mrp + '<#>' + _disc + '<#>' + _tax + '<#>' + _poDetailId + '<#>' + _convertionCalc + '<@>';
            }
        }
        
        // Validate product array
        if (prodArr.trim() === '') {
            Swal.fire({
                title: 'Validation Error',
                text: 'Please add at least one product with quantity.',
                icon: 'error',
                confirmButtonText: 'OK'
            });
            btn.prop('disabled', false);
            return false;
        }
        
        var status = 4;
        var poId = $('#poId').val() || '0';
        var mode = $('#mode').val() || 'standalone';
        
        // Debug: Log offer values
        console.log('Offer:', offer, 'Offer Date:', offerDate);
        
        //var param = 'status=' + status + '&productName=' + encodeURIComponent(productName.trim());
        invArr  = supplier + '<#>' +invoiceNo+ '<#>' +invoiceDate+ '<#>' +offer+ '<#>' +offerDate+ '<#>' +lrNo+ '<#>' +lrDate+ '<#>' +lrName;
        
        // Debug: Log invArr
        console.log('invArr:', invArr);
        
        payArr  = payType+ '<#>' +bank+ '<#>' +grandTotal+ '<#>' +paidAmount+ '<#>' +extraDisc+ '<#>' +balanceAmount;
        var param   = 'status=' +status+ '&invArr=' +encodeURIComponent(invArr)+ '&payArr=' +encodeURIComponent(payArr)+ '&prodArr=' +encodeURIComponent(prodArr)+ '&poId=' +poId+ '&mode=' +mode;

        $.ajax({
            type: "POST",
            url: contextPath + "/product/purchase/details.jsp",
            data: param,
            success: function (_result) {
                console.log("Server response:", _result);
                
                // Check for error message
                if (_result && _result.trim().startsWith('ERROR:')) {
                    var errorMsg = _result.trim().substring(7); // Remove 'ERROR: ' prefix
                    Swal.fire({
                        title: 'Error',
                        text: errorMsg,
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                    btn.prop('disabled', false);
                } else if (_result && _result.trim() !== '' && _result.trim() !== '0') {
                    Swal.fire({
                        title: 'Purchase Saved!',
                        text: 'Purchase bill saved successfully. Bill No: ' + _result.trim(),
                        icon: 'success',
                        confirmButtonText: 'OK'
                    }).then(function() {
                        // Redirect to standalone purchase page (remove poId from URL)
                        window.location.href = contextPath + '/product/purchase/page.jsp';
                    });
                } else {
                    Swal.fire({
                        title: 'Error',
                        text: 'Failed to save purchase. Server returned: ' + _result,
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                    btn.prop('disabled', false);
                }
            },
            error: function(xhr, status, error) {
                console.error("AJAX Error:", status, error);
                console.error("Response:", xhr.responseText);
                Swal.fire({
                    title: 'Error',
                    text: 'Failed to save purchase bill. Error: ' + error,
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                btn.prop('disabled', false);
            }
        });
    } else {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please add products to save.',
            icon: 'warning',
            confirmButtonText: 'OK'
        });
        btn.prop('disabled', false);
    }
}
