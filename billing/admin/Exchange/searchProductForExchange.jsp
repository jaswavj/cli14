<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.JSONArray" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    if (session.getAttribute("userId") == null) {
        out.print("[]");
        return;
    }

    String term = request.getParameter("term");
    if (term == null || term.trim().isEmpty()) {
        out.print("[]");
        return;
    }
    term = term.trim();

    try {
        Vector results = bill.searchProductsForExchange(term);
        JSONArray arr = new JSONArray();
        for (int i = 0; i < results.size(); i++) {
            Vector row = (Vector) results.get(i);
            // row: [prod_id, name, mrp, code]
            JSONObject obj = new JSONObject();
            obj.put("id",    row.get(0) != null ? row.get(0).toString() : "");
            obj.put("name",  row.get(1) != null ? row.get(1).toString() : "");
            obj.put("price", row.get(2) != null ? row.get(2).toString() : "0");
            obj.put("code",  row.size() > 3 && row.get(3) != null ? row.get(3).toString() : "");
            arr.add(obj);
        }
        out.print(arr.toJSONString());
    } catch (Exception e) {
        e.printStackTrace();
        out.print("[]");
    }
%>
