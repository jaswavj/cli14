<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Payment Type Change Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3 class="mb-4"><i class="fas fa-exchange-alt me-2"></i>Payment Type Change Report</h3>

        <form action="<%=contextPath%>/admin/report/paymentTypeChange/page0.jsp" method="get" class="row g-3">
            <div class="col-md-3">
                <label for="fromDate" class="form-label">From Date</label>
                <input type="date" id="fromDate" name="fromDate"
                       value="<%=new SimpleDateFormat("yyyy-MM-dd").format(new Date())%>"
                       class="form-control" required>
            </div>
            <div class="col-md-3">
                <label for="toDate" class="form-label">To Date</label>
                <input type="date" id="toDate" name="toDate"
                       value="<%=new SimpleDateFormat("yyyy-MM-dd").format(new Date())%>"
                       class="form-control" required>
            </div>
            <div class="col-md-4 d-flex align-items-end">
                <button type="submit" class="btn btn-primary w-100">
                    <i class="fas fa-search me-1"></i> Generate Report
                </button>
            </div>
        </form>
    </div>
</body>
</html>
