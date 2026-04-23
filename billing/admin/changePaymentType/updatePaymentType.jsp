<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
response.setContentType("text/plain");
response.setCharacterEncoding("UTF-8");

Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    out.print("ERROR: Not authenticated");
    return;
}

int    billId;
double cash;
double bank;
int    bankMode;

try {
    billId   = Integer.parseInt(request.getParameter("billId").trim());
    cash     = Double.parseDouble(request.getParameter("cash").trim());
    bank     = Double.parseDouble(request.getParameter("bank").trim());
    bankMode = Integer.parseInt(request.getParameter("bankMode").trim());
} catch (Exception e) {
    out.print("ERROR: Invalid parameters. " + e.getMessage());
    return;
}

if (cash < 0 || bank < 0) {
    out.print("ERROR: Amounts cannot be negative.");
    return;
}
if (cash == 0 && bank == 0) {
    out.print("ERROR: At least one payment amount must be greater than zero.");
    return;
}

try {
    bill.updateBillPaymentType(billId, cash, bank, bankMode, uid);
    out.print("OK");
} catch (Exception e) {
    out.print("ERROR: " + (e.getMessage() != null ? e.getMessage() : "Unknown error"));
}
%>
