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
        String searchParam = request.getParameter("purchaseId");
        if (searchParam == null || searchParam.trim().isEmpty()) searchParam = request.getParameter("search");
        int purchaseId = 0;
        try {
            purchaseId = Integer.parseInt(searchParam.trim());
        } catch (NumberFormatException nfe) {
            // Try lookup by prno
            purchaseId = prod.getPurchaseIdByPrno(searchParam.trim());
        }
        if (purchaseId <= 0) {
            resp.put("success", false);
            resp.put("message", "Purchase not found for: " + searchParam);
            out.print(resp.toString());
            return;
        }

        // Header
        Vector headers = prod.getPurchaseHeaderById(purchaseId);
        if (headers == null || headers.isEmpty()) {
            resp.put("success", false);
            resp.put("message", "Purchase not found.");
            out.print(resp.toString());
            return;
        }
        Vector h = (Vector) headers.get(0);
        JSONObject header = new JSONObject();
        header.put("id",       purchaseId);
        header.put("prno",     h.elementAt(0));
        header.put("invno",    h.elementAt(1));
        header.put("invdate",  h.elementAt(2));
        header.put("total",    h.elementAt(3));
        header.put("supplier", h.elementAt(9));

        // Items (only non-cancelled)
        Vector items = prod.getPurchaseDetailsForEdit(purchaseId);

        // Build map of already-returned qty per detail id
        java.util.HashMap<Integer,Double> returnedMap = new java.util.HashMap<>();
        Vector retList = prod.getAlreadyReturnedQtyForPurchase(purchaseId);
        for (int i = 0; i < retList.size(); i++) {
            Vector rv = (Vector) retList.get(i);
            returnedMap.put((Integer) rv.elementAt(0), (Double) rv.elementAt(1));
        }

        JSONArray arr = new JSONArray();
        for (int i = 0; i < items.size(); i++) {
            Vector row = (Vector) items.get(i);
            int isCancelled = (Integer) row.elementAt(14);
            if (isCancelled == 1) continue;
            int    detailId  = (Integer) row.elementAt(0);
            double origQty   = (Double)  row.elementAt(5) + (Double) row.elementAt(6);
            double returned  = returnedMap.getOrDefault(detailId, 0.0);
            double available = origQty - returned;
            if (available <= 0) continue; // fully returned — skip
            JSONObject obj = new JSONObject();
            obj.put("detailId",       detailId);
            obj.put("product",        row.elementAt(1));
            obj.put("qty",            row.elementAt(5));
            obj.put("free",           row.elementAt(6));
            obj.put("rate",           row.elementAt(7));
            obj.put("mrp",            row.elementAt(8));
            obj.put("alreadyReturned", returned);
            obj.put("availableQty",    available);
            arr.put(obj);
        }
        resp.put("success", true);
        resp.put("header", header);
        resp.put("items", arr);
    } catch (Exception e) {
        resp.put("success", false);
        resp.put("message", e.getMessage());
    }
    out.print(resp.toString());
%>
