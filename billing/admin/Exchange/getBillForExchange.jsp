<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.JSONArray" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    if (session.getAttribute("userId") == null) {
        out.print("{\"success\":false,\"message\":\"Not authenticated\"}");
        return;
    }

    String billNo = request.getParameter("billNo");
    if (billNo == null || billNo.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Missing bill number\"}");
        return;
    }
    billNo = billNo.trim();

    try {
        Vector header = bill.getBillHeaderForExchange(billNo);
        if (header == null || header.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Bill not found\"}");
            return;
        }
        // header: [bill_id, customer_id, total, payable, paid, cusName, billDate]
        int billId      = header.get(0) != null ? Integer.parseInt(header.get(0).toString()) : 0;
        String cusId    = header.get(1) != null ? header.get(1).toString() : "0";
        String total    = header.get(2) != null ? header.get(2).toString() : "0";
        String payable  = header.get(3) != null ? header.get(3).toString() : "0";
        String paid     = header.get(4) != null ? header.get(4).toString() : "0";
        String cusName  = header.get(5) != null ? header.get(5).toString() : "-";
        String billDate = header.get(6) != null ? header.get(6).toString() : "-";

        Vector items = bill.getBillItemsForExchange(billNo);

        JSONObject resp = new JSONObject();
        resp.put("success",  true);
        resp.put("billNo",   billNo);
        resp.put("billId",   billId);
        resp.put("customerId", cusId);
        resp.put("cusName",  cusName);
        resp.put("total",    total);
        resp.put("payable",  payable);
        resp.put("paid",     paid);
        resp.put("billDate", billDate);

        JSONArray itemsArr = new JSONArray();
        for (int i = 0; i < items.size(); i++) {
            Vector row = (Vector) items.get(i);
            // row: [detailId, prodId, productName, qty, price, disc, total, isExchanged]
            JSONObject obj = new JSONObject();
            obj.put("detailId",    row.get(0) != null ? row.get(0).toString() : "");
            obj.put("prodId",      row.get(1) != null ? row.get(1).toString() : "");
            obj.put("productName", row.get(2) != null ? row.get(2).toString() : "");
            obj.put("qty",         row.get(3) != null ? row.get(3).toString() : "0");
            obj.put("price",       row.get(4) != null ? row.get(4).toString() : "0");
            obj.put("disc",        row.get(5) != null ? row.get(5).toString() : "0");
            obj.put("total",       row.get(6) != null ? row.get(6).toString() : "0");
            obj.put("isExchanged", row.get(7) != null ? row.get(7).toString() : "0");
            itemsArr.add(obj);
        }
        resp.put("items", itemsArr);
        out.print(resp.toJSONString());

    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"success\":false,\"message\":\"Server error: " + e.getMessage().replace("\"","'") + "\"}");
    }
%>
