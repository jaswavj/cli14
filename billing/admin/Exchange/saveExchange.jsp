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

    String billNo    = request.getParameter("billNo");
    String detailIdS = request.getParameter("detailId");
    String newProdIdS= request.getParameter("newProdId");
    String newPriceS = request.getParameter("newPrice");

    if (billNo == null || billNo.trim().isEmpty()
        || detailIdS == null || detailIdS.trim().isEmpty()
        || newProdIdS == null || newProdIdS.trim().isEmpty()
        || newPriceS == null  || newPriceS.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Missing required parameters\"}");
        return;
    }

    try {
        billNo    = billNo.trim();
        int detailId  = Integer.parseInt(detailIdS.trim());
        int newProdId = Integer.parseInt(newProdIdS.trim());
        double newPrice = Double.parseDouble(newPriceS.trim());

        if (newPrice <= 0) {
            out.print("{\"success\":false,\"message\":\"Price must be greater than zero\"}");
            return;
        }

        String resultMsg = bill.saveExchange(billNo, detailId, newProdId, newPrice, uid);
        out.print("{\"success\":true,\"message\":\"" + resultMsg.replace("\"","'") + "\"}");

    } catch (NumberFormatException e) {
        out.print("{\"success\":false,\"message\":\"Invalid numeric input\"}");
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'") : "Server error";
        out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
    }
%>
