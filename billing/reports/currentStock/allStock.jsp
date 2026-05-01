<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*,java.text.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>All Stock Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .category-row {
            cursor: pointer;
            user-select: none;
        }
        .category-row:hover {
            background-color: #f5f5f5 !important;
        }
        .category-row td:nth-child(2)::before {
            content: "▶ ";
            display: inline-block;
            width: 20px;
        }
        .category-row.expanded td:nth-child(2)::before {
            content: "▼ ";
        }
        .item-row {
            display: none;
            background-color: #f9f9f9;
        }
        .item-row.show {
            display: table-row;
        }
        .item-row td:nth-child(2) {
            padding-left: 50px !important;
            font-size: 0.9rem;
        }
        .item-row td:nth-child(2) {
            color: #333;
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <p><strong>All Stock Report (Category Wise)</strong></p>

        <!-- Filters -->
        <div class="mb-3 no-print row g-2">
            <div class="col-md-9"></div>
            <div class="col-md-3 text-end">
                <a href="<%=request.getContextPath()%>/reports/currentStock/page1.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
                <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
                <button class="btn btn-success btn-sm" onclick="exportTableToExcel('stockTable', 'All_Stock_Report')">📊 Export</button>
            </div>
        </div>

        <div class="table-responsive">
            <table id="stockTable" class="table table-hover mt-3" style="font-size: 12px;">
                <thead>
                    <tr style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); border-bottom: 2px solid #e2e8f0;">
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">S.No</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">Category</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">Items Count</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">Total Stock</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Total Cost Value</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Total MRP Value</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Vector allStocks = prod.getCurrentStockDetailsWithCategory();
                    Map<String, Map<String, Object>> categoryData = new LinkedHashMap<>();
                    
                    // Group data by category
                    if (allStocks != null && allStocks.size() > 0) {
                        for (int i = 0; i < allStocks.size(); i++) {
                            Vector row = (Vector) allStocks.get(i);
                            String categoryId = row.size() > 10 ? row.elementAt(10).toString() : "0";
                            String categoryName = row.size() > 11 ? row.elementAt(11).toString() : "Uncategorized";
                            
                            if (categoryName.isEmpty()) {
                                categoryName = "Uncategorized";
                            }
                            
                            Map<String, Object> catMap = categoryData.getOrDefault(categoryId, new LinkedHashMap<>());
                            
                            // Initialize category data if first time
                            if (!categoryData.containsKey(categoryId)) {
                                catMap.put("name", categoryName);
                                catMap.put("items", new Vector());
                                catMap.put("totalCost", 0.0);
                                catMap.put("totalMRP", 0.0);
                                catMap.put("totalStock", 0.0);
                                catMap.put("itemCount", 0);
                            }
                            
                            // Parse numeric values
                            double stock = Double.parseDouble(row.elementAt(2).toString());
                            double costValue = Double.parseDouble(row.elementAt(7).toString().replace(",", ""));
                            double mrpValue = Double.parseDouble(row.elementAt(8).toString().replace(",", ""));
                            
                            // Update totals
                            double currentCost = (Double) catMap.get("totalCost");
                            double currentMRP = (Double) catMap.get("totalMRP");
                            double currentStock = (Double) catMap.get("totalStock");
                            int itemCount = (Integer) catMap.get("itemCount");
                            
                            catMap.put("totalCost", currentCost + costValue);
                            catMap.put("totalMRP", currentMRP + mrpValue);
                            catMap.put("totalStock", currentStock + stock);
                            catMap.put("itemCount", itemCount + 1);
                            
                            // Add item to the list
                            Vector items = (Vector) catMap.get("items");
                            items.add(row);
                            
                            categoryData.put(categoryId, catMap);
                        }
                    }
                    
                    // Display category rows
                    double grandTotalCost = 0.0;
                    double grandTotalMRP = 0.0;
                    int categoryRowIndex = 0;
                    
                    for (Map.Entry<String, Map<String, Object>> entry : categoryData.entrySet()) {
                        String catId = entry.getKey();
                        Map<String, Object> catData = entry.getValue();
                        String catName = (String) catData.get("name");
                        Vector items = (Vector) catData.get("items");
                        double catTotalCost = (Double) catData.get("totalCost");
                        double catTotalMRP = (Double) catData.get("totalMRP");
                        double catTotalStock = (Double) catData.get("totalStock");
                        int itemCount = (Integer) catData.get("itemCount");
                        
                        grandTotalCost += catTotalCost;
                        grandTotalMRP += catTotalMRP;
                        
                        String categoryRowId = "category_" + categoryRowIndex;
                    %>
                    <tr class="category-row" onclick="toggleCategory('<%=categoryRowId%>')" style="background-color: #e8f4f8; font-weight: 600;">
                        <td style="padding: 0.4rem; text-align: center;"><%=categoryRowIndex + 1%></td>
                        <td style="padding: 0.4rem; text-align: center;"><%=catName%></td>
                        <td style="padding: 0.4rem; text-align: center;"><%=itemCount%></td>
                        <td style="padding: 0.4rem; text-align: center;"><%=String.format("%.2f", catTotalStock)%></td>
                        <td style="padding: 0.4rem; text-align: right;">₹<%=String.format("%.3f", catTotalCost)%></td>
                        <td style="padding: 0.4rem; text-align: right;">₹<%=String.format("%.3f", catTotalMRP)%></td>
                    </tr>
                    <%
                    // Display individual items for this category
                    for (int j = 0; j < items.size(); j++) {
                        Vector itemRow = (Vector) items.get(j);
                        double itemStock = Double.parseDouble(itemRow.elementAt(2).toString());
                        double itemCost = Double.parseDouble(itemRow.elementAt(3).toString().replace(",", ""));
                        double itemMRP = Double.parseDouble(itemRow.elementAt(4).toString().replace(",", ""));
                        double itemTotalCost = Double.parseDouble(itemRow.elementAt(7).toString().replace(",", ""));
                        double itemTotalMRP = Double.parseDouble(itemRow.elementAt(8).toString().replace(",", ""));
                    %>
                    <tr class="item-row" data-category="<%=categoryRowId%>">
                        <td style="padding: 0.4rem; text-align: center;"><%=j + 1%></td>
                        <td style="padding: 0.4rem;">
                            <%=itemRow.elementAt(0)%> (<%=itemRow.elementAt(1)%>)
                        </td>
                        <td style="text-align: center; padding: 0.4rem;">-</td>
                        <td style="text-align: center; padding: 0.4rem;"><%=String.format("%.2f", itemStock)%></td>
                        <td style="text-align: right; padding: 0.4rem;">₹<%=String.format("%.3f", itemTotalCost)%></td>
                        <td style="text-align: right; padding: 0.4rem;">₹<%=String.format("%.3f", itemTotalMRP)%></td>
                    </tr>
                    <%
                    }
                    categoryRowIndex++;
                    }
                    
                    if (categoryData.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="6" class="text-center text-muted">
                            <strong>No stock data found.</strong><br>
                            There are no products with current stock available.
                        </td>
                    </tr>
                    <%
                    } else {
                    %>
                    <tr class="table-secondary" style="font-weight: bold;">
                        <td style="padding: 0.4rem; text-align: center;"></td>
                        <td style="padding: 0.4rem; text-align: center;">TOTAL</td>
                        <td style="padding: 0.4rem; text-align: center;"><%=categoryData.size()%></td>
                        <td style="padding: 0.4rem; text-align: center;">-</td>
                        <td style="padding: 0.4rem; text-align: right;">₹<%=String.format("%.3f", grandTotalCost)%></td>
                        <td style="padding: 0.4rem; text-align: right;">₹<%=String.format("%.3f", grandTotalMRP)%></td>
                    </tr>
                    <%
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- JS Functions -->
    <script>
        // Toggle category expansion
        function toggleCategory(categoryId) {
            const categoryRows = document.querySelectorAll(`[data-category="${categoryId}"]`);
            const categoryHeader = document.querySelector(`[onclick="toggleCategory('${categoryId}')"]`);
            
            categoryRows.forEach(row => {
                row.classList.toggle('show');
            });
            
            categoryHeader.classList.toggle('expanded');
        }

        // Expand all categories
        function expandAllCategories() {
            document.querySelectorAll('.category-row').forEach(row => {
                const categoryId = row.getAttribute('data-onclick')?.match(/'([^']+)'/)?.[1];
                if (categoryId && !row.classList.contains('expanded')) {
                    row.click();
                }
            });
        }

        // Collapse all categories
        function collapseAllCategories() {
            document.querySelectorAll('.category-row.expanded').forEach(row => {
                row.click();
            });
        }

        // Print function
        function printReport() {
            var printArea = document.createElement('div');
            printArea.id = 'printArea';
            
            fetch('<%=request.getContextPath()%>/printHeader.jsp')
                .then(response => response.text())
                .then(headerHtml => {
                    printArea.innerHTML = headerHtml;
                    
                    var tableContainer = document.querySelector('.container');
                    var tableClone = tableContainer.cloneNode(true);
                    
                    var buttons = tableClone.querySelector('.no-print');
                    if(buttons) buttons.remove();
                    
                    // Expand all items for print
                    tableClone.querySelectorAll('.item-row').forEach(row => {
                        row.classList.add('show');
                    });
                    
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

        // Export to Excel function
        function exportTableToExcel(tableID, filename = '') {
            var table = document.getElementById(tableID);
            var tableHTML = '<table>';
            
            // Add headers
            tableHTML += '<tr>';
            table.querySelectorAll('thead th').forEach(th => {
                tableHTML += '<td style="background: #333; color: white; font-weight: bold;">' + th.textContent + '</td>';
            });
            tableHTML += '</tr>';
            
            // Add all visible rows (both category and item rows)
            table.querySelectorAll('tbody tr').forEach(tr => {
                if (tr.style.display !== 'none') {
                    tableHTML += '<tr>';
                    tr.querySelectorAll('td').forEach(td => {
                        tableHTML += '<td>' + td.textContent.replace(/▶|▼/g, '') + '</td>';
                    });
                    tableHTML += '</tr>';
                }
            });
            
            tableHTML += '</table>';

            filename = filename ? filename + '.xls' : 'all_stock_report.xls';

            var downloadLink = document.createElement("a");
            document.body.appendChild(downloadLink);

            if (navigator.msSaveOrOpenBlob) {
                var blob = new Blob(['\ufeff', tableHTML], { type: 'application/vnd.ms-excel' });
                navigator.msSaveOrOpenBlob(blob, filename);
            } else {
                downloadLink.href = 'data:application/vnd.ms-excel,' + encodeURIComponent(tableHTML);
                downloadLink.download = filename;
                downloadLink.click();
            }
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
            .item-row {
                display: table-row !important;
            }
        }
    </style>
</body>
</html>
