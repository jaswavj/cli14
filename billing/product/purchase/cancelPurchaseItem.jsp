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
        int detailId   = Integer.parseInt(request.getParameter("detailId"));
        int purchaseId = Integer.parseInt(request.getParameter("purchaseId"));
        String reason  = request.getParameter("reason");
        if (reason == null) reason = "";

        String msg = prod.cancelPurchaseItem(detailId, purchaseId, reason, uid);
        resp.put("success", true);
        resp.put("message", msg);
    } catch (Exception e) {
        resp.put("success", false);
        resp.put("message", e.getMessage());
    }
    out.print(resp.toString());
%>
