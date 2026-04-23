<%@ page import="java.util.*, product.productBean" contentType="application/json; charset=UTF-8" %>
<%@ page import="org.json.simple.JSONObject, org.json.simple.JSONArray" %>
<%
    response.setHeader("Cache-Control","no-cache");
    if (session.getAttribute("userId") == null) {
        out.print("{\"error\":\"Session expired\"}");
        return;
    }

    String customerIdStr = request.getParameter("customerId");
    String fromDate      = request.getParameter("fromDate");
    String toDate        = request.getParameter("toDate");

    if (customerIdStr == null || fromDate == null || toDate == null ||
        customerIdStr.trim().isEmpty() || fromDate.trim().isEmpty() || toDate.trim().isEmpty()) {
        out.print("{\"error\":\"Missing parameters\"}");
        return;
    }

    int customerId;
    try {
        customerId = Integer.parseInt(customerIdStr.trim());
    } catch (NumberFormatException e) {
        out.print("{\"error\":\"Invalid customer\"}");
        return;
    }

    productBean prod = new productBean();
    JSONObject result = new JSONObject();

    try {
        // ── SALES ────────────────────────────────────────────────────────────
        Vector salesVec = prod.getCustomerSalesReport(customerId, fromDate, toDate);
        JSONArray salesRows = new JSONArray();
        double salesTotalAmt = 0, salesTotalPayable = 0, salesTotalPaid = 0, salesTotalBalance = 0;
        for (int i = 0; i < salesVec.size(); i++) {
            Vector row = (Vector) salesVec.get(i);
            JSONObject r = new JSONObject();
            r.put("bill",        row.get(0));
            r.put("date",        row.get(1));
            r.put("total",       row.get(2));
            r.put("payable",     row.get(3));
            r.put("paid",        row.get(4));
            r.put("balance",     row.get(5));
            r.put("paymentMode", row.get(6));
            r.put("user",        row.get(7));
            salesRows.add(r);
            salesTotalAmt     += ((Number) row.get(2)).doubleValue();
            salesTotalPayable += ((Number) row.get(3)).doubleValue();
            salesTotalPaid    += ((Number) row.get(4)).doubleValue();
            salesTotalBalance += ((Number) row.get(5)).doubleValue();
        }
        JSONObject salesObj = new JSONObject();
        salesObj.put("rows",         salesRows);
        salesObj.put("count",        salesVec.size());
        salesObj.put("totalAmt",     salesTotalAmt);
        salesObj.put("totalPayable", salesTotalPayable);
        salesObj.put("totalPaid",    salesTotalPaid);
        salesObj.put("totalBalance", salesTotalBalance);
        result.put("sales", salesObj);

        // ── SALES RETURN ─────────────────────────────────────────────────────
        Vector retVec = prod.getCustomerSalesReturnReport(customerId, fromDate, toDate);
        JSONArray retRows = new JSONArray();
        double retTotalQty = 0, retTotalAmt = 0;
        for (int i = 0; i < retVec.size(); i++) {
            Vector row = (Vector) retVec.get(i);
            JSONObject r = new JSONObject();
            r.put("bill",    row.get(0));
            r.put("date",    row.get(1));
            r.put("product", row.get(2));
            r.put("qty",     row.get(3));
            r.put("price",   row.get(4));
            r.put("total",   row.get(5));
            r.put("user",    row.get(6));
            retRows.add(r);
            retTotalQty += ((Number) row.get(3)).doubleValue();
            retTotalAmt += ((Number) row.get(5)).doubleValue();
        }
        JSONObject retObj = new JSONObject();
        retObj.put("rows",     retRows);
        retObj.put("count",    retVec.size());
        retObj.put("totalQty", retTotalQty);
        retObj.put("totalAmt", retTotalAmt);
        result.put("salesReturn", retObj);

        // ── EXCHANGE ─────────────────────────────────────────────────────────
        Vector exVec = prod.getCustomerExchangeReport(customerId, fromDate, toDate);
        JSONArray exRows = new JSONArray();
        for (int i = 0; i < exVec.size(); i++) {
            Vector row = (Vector) exVec.get(i);
            JSONObject r = new JSONObject();
            r.put("bill",     row.get(0));
            r.put("date",     row.get(1));
            r.put("oldProd",  row.get(2));
            r.put("newProd",  row.get(3));
            r.put("user",     row.get(4));
            exRows.add(r);
        }
        JSONObject exObj = new JSONObject();
        exObj.put("rows",  exRows);
        exObj.put("count", exVec.size());
        result.put("exchange", exObj);

        // ── EXCHANGE POINTS ───────────────────────────────────────────────────
        Vector epVec = prod.getCustomerExchangePoints(customerId, fromDate, toDate);
        JSONArray epRows = new JSONArray();
        double totalEarned = 0, totalUsed = 0, currentBalance = 0;
        for (int i = 0; i < epVec.size(); i++) {
            Vector row = (Vector) epVec.get(i);
            JSONObject r = new JSONObject();
            r.put("bill",          row.get(0));
            r.put("date",          row.get(1));
            r.put("openingPoints", row.get(2));
            r.put("changePoints",  row.get(3));
            r.put("closingPoints", row.get(4));
            r.put("notes",         row.get(5));
            r.put("user",          row.get(6));
            epRows.add(r);
            double change = ((Number) row.get(3)).doubleValue();
            if (change > 0) totalEarned += change;
            else            totalUsed   += Math.abs(change);
            currentBalance = ((Number) row.get(4)).doubleValue();
        }
        JSONObject epObj = new JSONObject();
        epObj.put("rows",           epRows);
        epObj.put("count",          epVec.size());
        epObj.put("totalEarned",    totalEarned);
        epObj.put("totalUsed",      totalUsed);
        epObj.put("currentBalance", currentBalance);
        result.put("exchangePoints", epObj);

        out.print(result.toJSONString());

    } catch (Exception e) {
        JSONObject err = new JSONObject();
        err.put("error", e.getMessage());
        out.print(err.toJSONString());
    }
%>
