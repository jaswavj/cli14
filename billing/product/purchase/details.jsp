<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<jsp:useBean id="ph" class="product.productBean" />

<%
String statusParam = request.getParameter("status");
if (statusParam == null || statusParam.trim().isEmpty()) {
	out.print("Invalid Status");
	return;
}

int Status = 0;
try {
	Status = Integer.parseInt(statusParam.trim());
} catch (NumberFormatException e) {
	out.print("Invalid Status");
	return;
}

Integer uid				= (Integer) session.getAttribute("userId");
if (uid == null) {
	uid = 1; // Fallback if session is lost
}
if(Status == 0)
	{
		String Supplier	= "";
		Vector vec		= ph.GetSupplier();
		///////////////Supplier////////
		for(int n=0;n< vec.size();n++)
			{
			Vector sub	 	= (Vector)vec.elementAt(n);
			int ID			= Integer.parseInt(sub.elementAt(0).toString());
			String name 	= sub.elementAt(1).toString();
	
			Supplier		    += ID +"<#>"+ name +"<@>"; 
			}
		///////////////////////////////
	out.print(Supplier);
	}

////////////////////////
if(Status == 1)
	{
		String productName		= request.getParameter("productName").toString();
		String productCode		= request.getParameter("productCode");
		String productDetails	= ph.getProductFullDetails(productName, productCode);
		out.print(productDetails);
	}
///////////////////////
if(Status == 2)
	{
		String PaymentType	= "";
		Vector vec		= ph.getPaymentTypeDetails();
		///////////////PaymentType////////
		for(int n=0;n< vec.size();n++)
			{
			Vector sub	 	= (Vector)vec.elementAt(n);
			int ID			= Integer.parseInt(sub.elementAt(0).toString());
			String name 	= sub.elementAt(1).toString();
	
			PaymentType		    += ID +"<#>"+ name +"<@>"; 
			}
		///////////////////////////////
	out.print(PaymentType);
	}

////////////////////////
if(Status == 3)
	{
		String Bank	= "";
		Vector vec		= ph.getBankDetails();
		///////////////Bank////////
		for(int n=0;n< vec.size();n++)
			{
			Vector sub	 	= (Vector)vec.elementAt(n);
			int ID			= Integer.parseInt(sub.elementAt(0).toString());
			String name 	= sub.elementAt(1).toString();
	
			Bank		    += ID +"<#>"+ name +"<@>"; 
			}
		///////////////////////////////
	out.print(Bank);
	}

////////////////////////
if(Status == 5)
	{
		String productName	= request.getParameter("productName");
		
		Vector history = ph.getProductPurchaseHistory(productName, 6);
		
		if (history.size() == 0) {
			out.print("<div class='alert alert-info'>No purchase history found for this product.</div>");
		} else {
			out.print("<div class='table-responsive'>");
			out.print("<table class='table table-sm table-bordered'>");
			out.print("<thead><tr><th>Supplier</th><th>Date & Time</th><th>Invoice</th><th>Pack</th><th>Qty/Pack</th><th>Total Qty</th><th>Free</th><th>Cost</th><th>MRP</th><th>Disc%</th><th>Tax%</th></tr></thead>");
			out.print("<tbody>");
			
			for (int i = 0; i < history.size(); i++) {
				Vector row = (Vector) history.get(i);
				String unit = row.get(11).toString();
				String unitSuffix = (unit != null && !unit.isEmpty()) ? " " + unit : "";
				out.print("<tr>");
				out.print("<td>" + row.get(0) + "</td>"); // supplier
				out.print("<td>" + row.get(1) + "</td>"); // date & time
				out.print("<td>" + row.get(2) + "</td>"); // invoice
				out.print("<td>" + row.get(3) + "</td>"); // pack
				out.print("<td>" + row.get(4) + unitSuffix + "</td>"); // qty per pack + unit
				out.print("<td>" + row.get(5) + unitSuffix + "</td>"); // total qty + unit
				out.print("<td>" + row.get(6) + "</td>"); // free
				out.print("<td>" + row.get(7) + "</td>"); // cost
				out.print("<td>" + row.get(8) + "</td>"); // mrp
				out.print("<td>" + row.get(9) + "</td>"); // disc
				out.print("<td>" + row.get(10) + "</td>"); // tax
				out.print("</tr>");
			}
			
			out.print("</tbody></table></div>");
		}
	}

////////////////////////
if(Status == 6)
	{
		String PaymentType	= "";
		Vector vec		= ph.getBillPaymentTypes();
		///////////////Bill Payment Types (excluding id=0)////////
		for(int n=0;n< vec.size();n++)
			{
			Vector sub	 	= (Vector)vec.elementAt(n);
			int ID			= Integer.parseInt(sub.elementAt(0).toString());
			String name 	= sub.elementAt(1).toString();
			
			if (ID != 0) {  // Exclude id=0
				PaymentType	+= ID +"<#>"+ name +"<@>";
			}
			}
		///////////////////////////////
	out.print(PaymentType);
	}

////////////////////////
if(Status == 7)
	{
		int supplierId = Integer.parseInt(request.getParameter("supplierId").toString());
		int isGst = ph.getSupplierGstStatus(supplierId);
		out.print(isGst);
	}

////////////////////////
if(Status == 8)
	{
		String productName = request.getParameter("productName");
		String productCode = request.getParameter("productCode");
		String categoryIdParam = request.getParameter("categoryId");
		String brandIdParam = request.getParameter("brandId");
		String unitIdParam = request.getParameter("unitId");
		String hsn = request.getParameter("hsn");
		String costParam = request.getParameter("cost");
		String mrpParam = request.getParameter("mrp");
		String gstParam = request.getParameter("gst");

		if (productName == null || productName.trim().isEmpty()) {
			out.print("ERROR<#>Product name is required");
			return;
		}

		int categoryId = 0;
		int brandId = 0;
		int unitId = 0;
		int gst = 0;
		double cost = 0.0;
		double mrp = 0.0;

		try {
			categoryId = Integer.parseInt(categoryIdParam);
			brandId = Integer.parseInt(brandIdParam);
			unitId = Integer.parseInt(unitIdParam);
			cost = Double.parseDouble(costParam);
			mrp = Double.parseDouble(mrpParam);
			gst = Integer.parseInt(gstParam);
		} catch (Exception e) {
			out.print("ERROR<#>Invalid input values");
			return;
		}

		if (categoryId <= 0 || brandId <= 0 || unitId <= 0) {
			out.print("ERROR<#>Please select category, brand, and unit");
			return;
		}

		if (cost < 0 || mrp < 0) {
			out.print("ERROR<#>Cost and MRP must be valid numbers");
			return;
		}

		if (productCode == null || productCode.trim().isEmpty()) {
			productCode = "0";
		}

		if (hsn != null && hsn.trim().isEmpty()) {
			hsn = null;
		}

		try {
			ph.addProduct(productName.trim(), categoryId, brandId, productCode.trim(), cost, mrp, 0, 0.0, BigDecimal.ZERO, uid, gst, unitId, hsn, 0.0);
			out.print("SUCCESS<#>" + productName.trim() + "<#>" + productCode.trim());
		} catch (Exception e) {
			out.print("ERROR<#>" + e.getMessage());
		}
	}

////////////////////////
if(Status == 4)
	{
		String invArr	= request.getParameter("invArr");
		String payArr	= request.getParameter("payArr");
		String prodArr	= request.getParameter("prodArr");
		String poIdStr	= request.getParameter("poId");
		String mode		= request.getParameter("mode");
		
		// URL decode if needed (request.getParameter should auto-decode, but just in case)
		if (invArr != null) invArr = java.net.URLDecoder.decode(invArr, "UTF-8");
		if (payArr != null) payArr = java.net.URLDecoder.decode(payArr, "UTF-8");
		if (prodArr != null) prodArr = java.net.URLDecoder.decode(prodArr, "UTF-8");
		
		int poId = 0;
		if (poIdStr != null && !poIdStr.trim().isEmpty()) {
			try {
				poId = Integer.parseInt(poIdStr);
			} catch (NumberFormatException e) {
				poId = 0;
			}
		}
		
		if (mode == null || mode.trim().isEmpty()) {
			mode = "standalone";
		}
		
		String display = "";
		try {
			if (poId > 0 && mode.equals("from-po")) {
				display = ph.savePurchaseBill(invArr, payArr, prodArr, uid, poId, mode);
			} else {
				display = ph.savePurchaseBill(invArr, payArr, prodArr, uid);
			}
		} catch (Exception e) {
			// Return error message to client
			display = "ERROR: " + e.getMessage();
		}
		out.print(display);
	}
///////////////////////

%>
