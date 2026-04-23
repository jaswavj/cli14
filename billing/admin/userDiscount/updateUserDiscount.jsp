<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="userBn" class="user.userBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) { out.print("ERROR: Not authenticated"); return; }

try {
    int userId  = Integer.parseInt(request.getParameter("userId").trim());
    int discPer = Integer.parseInt(request.getParameter("discPer").trim());

    if (discPer < 0 || discPer > 100) {
        out.print("ERROR: Discount must be between 0 and 100");
        return;
    }

    userBn.updateUserDiscount(userId, discPer);
    out.print("OK");
} catch (NumberFormatException e) {
    out.print("ERROR: Invalid input");
} catch (Exception e) {
    out.print("ERROR: " + e.getMessage());
}
%>
