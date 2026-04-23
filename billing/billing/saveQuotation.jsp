<%@ page import="org.json.*, java.io.*, java.util.*, java.math.BigDecimal, billing.ProductItem" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />

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

    String customerName = request.getParameter("customerName");
    String customerPhn = request.getParameter("customerPhn");
    int customerId = 0;
    
    // Get customerId from request
    String customerIdStr = request.getParameter("customerId");
    if (customerIdStr != null && !customerIdStr.trim().isEmpty()) {
        customerId = Integer.parseInt(customerIdStr);
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
                prod.AddCustomer(customerName, "", customerPhn, "", 0, 0);
                customerId = prod.checkTheCustomerNameExist(customerName);
            }
        }
    }
    
    // Parse numeric parameters with null-safety
    double finalDiscount = 0.0;
    double payableAmount = 0.0;
    double grandTotal = 0.0;
    double priceTotal = 0.0;
    double discountTotal = 0.0;
    
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
    
    // Parse JSON array of products
    String productsJson = request.getParameter("products");
    System.out.println("DEBUG: productsJson = " + productsJson);
    
    if (productsJson == null || productsJson.trim().isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("ERROR: No products provided");
        return;
    }

    JSONArray jsonArray = new JSONArray(productsJson);
    System.out.println("DEBUG: jsonArray length = " + jsonArray.length());
    
    List<ProductItem> items = new ArrayList<>();

    for (int i = 0; i < jsonArray.length(); i++) {
        JSONObject jsonObj = jsonArray.getJSONObject(i);
        
        int productId = jsonObj.getInt("productId");
        BigDecimal qty = BigDecimal.valueOf(jsonObj.getDouble("qty"));
        double price = jsonObj.getDouble("price");
        double discount = jsonObj.getDouble("discount");
        double total = jsonObj.getDouble("total");
        int gst = bill.getProductGST(productId); // Fetch GST from database
        double cost = 0.0; // Cost not needed for quotation
        
        items.add(new ProductItem(productId, qty, price, discount, total, gst, cost));
    }

    // Check if products were added
    if (items.isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("ERROR: No products to save");
        return;
    }

    // Save quotation
    String result = bill.saveQuotation(items, customerName, customerPhn, customerId, 
                                      finalDiscount, payableAmount, grandTotal, 
                                      uid, priceTotal, discountTotal);

    // result format: "quotNo|quotId"
    String[] parts = result.split("\\|");
    String quotNo = parts[0];
    String quotId = parts.length > 1 ? parts[1] : "0";
    
    // Return success with quotation number and ID
    out.print("SUCCESS|" + quotNo + "|" + quotId);

} catch (NumberFormatException e) {
    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    out.print("ERROR: Invalid number format - " + e.getMessage());
    e.printStackTrace();
} catch (Exception e) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.print("ERROR: " + e.getMessage());
    e.printStackTrace();
}
%>
