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

    String prodIdS   = request.getParameter("prodId");
    String fromDate  = request.getParameter("fromDate");
    String toDate    = request.getParameter("toDate");

    if (prodIdS == null || fromDate == null || toDate == null ||
        prodIdS.trim().isEmpty() || fromDate.trim().isEmpty() || toDate.trim().isEmpty()) {
        out.print("{\"error\":\"Missing parameters\"}");
        return;
    }

    int prodId = 0;
    try { prodId = Integer.parseInt(prodIdS.trim()); } catch (Exception e) {
        out.print("{\"error\":\"Invalid product\"}");
        return;
    }

    try {
        JSONObject result = new JSONObject();

        // ── 1. SALES ──────────────────────────────────────────────────────────
        Vector salesRows = prod.getProductSalesReport(prodId, fromDate, toDate);
        JSONArray salesArr = new JSONArray();
        double salesTotalQty = 0, salesTotalAmt = 0, salesTotalCost = 0;
        for (int i = 0; i < salesRows.size(); i++) {
            Vector r = (Vector) salesRows.get(i);
            JSONObject row = new JSONObject();
            row.put("bill",   r.get(0) != null ? r.get(0).toString() : "");
            row.put("date",   r.get(1) != null ? r.get(1).toString() : "");
            row.put("cus",    r.get(2) != null ? r.get(2).toString() : "");
            double qty   = r.get(3) != null ? ((Double) r.get(3)) : 0;
            double price = r.get(4) != null ? ((Double) r.get(4)) : 0;
            double disc  = r.get(5) != null ? ((Double) r.get(5)) : 0;
            double gst   = r.get(6) != null ? ((Double) r.get(6)) : 0;
            double total = r.get(7) != null ? ((Double) r.get(7)) : 0;
            double cost  = r.get(8) != null ? ((Double) r.get(8)) : 0;
            row.put("qty",   qty);
            row.put("price", price);
            row.put("disc",  disc);
            row.put("gst",   gst);
            row.put("total", total);
            row.put("cost",  cost);
            row.put("user",  r.get(9) != null ? r.get(9).toString() : "");
            salesTotalQty += qty;
            salesTotalAmt += total;
            salesTotalCost += (cost * qty);
            salesArr.add(row);
        }
        JSONObject salesObj = new JSONObject();
        salesObj.put("rows", salesArr);
        salesObj.put("count", salesRows.size());
        salesObj.put("totalQty", salesTotalQty);
        salesObj.put("totalAmt", salesTotalAmt);
        salesObj.put("totalCost", salesTotalCost);
        result.put("sales", salesObj);

        // ── 2. SALES RETURNS ─────────────────────────────────────────────────
        Vector retRows = prod.getProductSalesReturnReport(prodId, fromDate, toDate);
        JSONArray retArr = new JSONArray();
        double retTotalQty = 0, retTotalAmt = 0;
        for (int i = 0; i < retRows.size(); i++) {
            Vector r = (Vector) retRows.get(i);
            JSONObject row = new JSONObject();
            row.put("bill",  r.get(0) != null ? r.get(0).toString() : "");
            row.put("date",  r.get(1) != null ? r.get(1).toString() : "");
            row.put("cus",   r.get(2) != null ? r.get(2).toString() : "");
            double qty   = r.get(3) != null ? ((Double) r.get(3)) : 0;
            double price = r.get(4) != null ? ((Double) r.get(4)) : 0;
            double total = r.get(5) != null ? ((Double) r.get(5)) : 0;
            row.put("qty",   qty);
            row.put("price", price);
            row.put("total", total);
            row.put("user",  r.get(6) != null ? r.get(6).toString() : "");
            retTotalQty += qty;
            retTotalAmt += total;
            retArr.add(row);
        }
        JSONObject retObj = new JSONObject();
        retObj.put("rows", retArr);
        retObj.put("count", retRows.size());
        retObj.put("totalQty", retTotalQty);
        retObj.put("totalAmt", retTotalAmt);
        result.put("salesReturn", retObj);

        // ── 3. PURCHASE ───────────────────────────────────────────────────────
        Vector purRows = prod.getProductPurchaseReport(prodId, fromDate, toDate);
        JSONArray purArr = new JSONArray();
        double purTotalQty = 0, purTotalAmt = 0;
        for (int i = 0; i < purRows.size(); i++) {
            Vector r = (Vector) purRows.get(i);
            JSONObject row = new JSONObject();
            row.put("prno",     r.get(0) != null ? r.get(0).toString() : "");
            row.put("invno",    r.get(1) != null ? r.get(1).toString() : "");
            row.put("date",     r.get(2) != null ? r.get(2).toString() : "");
            row.put("supplier", r.get(3) != null ? r.get(3).toString() : "");
            double qty    = r.get(4) != null ? ((Double) r.get(4)) : 0;
            double free   = r.get(5) != null ? ((Double) r.get(5)) : 0;
            double rate   = r.get(6) != null ? ((Double) r.get(6)) : 0;
            double mrp    = r.get(7) != null ? ((Double) r.get(7)) : 0;
            double disc   = r.get(8) != null ? ((Double) r.get(8)) : 0;
            double tax    = r.get(9) != null ? ((Double) r.get(9)) : 0;
            double total  = r.get(10) != null ? ((Double) r.get(10)) : 0;
            double netamt = r.get(11) != null ? ((Double) r.get(11)) : 0;
            row.put("qty",    qty);
            row.put("free",   free);
            row.put("rate",   rate);
            row.put("mrp",    mrp);
            row.put("disc",   disc);
            row.put("tax",    tax);
            row.put("total",  total);
            row.put("netamt", netamt);
            row.put("user",   r.get(12) != null ? r.get(12).toString() : "");
            purTotalQty += qty;
            purTotalAmt += netamt;
            purArr.add(row);
        }
        JSONObject purObj = new JSONObject();
        purObj.put("rows", purArr);
        purObj.put("count", purRows.size());
        purObj.put("totalQty", purTotalQty);
        purObj.put("totalAmt", purTotalAmt);
        result.put("purchase", purObj);

        // ── 4. PURCHASE RETURNS ───────────────────────────────────────────────
        Vector purRetRows = prod.getProductPurchaseReturnReport(prodId, fromDate, toDate);
        JSONArray purRetArr = new JSONArray();
        double purRetTotalQty = 0, purRetTotalAmt = 0;
        for (int i = 0; i < purRetRows.size(); i++) {
            Vector r = (Vector) purRetRows.get(i);
            JSONObject row = new JSONObject();
            row.put("returnNo", r.get(0) != null ? r.get(0).toString() : "");
            row.put("date",     r.get(1) != null ? r.get(1).toString() : "");
            row.put("supplier", r.get(2) != null ? r.get(2).toString() : "");
            double qty   = r.get(3) != null ? ((Double) r.get(3)) : 0;
            double rate  = r.get(4) != null ? ((Double) r.get(4)) : 0;
            double total = r.get(5) != null ? ((Double) r.get(5)) : 0;
            row.put("qty",   qty);
            row.put("rate",  rate);
            row.put("total", total);
            row.put("notes", r.get(6) != null ? r.get(6).toString() : "");
            row.put("user",  r.get(7) != null ? r.get(7).toString() : "");
            purRetTotalQty += qty;
            purRetTotalAmt += total;
            purRetArr.add(row);
        }
        JSONObject purRetObj = new JSONObject();
        purRetObj.put("rows", purRetArr);
        purRetObj.put("count", purRetRows.size());
        purRetObj.put("totalQty", purRetTotalQty);
        purRetObj.put("totalAmt", purRetTotalAmt);
        result.put("purchaseReturn", purRetObj);

        // ── 5. EXCHANGES ──────────────────────────────────────────────────────
        Vector excRows = prod.getProductExchangeReport(prodId, fromDate, toDate);
        JSONArray excArr = new JSONArray();
        int excOut = 0, excIn = 0;
        for (int i = 0; i < excRows.size(); i++) {
            Vector r = (Vector) excRows.get(i);
            JSONObject row = new JSONObject();
            row.put("bill",      r.get(0) != null ? r.get(0).toString() : "");
            row.put("date",      r.get(1) != null ? r.get(1).toString() : "");
            row.put("cus",       r.get(2) != null ? r.get(2).toString() : "");
            row.put("oldProd",   r.get(3) != null ? r.get(3).toString() : "");
            row.put("newProd",   r.get(4) != null ? r.get(4).toString() : "");
            String dir = r.get(5) != null ? r.get(5).toString() : "Out";
            row.put("direction", dir);
            row.put("user",      r.get(6) != null ? r.get(6).toString() : "");
            if ("Out".equals(dir)) excOut++; else excIn++;
            excArr.add(row);
        }
        JSONObject excObj = new JSONObject();
        excObj.put("rows", excArr);
        excObj.put("count", excRows.size());
        excObj.put("outCount", excOut);
        excObj.put("inCount", excIn);
        result.put("exchange", excObj);

        // ── 6. CANCELLATIONS ──────────────────────────────────────────────────
        Vector canRows = prod.getProductCancelReport(prodId, fromDate, toDate);
        JSONArray canArr = new JSONArray();
        double canTotalQty = 0, canTotalAmt = 0;
        for (int i = 0; i < canRows.size(); i++) {
            Vector r = (Vector) canRows.get(i);
            JSONObject row = new JSONObject();
            row.put("bill",  r.get(0) != null ? r.get(0).toString() : "");
            row.put("date",  r.get(1) != null ? r.get(1).toString() : "");
            row.put("cus",   r.get(2) != null ? r.get(2).toString() : "");
            double qty   = r.get(3) != null ? ((Double) r.get(3)) : 0;
            double price = r.get(4) != null ? ((Double) r.get(4)) : 0;
            double total = r.get(5) != null ? ((Double) r.get(5)) : 0;
            row.put("qty",        qty);
            row.put("price",      price);
            row.put("total",      total);
            row.put("cancelType", r.get(6) != null ? r.get(6).toString() : "");
            row.put("user",       r.get(7) != null ? r.get(7).toString() : "");
            canTotalQty += qty;
            canTotalAmt += total;
            canArr.add(row);
        }
        JSONObject canObj = new JSONObject();
        canObj.put("rows", canArr);
        canObj.put("count", canRows.size());
        canObj.put("totalQty", canTotalQty);
        canObj.put("totalAmt", canTotalAmt);
        result.put("cancelled", canObj);

        // ── 7. STOCK ADJUSTMENTS ─────────────────────────────────────────────
        Vector adjRows = prod.getStockAdjReport(fromDate, toDate, prodId);
        JSONArray adjArr = new JSONArray();
        double adjTotalAdd = 0, adjTotalRemove = 0;
        for (int i = 0; i < adjRows.size(); i++) {
            Vector r = (Vector) adjRows.get(i);
            JSONObject row = new JSONObject();
            row.put("date",      r.get(6) != null ? r.get(6).toString() : "");
            row.put("time",      r.get(7) != null ? r.get(7).toString() : "");
            String sType = r.get(4) != null ? r.get(4).toString() : "2";
            row.put("stockType", sType);
            double stock = 0;
            try { stock = Double.parseDouble(r.get(5).toString()); } catch(Exception ex) {}
            String unit = r.get(11) != null ? r.get(11).toString() : "";
            row.put("stock",     stock);
            row.put("unit",      unit);
            row.put("notes",     r.get(8) != null ? r.get(8).toString() : "");
            row.put("user",      r.get(10) != null ? r.get(10).toString() : "");
            if ("1".equals(sType)) adjTotalAdd += stock;
            else adjTotalRemove += stock;
            adjArr.add(row);
        }
        JSONObject adjObj = new JSONObject();
        adjObj.put("rows", adjArr);
        adjObj.put("count", adjRows.size());
        adjObj.put("totalAdd", adjTotalAdd);
        adjObj.put("totalRemove", adjTotalRemove);
        result.put("stockAdj", adjObj);

        out.print(result.toJSONString());

    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"error\":\"" + e.getMessage().replace("\"","'") + "\"}");
    }
%>
