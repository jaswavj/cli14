<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
String contextPath = request.getContextPath();
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    
    String modeParam = request.getParameter("mode");
    int modeId = 0;
    if (modeParam != null && !modeParam.isEmpty()) {
        modeId = Integer.parseInt(modeParam);
    }
    
    String userParam = request.getParameter("userId");
    int userId = 0;
    if (userParam != null && !userParam.isEmpty()) {
        userId = Integer.parseInt(userParam);
    }
    
    String typeParam = request.getParameter("type");
    int typeId = 0;
    if (typeParam != null && !typeParam.isEmpty()) {
        typeId = Integer.parseInt(typeParam);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    
    <meta charset="UTF-8">
    <title>Collection Report</title>
<jsp:include page="/assets/common/head.jsp" />




</head>
<body > 

    <jsp:include page="/assets/navbar/navbar.jsp" />



<div class="container mt-4 ">
<p ><strong>Collection Report From:</strong> <%= fromDate %> - <%= toDate %></p>
    <div class="mb-3 no-print">
        <a href="<%=contextPath%>/reports/sales/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
        <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
        <button class="btn btn-success btn-sm" onclick="exportTableToExcel('printTable', 'Sales_Report')">📊 Export to Excel</button>
    </div>
<div class="table-responsive">
<table id="printTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; font-size: 12px;">
    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
        <tr>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">S.No</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Bill No</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Customer Name</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Total</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Disc</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Payable</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Paid</th>
            <% if(modeId !=2) { %><th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">cash</th><%}%>
            <% if(modeId !=1) { %><th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Bank</th><% } %>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Qty</th>
           <!--<% if(modeId !=1) { %><th>Mode</th><% } %>-->
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Date</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Time</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Biller</th>
            
        </tr>
    </thead>
    <tbody>
        <%
        Vector vec = bill.getsalesCashBankReport(fromDate,toDate,modeId,typeId,userId);
        double finTotal=0.0;
        double finDiscount=0.0;
        double finPayable=0.0; 
        double finPaid=0.0;
        double finCash=0.0;
        double finBank=0.0;
        double finQty=0.0;
        for(int i=0;i< vec.size();i++)
		{
            Vector row		= (Vector)vec.elementAt(i);
            int billId		= Integer.parseInt(row.elementAt(8).toString());  
            double totalAmt   = Double.parseDouble(row.elementAt(1).toString());
            double discount    = Double.parseDouble(row.elementAt(2).toString());
            double payable     = Double.parseDouble(row.elementAt(3).toString());
            double paid        = Double.parseDouble(row.elementAt(4).toString());
            double cash       = Double.parseDouble(row.elementAt(10).toString());
            double bank       = Double.parseDouble(row.elementAt(11).toString());
            double billQty    = row.size() > 16 && row.elementAt(16) != null ? Double.parseDouble(row.elementAt(16).toString()) : 0.0;
            String billNo    = row.elementAt(0).toString();
            finTotal+=totalAmt;
            finDiscount+=discount;  
            finPayable+=payable;
            finPaid+=paid;
            finCash+=cash;
            finBank+=bank;
            finQty+=billQty;
            String cusPhone = row.elementAt(15).toString();
            


        %>
        <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
                <a href="<%=contextPath%>/billing/print.jsp?billNo=<%=billNo%>" target="_blank" name="billNo" class="btn btn-sm btn-edit" style="background-color:hsl(222, 86%, 89%); color:#000000;"><%=row.elementAt(0)%></a>
                <button onclick="directPrint('<%=billNo%>')" class="btn btn-sm ms-1" title="Thermal Print" style="background-color:#10b981; color:#fff; padding: 0.25rem 0.5rem; font-size: 0.85rem;">
                    <i class="fas fa-receipt"></i>
                </button>
            </td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><a href="https://wa.me/<%=cusPhone%>" target="_blank" style="color: #25D366; text-decoration: none; font-weight: 500;"><%=row.elementAt(14)%></a></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(1)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(2)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(3)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(4)%></td>
            <% if(modeId !=2) { %><td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(10)%></td><%}%>
            <% if(modeId !=1) { %><td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(11)%></td><%}%>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.size() > 16 && row.elementAt(16) != null ? row.elementAt(16) : "0" %></td>
            <!--<% if(modeId !=1) { %><td><%=row.elementAt(9)%></td><%}%>-->
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(5)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(6)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(7)%></td>
            
        </tr>
        <%
    
}
        %>
        <tr style="background: #f7fafc; border-top: 2px solid #4a5568;">
            <td colspan="3" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong>Grand Total</strong></td>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.3f", finTotal)%></strong></td>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.3f", finDiscount)%></strong></td>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.3f", finPayable)%></strong></td>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.3f", finPaid)%></strong></td>
            <% if(modeId !=2) { %><td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.3f", finCash)%></strong></td><%}%>
            <% if(modeId !=1) { %><td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.3f", finBank)%></strong></td><%}%>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.3f", finQty)%></strong></td>
            <td style="padding: 0.4rem; border: none;"></td>
            <td style="padding: 0.4rem; border: none;"></td>
            <td style="padding: 0.4rem; border: none;"></td>
            
            <!--td></td-->
        </tr>
    </tbody>
</table>
</div>
<p><strong>Due Collection Report From:</strong> <%= fromDate %> - <%= toDate %></p>

<div class="table-responsive">
<table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; font-size: 12px;">
   <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
    <tr>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">S.No</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Bill No</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Customer Name</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Balance</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Cash Paid</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Bank Paid</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Mode</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Bank Option</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Date</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Time</th>
        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Biller</th>
    </tr>
</thead>
<tbody>
<%
    Vector dueDetails = bill.getDuePaidList(fromDate, toDate, userId);
    double totalCashPaid = 0.0;
    double totalBankPaid = 0.0;
    for (int j = 0; j < dueDetails.size(); j++) {
        Vector row = (Vector) dueDetails.elementAt(j);

        String cusName     = row.elementAt(0).toString();   // Customer
        String mode        = row.elementAt(4).toString();   // Cash / Bank
        String bank        = row.elementAt(5).toString();   // UPI / NEFT / etc.
        String date        = row.elementAt(6).toString();   // Date
        String time        = row.elementAt(7).toString();   // Time
        String userName    = row.elementAt(8).toString();   // Biller
        String billDisplay = row.elementAt(9).toString();   // Bill No

        double balance  = Double.parseDouble(row.elementAt(1).toString());
        double cashPaid = Double.parseDouble(row.elementAt(2).toString());
        double bankPaid = Double.parseDouble(row.elementAt(3).toString());
        int billId      = Integer.parseInt(row.elementAt(10).toString());

        totalCashPaid += cashPaid;
        totalBankPaid += bankPaid;
        double totalPaid = cashPaid + bankPaid;
%>
    <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= j + 1 %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= billDisplay %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= cusName %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= balance %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= cashPaid %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= bankPaid %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= mode %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= bank %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= date %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= time %></td>
        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= userName %></td>
    </tr>
<%
    } // end for
%>
    <tr class="table-secondary">
        <td colspan="4"><strong>Grand Total</strong></td>
        <td><strong><%= String.format("%.3f", totalCashPaid) %></strong></td>
        <td><strong><%= String.format("%.3f", totalBankPaid) %></strong></td>
        <td colspan="5"></td>
    </tr>
</tbody>




</table>
</div>
</div>

<style>
@keyframes slideIn {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

@keyframes slideOut {
    from {
        transform: translateX(0);
        opacity: 1;
    }
    to {
        transform: translateX(100%);
        opacity: 0;
    }
}

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
        table-layout: auto !important;
    }
    #printArea table th,
    #printArea table td {
        padding: 1px 2px !important;
        font-size: 8px !important;
        word-wrap: break-word;
        overflow-wrap: break-word;
        max-width: 80px;
    }
}
</style>

<script>
// Toast notification function
function showToast(message, type = 'success') {
    const toastColors = {
        success: '#10b981',
        error: '#ef4444',
        info: '#3b82f6'
    };
    
    const toast = document.createElement('div');
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        background-color: ${toastColors[type] || toastColors.success};
        color: white;
        border-radius: 6px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        animation: slideIn 0.3s ease-out;
        font-size: 14px;
    `;
    toast.textContent = message;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => document.body.removeChild(toast), 300);
    }, 3000);
}

// Direct thermal print function
function directPrint(billNo) {
    fetch('<%=contextPath%>/billing/directPrint.jsp?billNo=' + billNo, {
        credentials: 'same-origin'
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                if (data.type === 'a4') {
                    // A4 format selected in company settings - open print.jsp
                    window.open('<%=contextPath%>/billing/print.jsp?billNo=' + encodeURIComponent(data.billNo), '_blank');
                    showToast('✓ Opening A4 print preview', 'info');
                } else if (data.type === 'printed') {
                    showToast('✓ Receipt printed successfully!', 'success');
                } else if (data.type === 'txt') {
                    showToast('ℹ No printer found. Receipt saved as TXT file', 'info');
                    alert('Receipt saved to: ' + data.txtPath + '\n\nFile: ' + data.txtFile + '\n\nYou can open this file with Notepad to see how the receipt looks.');
                }
            } else {
                showToast('✗ Print failed: ' + data.message, 'error');
            }
        })
        .catch(error => {
            console.error('Print error:', error);
            showToast('✗ Print failed: ' + error.message, 'error');
        });
}

function printReport() {
    // Create print area
    var printArea = document.createElement('div');
    printArea.id = 'printArea';
    
    // Fetch and add header
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            printArea.innerHTML = headerHtml;
            
            // Add the table content
            var tableContainer = document.querySelector('.container');
            var tableClone = tableContainer.cloneNode(true);
            
            // Remove the button div from clone
            var buttons = tableClone.querySelector('.no-print');
            if(buttons) buttons.remove();
            
            printArea.appendChild(tableClone);
            
            // Append to body and print
            document.body.appendChild(printArea);
            window.print();
            
            // Remove after print
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
    
    // Create a copy of the table
    var tableClone = table.cloneNode(true);
    
    // Create HTML content with proper Excel format
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
