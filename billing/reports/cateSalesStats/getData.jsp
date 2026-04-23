<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.simple.JSONObject, org.json.simple.JSONArray" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        out.print("{\"error\":\"Session expired\"}");
        return;
    }

    String fromDate  = request.getParameter("fromDate");
    String toDate    = request.getParameter("toDate");
    String catIdStr  = request.getParameter("catId"); // optional – for product detail drill-down

    if (fromDate == null || fromDate.trim().isEmpty() ||
        toDate   == null || toDate.trim().isEmpty()) {
        out.print("{\"error\":\"Missing date parameters\"}");
        return;
    }

    try {
        JSONObject result = new JSONObject();

        if (catIdStr != null && !catIdStr.trim().isEmpty()) {
            // ── Drill-down: products within a category ─────────────────────
            int catId = Integer.parseInt(catIdStr.trim());
            Vector rows = prod.getCategoryProductDetails(catId, fromDate, toDate);
            JSONArray arr = new JSONArray();
            for (int i = 0; i < rows.size(); i++) {
                Vector r = (Vector) rows.get(i);
                JSONObject row = new JSONObject();
                row.put("productId",   r.get(0));
                row.put("productName", r.get(1) != null ? r.get(1).toString() : "");
                row.put("totalQty",    r.get(2));
                row.put("totalAmt",    r.get(3));
                row.put("billCount",   r.get(4));
                row.put("avgPrice",    r.get(5));
                arr.add(row);
            }
            result.put("products", arr);

        } else {
            // ── Summary: all categories ────────────────────────────────────
            Vector rows = prod.getCategorySalesStats(fromDate, toDate);
            JSONArray arr = new JSONArray();
            double grandAmt  = 0;
            double grandQty  = 0;
            int    activeCats = 0;

            for (int i = 0; i < rows.size(); i++) {
                Vector r = (Vector) rows.get(i);
                JSONObject row = new JSONObject();
                row.put("catId",         r.get(0));
                row.put("catName",       r.get(1) != null ? r.get(1).toString() : "");
                double qty = (Double) r.get(2);
                double amt = (Double) r.get(3);
                row.put("totalQty",      qty);
                row.put("totalAmt",      amt);
                row.put("billCount",     r.get(4));
                row.put("productCount",  r.get(5));
                row.put("topProduct",    r.get(6) != null ? r.get(6).toString() : "");
                row.put("topProductQty", r.get(7));
                grandAmt += amt;
                grandQty += qty;
                if (amt > 0) activeCats++;
                arr.add(row);
            }

            result.put("categories", arr);
            result.put("grandAmt",   grandAmt);
            result.put("grandQty",   grandQty);
            result.put("totalCats",  rows.size());
            result.put("activeCats", activeCats);
        }

        out.print(result.toJSONString());

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'") : "Server error";
        out.print("{\"error\":\"" + msg + "\"}");
    }
%>
