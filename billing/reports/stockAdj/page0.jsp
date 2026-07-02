<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*,java.sql.*,java.text.*"%>
<jsp:useBean id="prod" class="product.productBean" />

<%
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    int productId = 0;
    if(request.getParameter("productId") != null && !request.getParameter("productId").isEmpty()) {
        productId = Integer.parseInt(request.getParameter("productId"));
    }
    
    int stockType = 0;
    if(request.getParameter("stockType") != null && !request.getParameter("stockType").isEmpty()) {
        stockType = Integer.parseInt(request.getParameter("stockType"));
    }

    if(fromDate == null) fromDate = "";
    if(toDate == null) toDate = "";

    
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>Stock Adjustment Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .navbar { background-color: #4e73df; }
        .navbar-brand { color: #fff !important; }
        .table td, .table th { vertical-align: middle; }
        .badge-add { background: #28a745; color: white; }
        .badge-remove { background: #dc3545; color: white; }
        
        @media (max-width: 768px) {
            .d-flex.justify-content-between {
                flex-direction: column;
                gap: 1rem;
            }
            .no-print {
                display: flex;
                flex-direction: column;
                gap: 0.5rem;
            }
            .no-print a, .no-print button {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h4 class="mb-1">Stock Adjustment Report</h4>
            <p class="mb-0"><strong>From:</strong> <%= fromDate %> &nbsp;&nbsp; <strong>To:</strong> <%= toDate %></p>
        </div>
        <div class="no-print">
            <a href="<%=contextPath%>/reports/stockAdj/page.jsp" class="btn btn-secondary me-2">⬅ Back</a>
            <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
            <button class="btn btn-success btn-sm" onclick="exportTableToExcel('printTable', 'Stock_Adjustment_Report')">📊 Export to Excel</button>
        </div>
    </div>

    <div class="table-responsive">
    <table id="printTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; min-width: 800px;">
        <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
            <tr>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">SI.NO</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;"><%=head3%></th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;"><%=head3%> Code</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Action</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Stock</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Date</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Time</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">User</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Notes</th>
            </tr>
        </thead>
        <tbody>
        <%
    Vector vec = prod.getStockAdjReport(fromDate, toDate, productId, stockType);

    for (int i = 0; i < vec.size(); i++) {
        Vector row = (Vector) vec.elementAt(i);
%>
<tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1 %></td>  <!-- id -->
    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.get(2) %></td>  <!-- product_name -->
    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.size() > 12 && row.get(12) != null ? row.get(12) : "" %></td>  <!-- product_code -->

    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
        <%
            String stockTypeStr = row.get(4).toString();
            String badgeClass = "badge badge-remove";
            String label = "Removed";
            if("1".equals(stockTypeStr)) {
                badgeClass = "badge badge-add";
                label = "Added";
            } else if("3".equals(stockTypeStr)) {
                badgeClass = "badge badge-warning text-dark";
                label = "Damage";
            } else if("4".equals(stockTypeStr)) {
                badgeClass = "badge badge-info";
                label = "Internal Use";
            }
        %>
        <span class="<%= badgeClass %>">
            <%= label %>
        </span>
    </td>
    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.get(5) %><%=(row.size() > 11 && row.get(11) != null && !row.get(11).toString().isEmpty()) ? " " + row.get(11) : ""%></td>  <!-- stock -->
    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.get(6) %></td>  <!-- date -->
    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.get(7) %></td>  <!-- time -->
    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.get(10) %></td> <!-- user_name -->
    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.get(8) %></td>  <!-- notes -->
</tr>
<%
    }
%>

        </tbody>
    </div>
    </table>
</div>

<script>
function printReport(title) {
    var printContent = document.getElementById('printTable').outerHTML;
    var originalContent = document.body.innerHTML;

    document.body.innerHTML = '<html><head><title>' + title + '</title></head><body>' +
        '<h2>' + title + '</h2>' +
        '<p>Period: <%= fromDate %> to <%= toDate %></p>' +
        printContent +
        '</body></html>';

    window.print();
    document.body.innerHTML = originalContent;
}
</script>

<style>
@media print {
    @page {
        margin: 0.3cm;
        size: portrait;
    }
    body {
        margin: 0;
        padding: 0;
    }
    .no-print {
        display: none !important;
    }
    body * {
        visibility: hidden;
    }
    #printArea, #printArea * {
        visibility: visible;
    }
    #printArea {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        margin: 0;
        padding: 0;
    }
    #printArea .container {
        max-width: 100% !important;
        margin: 0 !important;
        padding: 0 5px !important;
    }
    #printArea table {
        width: 100% !important;
        font-size: 8px !important;
    }
    #printArea table th,
    #printArea table td {
        padding: 1px 2px !important;
        font-size: 8px !important;
        word-wrap: break-word;
        max-width: 80px;
    }
}
</style>

<script>
function printReport() {
    var printArea = document.createElement('div');
    printArea.id = 'printArea';
    
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            printArea.innerHTML = headerHtml;
            
            var tableContainer = document.querySelector('.container');
            var tableClone = tableContainer.cloneNode(true);
            
            var buttons = tableClone.querySelector('.no-print');
            if(buttons) buttons.remove();
            
            printArea.appendChild(tableClone);
            
            document.body.appendChild(printArea);
            window.print();
            
            document.body.removeChild(printArea);
        })
        .catch(error => {
            console.error('Error loading print header:', error);
            window.print();
        });
}

function exportTableToExcel(tableID, filename = ''){
    var table = document.getElementById(tableID);
    if (!table) {
        alert('Table not found!');
        return;
    }
    
    var tableClone = table.cloneNode(true);
    
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">';
    html += '<head><meta charset="UTF-8">';
    html += '<style>table {border-collapse: collapse;} td, th {border: 1px solid black; padding: 5px;}</style>';
    html += '</head><body>';
    html += '<table border="1">' + tableClone.innerHTML + '</table>';
    html += '</body></html>';
    
    filename = filename ? filename + '.xls' : 'excel_data.xls';
    
    var blob = new Blob(['\ufeff', html], {
        type: 'application/vnd.ms-excel'
    });
    
    var downloadLink = document.createElement("a");
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.download = filename;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}
</script>

</body>
</html>
