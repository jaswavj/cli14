<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,org.json.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    response.setContentType("application/json");
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) { out.print("{\"success\":false,\"message\":\"Not logged in.\"}"); return; }
    JSONObject resp = new JSONObject();
    try {
        int returnId = Integer.parseInt(request.getParameter("returnId"));
        Vector items = prod.getPurchaseReturnDetails(returnId);
        JSONArray arr = new JSONArray();
        for (int i = 0; i < items.size(); i++) {
            Vector row = (Vector) items.get(i);
            JSONObject obj = new JSONObject();
            obj.put("product", row.elementAt(1));
            obj.put("qty",     row.elementAt(2));
            obj.put("rate",    row.elementAt(3));
            obj.put("total",   row.elementAt(4));
            arr.put(obj);
        }
        resp.put("success", true);
        resp.put("items", arr);
    } catch (Exception e) {
        resp.put("success", false);
        resp.put("message", e.getMessage());
    }
    out.print(resp.toString());
%>
