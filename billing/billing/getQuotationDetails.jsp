<%@ page language="java" contentType="application/json; charset=UTF-8"%>
<%@ page import="java.util.*, org.json.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
try {
    String quotIdStr = request.getParameter("quotId");
    
    if (quotIdStr == null || quotIdStr.trim().isEmpty()) {
        out.print("{\"success\": false, \"message\": \"Missing quotation ID\"}");
        return;
    }
    
    int quotId = Integer.parseInt(quotIdStr);
    
    // Get quotation header
    Vector quotHeader = bill.getQuotationHeader(quotId);
    
    if (quotHeader == null || quotHeader.isEmpty()) {
        out.print("{\"success\": false, \"message\": \"Quotation not found\"}");
        return;
    }
    
    // Get quotation details
    Vector quotDetails = bill.getQuotationDetails(quotId);
    
    // Build JSON response
    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("success", true);
    jsonResponse.put("quotId", quotId);
    jsonResponse.put("quotNo", quotHeader.get(0));
    jsonResponse.put("customerName", quotHeader.get(5) != null ? quotHeader.get(5) : "");
    jsonResponse.put("customerPhone", quotHeader.get(6) != null ? quotHeader.get(6) : "");
    jsonResponse.put("customerId", quotHeader.get(7));
    jsonResponse.put("extraDisc", quotHeader.get(3));
    
    // Add products
    JSONArray productsArray = new JSONArray();
    for (int i = 0; i < quotDetails.size(); i++) {
        Vector row = (Vector) quotDetails.get(i);
        JSONObject product = new JSONObject();
        product.put("productId", row.get(1));
        product.put("productName", row.get(2));
        product.put("code", row.get(3));
        product.put("qty", row.get(4));
        product.put("price", row.get(5));
        product.put("discount", row.get(6));
        product.put("total", row.get(7));
        product.put("gst", row.get(8));
        // Look up current active batch for stock deduction
        int prodId = ((Number) row.get(1)).intValue();
        int batchId = 0;
        try { batchId = bill.getProductBatchId(prodId); } catch(Exception ex) { batchId = 0; }
        product.put("batchId", batchId);
        productsArray.put(product);
    }
    
    jsonResponse.put("products", productsArray);
    
    out.print(jsonResponse.toString());
    
} catch (Exception e) {
    out.print("{\"success\": false, \"message\": \"" + e.getMessage().replace("\"", "'") + "\"}");
    e.printStackTrace();
}
%>
