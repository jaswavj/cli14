let count = 0;
let grandTotal = 0;        // Total after discount
let subtotal = 0;          // Total before discount
let totalDiscount = 0;     // Total discount value
let totalCommission = 0;   // Total commission value
let prodTotal = 0;
let bypassDiscountCap = false; // true when exchange points are applied — skips userMaxDiscPer check
let currentProductStock = 0; // Store current product's available stock
let productQuantitiesInBill = {}; // Track quantities already added to bill by product ID
let currentQuotationId = null; // Store current quotation ID when converting to bill

// Customer Autocomplete Setup
let customerAutocompleteTimeout;
const customerNameInput = document.getElementById("customerName");
const customerPhnInput = document.getElementById("customerPhn");
const customerIdInput = document.getElementById("customerId");

customerNameInput.addEventListener("input", function() {
    const query = this.value.trim();
    
    clearTimeout(customerAutocompleteTimeout);
    
    // Remove existing autocomplete list
    removeCustomerAutocomplete();
    
    if (query.length < 2) {
        customerIdInput.value = "0";
        enableSaveButton(); // Re-enable when customer is cleared
        const ct = document.getElementById('isCommission');
        if (ct) ct.checked = false;
        refreshCommissionDisplay();
        return;
    }
    
    customerAutocompleteTimeout = setTimeout(() => {
        fetch(`customerAutocomplete.jsp?query=${encodeURIComponent(query)}`)
            .then(response => response.json())
            .then(data => {
                if (data.length > 0) {
                    showCustomerAutocomplete(data);
                }
            })
            .catch(error => console.error("Error fetching customers:", error));
    }, 300);
});

function showCustomerAutocomplete(customers) {
    removeCustomerAutocomplete();
    
    const list = document.createElement("ul");
    list.className = "autocomplete-list";
    list.style.cssText = "position: absolute; z-index: 1000; background: white; border: 1px solid #ddd; list-style: none; padding: 0; margin: 0; max-height: 200px; overflow-y: auto; width: " + customerNameInput.offsetWidth + "px;";
    
    customers.forEach(customer => {
        const item = document.createElement("li");
        item.style.cssText = "padding: 8px 12px; cursor: pointer; border-bottom: 1px solid #eee;";
        item.textContent = customer.name + (customer.phone !== '-' ? ' - ' + customer.phone : '');
        
        item.addEventListener("mouseenter", function() {
            this.style.backgroundColor = "#f0f0f0";
        });
        
        item.addEventListener("mouseleave", function() {
            this.style.backgroundColor = "white";
        });
        
        item.addEventListener("click", function() {
            selectCustomer(customer);
        });
        
        list.appendChild(item);
    });
    
    customerNameInput.parentElement.style.position = "relative";
    customerNameInput.parentElement.appendChild(list);
}

function selectCustomer(customer) {
    customerNameInput.value = customer.name;
    customerPhnInput.value = customer.phone !== '-' ? customer.phone : '';
    customerIdInput.value = customer.id;
    document.getElementById('customerCreditLimit').value = customer.creditLimit || 0;
    const commissionToggle = document.getElementById('isCommission');
    if (commissionToggle) commissionToggle.checked = (customer.isEligibleForCommission == 1);
    refreshCommissionDisplay();

    removeCustomerAutocomplete();
    removePhoneAutocomplete();

    // Handle exchange points
    const ep = parseFloat(customer.exchangePoint) || 0;
    document.getElementById('customerExchangePoint').value = ep;
    document.getElementById('exchangePointUsed').value = 0; // reset on new customer selection
    if (ep > 0) {
        document.getElementById('exchangePointValue').textContent = ep.toFixed(2);
        document.getElementById('exchangePointBanner').classList.remove('d-none');
        Swal.fire({
            toast: true,
            position: 'top-end',
            icon: 'info',
            title: '\u20b9' + ep.toFixed(2) + ' exchange points available!',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true
        });
    } else {
        document.getElementById('exchangePointBanner').classList.add('d-none');
        document.getElementById('customerExchangePoint').value = 0;
    }

    // Check for overdue dues first
    checkOverdueDues(customer.id);

    // Then check credit eligibility
    checkCreditEligibility(customer.id);
}

function applyExchangePointDiscount() {
    const ep = parseFloat(document.getElementById('customerExchangePoint').value) || 0;
    if (ep <= 0) return;
    // Cap only at current payable amount — exchange points bypass the userMaxDiscPer limit
    const payable = parseFloat(document.getElementById('payableAmount').value) || 0;
    const toUse = Math.min(ep, payable);
    if (toUse <= 0) return;
    document.getElementById('finalDiscount').value = toUse.toFixed(2);
    // Bypass discount % cap — exchange points are customer-earned, not a staff discount
    bypassDiscountCap = true;
    updatePayableAmount();
    bypassDiscountCap = false;
    document.getElementById('exchangePointUsed').value = toUse.toFixed(2);
    document.getElementById('exchangePointBanner').classList.add('d-none');
    Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: '\u20b9' + toUse.toFixed(2) + ' applied as exchange point discount!',
        showConfirmButton: false,
        timer: 2500
    });
}

function dismissExchangePointBanner() {
    document.getElementById('exchangePointBanner').classList.add('d-none');
    document.getElementById('exchangePointUsed').value = 0;
}



function checkOverdueDues(customerId) {
    if (!customerId || customerId === "0") {
        enableSaveButton();
        return;
    }
    
    
}

function disableSaveButton() {
    const saveBtn = document.getElementById('saveBillBtn');
    if (saveBtn) {
        saveBtn.disabled = true;
        saveBtn.style.opacity = '0.5';
        saveBtn.style.cursor = 'not-allowed';
    }
}

function enableSaveButton() {
    const saveBtn = document.getElementById('saveBillBtn');
    if (saveBtn) {
        saveBtn.disabled = false;
        saveBtn.style.opacity = '1';
        saveBtn.style.cursor = 'pointer';
    }
}

function removeCustomerAutocomplete() {
    const existingList = customerNameInput.parentElement.querySelector(".autocomplete-list");
    if (existingList) {
        existingList.remove();
    }
}

// Handle Tab/Enter key for autocomplete
customerNameInput.addEventListener("keydown", function(e) {
    const list = customerNameInput.parentElement.querySelector(".autocomplete-list");
    if (!list) return;
    
    const items = list.querySelectorAll("li");
    if (items.length === 0) return;
    
    if (e.key === "Tab" || e.key === "Enter") {
        e.preventDefault();
        items[0].click(); // Select first item
    }
});

// ── Phone number autocomplete ───────────────────────────────────────────────
let phoneAutocompleteTimeout;

customerPhnInput.addEventListener("input", function() {
    const q = this.value.trim();
    clearTimeout(phoneAutocompleteTimeout);
    removePhoneAutocomplete();
    if (q.length < 3) return;

    phoneAutocompleteTimeout = setTimeout(() => {
        fetch(`customerAutocomplete.jsp?phone=${encodeURIComponent(q)}`)
            .then(r => r.json())
            .then(data => { if (data.length > 0) showPhoneAutocomplete(data); })
            .catch(err => console.error('Phone autocomplete error:', err));
    }, 300);
});

function showPhoneAutocomplete(customers) {
    removePhoneAutocomplete();
    const list = document.createElement('ul');
    list.id = 'phoneAutocompleteList';
    list.className = 'autocomplete-list';
    list.style.cssText = 'position:absolute;z-index:1000;background:white;border:1px solid #ddd;list-style:none;padding:0;margin:0;max-height:200px;overflow-y:auto;width:' + customerPhnInput.offsetWidth + 'px;';

    customers.forEach(customer => {
        const item = document.createElement('li');
        item.style.cssText = 'padding:8px 12px;cursor:pointer;border-bottom:1px solid #eee;';
        item.textContent = customer.phone + (customer.name ? ' — ' + customer.name : '');
        item.addEventListener('mouseenter', function() { this.style.backgroundColor = '#f0f0f0'; });
        item.addEventListener('mouseleave', function() { this.style.backgroundColor = 'white'; });
        item.addEventListener('click', function() { selectCustomer(customer); });
        list.appendChild(item);
    });

    customerPhnInput.parentElement.style.position = 'relative';
    customerPhnInput.parentElement.appendChild(list);
}

function removePhoneAutocomplete() {
    const el = customerPhnInput.parentElement.querySelector('#phoneAutocompleteList');
    if (el) el.remove();
}

customerPhnInput.addEventListener('keydown', function(e) {
    const list = customerPhnInput.parentElement.querySelector('#phoneAutocompleteList');
    if (!list) return;
    const items = list.querySelectorAll('li');
    if (items.length === 0) return;
    if (e.key === 'Tab' || e.key === 'Enter') { e.preventDefault(); items[0].click(); }
});

// Close autocomplete when clicking outside
document.addEventListener("click", function(e) {
    if (e.target !== customerNameInput) removeCustomerAutocomplete();
    if (e.target !== customerPhnInput)  removePhoneAutocomplete();
});
        

function addProduct() {
    const code = document.getElementById("productCode").value.trim();
    const name = document.getElementById("productName").value.trim();
    const qtyInput = parseFloat(document.getElementById("productQty").value);
    const price = parseFloat(document.getElementById("productPrice").value);
    const discount = parseFloat(document.getElementById("productDiscount").value);
    const selectedUnit = document.getElementById("productUnit").value;
    const unitName = document.getElementById("productUnitName").value;
    const convertionUnit = (document.getElementById("productConvertionUnit").value || '').trim();

    if (code === "" || name === "" || isNaN(qtyInput) || isNaN(price) || isNaN(discount)) {
        alert("Please enter valid product details!");
        return;
    }

    // Validate per-product discount does not exceed user's allowed percentage
    if (price > 0 && userMaxDiscPer < 100) {
        const discPct = (discount / price) * 100;
        if (discPct > userMaxDiscPer) {
            Swal.fire({
                icon: 'error',
                title: 'Discount Exceeded',
                html: `Product discount <b>${discPct.toFixed(2)}%</b> exceeds your allowed limit of <b>${userMaxDiscPer}%</b>.`,
                confirmButtonText: 'OK'
            });
            return;
        }
    }

    const productId = parseInt(document.getElementById("productCode").dataset.id || 0);
    const productBatch = parseInt(document.getElementById("productCode").dataset.batchId || 0);
    const productCommission = parseFloat(document.getElementById("productCode").dataset.commission || 0);
    
    // Calculate actual quantity for stock (convert gram to kg if needed)
    let actualQty = qtyInput;
    let displayQty = qtyInput;
    let displayUnit = unitName;
    
    // Normalize unit name for comparison
    const normalizedUnitName = (unitName || '').trim().toLowerCase();
    
    // For KG products, check if user selected gram conversion
    if ((normalizedUnitName === 'kg' || normalizedUnitName === 'kgs') && selectedUnit === 'gram') {
        // Convert gram to kg for stock calculation
        actualQty = qtyInput / 1000;
        displayQty = qtyInput;
        displayUnit = 'Gram';
    } else if ((normalizedUnitName === 'kg' || normalizedUnitName === 'kgs') && selectedUnit === 'kg') {
        actualQty = qtyInput;
        displayQty = qtyInput;
        displayUnit = 'KG';
    } else {
        // For other units or when unit dropdown is disabled
        actualQty = qtyInput;
        displayQty = qtyInput;
        displayUnit = convertionUnit || unitName;
    }
    
    // Calculate already added quantity for this product (in actual units, e.g., KG)
    const alreadyAddedQty = parseFloat(productQuantitiesInBill[productId]) || 0;
    const availableToAdd = parseFloat(currentProductStock) - alreadyAddedQty;
    
    // Validate quantity against remaining available stock (skip if user has stock permission)
    if (!userHasStockPermission && actualQty > availableToAdd) {
        // Prepare stock message based on unit type
        let stockMessage = '';
        
        if (normalizedUnitName === 'kg' || normalizedUnitName === 'kgs') {
            // For KG products, show stock in KG or convert to gram if user is entering in gram
            if (selectedUnit === 'gram') {
                stockMessage = `Total available stock: ${parseFloat(currentProductStock).toFixed(2)} KG (${(parseFloat(currentProductStock) * 1000).toFixed(0)} Gram)<br>` +
                              `Already added: ${alreadyAddedQty.toFixed(2)} KG (${(alreadyAddedQty * 1000).toFixed(0)} Gram)<br>` +
                              `Available to add: ${availableToAdd.toFixed(2)} KG (${(availableToAdd * 1000).toFixed(0)} Gram)<br><br>` +
                              `You cannot add ${qtyInput} Gram (${actualQty.toFixed(2)} KG).`;
            } else {
                stockMessage = `Total available stock: ${parseFloat(currentProductStock).toFixed(2)} KG<br>` +
                              `Already added: ${alreadyAddedQty.toFixed(2)} KG<br>` +
                              `Available to add: ${availableToAdd.toFixed(2)} KG<br><br>` +
                              `You cannot add ${actualQty.toFixed(2)} KG.`;
            }
        } else {
            // For other units (NOS, Meter, etc.)
            stockMessage = `Total available stock: ${parseFloat(currentProductStock)} ${unitName}<br>` +
                          `Already added: ${alreadyAddedQty} ${unitName}<br>` +
                          `Available to add: ${availableToAdd} ${unitName}<br><br>` +
                          `You cannot add ${actualQty} ${unitName}.`;
        }
        
        Swal.fire({
            icon: 'error',
            title: 'Insufficient Stock',
            html: stockMessage,
            confirmButtonText: 'OK'
        });
        return;
    }

    // Remove empty placeholder rows on first product add
    if (count === 0) {
        const emptyRows = document.querySelectorAll('#billBody .empty-row');
        emptyRows.forEach(row => row.remove());
    }

    count++;

    // Use actualQty for calculations
    const productSubtotal = actualQty * price;
    
    const productDiscount = discount * actualQty;
    const total = productSubtotal - productDiscount;
    const commissionAmount = (document.getElementById('isCommission') && document.getElementById('isCommission').checked)
        ? (productCommission * actualQty)
        : 0;

    prodTotal+=productSubtotal;
    
    subtotal += productSubtotal;
    totalDiscount += productDiscount;
    totalCommission += commissionAmount;
    grandTotal += total;

    const row = `
        <tr id="row${count}" data-batch-id="${productBatch}" data-commission="${productCommission}" class="bill-item-row" style="display: table; width: 100%; table-layout: fixed; cursor: pointer;">
            <td style="width: 5%;">${count}</td>
            <td style="width: 10%;" data-id="${productId}">${code}</td>
            <td style="width: 22%;" data-name="${name}">${name}</td>
            <td style="width: 8%;">${displayQty} ${displayUnit}</td>
            <td style="width: 10%;">₹${price.toFixed(3)}</td>
            <td style="width: 10%;">₹${productDiscount.toFixed(3)}</td>
            <td style="width: 10%;">₹${commissionAmount.toFixed(3)}</td>
            <td style="width: 10%;">₹${total.toFixed(3)}</td>
            <td style="width: 15%;">
                <button class="btn btn-danger btn-sm" 
                    onclick="event.stopPropagation(); removeProduct(${count}, ${productSubtotal}, ${productDiscount}, ${commissionAmount}, ${total})">
                    Delete
                </button>
            </td>
        </tr>`;

    document.getElementById("billBody").insertAdjacentHTML("beforeend", row);

    // Track actual quantity added for this product (in base unit, e.g., KG)
    if (!productQuantitiesInBill[productId]) {
        productQuantitiesInBill[productId] = 0;
    }
    productQuantitiesInBill[productId] += actualQty;
    
    // Store quantity in row data attribute for removal tracking
    const addedRow = document.getElementById(`row${count}`);
    addedRow.dataset.productId = productId;
    addedRow.dataset.quantity = actualQty;
    addedRow.dataset.commissionAmount = commissionAmount;

    // Add click event to the newly added row
    addedRow.addEventListener('click', function(e) {
        // Don't trigger if clicking on delete button
        if (e.target.tagName === 'BUTTON' || e.target.closest('button')) {
            return;
        }
        showProductHistory(this);
    });

    updateTotals();
    updatePayableAmount();

    document.getElementById("productCode").value = "";
    document.getElementById("productCode").dataset.id = 0;
    document.getElementById("productCode").dataset.commission = "0";
    document.getElementById("productName").value = "";
    document.getElementById("productQty").value = "1";
    document.getElementById("productPrice").value = "";
    document.getElementById("productDiscount").value = "0";
    document.getElementById("productUnit").value = "";
    document.getElementById("productUnit").disabled = true;
    document.getElementById("productUnitId").value = "";
    document.getElementById("productUnitName").value = "";
    document.getElementById("productConvertionUnit").value = "";
    document.getElementById("qtyLabel").textContent = " Qty ";
    $('#productName').prop('disabled', false);
    document.getElementById("productCode").focus();
    
    // Reset stock counter
    currentProductStock = 0;
}

// Function to fetch product stock
function fetchProductStock(productId) {
    if (!productId || productId === 0) {
        currentProductStock = 0;
        return;
    }
    
    $.ajax({
        url: contextPath + "/billing/getProductStock.jsp",
        type: "GET",
        data: { productId: productId },
        dataType: "json",
        success: function (data) {
            currentProductStock = data.stock || 0;
        },
        error: function () {
            console.error("Error fetching product stock");
            currentProductStock = 0;
        }
    });
}

// Add quantity validation on input
document.getElementById("productQty").addEventListener("input", function() {
    const qty = parseInt(this.value);
    const productId = parseInt(document.getElementById("productCode").dataset.id || 0);
    
    if (isNaN(qty) || qty <= 0) {
        return;
    }
    
    // Skip validation if user has stock permission
    if (!userHasStockPermission && currentProductStock > 0 && productId > 0) {
        const alreadyAddedQty = productQuantitiesInBill[productId] || 0;
        const availableToAdd = currentProductStock - alreadyAddedQty;
        
        if (qty > availableToAdd) {
            Swal.fire({
                icon: 'warning',
                title: 'Stock Limit Exceeded',
                html: `Total available stock: ${currentProductStock}<br>Already added: ${alreadyAddedQty}<br>Available to add: ${availableToAdd}`,
                confirmButtonText: 'OK'
            });
            this.value = availableToAdd > 0 ? availableToAdd : 1;
        }
    }
});






function getCommissionAmountForRow(row) {
    const qty = parseFloat(row.dataset.quantity) || parseFloat(row.querySelector('td:nth-child(4)').textContent) || 0;
    const perUnitCommission = parseFloat(row.dataset.commission || 0);
    const isEligibleForCommission = document.getElementById('isCommission') ? document.getElementById('isCommission').checked : false;
    return isEligibleForCommission ? (qty * perUnitCommission) : 0;
}

function refreshCommissionDisplay() {
    totalCommission = 0;
    const rows = document.querySelectorAll('#billBody .bill-item-row, #billBody .item-row');
    rows.forEach(row => {
        const commissionAmount = getCommissionAmountForRow(row);
        row.dataset.commissionAmount = commissionAmount;
        const commissionCell = row.querySelector('td:nth-child(7)');
        if (commissionCell) {
            commissionCell.textContent = '₹' + commissionAmount.toFixed(3);
        }
        totalCommission += commissionAmount;
    });

    updateTotals();
    updatePayableAmount();
}

function removeProduct(rowId, rowSubtotal, rowDiscount, rowCommission, rowTotal) {
    const row = document.getElementById(`row${rowId}`);
     if (!row) return;
     const currentRowCommission = parseFloat(row.dataset.commissionAmount || rowCommission || 0);
    
    // Update product quantities tracker
    const productId = parseInt(row.dataset.productId);
    const qty = parseFloat(row.dataset.quantity);
    if (productId && qty && productQuantitiesInBill[productId]) {
        productQuantitiesInBill[productId] -= qty;
        if (productQuantitiesInBill[productId] <= 0) {
            delete productQuantitiesInBill[productId];
        }
    }
    
    row.remove();
    subtotal -= rowSubtotal;
    totalDiscount -= rowDiscount;
    totalCommission -= currentRowCommission;
    grandTotal -= rowTotal;

    updateTotals();
    updatePayableAmount();
}
function updateTotals() {
    document.getElementById("priceTotal").value = subtotal.toFixed(3);
    document.getElementById("discountTotal").value = totalDiscount.toFixed(3);
    document.getElementById("commissionTotal").value = totalCommission.toFixed(3);
    document.getElementById("grandTotal").value = grandTotal.toFixed(3);
}


function updatePayableAmount() {
    const extraDisc = parseFloat(document.getElementById("finalDiscount").value) || 0;

    // Validate total (item discounts + extra discount) does not exceed user's allowed percentage
    // bypassDiscountCap is true when exchange points are used — they are not a staff discount
    if (!bypassDiscountCap && subtotal > 0 && userMaxDiscPer < 100) {
        const maxAllowedDisc = (subtotal * userMaxDiscPer) / 100;
        if (totalDiscount + extraDisc > maxAllowedDisc) {
            const maxExtra = Math.max(0, Math.floor(maxAllowedDisc - totalDiscount));
            // Set the capped integer value directly (field is only-numbers so no decimals)
            document.getElementById("finalDiscount").value = maxExtra;
            Swal.fire({
                icon: 'warning',
                title: 'Extra Discount Exceeded',
                html: `Max allowed discount: <b>${userMaxDiscPer}%</b> of ₹${subtotal.toFixed(2)} = ₹${maxAllowedDisc.toFixed(2)}<br>`+
                      `Item discounts: ₹${totalDiscount.toFixed(2)}<br>`+
                      `Max extra discount allowed: ₹${maxExtra.toFixed(2)}`,
                confirmButtonText: 'OK'
            });
        }
    }

    const discount = parseFloat(document.getElementById("finalDiscount").value) || 0;
    const payable = grandTotal - discount;
    document.getElementById("payableAmount").value = payable.toFixed(3);
    //document.getElementById("paid").value = payable.toFixed(2);
    updatePaymentFields(payable);
}

function updatePaymentFields(payable) {
    const modeSelect   = document.getElementById("mode");
    const paidInput    = document.getElementById("paid");
    const bankPaidInput= document.getElementById("bankPaid");
    const balanceInput = document.getElementById("balance");

    // First: remove any old listeners to avoid duplicates
    paidInput.oninput    = null;
    bankPaidInput.oninput= null;
    balanceInput.oninput = null;

    if (modeSelect.value === "1") {
        // --- Cash ---
        paidInput.disabled     = false;
        bankPaidInput.disabled = true;
        balanceInput.disabled  = true;

        paidInput.value    = payable.toFixed(3);
        bankPaidInput.value= "0";
        balanceInput.value = (payable - parseFloat(paidInput.value || 0)).toFixed(3);

        paidInput.oninput = function () {
            const paidVal = parseFloat(paidInput.value) || 0;
            balanceInput.value = (payable - paidVal).toFixed(3);
        };

    } else if (modeSelect.value === "2") {
        // --- Bank ---
        paidInput.disabled     = true;
        bankPaidInput.disabled = false;
        balanceInput.disabled  = true;

        paidInput.value    = "0";
        bankPaidInput.value= payable.toFixed(3);
        balanceInput.value = (payable - parseFloat(bankPaidInput.value || 0)).toFixed(3);

        // Only update balance from bank changes (never touch paid)
        bankPaidInput.oninput = function () {
            const bankVal = parseFloat(bankPaidInput.value) || 0;
            balanceInput.value = (payable - bankVal).toFixed(3);
        };

        balanceInput.oninput = function () {
            const balVal = parseFloat(balanceInput.value) || 0;
            balanceInput.value = balVal.toFixed(3); // keep what user typed
        };

    } else if (modeSelect.value === "3") {
        // --- Mixed ---
        paidInput.disabled     = false;
        bankPaidInput.disabled = false;
        balanceInput.disabled  = false;

        paidInput.value    = payable.toFixed(3);
        bankPaidInput.value= "0";
        balanceInput.value = "0";

        paidInput.oninput = function () {
            const paidVal = parseFloat(paidInput.value) || 0;
            const balVal  = parseFloat(balanceInput.value) || 0;
            bankPaidInput.value = (payable - paidVal - balVal).toFixed(3);
        };

        bankPaidInput.oninput = function () {
            const bankVal = parseFloat(bankPaidInput.value) || 0;
            const balVal  = parseFloat(balanceInput.value) || 0;
            paidInput.value = (payable - bankVal - balVal).toFixed(3);
        };

        balanceInput.oninput = function () {
            const balVal  = parseFloat(balanceInput.value) || 0;
            const bankVal = parseFloat(bankPaidInput.value) || 0;
            paidInput.value = (payable - bankVal - balVal).toFixed(3);
        };
    }
}

document.getElementById("mode").addEventListener("change", function () {
    const payable = parseFloat(document.getElementById("payableAmount").value) || 0;
    updatePaymentFields(payable);
});

const commissionCheckbox = document.getElementById('isCommission');
if (commissionCheckbox) {
    commissionCheckbox.addEventListener('change', refreshCommissionDisplay);
}

function saveBill() {
    

    console.log("aa");  
    // Get customer name and ID
    let customerName = document.getElementById("customerName").value.trim();
    let customerPhn = document.getElementById("customerPhn").value.trim();
    let customerId = document.getElementById("customerId").value;
    let attenderId = document.getElementById("attenderId") ? document.getElementById("attenderId").value : "";
    
    // Get tax bill checkbox value
    let isTaxBill = document.getElementById("isTaxBill").checked ? 1 : 0;
    
    // Get selected price category (default to retailer since we removed the buttons)
    const priceCategory = 3;

    if (customerName === "") customerName = "-";
    if (customerPhn === "") customerPhn = "-";

    // Get totals
    const finalDiscount = parseFloat(document.getElementById("finalDiscount").value) || 0;    
    const payableAmount = parseFloat(document.getElementById("payableAmount").value) || 0;
    const grandTotal = parseFloat(document.getElementById("grandTotal").value) || 0;
    const priceTotal = parseFloat(document.getElementById("priceTotal").value) || 0;
    const discountTotal = parseFloat(document.getElementById("discountTotal").value) || 0;
    
    // Get payment details
    const mode = document.getElementById("mode").value;
    const type = document.getElementById("type") ? document.getElementById("type").value : "0";
    const cashPaid = parseFloat(document.getElementById("paid").value) || 0;
    const bankPaid = parseFloat(document.getElementById("bankPaid").value) || 0;
    
    const totalPaid = cashPaid + bankPaid;
    const balance = parseFloat(document.getElementById("balance").value) || 0;


    if (totalPaid > payableAmount) {
    alert("Paid amount exceeds payable amount!");
    return;
    }

    if (customerName == "-" && balance > 0) {
        alert("Please enter customer name for balance payment.");
        return;
    }
    
    if(totalPaid + balance != payableAmount){
        alert("Paid and Payable amount mismatch. Please check.");
        return;
    }
    const btn = document.getElementById("saveBillBtn"); // Your button
    btn.disabled = true;
    btn.innerText = "Saving..."; // Optional feedback
    

    if (priceTotal === 0) {
        alert("Empty Bill. Please Prepare Bill And Save.");
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-regular fa-floppy-disk"></i> SAVE BILL';
        return;
    }

    // Collect products
    const rows = document.querySelectorAll("#billBody tr");
    const isEligibleForCommission = document.getElementById('isCommission') ? document.getElementById('isCommission').checked : false;
    let products = [];

    rows.forEach(row => {
        const cols = row.querySelectorAll("td");
        const id = parseInt(cols[1].dataset.id || 0);
        const qty = parseFloat(cols[3].innerText) || 0;
        const price = parseFloat(cols[4].innerText.replace("₹","")) || 0;
        const discount = parseFloat(cols[5].innerText.replace("₹","")) || 0;
        const total = parseFloat(cols[7].innerText.replace("₹","")) || 0;
        const batchId = parseInt(row.dataset.batchId || 0);
        const commission = isEligibleForCommission ? parseFloat(row.dataset.commission || 0) : 0;

        products.push({ id, qty, price, discount, total, batchId, commission });
    });

    console.log("Products JSON:", JSON.stringify(products));

    // Send to server via AJAX
    $.ajax({
        url: contextPath + "/billing/saveBill.jsp",
        type: "POST",
        data: {
            customerName,
            customerId,
            attenderId,
            priceCategory,
            isTaxBill,
            finalDiscount,
            payableAmount,
            grandTotal,
            priceTotal,
            discountTotal,
            customerPhn,
            mode,
            type,
            cashPaid,
            bankPaid,
            totalPaid,
            balance,
            quotationId: currentQuotationId || 0,
            isEligibleForCommission: isEligibleForCommission ? 1 : 0,
            products: JSON.stringify(products),
            exchangePointUsed: parseFloat(document.getElementById('exchangePointUsed').value) || 0
        },
        success: function(response) {
            var cleanResponse = response.trim();
            
            // Check for error response
            if (cleanResponse.startsWith('ERROR:')) {
                Swal.fire({
                    title: 'Error Saving Bill',
                    text: cleanResponse,
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-floppy-o"></i> SAVE BILL';
                return;
            }
            
            document.getElementById("billNoSpan").innerText = "Bill No - " + cleanResponse;

            // Mark that duplicate bill modal needs refresh
            window.duplicateBillNeedsRefresh = true;

            // Show auto-closing toast for bill saved
            showBillSavedToast('Bill Saved! Bill No: ' + cleanResponse);
            
            // Keep button disabled after successful save
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-check"></i> BILL SAVED';
            btn.classList.remove('btn-outline-violet');
            btn.classList.add('btn-success');
            
            // If this was an order, update order status
            if(window.currentOrderId && window.currentOrderTableId) {
                $.post('updateOrderStatus.jsp', {
                    orderId: window.currentOrderId,
                    tableId: window.currentOrderTableId
                }, function(response) {
                    if(response.trim() === 'success') {
                        console.log('Order marked as billed and table freed');
                        window.currentOrderId = null;
                        window.currentOrderTableId = null;
                    }
                });
            }
        },
        error: function(xhr, status, error) {
            console.error("AJAX Error:", status, error);
            console.error("Response:", xhr.responseText);
            
            var errorMsg = 'Failed to save bill.';
            if (xhr.responseText && xhr.responseText.startsWith('ERROR:')) {
                errorMsg = xhr.responseText;
            } else if (xhr.status === 401) {
                errorMsg = 'Session expired. Please login again.';
            } else {
                errorMsg = 'Server Error (Status: ' + xhr.status + '). Check console for details.';
            }
            
            Swal.fire({
                title: 'Error!',
                html: errorMsg,
                icon: 'error',
                confirmButtonText: 'OK'
            });
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-regular fa-floppy-disk"></i> SAVE BILL';
        }
    });
}


document.getElementById("productQty").addEventListener("keydown", function(event) {
    if (event.key === "Enter") {
        event.preventDefault();
        addProduct();
    }
});

document.getElementById("productPrice").addEventListener("keydown", function(event) {
    if (event.key === "Enter") {
        event.preventDefault();
        addProduct();
    }
});

document.getElementById("productDiscount").addEventListener("keydown", function(event) {
    if (event.key === "Enter") {
        event.preventDefault();
        addProduct();
    }
});



document.getElementById("productCode").addEventListener("keydown", function (e) {
    if (e.key === "Tab" || e.key === "Enter") {  // Tab OR Enter
        e.preventDefault();

        const code = this.value.trim();
        if (code === "") return;

        fetchProductDetails(code);
    }
});

function fetchProductDetails(code) {
    // Since we removed price categories and always use MRP, default to retailer (3)
    const priceCategory = 3;
    
    $.ajax({
        url: contextPath + "/billing/details.jsp",
        type: "GET",
        data: { code: code, priceCategory: priceCategory },
        success: function (response) {
            const data = JSON.parse(response);

            $('#productName').val(data.name).prop('disabled', true);
            $('#productPrice').val(data.mrp);
            $('#productDiscount').val(data.discount);

            $('#productCode').data('id', data.id)[0].dataset.id = data.id;
            $('#productCode').data('batchId', data.batchId)[0].dataset.batchId = data.batchId;
            $('#productCode')[0].dataset.commission = data.commission || '0';

            // Set unit information
            $('#productUnitId').val(data.unitId || '');
            $('#productUnitName').val(data.unitName || '');
            $('#productConvertionUnit').val(data.convertionUnit || '');
            
            // Handle unit select box
            handleUnitSelection(data.unitName || '', data.convertionUnit || '');

            // Fetch and store stock
            fetchProductStock(data.id);

            setTimeout(() => {
                const qtyField = document.getElementById("productQty");
                qtyField.focus();
                qtyField.select();
            }, 10);
        },
        error: function () {
            console.error("Error sending data to detail.jsp");
        }
    });
}
let productNameSuggestions = [];

function getProductSuggestionName(item) {
        if (typeof item === 'string') return item;
        return item && (item.label || item.value || item.name || '');
}

$(function () {
        $("#productName").autocomplete({
            source: function (request, response) {
                $.ajax({
                    url: contextPath + "/billing/getProducts.jsp", // backend file returning product list
                    data: { term: request.term },
                    dataType: "json",
                    success: function (data) {
                        productNameSuggestions = Array.isArray(data) ? data : [];
                        response(data); // expects an array like ["Pen","Pencil","Notebook"]
                    }
                });
            },
            minLength: 1,   // start after 1 char
            select: function (event, ui) {
                const selectedName = getProductSuggestionName(ui.item);
                $("#productName").val(selectedName);
                fetchProductDetailsByName(selectedName);
                return false;
            }
        });
    });
document.getElementById("productName").addEventListener("keydown", function (e) {
    if (e.key === "Tab" || e.key === "Enter") {   // when user presses Tab or Enter
        e.preventDefault();

                const firstSuggestionName = productNameSuggestions.length > 0
                        ? getProductSuggestionName(productNameSuggestions[0]).trim()
                        : "";

                const name = firstSuggestionName || this.value.trim();
        if (name === "") return;

                this.value = name;

        fetchProductDetailsByName(name);
    }
});
function fetchProductDetailsByName(name) {
    // Since we removed price categories and always use MRP, default to retailer (3)
    const priceCategory = 3;
    
    $.ajax({
        url: contextPath + "/billing/productDetails.jsp",
        type: "GET",
        dataType: "json",      // important
        data: { productName: name, priceCategory: priceCategory },
        success: function (data) {   // data is already an object
            //alert(JSON.stringify(data));

            $('#productCode').val(data.code);  // Removed .prop('disabled', true)
            $('#productPrice').val(data.mrp);
            $('#productDiscount').val(data.discount);

            $('#productCode').data('id', data.id)[0].dataset.id = data.id;
            $('#productCode').data('batchId', data.batchId)[0].dataset.batchId = data.batchId;
            $('#productCode')[0].dataset.commission = data.commission || '0';

            // Set unit information
            $('#productUnitId').val(data.unitId || '');
            $('#productUnitName').val(data.unitName || '');
            $('#productConvertionUnit').val(data.convertionUnit || '');
            
            // Handle unit select box
            handleUnitSelection(data.unitName || '', data.convertionUnit || '');

            // Fetch and store stock
            fetchProductStock(data.id);

            setTimeout(() => {
                const qtyField = document.getElementById("productQty");
                qtyField.focus();
                qtyField.select();
            }, 10);
        },
        error: function () {
            console.error("Error getting product details by name");
        }
    });
}

// Handle unit selection and conversion
function handleUnitSelection(unitName, convertionUnit) {
    const unitSelect = document.getElementById('productUnit');
    const qtyLabel = document.getElementById('qtyLabel');
    
    // Normalize unit name for comparison
    const normalizedUnit = unitName.trim().toLowerCase();
    
    // Reset unit select
    unitSelect.value = '';
    unitSelect.disabled = true;
    qtyLabel.textContent = ' Qty ';
    
    // Enable unit conversion only for KG
    if (normalizedUnit === 'kg' || normalizedUnit === 'kgs') {
        unitSelect.disabled = true;
        unitSelect.innerHTML = '<option value="kg">KG</option><option value="gram">Gram</option>';
        unitSelect.value = 'kg';
    } else {
        // For other units, show unit name; append conversion unit if available
        const displayLabel = (convertionUnit && convertionUnit.trim())
            ? unitName + ' (' + convertionUnit.trim() + ')'
            : unitName;
        unitSelect.disabled = true;
        unitSelect.innerHTML = '<option value="">' + displayLabel + '</option>';
    }
}

// Unit change event listener
document.getElementById('productUnit').addEventListener('change', function() {
    const qtyLabel = document.getElementById('qtyLabel');
    const selectedUnit = this.value;
    
    if (selectedUnit === 'gram') {
        qtyLabel.textContent = ' Qty (Gram) ';
    } else if (selectedUnit === 'kg') {
        qtyLabel.textContent = ' Qty (KG) ';
    } else {
        qtyLabel.textContent = ' Qty ';
    }
});

// Price category functionality removed - always use MRP now
// document.addEventListener('DOMContentLoaded', function() {
//     const priceCategoryRadios = document.querySelectorAll('input[name="priceCategory"]');
//     priceCategoryRadios.forEach(radio => {
//         radio.addEventListener('change', function() {
//             // Check if a product is already loaded
//             const productCode = document.getElementById('productCode').value.trim();
//             const productName = document.getElementById('productName').value.trim();
            
//             if (productCode !== "") {
//                 // Re-fetch using product code
//                 fetchProductDetails(productCode);
//             } else if (productName !== "") {
//                 // Re-fetch using product name
//                 fetchProductDetailsByName(productName);
//             }
//         });
//     });
// });

function showProductHistory(row) {
    // Get product details from row
    const productId = row.querySelector('td[data-id]').getAttribute('data-id');
    const productName = row.querySelector('td[data-name]').getAttribute('data-name');
    
    // Update modal title
    document.getElementById('historyProductName').textContent = productName;
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('productHistoryModal'));
    modal.show();
    
    // Show loading spinner
    document.getElementById('historyLoadingSpinner').style.display = 'block';
    document.getElementById('historyContent').style.display = 'none';
    
    // Fetch history
    $.ajax({
        url: contextPath + '/billing/getProductHistory.jsp',
        type: 'GET',
        data: { 
            productId: productId
        },
        dataType: 'json',
        success: function(data) {
            document.getElementById('historyLoadingSpinner').style.display = 'none';
            document.getElementById('historyContent').style.display = 'block';
            
            const tbody = document.getElementById('historyTableBody');
            tbody.innerHTML = '';
            
            if (data.error) {
                tbody.innerHTML = '<tr><td colspan="8" class="text-center text-danger">Error: ' + data.error + '</td></tr>';
            } else if (data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8" class="text-center">No previous bills found for this product and customer</td></tr>';
            } else {
                data.forEach(function(bill) {
                    const row = `<tr>
                        <td>${bill.billNo}</td>
                        <td>${bill.date}</td>
                        <td>${bill.time}</td>
                        <td>${bill.customerName}</td>
                        <td>${bill.qty}</td>
                        <td>₹${bill.price.toFixed(3)}</td>
                        <td>₹${bill.discount.toFixed(3)}</td>
                        <td>₹${bill.total.toFixed(3)}</td>
                    </tr>`;
                    tbody.innerHTML += row;
                });
            }
        },
        error: function() {
            document.getElementById('historyLoadingSpinner').style.display = 'none';
            document.getElementById('historyContent').style.display = 'block';
            document.getElementById('historyTableBody').innerHTML = 
                '<tr><td colspan="8" class="text-center text-danger">Error loading product history</td></tr>';
        }
    });
}

function printBill() {
    // Get the current bill number from the span
    const billNoText = document.getElementById("billNoSpan").innerText; // e.g., "Bill No - 25-10"
    const billNo = billNoText.split(" - ")[1] || "";

    if (billNo === "") {
        alert("No Bill Number available to print!");
        return;
    }

    // Check if mobile device with Bluetooth support
    if (typeof isBluetoothPrintAvailable === 'function' && isBluetoothPrintAvailable()) {
        // Mobile device with Web Bluetooth - use Bluetooth printing
        console.log('Using Bluetooth printing for mobile device');
        bluetoothPrint(billNo);
    } else {
        // Desktop or non-Bluetooth device - use server-side printing
        console.log('Using server-side printing');
        directPrint(billNo);
    }
}

/**
 * Print order receipt - supports thermal POS, A4, and Bluetooth printing
 */
function printOrder(orderId) {
    if (!orderId || orderId === "") {
        alert("Invalid order ID!");
        return;
    }

    // Check if mobile device with Bluetooth support
    if (typeof isBluetoothPrintAvailable === 'function' && isBluetoothPrintAvailable()) {
        // Mobile device with Web Bluetooth - use Bluetooth printing
        console.log('Using Bluetooth printing for mobile device (order)');
        bluetoothPrintOrder(orderId);
    } else {
        // Desktop or non-Bluetooth device - use server-side printing
        console.log('Using server-side printing (order)');
        directPrintOrder(orderId);
    }
}

/**
 * Direct thermal print order via server-side ESC/POS
 */
function directPrintOrder(orderId) {
    fetch(`directPrintOrder.jsp?orderId=${encodeURIComponent(orderId)}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            if (data.type === 'a4') {
                // A4 format selected in company settings - open thermalPrintOrder.jsp in popup
                const width = 900;
                const height = 800;
                const left = (screen.width - width) / 2;
                const top = (screen.height - height) / 2;
                window.open(`thermalPrintOrder.jsp?orderId=${encodeURIComponent(orderId)}`, 'orderPrintWindow', 
                    `width=${width},height=${height},left=${left},top=${top},scrollbars=yes,resizable=yes`);
                showPrintToast('Opening order print preview', 'info');
            } else if (data.type === 'printed') {
                // Sent to thermal printer directly
                showPrintToast('Order receipt printed successfully!', 'success');
            } else if (data.type === 'txt') {
                // No printer found - TXT saved to D:\orders\
                showPrintToast('No printer found. Order receipt saved as TXT file', 'info');
            }
        } else {
            if (confirm('Print failed: ' + data.message + '\n\nOpen print preview instead?')) {
                openOrderPrintPreview(orderId);
            }
        }
    })
    .catch(error => {
        console.error('Order print error:', error);
        if (confirm('Could not reach print server.\n\nOpen print preview instead?')) {
            openOrderPrintPreview(orderId);
        }
    });
}

/**
 * Open browser-based order print preview
 */
function openOrderPrintPreview(orderId) {
    const width = 400;
    const height = 600;
    const left = (screen.width - width) / 2;
    const top = (screen.height - height) / 2;
    window.open(`thermalPrintOrder.jsp?orderId=${encodeURIComponent(orderId)}`, 'OrderPrintWindow', 
        `width=${width},height=${height},left=${left},top=${top},scrollbars=yes,resizable=yes`);
}

/**
 * Direct thermal print via server-side ESC/POS.
 * Sends raw commands to the thermal printer - no browser print dialog, no empty page.
 * Falls back to browser preview if direct print fails.
 */
function directPrint(billNo) {
    fetch(`directPrint.jsp?billNo=${encodeURIComponent(billNo)}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            if (data.type === 'a4') {
                // A4 format selected in company settings - open print.jsp in popup
                const width = 900;
                const height = 800;
                const left = (screen.width - width) / 2;
                const top = (screen.height - height) / 2;
                window.open(`print.jsp?billNo=${encodeURIComponent(data.billNo)}`, 'printWindow', 
                    `width=${width},height=${height},left=${left},top=${top},scrollbars=yes,resizable=yes`);
                showPrintToast('Opening A4 print preview', 'info');
            } else if (data.type === 'printed') {
                // Sent to thermal printer directly
                showPrintToast('Receipt printed successfully!', 'success');
            } else if (data.type === 'txt') {
                // No printer found - TXT saved to D:\bills\
                showPrintToast('No printer found. Receipt saved as TXT file', 'info');
                // Open file location in file explorer
                alert('Receipt saved to: ' + data.txtPath + '\n\nFile: ' + data.txtFile + '\n\nYou can open this file with Notepad to see how the receipt looks.');
            }
        } else {
            if (confirm('Print failed: ' + data.message + '\n\nOpen print preview instead?')) {
                openPrintPreview(billNo);
            }
        }
    })
    .catch(error => {
        console.error('Direct print error:', error);
        if (confirm('Could not reach print server.\n\nOpen print preview instead?')) {
            openPrintPreview(billNo);
        }
    });
}

/**
 * Open browser-based print preview (fallback)
 */
function openPrintPreview(billNo) {
    window.open(`thermalPrint.jsp?billNo=${encodeURIComponent(billNo)}`, 'ThermalPrintWindow', 'width=400,height=600');
}

/**
 * Show a brief toast notification for print status
 */
function showPrintToast(message, type) {
    // Create toast element
    let toast = document.createElement('div');
    toast.style.cssText = 'position:fixed;top:20px;right:20px;z-index:99999;padding:12px 24px;border-radius:8px;color:#fff;font-size:14px;font-weight:500;box-shadow:0 4px 12px rgba(0,0,0,0.3);transition:opacity 0.5s;';
    toast.style.backgroundColor = type === 'success' ? '#28a745' : type === 'info' ? '#0d6efd' : '#dc3545';
    toast.innerHTML = '<i class="fa-solid ' + (type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle') + '"></i> ' + message;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 500);
    }, 2500);
}

function showBillSavedToast(message) {
    let toast = document.createElement('div');
    toast.style.cssText = 'position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);z-index:99999;padding:18px 36px;border-radius:12px;color:#fff;font-size:18px;font-weight:700;box-shadow:0 6px 24px rgba(0,0,0,0.35);background:#28a745;text-align:center;transition:opacity 0.4s;';
    toast.innerHTML = '<i class="fa-solid fa-check-circle"></i> ' + message;
    document.body.appendChild(toast);
    setTimeout(() => {
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 400);
    }, 2000);
}

/**
 * Preview bill in browser (for viewing or manual browser print)
 */
function previewBill() {
    const billNoText = document.getElementById("billNoSpan").innerText;
    const billNo = billNoText.split(" - ")[1] || "";
    if (billNo === "") {
        alert("No Bill Number available to preview!");
        return;
    }
    openPrintPreview(billNo);
}

function printQuotation() {
    // Get customer details
    const customerName = document.getElementById("customerName").value.trim() || "-";
    const customerPhone = document.getElementById("customerPhn").value.trim() || "-";
    const extraDisc = document.getElementById("finalDiscount").value || "0";
    
    // Collect all items from the bill table
    const billBody = document.getElementById("billBody");
    const rows = billBody.querySelectorAll("tr:not(.empty-row)");
    
    if (rows.length === 0) {
        alert("No items selected! Please add items to print quotation.");
        return;
    }
    
    const items = [];
    rows.forEach((row, index) => {
        const cells = row.querySelectorAll("td");
        if (cells.length >= 8) {
            // Extract data from table cells
            const code = cells[1].textContent.trim();
            const productId = cells[1].getAttribute('data-id') || '0';
            const name = cells[2].textContent.trim();
            const qty = parseInt(cells[3].textContent.trim()) || 0;
            const priceText = cells[4].textContent.replace('₹', '').trim();
            const price = parseFloat(priceText) || 0;
            const discountText = cells[5].textContent.replace('₹', '').trim();
            const discount = parseFloat(discountText) || 0;
            const totalText = cells[7].textContent.replace('₹', '').trim();
            const total = parseFloat(totalText) || 0;
            
            items.push({
                code: code,
                name: name,
                qty: qty,
                price: price,
                discount: discount,
                total: total,
                productId: productId
            });
        }
    });
    
    // Create form to submit data
    const form = document.createElement("form");
    form.method = "POST";
    form.action = "quotation.jsp";
    form.target = "QuotationWindow";
    
    // Add customer name
    const custNameInput = document.createElement("input");
    custNameInput.type = "hidden";
    custNameInput.name = "customerName";
    custNameInput.value = customerName;
    form.appendChild(custNameInput);
    
    // Add customer phone
    const custPhoneInput = document.createElement("input");
    custPhoneInput.type = "hidden";
    custPhoneInput.name = "customerPhone";
    custPhoneInput.value = customerPhone;
    form.appendChild(custPhoneInput);
    
    // Add extra discount
    const extraDiscInput = document.createElement("input");
    extraDiscInput.type = "hidden";
    extraDiscInput.name = "extraDisc";
    extraDiscInput.value = extraDisc;
    form.appendChild(extraDiscInput);
    
    // Add items as JSON
    const itemsInput = document.createElement("input");
    itemsInput.type = "hidden";
    itemsInput.name = "items";
    itemsInput.value = JSON.stringify(items);
    form.appendChild(itemsInput);
    
    // Submit form
    document.body.appendChild(form);
    window.open("", "QuotationWindow", "width=800,height=600");
    form.submit();
    document.body.removeChild(form);
}
////////////////////////////////////////////////////////////
    const modeSelect = document.getElementById("mode");
    const typeSelect = document.getElementById("type");
    function toggleType() {
        if (modeSelect.value === "1") { 
            // Cash
            typeSelect.disabled = true;
            typeSelect.value = ""; 
        } else if (modeSelect.value === "2") { 
            // Bank
            typeSelect.disabled = false;
            typeSelect.value = "1"; // Auto-select UPI
        }
        else if (modeSelect.value === "3") { 
            // Mixed
            typeSelect.disabled = false;
            typeSelect.value = "1"; // Auto-select UPI
        } else { 
            // Mixed
            typeSelect.disabled = false;
            typeSelect.value = ""; // Let user choose
        }
    }

    // Run on page load
    toggleType();

    // Run on change
    modeSelect.addEventListener("change", toggleType);
/////////////////////////////////////////////

// Available Cheques Functionality
let userHasCreditPermission = false;
let userHasStockPermission = false;

// Check user's credit permission on page load
(function checkCreditPermission() {
    fetch('checkCreditPermission.jsp')
        .then(response => response.json())
        .then(data => {
            userHasCreditPermission = data.hasPermission || false;
        })
        .catch(error => {
            console.error("Error checking credit permission:", error);
            userHasCreditPermission = false;
        });
})();

// Check user's stock permission on page load
(function checkStockPermission() {
    fetch('checkStockPermission.jsp')
        .then(response => response.json())
        .then(data => {
            userHasStockPermission = data.hasPermission || false;
        })
        .catch(error => {
            console.error("Error checking stock permission:", error);
            userHasStockPermission = false;
        });
})();

function showAvailableCheques() {
    const customerId = document.getElementById("customerId").value;
    const customerName = document.getElementById("customerName").value;
    
    if (!customerId || customerId === "0" || !customerName) {
        Swal.fire({
            icon: 'warning',
            title: 'No Customer Selected',
            text: 'Please select a customer first to view available cheques.',
            confirmButtonText: 'OK'
        });
        return;
    }
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('availableChequesModal'));
    document.getElementById('chequeCustomerName').textContent = customerName;
    document.getElementById('chequeLoadingSpinner').style.display = 'block';
    document.getElementById('chequeContent').style.display = 'none';
    modal.show();
    
    // Fetch available cheques
    fetch(`getAvailableCheques.jsp?customerId=${customerId}`)
        .then(response => response.json())
        .then(cheques => {
            displayAvailableCheques(cheques);
            document.getElementById('chequeLoadingSpinner').style.display = 'none';
            document.getElementById('chequeContent').style.display = 'block';
        })
        .catch(error => {
            console.error("Error fetching cheques:", error);
            document.getElementById('chequeLoadingSpinner').style.display = 'none';
            document.getElementById('chequeContent').style.display = 'block';
            Swal.fire({
                icon: 'error',
                title: 'Error',
                text: 'Failed to load available cheques.',
                confirmButtonText: 'OK'
            });
        });
}

function displayAvailableCheques(cheques) {
    const tbody = document.getElementById('chequeTableBody');
    
    if (cheques.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted">No cheques available</td></tr>';
        return;
    }
    
    let html = '';
    cheques.forEach((cheque, index) => {
        html += `
            <tr>
                <td>${index + 1}</td>
                <td><strong>${cheque.chequeNumber}</strong></td>
                <td>${cheque.chequeDate}</td>
                <td>${cheque.bankName || '-'}</td>
                
                <td><span class="badge bg-warning">${cheque.status}</span></td>
            </tr>
        `;
    });
    
    tbody.innerHTML = html;
}

// LR Details Functions removed - no longer needed

// ==================== CAFE ORDER FUNCTIONS ====================
window.currentOrderId = null;
window.currentOrderTableId = null;

function showOrderList() {
    const modal = new bootstrap.Modal(document.getElementById('orderListModal'));
    modal.show();
    
    // Show spinner
    document.getElementById('orderListSpinner').style.display = 'block';
    document.getElementById('orderListContent').style.display = 'none';
    
    // Load orders
    $.ajax({
        url: contextPath + '/billing/getOrders.jsp',
        dataType: 'json',
        success: function(data) {
            document.getElementById('orderListSpinner').style.display = 'none';
            document.getElementById('orderListContent').style.display = 'block';
            
            const tbody = document.getElementById('orderListTableBody');
            const cardsBody = document.getElementById('orderListCardsBody');
            tbody.innerHTML = '';
            cardsBody.innerHTML = '';
            
            if(!data || data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center">No pending orders found</td></tr>';
                cardsBody.innerHTML = '<div class="alert alert-info text-center">No pending orders found</div>';
                return;
            }
            
            if(data[0] && data[0].error) {
                const errorMsg = '<td colspan="6" class="text-center text-danger">Error: ' + data[0].error + '</td>';
                tbody.innerHTML = '<tr>' + errorMsg + '</tr>';
                cardsBody.innerHTML = '<div class="alert alert-danger text-center">Error: ' + data[0].error + '</div>';
                return;
            }
            
            data.forEach(order => {
                const statusBadge = order.is_delivered == 1 
                    ? '<span class="badge bg-success">Delivered</span>'
                    : '<span class="badge bg-warning">Pending</span>';
                
                // Desktop table row
                const row = `
                    <tr>
                        <td>${order.order_no}</td>
                        <td>${order.table_name}</td>
                        <td>${order.date}</td>
                        <td>${order.time}</td>
                        <td>${statusBadge}</td>
                        <td>
                            <button class="btn btn-sm btn-success me-1" onclick="printOrder(${order.id}, '${order.order_no}')" title="Print Order">
                                <i class="fas fa-print"></i>
                            </button>
                            <button class="btn btn-sm btn-primary" onclick="selectOrderFromModal(${order.id})">
                                <i class="fas fa-file-invoice"></i> Bill This
                            </button>
                        </td>
                    </tr>
                `;
                tbody.innerHTML += row;
                
                // Mobile card
                const card = `
                    <div class="card mb-2 shadow-sm">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <div>
                                    <h6 class="mb-1 fw-bold text-success">
                                        <i class="fas fa-receipt"></i> ${order.order_no}
                                    </h6>
                                    <div class="small text-muted">
                                        <i class="fas fa-utensils"></i> ${order.table_name}
                                    </div>
                                </div>
                                <div class="text-end">
                                    ${statusBadge}
                                </div>
                            </div>
                            <div class="row small mb-2">
                                <div class="col-6">
                                    <i class="fas fa-calendar"></i> ${order.date}
                                </div>
                                <div class="col-6 text-end">
                                    <i class="fas fa-clock"></i> ${order.time}
                                </div>
                            </div>
                            <div class="d-grid gap-2">
                                <button class="btn btn-sm btn-success" onclick="printOrder(${order.id}, '${order.order_no}')">
                                    <i class="fas fa-print"></i> Print Order
                                </button>
                                <button class="btn btn-sm btn-primary" onclick="selectOrderFromModal(${order.id})">
                                    <i class="fas fa-file-invoice"></i> Bill This Order
                                </button>
                            </div>
                        </div>
                    </div>
                `;
                cardsBody.innerHTML += card;
            });
        },
        error: function(xhr, status, error) {
            document.getElementById('orderListSpinner').style.display = 'none';
            document.getElementById('orderListContent').style.display = 'block';
            const errorMsg = 'Error: ' + error + '<br>Status: ' + xhr.status;
            document.getElementById('orderListTableBody').innerHTML = 
                '<tr><td colspan="6" class="text-center text-danger">' + errorMsg + '</td></tr>';
            document.getElementById('orderListCardsBody').innerHTML = 
                '<div class="alert alert-danger text-center">' + errorMsg + '</div>';
        }
    });
}

function selectOrderFromModal(orderId) {
    // Close modal
    const modal = bootstrap.Modal.getInstance(document.getElementById('orderListModal'));
    modal.hide();
    
    // Load order to bill
    loadOrderToBill(orderId);
}

function loadOrderToBill(orderId) {
    $.ajax({
        url: contextPath + '/billing/getOrderDetails.jsp',
        data: { orderId: orderId },
        dataType: 'json',
        success: function(data) {
            if(data.error) {
                alert('Error loading order: ' + data.error);
                return;
            }
            
            // Store order info
            window.currentOrderId = data.orderId;
            window.currentOrderTableId = data.tableId;
            
            // Clear existing bill
            clearBill();
            
            // Add order items to bill
            data.items.forEach(function(item) {
                addOrderItemToBill(item);
            });
            
            // Show order info
            Swal.fire({
                title: 'Order Loaded',
                html: 'Order: ' + data.orderNo + '<br>Table: ' + data.tableName,
                icon: 'success',
                confirmButtonText: 'OK'
            });
        },
        error: function() {
            alert('Error loading order details');
        }
    });
}

function addOrderItemToBill(item) {
    count++;
    
    // Use batch ID from order data, default to 0 if not available
    const batchId = item.batchId || 0;
    
    const row = `
        <tr id="row${count}" class="item-row" style="display: table; width: 100%; table-layout: fixed;" data-batch-id="${batchId}" data-commission="0">
            <td style="width: 5%;">${count}</td>
            <td style="width: 10%;" data-id="${item.prodId}">${item.code || ''}</td>
            <td style="width: 22%;">${item.prodName}</td>
            <td style="width: 8%;">${item.qty}</td>
            <td style="width: 10%;">₹${item.price.toFixed(3)}</td>
            <td style="width: 10%;">₹0.000</td>
            <td style="width: 10%;">₹0.000</td>
            <td style="width: 10%;">₹${item.total.toFixed(3)}</td>
            <td style="width: 15%;">
                <button class="btn btn-danger btn-sm" onclick="removeProduct(${count}, ${item.total}, 0, 0, ${item.total})">
                    <i class="fas fa-trash"></i>
                </button>
            </td>
        </tr>
    `;
    
    // Add new item
    const billBody = document.getElementById("billBody");
    billBody.insertAdjacentHTML('beforeend', row);

    const addedRow = document.getElementById(`row${count}`);
    addedRow.dataset.productId = item.prodId;
    addedRow.dataset.quantity = item.qty;
    
    // Track product quantity
    if (!productQuantitiesInBill[item.prodId]) {
        productQuantitiesInBill[item.prodId] = 0;
    }
    productQuantitiesInBill[item.prodId] += item.qty;
    
    // Update totals
    subtotal += item.total;
    grandTotal += item.total;
    prodTotal += item.total;
    
    updateTotals();
    updatePayableAmount();
}

function clearBill() {
    count = 0;
    grandTotal = 0;
    subtotal = 0;
    totalDiscount = 0;
    totalCommission = 0;
    prodTotal = 0;
    productQuantitiesInBill = {};
    currentQuotationId = null;
    
    const billBody = document.getElementById("billBody");
    // Remove all rows first
    billBody.innerHTML = '';
    
    // Don't add empty rows when loading order - they'll be added as items come in
    
    // Reset quotation button visibility
    document.getElementById('quotationBtnDiv').style.display = 'block';
    document.getElementById('quotationPrintBtnDiv').style.display = 'none';
    
    updateTotals();
    updatePayableAmount();
}

function newBill() {
    // Reload page for a clean slate and focus productCode
    location.reload();
    return;

    // Clear bill data (legacy - kept for reference)
    clearBill();
    
    // Reset quotation ID
    currentQuotationId = null;
    
    // Reset customer fields
    document.getElementById('customerName').value = '';
    document.getElementById('customerPhn').value = '';
    document.getElementById('customerId').value = '0';
    document.getElementById('customerCreditLimit').value = '0';
    
    // Reset tax bill checkbox to ON (default)
    document.getElementById('isTaxBill').checked = true;
    
    // Reset product fields
    document.getElementById('productCode').value = '';
    document.getElementById('productName').value = '';
    document.getElementById('productUnit').value = '';
    document.getElementById('productUnitId').value = '';
    document.getElementById('productUnitName').value = '';
    document.getElementById('productQty').value = '1';
    document.getElementById('productPrice').value = '';
    document.getElementById('productDiscount').value = '0';
    
    // Reset payment fields
    document.getElementById('priceTotal').value = '0';
    document.getElementById('discountTotal').value = '0';
    document.getElementById('commissionTotal').value = '0';
    document.getElementById('grandTotal').value = '0';
    document.getElementById('finalDiscount').value = '0';
    document.getElementById('payableAmount').value = '0';
    document.getElementById('mode').value = '1';
    document.getElementById('type').value = '1';
    document.getElementById('paid').value = '0';
    document.getElementById('bankPaid').value = '0';
    document.getElementById('balance').value = '0';
    
    // Reset bill number display
    document.getElementById('billNoSpan').textContent = '';
    
    // Reset save bill button state
    const saveBtn = document.getElementById('saveBillBtn');
    if (saveBtn) {
        saveBtn.disabled = false;
        saveBtn.innerHTML = '<i class="fa-regular fa-floppy-disk"></i> SAVE BILL';
        saveBtn.classList.remove('btn-success');
        saveBtn.classList.add('btn-outline-violet');
    }
    
    // Reset quotation button visibility
    document.getElementById('quotationBtnDiv').style.display = 'block';
    document.getElementById('quotationPrintBtnDiv').style.display = 'none';
    
    // Clear order tracking
    if (window.currentOrderId) window.currentOrderId = null;
    if (window.currentOrderTableId) window.currentOrderTableId = null;
    
    // Reset modal refresh flags
    window.quotationListNeedsRefresh = false;
    window.duplicateBillNeedsRefresh = false;
    
    // Add empty rows back to table
    const billBody = document.getElementById('billBody');
    const emptyRowHTML = '<tr class="empty-row" style="display: table; width: 100%; table-layout: fixed;"><td style="width: 5%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 22%;">&nbsp;</td><td style="width: 8%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 10%;">&nbsp;</td><td style="width: 15%;">&nbsp;</td></tr>';
    billBody.innerHTML = emptyRowHTML.repeat(5);
    
    // Reset stock tracking
    currentProductStock = 0;
    
    // Focus on code field
    setTimeout(() => {
        document.getElementById('productCode').focus();
    }, 100);
}

// ==================== QUOTATION FUNCTIONS ====================

function saveQuotation() {
    // Check if there are items in the bill
    const billBody = document.getElementById('billBody');
    const rows = billBody.querySelectorAll('tr:not(.empty-row)');
    
    console.log('Bill body:', billBody);
    console.log('Total rows:', billBody.querySelectorAll('tr').length);
    console.log('Non-empty rows:', rows.length);
    
    if (rows.length === 0) {
        Swal.fire({
            title: 'No Products',
            text: 'Please add at least one product to save quotation',
            icon: 'warning',
            confirmButtonText: 'OK'
        });
        return;
    }
    
    // Collect products data
    const products = [];
    rows.forEach(row => {
        const productId = parseInt(row.dataset.productId);
        const qtyText = row.querySelector('td:nth-child(4)').textContent.trim();
        const qty = parseFloat(qtyText.split(' ')[0]); // Remove unit suffix
        const priceText = row.querySelector('td:nth-child(5)').textContent.replace('₹', '').trim();
        const price = parseFloat(priceText);
        const discountText = row.querySelector('td:nth-child(6)').textContent.replace('₹', '').trim();
        const discount = parseFloat(discountText);
        const totalText = row.querySelector('td:nth-child(8)').textContent.replace('₹', '').trim();
        const total = parseFloat(totalText);
        
        products.push({
            productId: productId,
            qty: qty,
            price: price,
            discount: discount,
            total: total
        });
    });
    
    // Debug: log collected products
    console.log('Collected products:', products);
    console.log('Products JSON:', JSON.stringify(products));
    
    if (products.length === 0) {
        Swal.fire({
            title: 'Invalid Products',
            text: 'No valid products found in the bill',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        return;
    }
    
    // Get customer and payment details
    const customerName = document.getElementById('customerName').value || 'Walk-in Customer';
    const customerPhn = document.getElementById('customerPhn').value || '';
    const customerId = document.getElementById('customerId').value || '0';
    const finalDiscount = parseFloat(document.getElementById('finalDiscount').value) || 0;
    const payableAmount = parseFloat(document.getElementById('payableAmount').value) || 0;
    const grandTotal = parseFloat(document.getElementById('grandTotal').value) || 0;
    const priceTotal = parseFloat(document.getElementById('priceTotal').value) || 0;
    const discountTotal = parseFloat(document.getElementById('discountTotal').value) || 0;
    
    console.log('Sending data to server...');
    
    // Send AJAX request using jQuery (same as saveBill)
    $.ajax({
        url: 'saveQuotation.jsp',
        type: 'POST',
        data: {
            customerName: customerName,
            customerPhn: customerPhn,
            customerId: customerId,
            finalDiscount: finalDiscount,
            payableAmount: payableAmount,
            grandTotal: grandTotal,
            priceTotal: priceTotal,
            discountTotal: discountTotal,
            products: JSON.stringify(products)
        },
        success: function(data) {
            console.log('Server response:', data);
            
            var cleanResponse = data.trim();
            
            if (cleanResponse.startsWith('SUCCESS')) {
                const parts = cleanResponse.split('|');
                const quotNo = parts[1];
                const quotId = parts[2];
                
                // Store quotation ID
                currentQuotationId = quotId;
                
                // Mark that quotation list needs refresh
                window.quotationListNeedsRefresh = true;
                
                // Show success message with SweetAlert
                Swal.fire({
                    title: 'Quotation Saved!',
                    text: 'Quotation No: ' + quotNo,
                    icon: 'success',
                    confirmButtonText: 'OK'
                });
                
                // Hide QUOTATION button and show PRINT QUOTATION button
                document.getElementById('quotationBtnDiv').style.display = 'none';
                document.getElementById('quotationPrintBtnDiv').style.display = 'block';
            } else {
                Swal.fire({
                    title: 'Error Saving Quotation',
                    text: cleanResponse,
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX Error:', status, error);
            console.error('Response:', xhr.responseText);
            
            Swal.fire({
                title: 'Error',
                text: 'Failed to save quotation. Please check console for details.',
                icon: 'error',
                confirmButtonText: 'OK'
            });
        }
    });
}

function printSavedQuotation() {
    if (!currentQuotationId) {
        Swal.fire({
            title: 'No Quotation',
            text: 'Please save a quotation first',
            icon: 'warning',
            confirmButtonText: 'OK'
        });
        return;
    }
    
    // Open print page in new window
    const printWindow = window.open('quotationPrint.jsp?quotId=' + currentQuotationId, '_blank');
    if (printWindow) {
        printWindow.focus();
    }
}

function clearBillTable() {
    // Clear bill body
    const billBody = document.getElementById('billBody');
    billBody.innerHTML = '';
    
    // Reset counters
    count = 0;
    grandTotal = 0;
    subtotal = 0;
    totalDiscount = 0;
    totalCommission = 0;
    prodTotal = 0;
    productQuantitiesInBill = {};
    
    // Update totals
    updateTotals();
    updatePayableAmount();
}

function addProductToBillTable(product) {
    // Remove empty placeholder rows on first product add
    if (count === 0) {
        const emptyRows = document.querySelectorAll('#billBody .empty-row');
        emptyRows.forEach(row => row.remove());
    }
    
    // Increment count
    count++;
    
    // Calculate values
    const productSubtotal = parseFloat(product.price) * parseFloat(product.qty);
    const productDiscount = parseFloat(product.discount);
    const productTotal = parseFloat(product.total);
    const productCommissionPerUnit = parseFloat(product.commission || 0);
    const productCommissionAmount = (document.getElementById('isCommission') && document.getElementById('isCommission').checked)
        ? (productCommissionPerUnit * parseFloat(product.qty))
        : 0;
    
    // Create new row with proper styling and structure
    const row = `
        <tr id="row${count}" class="bill-item-row" style="display: table; width: 100%; table-layout: fixed; cursor: pointer;" data-batch-id="${product.batchId || 0}" data-commission="${productCommissionPerUnit}">
            <td style="width: 5%;">${count}</td>
            <td style="width: 10%;" data-id="${product.productId}">${product.code}</td>
            <td style="width: 22%;" data-name="${product.productName}">${product.productName}</td>
            <td style="width: 8%;">${product.qty}</td>
            <td style="width: 10%;">₹${parseFloat(product.price).toFixed(3)}</td>
            <td style="width: 10%;">₹${productDiscount.toFixed(3)}</td>
            <td style="width: 10%;">₹${productCommissionAmount.toFixed(3)}</td>
            <td style="width: 10%;">₹${productTotal.toFixed(3)}</td>
            <td style="width: 15%;">
                <button class="btn btn-danger btn-sm" 
                    onclick="event.stopPropagation(); removeProduct(${count}, ${productSubtotal}, ${productDiscount}, ${productCommissionAmount}, ${productTotal})">
                    Delete
                </button>
            </td>
        </tr>`;
    
    document.getElementById('billBody').insertAdjacentHTML('beforeend', row);
    
    // Update quantities tracking
    if (!productQuantitiesInBill[product.productId]) {
        productQuantitiesInBill[product.productId] = 0;
    }
    productQuantitiesInBill[product.productId] += parseFloat(product.qty);
    
    // Store quantity in row data attribute for removal tracking
    const addedRow = document.getElementById(`row${count}`);
    addedRow.dataset.productId = product.productId;
    addedRow.dataset.quantity = product.qty;
    addedRow.dataset.commissionAmount = productCommissionAmount;
    
    // Add click event to show product history
    addedRow.addEventListener('click', function(e) {
        // Don't trigger if clicking on delete button
        if (e.target.tagName === 'BUTTON' || e.target.closest('button')) {
            return;
        }
        showProductHistory(this);
    });
    
    // Update totals
    subtotal += productSubtotal;
    totalDiscount += productDiscount;
    totalCommission += productCommissionAmount;
    grandTotal += productTotal;
    prodTotal += productSubtotal;
    
    updateTotals();
    updatePayableAmount();
}
