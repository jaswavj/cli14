<%@ page import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<% 
	String query 	= (String)request.getParameter("q");
	int typeId		= Integer.parseInt(request.getParameter("typeId").toString());
	response.setHeader("Content-Type", "text/html");
	
	Vector vec		= prod.getAutoLoadDetails(query,typeId);
	for(int i=0;i< vec.size();i++)
		{
		Vector vec1	= (Vector)vec.elementAt(i); 
		String name	= vec1.elementAt(0).toString();
		String code	= vec1.elementAt(1).toString();
		
		out.print(name+"<#>"+code+"\n"); 
		}  
	%>