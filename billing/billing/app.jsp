<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%
// Prevent caching
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);
%>
<jsp:useBean id="user" class="user.userBean" />
<%
    Integer uids = (Integer) session.getAttribute("userId");
    
    // Check if user is logged in
    if (uids == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }
    
    String contextPath = request.getContextPath();
%>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BILLING APP</title>
    <link rel="icon" type="image/jpeg" href="jasxbill.jpeg">
	<style>*{margin:0;padding:0;box-sizing:border-box;}html,body{height:100%;overflow:hidden;}</style>

</head>
<body>
    
<iframe 
                    src="billing.jsp" 
                    width="100%" 
                    height="100%" 
                    frameborder="0"
                    style="margin:0; padding:0; display:block; height: calc(107vh - 20px);">
                
                </iframe>
    <!--script>
        $(document).ready(function() {
            // Check for today's bills and due cheques
            $.ajax({
                url: 'checkDueCheques.jsp',
                type: 'GET',
                dataType: 'json',
                success: function(response) {
                    if (response.hasBillsToday) {
                        // Bills exist today, go directly to billing.jsp
                        loadBillingPage();
                    } else if (response.hasDueCheques) {
                        // No bills today but have due cheques, show due cheques list
                        window.location.href = '<%=contextPath%>/billing/dueChequesList.jsp';
                    } else {
                        // No bills and no due cheques, go to billing.jsp
                        loadBillingPage();
                    }
                },
                error: function() {
                    // On error, go to billing.jsp
                    loadBillingPage();
                }
            });
        });*/

        function loadBillingPage() {
            document.body.innerHTML = `
                <iframe 
                    src="billing.jsp" 
                    width="100%" 
                    height="100%" 
                    frameborder="0"
                    style="margin:0; padding:0; display:block; height: calc(107vh - 60px);">
                </iframe>
            `;
        }

        // This must be in the parent page!
        function closeMenuFrame() {
            const frame = document.getElementById("menuFrame");
            if (frame) {
                frame.style.display = "none";
            }
            // redirect main page to dashboard.jsp
            window.location.href = '<%=request.getContextPath()%>/index.jsp';
        }
    </script-->
</body>
</html>