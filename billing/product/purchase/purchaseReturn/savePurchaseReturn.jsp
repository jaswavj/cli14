<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,org.json.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    response.setContentType("application/json");
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        out.print("{\"success\":false,\"message\":\"Not logged in.\"}");
        return;
    }
    JSONObject resp = new JSONObject();
    try {
        int    purchaseId = Integer.parseInt(request.getParameter("purchaseId"));
        String itemsArr   = request.getParameter("itemsArr");
        String notes      = request.getParameter("notes");
        if (itemsArr == null || itemsArr.trim().isEmpty()) throw new Exception("No items provided.");

        String returnNo = prod.savePurchaseReturn(purchaseId, itemsArr, notes, uid);
        resp.put("success",  true);
        resp.put("returnNo", returnNo);
        resp.put("message",  "Purchase return " + returnNo + " saved successfully.");
    } catch (Exception e) {
        resp.put("success", false);
        resp.put("message", e.getMessage());
    }
    out.print(resp.toString());
%>
