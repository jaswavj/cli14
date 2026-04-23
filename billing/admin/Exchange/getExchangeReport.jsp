<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        out.print("{\"success\":false,\"message\":\"Not authenticated\"}");
        return;
    }

    String fromDate  = request.getParameter("fromDate");
    String toDate    = request.getParameter("toDate");
    String typeParam = request.getParameter("type");

    if (fromDate == null || fromDate.trim().isEmpty()
        || toDate == null || toDate.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Date range required\"}");
        return;
    }

    int typeFilter = 0;
    try { if (typeParam != null) typeFilter = Integer.parseInt(typeParam.trim()); } catch (Exception e) { typeFilter = 0; }

    try {
        Vector rows = bill.getExchangeReturnReport(fromDate.trim(), toDate.trim(), typeFilter);

        StringBuilder sb = new StringBuilder();
        sb.append("{\"success\":true,\"rows\":[");
        for (int i = 0; i < rows.size(); i++) {
            Vector row = (Vector) rows.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"id\":").append(row.get(0)).append(",");
            sb.append("\"dt\":\"").append(String.valueOf(row.get(1)).replace("\"","'")).append("\",");
            sb.append("\"billNo\":\"").append(String.valueOf(row.get(2)).replace("\"","'")).append("\",");
            sb.append("\"customer\":\"").append(String.valueOf(row.get(3)).replace("\"","'")).append("\",");
            sb.append("\"oldProd\":\"").append(String.valueOf(row.get(4)).replace("\"","'")).append("\",");
            sb.append("\"newProd\":\"").append(String.valueOf(row.get(5)).replace("\"","'")).append("\",");
            sb.append("\"type\":").append(row.get(6)).append(",");
            sb.append("\"points\":").append(row.get(7)).append(",");
            sb.append("\"staff\":\"").append(String.valueOf(row.get(8)).replace("\"","'")).append("\"");
            sb.append("}");
        }
        sb.append("]}");
        out.print(sb.toString());

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'") : "Server error";
        out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
    }
%>
