<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
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
    out.print("{\"success\":false,\"message\":\"Bill number is required\"}");
    return;
}
billNo = billNo.trim();

try {
    Vector data = bill.getBillPaymentInfo(billNo);
    if (data == null || data.isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Bill not found or has been cancelled\"}");
        return;
    }

    int    id          = (Integer) data.elementAt(0);
    String display     = data.elementAt(1).toString().replace("\\", "\\\\").replace("\"", "\\\"");
    String date        = data.elementAt(2).toString();
    String cusName     = data.elementAt(3).toString().replace("\\", "\\\\").replace("\"", "\\\"");
    double payable     = (Double) data.elementAt(4);
    int    paymentMode = (Integer) data.elementAt(5);
    int    paymentType = (Integer) data.elementAt(6);
    double cash        = (Double) data.elementAt(7);
    double bank        = (Double) data.elementAt(8);

    out.print("{");
    out.print("\"success\":true,");
    out.print("\"billId\":"        + id          + ",");
    out.print("\"billNo\":\""      + display     + "\",");
    out.print("\"date\":\""        + date        + "\",");
    out.print("\"cusName\":\""     + cusName     + "\",");
    out.print("\"payable\":"       + payable     + ",");
    out.print("\"paymentMode\":"   + paymentMode + ",");
    out.print("\"paymentType\":"   + paymentType + ",");
    out.print("\"cash\":"          + cash        + ",");
    out.print("\"bank\":"          + bank);
    out.print("}");

} catch (Exception e) {
    String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown error";
    out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
}
%>
