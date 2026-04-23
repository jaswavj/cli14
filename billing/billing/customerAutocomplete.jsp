<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    request.setCharacterEncoding("UTF-8");
    String query = request.getParameter("query");
    String phone = request.getParameter("phone");
    
    JSONArray results = new JSONArray();
    
    try {
        Vector customers;
        if (phone != null && !phone.trim().isEmpty()) {
            customers = prod.searchCustomersByPhone(phone.trim());
        } else if (query != null && !query.trim().isEmpty()) {
            customers = prod.searchCustomers(query.trim());
        } else {
            out.print(results.toString());
            return;
        }
        
        for (int i = 0; i < customers.size(); i++) {
            Vector customer = (Vector) customers.get(i);
            
            JSONObject obj = new JSONObject();
            obj.put("id", customer.elementAt(0));
            obj.put("name", customer.elementAt(1));
            obj.put("phone", customer.elementAt(2));
            obj.put("address", customer.elementAt(3));
            obj.put("gstin", customer.elementAt(4));
            obj.put("creditLimit", customer.elementAt(5));
            obj.put("isGst", customer.elementAt(6));
            obj.put("isEligibleForCommission", customer.elementAt(7));
            obj.put("exchangePoint", customer.size() > 8 ? customer.elementAt(8) : 0);
            
            results.put(obj);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    out.print(results.toString());
%>
