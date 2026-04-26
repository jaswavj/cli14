<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    String code = request.getParameter("code");
    String priceCategoryStr = request.getParameter("priceCategory");
    int priceCategory = (priceCategoryStr != null && !priceCategoryStr.isEmpty()) ? Integer.parseInt(priceCategoryStr) : 3;

    if (code == null || code.trim().isEmpty()) {
        out.print("[]");
        return;
    }

    Vector results = bill.getAllProductsByCode(code.trim(), priceCategory);

    StringBuilder json = new StringBuilder("[");
    for (int i = 0; i < results.size(); i++) {
        Vector row = (Vector) results.elementAt(i);
        if (i > 0) json.append(",");
        json.append("{");
        json.append("\"id\":\"").append(row.get(0)).append("\",");
        json.append("\"name\":\"").append(row.get(1).toString().replace("\"","\\\"")).append("\",");
        json.append("\"mrp\":\"").append(row.get(2)).append("\",");
        json.append("\"discount\":\"").append(row.get(3)).append("\",");
        json.append("\"batchId\":\"").append(row.get(4)).append("\",");
        json.append("\"unitId\":\"").append(row.get(5) != null ? row.get(5) : "").append("\",");
        json.append("\"unitName\":\"").append(row.get(6) != null ? row.get(6) : "").append("\",");
        json.append("\"commission\":\"").append(row.get(7) != null ? row.get(7) : "0").append("\",");
        json.append("\"convertionUnit\":\"").append(row.get(8) != null ? row.get(8) : "").append("\"");
        json.append("}");
    }
    json.append("]");
    out.print(json.toString());
%>
