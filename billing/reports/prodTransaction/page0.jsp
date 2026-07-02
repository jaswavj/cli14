<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    int productId = 0;
    if(request.getParameter("productId") != null && !request.getParameter("productId").isEmpty()) {
        productId = Integer.parseInt(request.getParameter("productId"));
    }

    
%>
<!DOCTYPE html>
<html lang="en">
<head>
    
    <meta charset="UTF-8">
    <title>Collection Report</title>
<%@ include file="/assets/common/head.jsp" %>
    <style>
        .table td, .table th {
            vertical-align: middle;
        }
        .btn-edit, .btn-delete {
            margin: 0 2px;
        }

    </style>
</head>
<body >
<!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4 ">
<div class="d-flex justify-content-between align-items-center mb-3">
    <p class="mb-0"><strong>Collection Report From:</strong> <%= fromDate %> - <%= toDate %></p>
    <div class="no-print">
        <a href="<%=contextPath%>/reports/prodTransaction/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
        <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
        <button class="btn btn-success btn-sm" onclick="exportTableToExcel('printTable', 'Product_Transaction_Report')">📊 Export to Excel</button>
    </div>
</div>

<div class="table-responsive">
<table id="printTable" class="table table-hover mt-3" style="font-size: 12px;">
    <thead>
        <tr style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); border-bottom: 2px solid #e2e8f0;">
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">S.No</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;"><%=head3%> Name</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;"><%=head3%> Code</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">Stock in</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">Stock out</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">Stock now</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Notes</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Date/Time</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Stock Adj</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">User</th>
        </tr>
    </thead>
    <tbody>
        <%
        Vector vec = bill.getStockAdj(fromDate,toDate,productId);
        String color ="";
        String colors ="";
        String adjColors ="";
        String adjText = "-";
        for(int i=0;i< vec.size();i++)
		{
            Vector row		= (Vector)vec.elementAt(i);
            double addedStock = Double.parseDouble(row.elementAt(1).toString());  
            double removedStock = Double.parseDouble(row.elementAt(2).toString());
            int adjType = Integer.parseInt(row.elementAt(7).toString());

           
            if(addedStock>0){       
                color=" style='background-color: #d4edda;'"; // Green for added stock
            }
            else{
                color="";
            }
            if(removedStock>0){       
                colors=" style='background-color: #f8d7da;'"; // Green for added stock
            }
            else{
                colors="";
            }

        if(adjType == 1){       
            adjColors = " style='background-color: #d4edda;'"; 
            adjText   = "Added";
        }
        else if(adjType == 2){
            adjColors = " style='background-color: #f8d7da;'";
            adjText   = "Removed";
        }
        else{
            adjColors = "";
            adjText   = "-";
        }

           


        %>
        <tr>
            <td><%=i+1%></td>
            <td ><%=row.elementAt(0)%></td>
            <td><%= row.size() > 10 && row.elementAt(10) != null ? row.elementAt(10) : "" %></td>
            <td <%=color%>><%=row.elementAt(1)%> <%=(row.size() > 9 && row.elementAt(9) != null && !row.elementAt(9).toString().isEmpty()) ? row.elementAt(9) : (row.size() > 8 && row.elementAt(8) != null ? row.elementAt(8) : "")%></td>
            <td <%=colors%>><%=row.elementAt(2)%> <%=(row.size() > 9 && row.elementAt(9) != null && !row.elementAt(9).toString().isEmpty()) ? row.elementAt(9) : (row.size() > 8 && row.elementAt(8) != null ? row.elementAt(8) : "")%></td>
            <td><%=row.elementAt(3)%> <%=(row.size() > 9 && row.elementAt(9) != null && !row.elementAt(9).toString().isEmpty()) ? row.elementAt(9) : (row.size() > 8 && row.elementAt(8) != null ? row.elementAt(8) : "")%></td>
            <td><%=row.elementAt(4)%></td>
            <td><%=row.elementAt(5)%></td>
            <td <%=adjColors%> ><%=adjText%></td> <!-- Adjustment type -->
            <td><%=row.elementAt(6)%></td>
            
            
        </tr>
        <%
    
}
        %>

    </tbody>
</table>
</div>
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
    #printArea .table-responsive {
        overflow: visible !important;
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
