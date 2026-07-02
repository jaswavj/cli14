<%@page language="java" import="java.util.*, java.math.BigDecimal" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

String[] catIds = request.getParameterValues("catId");
String[] catNames = request.getParameterValues("catName");
String[] curStocks = request.getParameterValues("curStock");
String[] proBatches = request.getParameterValues("proBatch");
String[] discTypes = request.getParameterValues("discType");
String[] discValues = request.getParameterValues("discValue");
String[] reasons = request.getParameterValues("reason");

if (catIds != null && catIds.length > 0) {
    for (int i = 0; i < catIds.length; i++) {
        try {
            int prodId = Integer.parseInt(catIds[i]);
            String prodName = catNames != null && i < catNames.length ? catNames[i] : "";
            BigDecimal curStock = new BigDecimal(curStocks[i]);
            int proBatch = Integer.parseInt(proBatches[i]);
            int discType = Integer.parseInt(discTypes[i]);
            BigDecimal discValue = new BigDecimal(discValues[i]);
            String reason = reasons != null && i < reasons.length ? reasons[i] : "";

            if (discType == 1) {
                prod.addProductStock(prodId, discValue, reason, curStock, proBatch, discType, uid);
            } else if (discType == 2) {
                prod.removeProductStock(prodId, discValue, reason, curStock, proBatch, discType, uid);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

response.sendRedirect(request.getContextPath() + "/product/master/stock/stock.jsp");
%>
