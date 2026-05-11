<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
Integer userId     = (Integer) session.getAttribute("userId");
String newProduct  = request.getParameter("productName");
String prodCode    = request.getParameter("productCode"); // Changed from prodCode to productCode

String productIdParam = request.getParameter("productId");
String categoryIdParam = request.getParameter("categoryId");
String brandIdParam = request.getParameter("brandId");
String mrpParam = request.getParameter("mrp");
String costParam = request.getParameter("cost");
String discValueParam = request.getParameter("discValue");
String discTypeParam = request.getParameter("discType");
String gstParam = request.getParameter("gst");
String unitIdParam = request.getParameter("unitId");

String commissionParam = request.getParameter("commission");
double commission = 0.0;
if (commissionParam != null && !commissionParam.trim().isEmpty()) {
    try { commission = Double.parseDouble(commissionParam); } catch (NumberFormatException e) { commission = 0.0; }
}

// Validate required parameters
if (productIdParam == null || productIdParam.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/product/master/product/product.jsp?msg=Product+ID+is+missing&type=danger");
    return;
}

int productId      = Integer.parseInt(productIdParam);
int categoryId     = Integer.parseInt(categoryIdParam != null ? categoryIdParam : "0");
int brandId        = Integer.parseInt(brandIdParam != null ? brandIdParam : "0");

double mrp         = Double.parseDouble(mrpParam != null ? mrpParam : "0");
double cost        = Double.parseDouble(costParam != null ? costParam : "0");
double discValue   = Double.parseDouble(discValueParam != null ? discValueParam : "0");
int discType       = Integer.parseInt(discTypeParam != null ? discTypeParam : "0");
int gst            = Integer.parseInt(gstParam != null ? gstParam : "0");
int unitId         = Integer.parseInt(unitIdParam != null ? unitIdParam : "0");
String hsn         = request.getParameter("hsn");
if (hsn != null && hsn.trim().isEmpty()) {
    hsn = null;
}

try {
    // Get the original product name to check if it changed
    String originalName = prod.getProductNameById(productId);
    
    // Only check for duplicate names if the name actually changed
    

    /*if (codeId != 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/product/product.jsp?msg=Object+code+already+exists!&type=warning");
        return;
    }*/

    prod.editProduct(productId, newProduct, prodCode, categoryId, brandId,
                     mrp, cost, discValue, discType, gst, userId, unitId, hsn, commission);

    response.sendRedirect(request.getContextPath() + "/product/master/product/product.jsp?msg=Object+updated+successfully!&type=success");

} catch (Exception e) {
    response.sendRedirect(
        "product.jsp?msg=Error+occurred+while+updating+Object:+"
        + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")
        + "&type=danger"
    );
}
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Category - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <link href="../dist/css/bootstrap.min.css" rel="stylesheet">
    
</head>
<body>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p align="center"><b><font size="6" face="Garamond" color="#000080">Successfully Added .&nbsp; .&nbsp; .&nbsp; .</font></b></p>

<p align="center"><font size="6"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</b></font><font face="Batang"><a class=mainlevel href="category.jsp">Back</a></font></p>



</body>

</html>