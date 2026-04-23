<%@ page import="org.json.*, java.io.*, java.util.*, java.math.BigDecimal, billing.ProductItem, user.userBean" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<jsp:useBean id="chequeBean" class="cheque.chequeBean" />
<jsp:useBean id="userBeanObj" class="user.userBean" />

<%
try {
    request.setCharacterEncoding("UTF-8");
    Integer uid = (Integer) session.getAttribute("userId");
    
    // Check if user is logged in
    if (uid == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print("ERROR: Session expired. Please login again.");
        return;
    }
    
    // Check if user has stock permission (content_id=1) for forcing stock update
    boolean userHasStockPermission = userBeanObj.checkUserSpecialPermission(uid, 1);

    String customerName = request.getParameter("customerName");
    String customerPhn = request.getParameter("customerPhn");
    int customerId = 0;
    
    // Get customerId from request
    String customerIdStr = request.getParameter("customerId");
    if (customerIdStr != null && !customerIdStr.trim().isEmpty()) {
        customerId = Integer.parseInt(customerIdStr);
    }

    // Get commission eligibility for new customer creation
    int isEligibleForCommission = 0;
    String isEligibleCommStr = request.getParameter("isEligibleForCommission");
    if (isEligibleCommStr != null && !isEligibleCommStr.trim().isEmpty()) {
        isEligibleForCommission = Integer.parseInt(isEligibleCommStr);
    }
    
    // If customer name is provided and not "-", handle customer logic
    if (customerName != null && !customerName.equals("-") && !customerName.trim().isEmpty()) {
        if (customerId == 0) {
            // Customer name typed but not selected from autocomplete
            // Check if customer exists
            int existingCustomerId = prod.checkTheCustomerNameExist(customerName);
            if (existingCustomerId != 0) {
                customerId = existingCustomerId;
            } else {
                // Insert new customer
                prod.AddCustomer(customerName, "", customerPhn, "", 0, isEligibleForCommission);
                customerId = prod.checkTheCustomerNameExist(customerName);
            }
        }
    }
    
    // Get price category
    int priceCategory = 3; // Default to Retailer
    String priceCategoryStr = request.getParameter("priceCategory");
    if (priceCategoryStr != null && !priceCategoryStr.trim().isEmpty()) {
        priceCategory = Integer.parseInt(priceCategoryStr);
    }
    
    // Get attender ID
    int attenderId = 0;
    String attenderIdStr = request.getParameter("attenderId");
    if (attenderIdStr != null && !attenderIdStr.trim().isEmpty()) {
        attenderId = Integer.parseInt(attenderIdStr);
    }
    
    // Get tax bill flag
    int isTaxBill = 1; // Default to tax bill (ON)
    String isTaxBillStr = request.getParameter("isTaxBill");
    if (isTaxBillStr != null && !isTaxBillStr.trim().isEmpty()) {
        isTaxBill = Integer.parseInt(isTaxBillStr);
    }
    
    // Parse numeric parameters with null-safety
    double finalDiscount = 0.0;
    double payableAmount = 0.0;
    double grandTotal = 0.0;
    double priceTotal = 0.0;
    double discountTotal = 0.0;
    
    // Get quotation ID if converting from quotation
    int quotationId = 0;
    String quotationIdStr = request.getParameter("quotationId");
    if (quotationIdStr != null && !quotationIdStr.trim().isEmpty()) {
        quotationId = Integer.parseInt(quotationIdStr);
    }
    
    String finalDiscountStr = request.getParameter("finalDiscount");
    String payableAmountStr = request.getParameter("payableAmount");
    String grandTotalStr = request.getParameter("grandTotal");
    String priceTotalStr = request.getParameter("priceTotal");
    String discountTotalStr = request.getParameter("discountTotal");
    
    if (finalDiscountStr != null && !finalDiscountStr.trim().isEmpty()) {
        finalDiscount = Double.parseDouble(finalDiscountStr);
    }
    if (payableAmountStr != null && !payableAmountStr.trim().isEmpty()) {
        payableAmount = Double.parseDouble(payableAmountStr);
    }
    if (grandTotalStr != null && !grandTotalStr.trim().isEmpty()) {
        grandTotal = Double.parseDouble(grandTotalStr);
    }
    if (priceTotalStr != null && !priceTotalStr.trim().isEmpty()) {
        priceTotal = Double.parseDouble(priceTotalStr);
    }
    if (discountTotalStr != null && !discountTotalStr.trim().isEmpty()) {
        discountTotal = Double.parseDouble(discountTotalStr);
    }
    
    double cashPaid = 0.0;
    double bankPaid = 0.0;
    int mode = 0;
    int type = 0;
    double balance = 0.0;

    try {
        String cashStr = request.getParameter("cashPaid");
        String bankStr = request.getParameter("bankPaid");
        String modeStr = request.getParameter("mode");
        String typeStr = request.getParameter("type");
        String balanceStr = request.getParameter("balance");

        if (cashStr != null && !cashStr.trim().isEmpty()) {
            cashPaid = Double.parseDouble(cashStr);
        }
        if (bankStr != null && !bankStr.trim().isEmpty()) {
            bankPaid = Double.parseDouble(bankStr);
        }
        if (modeStr != null && !modeStr.trim().isEmpty()) {
            mode = Integer.parseInt(modeStr);
        }
        if (typeStr != null && !typeStr.trim().isEmpty()) {
            type = Integer.parseInt(typeStr);
        }
        if (balanceStr != null && !balanceStr.trim().isEmpty()) {
            balance = Double.parseDouble(balanceStr);
        }

    } catch (NumberFormatException e) {
        e.printStackTrace(); // log error
    }

    double totalPaid = cashPaid + bankPaid;


    String productsJson = request.getParameter("products");
    JSONArray products = new JSONArray(productsJson);

    
    List<ProductItem> productList = new ArrayList<ProductItem>();

    for (int i = 0; i < products.length(); i++) {
        JSONObject p = products.getJSONObject(i);

        int productId = p.getInt("id");
        BigDecimal qty = BigDecimal.valueOf(p.getDouble("qty"));
        double price = p.getDouble("price");
        double discount = p.getDouble("discount");
        double total = p.getDouble("total");
        int batchId = p.getInt("batchId");
        double commission = p.has("commission") ? p.getDouble("commission") : 0.0;
        
        // Get product GST, but set to 0 if not a tax bill
        int gst = isTaxBill == 1 ? bill.getProductGST(productId) : 0;
        
        double cost = bill.getProductCost(productId, batchId);
        productList.add(new ProductItem(productId, qty, price, discount, total, gst, cost, commission));
    }

    String billDisplay = bill.saveBillItems(productList, customerName, finalDiscount, payableAmount, grandTotal, uid, priceTotal, discountTotal,customerPhn,totalPaid,cashPaid,bankPaid,mode,type,balance,customerId,priceCategory,attenderId,isTaxBill);
    int billId = bill.getBillId(billDisplay);
    
    // Auto-allocate cheques for credit bills
    if (balance > 0 && customerId > 0) {
        try {
            chequeBean.checkAndAutoClearCheques();
            chequeBean.allocatePendingChequesToBill(customerId, billId, balance);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    for (int i = 0; i < products.length(); i++) {
        JSONObject p = products.getJSONObject(i);
        int productId = p.getInt("id");
        BigDecimal qty = BigDecimal.valueOf(p.getDouble("qty"));
        int batchId = p.getInt("batchId");
        bill.updateStock(productId, qty, uid, batchId, billId, userHasStockPermission);
        
        // Check for components and reduce their stock
        try {
            Vector components = prod.getProductComponents(productId);
            if (components != null && components.size() > 0) {
                // Get main product name for notes
                String productName = prod.getProductNameById(productId);
                
                for (int j = 0; j < components.size(); j++) {
                    Vector comp = (Vector) components.get(j);
                    int componentProductId = (Integer) comp.elementAt(4);  // component product_id
                    double componentQty = (Double) comp.elementAt(3);      // quantity per unit
                    BigDecimal totalComponentQty = qty.multiply(BigDecimal.valueOf(componentQty));    // total quantity to reduce
                    
                    // Get the batch ID for the component product (use first active batch)
                    int componentBatchId = bill.getProductBatchId(componentProductId);
                    if (componentBatchId > 0) {
                        // Track the main product name in notes
                        String notes = "Bill of Materials: " + productName;
                        bill.updateStock(componentProductId, totalComponentQty, uid, componentBatchId, billId, notes, userHasStockPermission);
                    }
                }
            }
        } catch (Exception e) {
            // Log error but don't fail the bill
            System.out.println("Error reducing component stock: " + e.getMessage());
        }
    }
    
    // Mark quotation as billed if this bill is from a quotation
    if (quotationId > 0) {
        try {
            bill.markQuotationAsBilled(quotationId);
        } catch (Exception e) {
            System.out.println("Error marking quotation as billed: " + e.getMessage());
        }
    }

    // Deduct exchange points if used
    double exchangePointUsed = 0.0;
    String epUsedStr = request.getParameter("exchangePointUsed");
    if (epUsedStr != null && !epUsedStr.trim().isEmpty()) {
        try { exchangePointUsed = Double.parseDouble(epUsedStr.trim()); } catch (NumberFormatException ex) { }
    }
    if (exchangePointUsed > 0 && customerId > 0) {
        try {
            bill.useExchangePoint(customerId, billId, exchangePointUsed, uid);
        } catch (Exception e) {
            System.out.println("Error deducting exchange points: " + e.getMessage());
        }
    }

    out.print(billDisplay);
    
} catch (Exception e) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    e.printStackTrace();
    out.print("ERROR: " + e.getMessage() + " - " + e.getClass().getName());
}
%>
