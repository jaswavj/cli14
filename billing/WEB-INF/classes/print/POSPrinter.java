package print;

import javax.print.*;
import javax.print.attribute.*;
import javax.print.attribute.standard.*;
import java.io.*;
import java.util.*;
import java.text.DecimalFormat;
import billing.billingBean;
import user.userBean;

// iText PDF imports (itextpdf-5.2.0.jar)
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.pdf.draw.LineSeparator;

/**
 * ESC/POS Direct Thermal Printer Utility
 * Sends raw ESC/POS commands directly to the thermal printer
 * bypassing the browser print dialog. No empty page issue.
 */
public class POSPrinter {

    // ESC/POS Command Constants (using byte arrays for better control)
    private static final byte[] ESC = {0x1B};
    private static final byte[] GS = {0x1D};
    private static final byte[] INIT = {0x1B, 0x40};                    // Initialize printer
    private static final byte[] BOLD_ON = {0x1B, 0x45, 0x01};           // Bold on
    private static final byte[] BOLD_OFF = {0x1B, 0x45, 0x00};          // Bold off
    private static final byte[] ALIGN_CENTER = {0x1B, 0x61, 0x01};      // Center align
    private static final byte[] ALIGN_LEFT = {0x1B, 0x61, 0x00};        // Left align
    private static final byte[] ALIGN_RIGHT = {0x1B, 0x61, 0x02};       // Right align
    private static final byte[] FONT_NORMAL = {0x1B, 0x21, 0x00};       // Normal font
    private static final byte[] FONT_DOUBLE_H = {0x1B, 0x21, 0x10};     // Double height
    private static final byte[] FONT_B = {0x1B, 0x4D, 0x01};            // Font B (small/compact)
    private static final byte[] FONT_A = {0x1B, 0x4D, 0x00};            // Font A (default)
    private static final byte[] CUT_PAPER = {0x1D, 0x56, 0x01};         // Partial cut
    private static final byte[] FEED_2_LINES = {0x1B, 0x64, 0x02};      // Feed 2 lines
    private static final byte[] FEED_3_LINES = {0x1B, 0x64, 0x03};      // Feed 3 lines
    
    // Receipt width - configurable for different printer sizes
    private static int RECEIPT_WIDTH = 48; // Default: 80mm printer (48 chars)
    private static final int RECEIPT_WIDTH_58MM = 32; // 58mm printer
    private static final int RECEIPT_WIDTH_80MM = 48; // 80mm printer
    
    private static final DecimalFormat df = new DecimalFormat("0.00");
    
    // Base path for the web application (set from JSP using setApplicationPath)
    private static String applicationBasePath = null;
    
    // TXT output folder when no printer is available (relative to application)
    private static String getTxtOutputDir() {
        if (applicationBasePath != null) {
            return applicationBasePath + File.separator + "bills";
        }
        // Fallback to current directory + bills (for local development)
        return "bills";
    }
    
    /**
     * Set the application base path from JSP/Servlet context
     * Call this from JSP: POSPrinter.setApplicationPath(application.getRealPath("/"));
     */
    public static void setApplicationPath(String basePath) {
        applicationBasePath = basePath;
    }
    
    // Printer name from config (null = use default printer)
    // NOT cached statically - always read fresh from DB so changes take effect immediately
    private static String configuredPrinterName = null;

    /**
     * Load printer name from company_details table in database
     * Also detect printer width (58mm vs 80mm)
     */
    private static String getConfiguredPrinterName() {
        // Always re-read from DB (do not cache - admin can change printer name at any time)
        configuredPrinterName = null;
        try {
            userBean uBean = new userBean();
            Vector companyDetails = uBean.getCompanyDetails();
            if (companyDetails != null && companyDetails.size() > 5) {
                String printerName = (String) companyDetails.elementAt(5);
                if (printerName != null && !printerName.trim().isEmpty()) {
                    configuredPrinterName = printerName.trim();
                    // Auto-detect width: if printer name contains "58", use 32 chars
                    if (printerName.contains("58")) {
                        RECEIPT_WIDTH = RECEIPT_WIDTH_58MM;
                    } else {
                        RECEIPT_WIDTH = RECEIPT_WIDTH_80MM;
                    }
                }
            }
        } catch (Exception e) {
            // Ignore, use default printer
            e.printStackTrace();
        }
        return configuredPrinterName;
    }

    /**
     * Find the print service by configured name.
     * Returns null if no printer is configured or no matching printer is found (triggers TXT fallback).
     * Does NOT fall back to OS default printer (e.g. "Microsoft Print to PDF") since that
     * would silently "succeed" without producing a physical receipt.
     */
    private static PrintService findPrintService() {
        String printerName = getConfiguredPrinterName();
        
        if (printerName == null || printerName.isEmpty()) {
            // No printer configured in company_details - return null to trigger TXT fallback
            return null;
        }
        
        PrintService[] services = PrintServiceLookup.lookupPrintServices(null, null);
        for (PrintService service : services) {
            if (service.getName().toLowerCase().contains(printerName.toLowerCase())) {
                return service;
            }
        }
        // Configured printer not found in system - return null to trigger TXT fallback
        return null;
    }

    /**
     * List all available printers on the system
     */
    public static java.util.List<String> getAvailablePrinters() {
        java.util.List<String> printers = new ArrayList<String>();
        PrintService[] services = PrintServiceLookup.lookupPrintServices(null, null);
        for (PrintService service : services) {
            printers.add(service.getName());
        }
        return printers;
    }

    /**
     * Print result object - indicates whether printed or saved as TXT
     */
   
    public static class PrintResult {
        public boolean printed;     // true if sent to printer
        public boolean txtSaved;    // true if saved as TXT
        public String txtPath;      // path to TXT file (if saved)
        public String message;
        
        public PrintResult(boolean printed, boolean txtSaved, String txtPath, String message) {
            this.printed = printed;
            this.txtSaved = txtSaved;
            this.txtPath = txtPath;
            this.message = message;
        }
    }

    /**
     * Print a receipt for the given bill number.
     * If no printer is found, generates a TXT to D:\bills\ folder.
     * @param billNo The bill number to print
     * @return PrintResult with status and details
     * @throws Exception if bill data cannot be fetched
     */
    public static PrintResult printReceipt(String billNo) throws Exception {
        PrintService service = findPrintService();
        
        if (service != null) {
            // Direct ESC/POS print using byte array
            byte[] receiptData = buildReceiptData(billNo);
            DocFlavor flavor = DocFlavor.BYTE_ARRAY.AUTOSENSE;
            Doc doc = new SimpleDoc(receiptData, flavor, null);
            DocPrintJob job = service.createPrintJob();
            job.print(doc, null);
            return new PrintResult(true, false, null, "Printed to: " + service.getName());
        } else {
            // No printer found - generate TXT fallback
            String txtPath = generateTxtReceipt(billNo);
            return new PrintResult(false, true, txtPath, "No printer found. TXT saved to: " + txtPath);
        }
    }

    /**
     * Generate a plain text receipt and save to D:\bills\ folder
     * @param billNo The bill number
     * @return The full path to the saved TXT file
     */
    public static String generateTxtReceipt(String billNo) throws Exception {
        // Create output directory
        File dir = new File(getTxtOutputDir());
        if (!dir.exists()) dir.mkdirs();
        
        // Sanitize bill number for filename
        String safeBillNo = billNo.replace("/", "-").replace("\\", "-").replace(" ", "_");
        String fileName = "Bill_" + safeBillNo + ".txt";
        String filePath = getTxtOutputDir() + File.separator + fileName;
        
        // Build plain text receipt (without ESC/POS commands)
        String receiptText = buildPlainTextReceipt(billNo);
        
        // Write to file
        FileWriter writer = new FileWriter(filePath);
        writer.write(receiptText);
        writer.close();
        
        return filePath;
    }

    /**
     * Generate a PDF receipt and save to D:\bills\ folder
     * @param billNo The bill number
     * @return The full path to the saved PDF file
     */
    public static String generatePdfReceipt(String billNo) throws Exception {
        billingBean bill = new billingBean();
        userBean uBean = new userBean();
        
        // Create output directory
        File dir = new File(getTxtOutputDir());
        if (!dir.exists()) dir.mkdirs();
        
        // Sanitize bill number for filename
        String safeBillNo = billNo.replace("/", "-").replace("\\", "-").replace(" ", "_");
        String fileName = "Bill_" + safeBillNo + ".pdf";
        String filePath = getTxtOutputDir() + File.separator + fileName;
        
        // Page size: 80mm width, long auto-height (use a tall page)
        float mmToPoint = 2.83465f;
        float pageWidth = 80 * mmToPoint;  // 80mm
        Rectangle pageSize = new Rectangle(pageWidth, 2000); // tall page, will trim
        pageSize.setBackgroundColor(BaseColor.WHITE);
        
        Document document = new Document(pageSize, 10, 10, 10, 10);
        PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream(filePath));
        document.open();
        
        // Fonts
        Font fontTitle = new Font(Font.FontFamily.COURIER, 14, Font.BOLD);
        Font fontNormal = new Font(Font.FontFamily.COURIER, 9);
        Font fontBold = new Font(Font.FontFamily.COURIER, 9, Font.BOLD);
        Font fontSmall = new Font(Font.FontFamily.COURIER, 8);
        Font fontLarge = new Font(Font.FontFamily.COURIER, 12, Font.BOLD);
        
        // ===== COMPANY HEADER =====
        Vector companyDetails = uBean.getCompanyDetails();
        String companyName = "";
        String companyAddress = "";
        String companyGSTIN = "";
        
        if (companyDetails != null && companyDetails.size() >= 4) {
            companyName = companyDetails.get(1) != null ? companyDetails.get(1).toString() : "";
            companyAddress = companyDetails.get(2) != null ? companyDetails.get(2).toString() : "";
            companyGSTIN = companyDetails.get(3) != null ? companyDetails.get(3).toString() : "";
        }
        
        Paragraph pVerse1 = new Paragraph("I Can Do All Things Through Jesus Christ Who", fontSmall);
        pVerse1.setAlignment(Element.ALIGN_CENTER);
        document.add(pVerse1);
        Paragraph pVerse2 = new Paragraph("Strengthens Me.", fontSmall);
        pVerse2.setAlignment(Element.ALIGN_CENTER);
        document.add(pVerse2);

        // Logo after verse
        if (applicationBasePath != null) {
            File logoFile = new File(applicationBasePath + File.separator + "billing" + File.separator + "logo.png");
            if (!logoFile.exists()) logoFile = new File(applicationBasePath + File.separator + "logo.png");
            if (logoFile.exists()) {
                Image logo = Image.getInstance(logoFile.getAbsolutePath());
                logo.setAlignment(Element.ALIGN_CENTER);
                float maxWidth = pageWidth * 0.75f;
                if (logo.getWidth() > maxWidth) {
                    logo.scaleToFit(maxWidth, 1000);
                }
                document.add(logo);
            }
        }

        Paragraph pCompany = new Paragraph(companyName, fontTitle);
        pCompany.setAlignment(Element.ALIGN_CENTER);
        document.add(pCompany);
        
        Paragraph pAddr = new Paragraph(companyAddress, fontSmall);
        pAddr.setAlignment(Element.ALIGN_CENTER);
        document.add(pAddr);
        
        if (!companyGSTIN.isEmpty()) {
            Paragraph pGst = new Paragraph("GSTIN: " + companyGSTIN, fontSmall);
            pGst.setAlignment(Element.ALIGN_CENTER);
            document.add(pGst);
        }
        
        addPdfDivider(document, pageWidth);
        // ===== BILL INFO =====
        String billDate = bill.getBillDate(billNo);
        PdfPTable billInfoTable = new PdfPTable(2);
        billInfoTable.setWidthPercentage(100);
        PdfPCell cellBillNo = new PdfPCell(new Phrase("Bill No: " + billNo, fontBold));
        cellBillNo.setBorder(Rectangle.NO_BORDER);
        cellBillNo.setHorizontalAlignment(Element.ALIGN_LEFT);
        PdfPCell cellDate = new PdfPCell(new Phrase(billDate, fontBold));
        cellDate.setBorder(Rectangle.NO_BORDER);
        cellDate.setHorizontalAlignment(Element.ALIGN_RIGHT);
        billInfoTable.addCell(cellBillNo);
        billInfoTable.addCell(cellDate);
        document.add(billInfoTable);
        
        addPdfDivider(document, pageWidth);
        
        // ===== CUSTOMER INFO =====
        String cusName = bill.getCusName(billNo);
        String cusNumber = bill.getCusNumber(billNo);
        Vector customerDetails = bill.getCustomerDetailsByBillNo(billNo);
        String customerName = cusName;
        String customerPhone = "-";
        String customerGSTIN = "-";
        
        if (customerDetails != null && customerDetails.size() >= 4) {
            customerName = customerDetails.get(0) != null ? customerDetails.get(0).toString() : cusName;
            customerPhone = customerDetails.get(1) != null ? customerDetails.get(1).toString() : cusNumber;
            customerGSTIN = customerDetails.get(3) != null ? customerDetails.get(3).toString() : "-";
        } else {
            customerPhone = cusNumber != null ? cusNumber : "-";
        }
        
        document.add(new Paragraph("Customer: " + customerName, fontSmall));
        if (!"-".equals(customerPhone) && customerPhone != null && !customerPhone.isEmpty()) {
            document.add(new Paragraph("Phone: " + customerPhone, fontSmall));
        }
        if (!"-".equals(customerGSTIN) && customerGSTIN != null && !customerGSTIN.isEmpty()) {
            document.add(new Paragraph("GSTIN: " + customerGSTIN, fontSmall));
        }
        
        addPdfDivider(document, pageWidth);
        
        // ===== ITEMS TABLE =====
        PdfPTable itemTable = new PdfPTable(new float[]{0.5f, 3f, 1.2f, 1f, 1.5f, 1.2f, 0.8f, 1.8f});
        itemTable.setWidthPercentage(100);
        itemTable.setSpacingBefore(3);
        
        // Header: #, ITEM, CODE, QTY, RATE, DISC, GST%, AMT
        addPdfCell(itemTable, "#", fontBold, Element.ALIGN_CENTER);
        addPdfCell(itemTable, "ITEM", fontBold, Element.ALIGN_LEFT);
        addPdfCell(itemTable, "CODE", fontBold, Element.ALIGN_LEFT);
        addPdfCell(itemTable, "QTY", fontBold, Element.ALIGN_CENTER);
        addPdfCell(itemTable, "RATE", fontBold, Element.ALIGN_RIGHT);
        addPdfCell(itemTable, "DISC", fontBold, Element.ALIGN_RIGHT);
        addPdfCell(itemTable, "GST%", fontBold, Element.ALIGN_CENTER);
        addPdfCell(itemTable, "AMT", fontBold, Element.ALIGN_RIGHT);
        
        Vector<Vector<Object>> billDetails = bill.getBillDetailsUsingNo(billNo);
        double extradisc = bill.getExtraDisc(billNo);
        
        double totalAmount = 0, totalDiscount = 0, totalQtyD = 0;
        double totalTaxableAmount = 0, totalGSTAmount = 0, totalCGST = 0, totalSGST = 0;
        
        Map<Integer, Double> gstWiseTaxable = new HashMap<Integer, Double>();
        Map<Integer, Double> gstWiseCGST = new HashMap<Integer, Double>();
        Map<Integer, Double> gstWiseSGST = new HashMap<Integer, Double>();
        
        int pdfSno = 0;
        for (Vector<Object> prod : billDetails) {
            pdfSno++;
            String itemName = prod.get(0).toString();
            String itemCode = (prod.size() > 7 && prod.get(7) != null) ? prod.get(7).toString() : "";
            double qty = Double.parseDouble(prod.get(1).toString());
            double itemPrice = Double.parseDouble(prod.get(2).toString());
            double itemDisc = Double.parseDouble(prod.get(3).toString());
            double itemTotal = Double.parseDouble(prod.get(4).toString());
            int gstPer = Integer.parseInt(prod.get(5).toString());
            
            double taxableAmount = itemTotal / (1 + (gstPer / 100.0));
            double gstAmount = itemTotal - taxableAmount;
            double cgst = gstAmount / 2;
            double sgst = gstAmount / 2;
            
            totalQtyD += qty;
            totalAmount += itemTotal;
            totalDiscount += itemDisc;
            totalTaxableAmount += taxableAmount;
            totalGSTAmount += gstAmount;
            totalCGST += cgst;
            totalSGST += sgst;
            
            if (!gstWiseTaxable.containsKey(gstPer)) {
                gstWiseTaxable.put(gstPer, 0.0);
                gstWiseCGST.put(gstPer, 0.0);
                gstWiseSGST.put(gstPer, 0.0);
            }
            gstWiseTaxable.put(gstPer, gstWiseTaxable.get(gstPer) + taxableAmount);
            gstWiseCGST.put(gstPer, gstWiseCGST.get(gstPer) + cgst);
            gstWiseSGST.put(gstPer, gstWiseSGST.get(gstPer) + sgst);
            
            String gstStr = gstPer > 0 ? gstPer + "%" : "-";
            addPdfCell(itemTable, String.valueOf(pdfSno), fontSmall, Element.ALIGN_CENTER);
            addPdfCell(itemTable, itemName, fontSmall, Element.ALIGN_LEFT);
            addPdfCell(itemTable, itemCode, fontSmall, Element.ALIGN_LEFT);
            addPdfCell(itemTable, prod.get(1).toString(), fontSmall, Element.ALIGN_CENTER);
            addPdfCell(itemTable, df.format(itemPrice), fontSmall, Element.ALIGN_RIGHT);
            addPdfCell(itemTable, df.format(itemDisc), fontSmall, Element.ALIGN_RIGHT);
            addPdfCell(itemTable, gstStr, fontSmall, Element.ALIGN_CENTER);
            addPdfCell(itemTable, df.format(itemTotal), fontSmall, Element.ALIGN_RIGHT);
        }
        document.add(itemTable);
        
        addPdfDivider(document, pageWidth);
        
        // ===== TOTALS =====
        double subTotalBeforeDiscount = totalAmount + totalDiscount;
        double finalPaid = totalAmount - extradisc;
        double paid = bill.getPaidTotal(billNo);
        double balance = bill.getbalanceTotal(billNo);
        String numPaid = bill.getNumPaid(paid);
        
        addPdfTotalRow(document, "Items:", String.valueOf(totalQtyD), fontNormal);
        addPdfTotalRow(document, "Sub Total:", "Rs " + df.format(subTotalBeforeDiscount), fontNormal);
        
        if (totalDiscount > 0) {
            addPdfTotalRow(document, "Item Discount:", "- Rs " + df.format(totalDiscount), fontNormal);
        }
        if (extradisc > 0) {
            addPdfTotalRow(document, "Extra Discount:", "- Rs " + df.format(extradisc), fontNormal);
        }
        
        addPdfDivider(document, pageWidth);
        addPdfTotalRow(document, "TOTAL:", "Rs " + df.format(finalPaid), fontLarge);
        addPdfDivider(document, pageWidth);
        
        double[] cashBank = bill.getCashBankPaid(billNo);
        double cashPaid = cashBank[0];
        double bankPaid = cashBank[1];
        String paidLabel;
        if (cashPaid > 0 && bankPaid > 0) {
            paidLabel = "Cash & Bank Paid:";
        } else if (bankPaid > 0) {
            paidLabel = "Bank Paid:";
        } else {
            paidLabel = "Cash Paid:";
        }
        addPdfTotalRow(document, paidLabel, "Rs " + df.format(paid), fontNormal);
        
        if (balance != 0) {
            String label = balance > 0 ? "Balance Due:" : "Change:";
            addPdfTotalRow(document, label, "Rs " + df.format(Math.abs(balance)), fontBold);
        }
        
        // ===== GST SUMMARY =====
        if (totalGSTAmount > 0) {
            addPdfDivider(document, pageWidth);
            Paragraph pGstTitle = new Paragraph("GST SUMMARY", fontBold);
            pGstTitle.setAlignment(Element.ALIGN_CENTER);
            document.add(pGstTitle);
            addPdfDivider(document, pageWidth);
            
            // GST table: Base Amt, SGST, CGST, TOTAL
            PdfPTable gstTable = new PdfPTable(4);
            gstTable.setWidthPercentage(100);
            addPdfCell(gstTable, "Base Amt", fontBold, Element.ALIGN_LEFT);
            addPdfCell(gstTable, "SGST", fontBold, Element.ALIGN_RIGHT);
            addPdfCell(gstTable, "CGST", fontBold, Element.ALIGN_RIGHT);
            addPdfCell(gstTable, "TOTAL", fontBold, Element.ALIGN_RIGHT);
            
            java.util.List<Integer> gstRates = new ArrayList<Integer>(gstWiseTaxable.keySet());
            Collections.sort(gstRates);
            for (Integer rate : gstRates) {
                if (rate > 0) {
                    double rowBase = gstWiseTaxable.get(rate);
                    double rowSgst = gstWiseSGST.get(rate);
                    double rowCgst = gstWiseCGST.get(rate);
                    double rowTotal = rowBase + rowSgst + rowCgst;
                    addPdfCell(gstTable, df.format(rowBase), fontSmall, Element.ALIGN_LEFT);
                    addPdfCell(gstTable, df.format(rowSgst), fontSmall, Element.ALIGN_RIGHT);
                    addPdfCell(gstTable, df.format(rowCgst), fontSmall, Element.ALIGN_RIGHT);
                    addPdfCell(gstTable, df.format(rowTotal), fontSmall, Element.ALIGN_RIGHT);
                }
            }
            document.add(gstTable);
            addPdfDivider(document, pageWidth);
            addPdfTotalRow(document, "Total GST   :", "Rs " + df.format(totalGSTAmount), fontNormal);
            addPdfTotalRow(document, "Total Sales :", "Rs " + df.format(subTotalBeforeDiscount), fontNormal);
            addPdfTotalRow(document, "Total Savings:", "Rs " + df.format(totalDiscount + extradisc), fontNormal);
            addPdfTotalRow(document, "Nett Sales  :", "Rs " + df.format(finalPaid), fontBold);
        }
        
        addPdfDivider(document, pageWidth);
        
        // ===== FOOTER =====
        Paragraph pAmount = new Paragraph(numPaid.toUpperCase(), fontBold);
        pAmount.setAlignment(Element.ALIGN_CENTER);
        document.add(pAmount);
        
        Paragraph pThanks = new Paragraph("\nTHANK YOU, VISIT AGAIN", fontSmall);
        pThanks.setAlignment(Element.ALIGN_CENTER);
        document.add(pThanks);
        Paragraph pMsg1 = new Paragraph("No Refund, No Exchange for Offer Items", fontSmall);
        pMsg1.setAlignment(Element.ALIGN_CENTER);
        document.add(pMsg1);
        Paragraph pMsg2 = new Paragraph("Exchange within 3 days with Compulsory Bill", fontSmall);
        pMsg2.setAlignment(Element.ALIGN_CENTER);
        document.add(pMsg2);
        Paragraph pMsg3 = new Paragraph("We Cannot Spell SUCCESS without U", fontSmall);
        pMsg3.setAlignment(Element.ALIGN_CENTER);
        document.add(pMsg3);
        
        document.close();
        return filePath;
    }
    
    // ===== PDF HELPER METHODS =====
    
    private static void addPdfDivider(Document doc, float width) throws DocumentException {
        Paragraph p = new Paragraph("  ");
        p.setSpacingBefore(2);
        p.setSpacingAfter(2);
        LineSeparator line = new LineSeparator(0.5f, 100, BaseColor.BLACK, Element.ALIGN_CENTER, -2);
        doc.add(line);
    }
    
    private static void addPdfCell(PdfPTable table, String text, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setHorizontalAlignment(align);
        cell.setPaddingBottom(2);
        cell.setPaddingTop(1);
        table.addCell(cell);
    }
    
    private static void addPdfTotalRow(Document doc, String label, String value, Font font) throws DocumentException {
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        PdfPCell cellLabel = new PdfPCell(new Phrase(label, font));
        cellLabel.setBorder(Rectangle.NO_BORDER);
        cellLabel.setHorizontalAlignment(Element.ALIGN_LEFT);
        PdfPCell cellValue = new PdfPCell(new Phrase(value, font));
        cellValue.setBorder(Rectangle.NO_BORDER);
        cellValue.setHorizontalAlignment(Element.ALIGN_RIGHT);
        table.addCell(cellLabel);
        table.addCell(cellValue);
        doc.add(table);
    }

    /**
     * Print logo image via ESC/POS raster command (GS v 0).
     * Silently skipped if logo file is missing or unreadable.
     */
    private static void printLogoEscPos(ByteArrayOutputStream baos) {
        try {
            if (applicationBasePath == null) return;
            File logoFile = new File(applicationBasePath + File.separator + "billing" + File.separator + "logo.png");
            if (!logoFile.exists()) logoFile = new File(applicationBasePath + File.separator + "logo.png");
            if (!logoFile.exists()) return;

            java.awt.image.BufferedImage original = javax.imageio.ImageIO.read(logoFile);
            if (original == null) return;

                // Medium size: 200px wide for 80mm, 150px for 58mm
                int targetWidth = (RECEIPT_WIDTH == RECEIPT_WIDTH_58MM) ? 150 : 200;
            int targetHeight = (int)((double)original.getHeight() / original.getWidth() * targetWidth);
            if (targetHeight < 1) return;

            java.awt.image.BufferedImage scaled = new java.awt.image.BufferedImage(
                    targetWidth, targetHeight, java.awt.image.BufferedImage.TYPE_INT_RGB);
            java.awt.Graphics2D g2d = scaled.createGraphics();
            g2d.setRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION,
                    java.awt.RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g2d.drawImage(original, 0, 0, targetWidth, targetHeight, null);
            g2d.dispose();

            // Build a full-width canvas and place logo centered.
            // This works even on printers that ignore alignment for raster image commands.
            int paperWidthPx = (RECEIPT_WIDTH == RECEIPT_WIDTH_58MM) ? 384 : 576;
            java.awt.image.BufferedImage centered = new java.awt.image.BufferedImage(
                    paperWidthPx, targetHeight, java.awt.image.BufferedImage.TYPE_INT_RGB);
            java.awt.Graphics2D gCentered = centered.createGraphics();
            gCentered.setColor(java.awt.Color.WHITE);
            gCentered.fillRect(0, 0, paperWidthPx, targetHeight);
            int xOffset = Math.max(0, (paperWidthPx - targetWidth) / 2);
            gCentered.drawImage(scaled, xOffset, 0, null);
            gCentered.dispose();

            // GS v 0 – Print raster bit image
            int widthBytes = (paperWidthPx + 7) / 8;
            baos.write(new byte[]{0x1D, 0x76, 0x30, 0x00});
            baos.write(widthBytes & 0xFF);
            baos.write((widthBytes >> 8) & 0xFF);
            baos.write(targetHeight & 0xFF);
            baos.write((targetHeight >> 8) & 0xFF);

            for (int y = 0; y < targetHeight; y++) {
                for (int xByte = 0; xByte < widthBytes; xByte++) {
                    int b = 0;
                    for (int bit = 0; bit < 8; bit++) {
                        int x = xByte * 8 + bit;
                        if (x < paperWidthPx) {
                            int rgb = centered.getRGB(x, y);
                            int r = (rgb >> 16) & 0xFF;
                            int g = (rgb >> 8) & 0xFF;
                            int bl = rgb & 0xFF;
                            int gray = (r + g + bl) / 3;
                            if (gray < 128) {
                                b |= (0x80 >> bit);
                            }
                        }
                    }
                    baos.write(b);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Helper method to append byte array to ByteArrayOutputStream
     */
    private static void writeBytes(ByteArrayOutputStream baos, byte[] data) {
        try {
            baos.write(data);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Helper method to write string as bytes
     */
    private static void writeString(ByteArrayOutputStream baos, String str) {
        try {
            baos.write(str.getBytes("UTF-8"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Build the full ESC/POS receipt data as byte array (optimized for minimal paper usage)
     */
    /**
     * Build plain text receipt (without ESC/POS commands) for saving to file
     */
    private static String buildPlainTextReceipt(String billNo) throws Exception {
        billingBean bill = new billingBean();
        userBean uBean = new userBean();
        
        StringBuilder sb = new StringBuilder();
        
        // ===== COMPANY HEADER =====
        Vector companyDetails = uBean.getCompanyDetails();
        String companyName = "";
        String companyAddress = "";
        String companyGSTIN = "";
        
        if (companyDetails != null && companyDetails.size() >= 4) {
            companyName = companyDetails.get(1) != null ? companyDetails.get(1).toString() : "";
            companyAddress = companyDetails.get(2) != null ? companyDetails.get(2).toString() : "";
            companyGSTIN = companyDetails.get(3) != null ? companyDetails.get(3).toString() : "";
        }
        
        sb.append(centerText("I Can Do All Things Through Jesus Christ Who")).append("\n");
        sb.append(centerText("Strengthens Me.")).append("\n");

        // Center align company name
        sb.append(centerText(companyName)).append("\n");
        
        // Split address by newlines and center each line
        if (!companyAddress.isEmpty()) {
            String[] addressLines = companyAddress.split("\\r?\\n");
            for (String line : addressLines) {
                if (line != null && !line.trim().isEmpty()) {
                    sb.append(centerText(line.trim())).append("\n");
                }
            }
        }
        
        if (!companyGSTIN.isEmpty()) {
            sb.append(centerText("GSTIN: " + companyGSTIN)).append("\n");
        }
        
        sb.append(divider());
        
        // ===== BILL INFO =====
        String billDate = bill.getBillDate(billNo);
        sb.append(padRight("Bill: " + billNo, RECEIPT_WIDTH - billDate.length()));
        sb.append(billDate).append("\n");
        
        // ===== CUSTOMER INFO ===== (no divider between bill and customer)
        String cusName = bill.getCusName(billNo);
        String cusNumber = bill.getCusNumber(billNo);
        Vector customerDetails = bill.getCustomerDetailsByBillNo(billNo);
        String customerName = cusName;
        String customerPhone = "-";
        String customerGSTIN = "-";
        
        if (customerDetails != null && customerDetails.size() >= 4) {
            customerName = customerDetails.get(0) != null ? customerDetails.get(0).toString() : cusName;
            customerPhone = customerDetails.get(1) != null ? customerDetails.get(1).toString() : cusNumber;
            customerGSTIN = customerDetails.get(3) != null ? customerDetails.get(3).toString() : "-";
        } else {
            customerPhone = cusNumber != null ? cusNumber : "-";
        }
        
        sb.append("Cust: ").append(customerName).append("\n");
        if (!"-".equals(customerPhone) && customerPhone != null && !customerPhone.isEmpty()) {
            sb.append("Ph: ").append(customerPhone).append("\n");
        }
        if (!"-".equals(customerGSTIN) && customerGSTIN != null && !customerGSTIN.isEmpty()) {
            sb.append("GSTIN: ").append(customerGSTIN).append("\n");
        }
        
        sb.append(divider());
        
        // ===== ITEMS HEADER =====
        sb.append(formatItemHeader());
        sb.append(divider());
        
        // ===== ITEMS =====
        Vector<Vector<Object>> billDetails = bill.getBillDetailsUsingNo(billNo);
        double extradisc = bill.getExtraDisc(billNo);
        
        double totalAmount = 0;
        double totalDiscount = 0;
        double totalQtyD = 0;
        double totalTaxableAmount = 0;
        double totalGSTAmount = 0;
        double totalCGST = 0;
        double totalSGST = 0;
        
        Map<Integer, Double> gstWiseTaxable = new HashMap<Integer, Double>();
        Map<Integer, Double> gstWiseCGST = new HashMap<Integer, Double>();
        Map<Integer, Double> gstWiseSGST = new HashMap<Integer, Double>();
        
        int sno = 0;
        for (Vector<Object> prod : billDetails) {
            sno++;
            String itemName = prod.get(0).toString();
            String itemCode = (prod.size() > 7 && prod.get(7) != null) ? prod.get(7).toString() : "";
            double qty = Double.parseDouble(prod.get(1).toString());
            double itemPrice = Double.parseDouble(prod.get(2).toString());
            double itemDisc = Double.parseDouble(prod.get(3).toString());
            double itemTotal = Double.parseDouble(prod.get(4).toString());
            int gstPer = Integer.parseInt(prod.get(5).toString());
            
            // Calculations
            double taxableAmount = itemTotal / (1 + (gstPer / 100.0));
            double gstAmount = itemTotal - taxableAmount;
            double cgst = gstAmount / 2;
            double sgst = gstAmount / 2;
            
            totalQtyD += qty;
            totalAmount += itemTotal;
            totalDiscount += itemDisc;
            totalTaxableAmount += taxableAmount;
            totalGSTAmount += gstAmount;
            totalCGST += cgst;
            totalSGST += sgst;
            
            if (!gstWiseTaxable.containsKey(gstPer)) {
                gstWiseTaxable.put(gstPer, 0.0);
                gstWiseCGST.put(gstPer, 0.0);
                gstWiseSGST.put(gstPer, 0.0);
            }
            gstWiseTaxable.put(gstPer, gstWiseTaxable.get(gstPer) + taxableAmount);
            gstWiseCGST.put(gstPer, gstWiseCGST.get(gstPer) + cgst);
            gstWiseSGST.put(gstPer, gstWiseSGST.get(gstPer) + sgst);
            
            // Print item (2-row layout, blank line included)
            sb.append(formatItemRow(sno, itemName, itemCode, prod.get(1).toString(), df.format(itemPrice), df.format(itemDisc), gstPer, df.format(itemTotal), gstAmount));
        }
        
        sb.append(divider());
        
        // ===== TOTALS =====
        double subTotalBeforeDiscount = totalAmount + totalDiscount;
        double finalPaid = totalAmount - extradisc;
        double paid = bill.getPaidTotal(billNo);
        double balance = bill.getbalanceTotal(billNo);
        String numPaid = bill.getNumPaid(paid);
        
        sb.append(formatTotalRow("Items:", String.valueOf((int)totalQtyD)));
        
        if (totalDiscount > 0) {
            sb.append(formatTotalRow("Item Disc:", "-Rs " + df.format(totalDiscount)));
        }
        if (extradisc > 0) {
            sb.append(formatTotalRow("Extra Disc:", "-Rs " + df.format(extradisc)));
        }
        
        sb.append(divider());
        sb.append(formatTotalRow("TOTAL:", "Rs " + df.format(finalPaid)));
        sb.append(divider());
        
        double[] cashBank = bill.getCashBankPaid(billNo);
        double cashPaid = cashBank[0];
        double bankPaid = cashBank[1];
        String paidLabel;
        if (cashPaid > 0 && bankPaid > 0) {
            paidLabel = "Cash & Bank Paid:";
        } else if (bankPaid > 0) {
            paidLabel = "Bank Paid:";
        } else {
            paidLabel = "Cash Paid:";
        }
        sb.append(formatTotalRow(paidLabel, "Rs " + df.format(paid)));
        
        if (balance != 0) {
            String label = balance > 0 ? "Balance:" : "Change:";
            sb.append(formatTotalRow(label, "Rs " + df.format(Math.abs(balance))));
        }
        
        // ===== GST SUMMARY =====
        if (totalGSTAmount > 0) {
            sb.append(divider());
            sb.append(centerText("GST SUMMARY")).append("\n");
            sb.append(divider());
            sb.append(formatGstTableRow("Base Amt", "SGST", "CGST", "TOTAL"));
            
            java.util.List<Integer> gstRates = new ArrayList<Integer>(gstWiseTaxable.keySet());
            Collections.sort(gstRates);
            for (Integer rate : gstRates) {
                if (rate > 0) {
                    double rowBase = gstWiseTaxable.get(rate);
                    double rowSgst = gstWiseSGST.get(rate);
                    double rowCgst = gstWiseCGST.get(rate);
                    double rowTotal = rowBase + rowSgst + rowCgst;
                    sb.append(formatGstTableRow(df.format(rowBase), df.format(rowSgst), df.format(rowCgst), df.format(rowTotal)));
                }
            }
            sb.append(divider());
            sb.append(formatTotalRow("Total GST   :", "Rs " + df.format(totalGSTAmount)));
            sb.append(formatTotalRow("Total Sales :", "Rs " + df.format(subTotalBeforeDiscount)));
            sb.append(formatTotalRow("Total Savings:", "Rs " + df.format(totalDiscount + extradisc)));
            sb.append(formatTotalRow("Nett Sales  :", "Rs " + df.format(finalPaid)));
        }
        
        sb.append(divider());
        
        // ===== FOOTER =====
        sb.append(centerText(numPaid.toUpperCase())).append("\n");
        sb.append(divider());
        sb.append(centerText("THANK YOU, VISIT AGAIN")).append("\n");
        sb.append(centerText("No Refund, No Exchange for Offer Items")).append("\n");
        sb.append(centerText("Exchange within 3 days with Compulsory Bill")).append("\n");
        sb.append(centerText("We Cannot Spell SUCCESS without U")).append("\n");
        sb.append("\n\n\n\n");
        
        return sb.toString();
    }

    private static byte[] buildReceiptData(String billNo) throws Exception {
        billingBean bill = new billingBean();
        userBean uBean = new userBean();
        
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        
        // Initialize printer
        writeBytes(baos, INIT);
        writeBytes(baos, FONT_NORMAL);  // Normal font size
        writeBytes(baos, FONT_A);       // Use Font A (default/larger)
        
        // ===== COMPANY HEADER =====
        Vector companyDetails = uBean.getCompanyDetails();
        String companyName = "";
        String companyAddress = "";
        String companyGSTIN = "";
        
        if (companyDetails != null && companyDetails.size() >= 4) {
            companyName = companyDetails.get(1) != null ? companyDetails.get(1).toString() : "";
            companyAddress = companyDetails.get(2) != null ? companyDetails.get(2).toString() : "";
            companyGSTIN = companyDetails.get(3) != null ? companyDetails.get(3).toString() : "";
        }
        
        writeBytes(baos, ALIGN_CENTER);
        writeString(baos, "I Can Do All Things Through Jesus Christ Who\n");
        writeString(baos, "Strengthens Me.\n");

        // Print logo after verse
        printLogoEscPos(baos);

        writeBytes(baos, BOLD_ON);
        writeString(baos, companyName + "\n");
        writeBytes(baos, BOLD_OFF);
        
        // Handle multi-line address
        if (!companyAddress.isEmpty()) {
            String[] addressLines = companyAddress.split("\\r?\\n");
            for (String line : addressLines) {
                if (line != null && !line.trim().isEmpty()) {
                    writeString(baos, line.trim() + "\n");
                }
            }
        }
        
        if (!companyGSTIN.isEmpty()) {
            writeString(baos, "GSTIN: " + companyGSTIN + "\n");
        }
        
        writeDivider(baos);
        
        // ===== BILL INFO =====
        writeBytes(baos, ALIGN_LEFT);
        String billDate = bill.getBillDate(billNo);
        writeString(baos, padRight("Bill: " + billNo, RECEIPT_WIDTH - billDate.length()) + billDate + "\n");
        
        // ===== CUSTOMER INFO ===== (no divider between bill and customer)
        String cusName = bill.getCusName(billNo);
        String cusNumber = bill.getCusNumber(billNo);
        Vector customerDetails = bill.getCustomerDetailsByBillNo(billNo);
        String customerName = cusName;
        String customerPhone = "-";
        String customerGSTIN = "-";
        
        if (customerDetails != null && customerDetails.size() >= 4) {
            customerName = customerDetails.get(0) != null ? customerDetails.get(0).toString() : cusName;
            customerPhone = customerDetails.get(1) != null ? customerDetails.get(1).toString() : cusNumber;
            customerGSTIN = customerDetails.get(3) != null ? customerDetails.get(3).toString() : "-";
        } else {
            customerPhone = cusNumber != null ? cusNumber : "-";
        }
        
        writeString(baos, "Cust: " + customerName + "\n");
        if (!"-".equals(customerPhone) && customerPhone != null && !customerPhone.isEmpty()) {
            writeString(baos, "Ph: " + customerPhone + "\n");
        }
        if (!"-".equals(customerGSTIN) && customerGSTIN != null && !customerGSTIN.isEmpty()) {
            writeString(baos, "GSTIN: " + customerGSTIN + "\n");
        }
        
        writeDivider(baos);
        
        // ===== ITEMS HEADER =====
        writeBytes(baos, BOLD_ON);
        writeString(baos, formatItemHeader());
        writeBytes(baos, BOLD_OFF);
        writeDivider(baos);
        
        // ===== ITEMS =====
        Vector<Vector<Object>> billDetails = bill.getBillDetailsUsingNo(billNo);
        double extradisc = bill.getExtraDisc(billNo);
        
        double totalAmount = 0;
        double totalDiscount = 0;
        double totalQtyD = 0;
        double totalTaxableAmount = 0;
        double totalGSTAmount = 0;
        double totalCGST = 0;
        double totalSGST = 0;
        
        Map<Integer, Double> gstWiseTaxable = new HashMap<Integer, Double>();
        Map<Integer, Double> gstWiseCGST = new HashMap<Integer, Double>();
        Map<Integer, Double> gstWiseSGST = new HashMap<Integer, Double>();
        
        int sno = 0;
        for (Vector<Object> prod : billDetails) {
            sno++;
            String itemName = prod.get(0).toString();
            String itemCode = (prod.size() > 7 && prod.get(7) != null) ? prod.get(7).toString() : "";
            double qty = Double.parseDouble(prod.get(1).toString());
            double itemPrice = Double.parseDouble(prod.get(2).toString());
            double itemDisc = Double.parseDouble(prod.get(3).toString());
            double itemTotal = Double.parseDouble(prod.get(4).toString());
            int gstPer = Integer.parseInt(prod.get(5).toString());
            
            // Calculations
            double taxableAmount = itemTotal / (1 + (gstPer / 100.0));
            double gstAmount = itemTotal - taxableAmount;
            double cgst = gstAmount / 2;
            double sgst = gstAmount / 2;
            
            totalQtyD += qty;
            totalAmount += itemTotal;
            totalDiscount += itemDisc;
            totalTaxableAmount += taxableAmount;
            totalGSTAmount += gstAmount;
            totalCGST += cgst;
            totalSGST += sgst;
            
            if (!gstWiseTaxable.containsKey(gstPer)) {
                gstWiseTaxable.put(gstPer, 0.0);
                gstWiseCGST.put(gstPer, 0.0);
                gstWiseSGST.put(gstPer, 0.0);
            }
            gstWiseTaxable.put(gstPer, gstWiseTaxable.get(gstPer) + taxableAmount);
            gstWiseCGST.put(gstPer, gstWiseCGST.get(gstPer) + cgst);
            gstWiseSGST.put(gstPer, gstWiseSGST.get(gstPer) + sgst);
            
            // Print item (2-row layout, blank line included)
            writeString(baos, formatItemRow(sno, itemName, itemCode, prod.get(1).toString(), df.format(itemPrice), df.format(itemDisc), gstPer, df.format(itemTotal), gstAmount));
        }
        
        writeDivider(baos);
        
        // ===== TOTALS =====
        double subTotalBeforeDiscount = totalAmount + totalDiscount;
        double finalPaid = totalAmount - extradisc;
        double paid = bill.getPaidTotal(billNo);
        double balance = bill.getbalanceTotal(billNo);
        String numPaid = bill.getNumPaid(paid);
        
        writeString(baos, formatTotalRow("Items:", String.valueOf((int)totalQtyD)));
        
        if (totalDiscount > 0) {
            writeString(baos, formatTotalRow("Item Disc:", "-Rs " + df.format(totalDiscount)));
        }
        if (extradisc > 0) {
            writeString(baos, formatTotalRow("Extra Disc:", "-Rs " + df.format(extradisc)));
        }
        
        writeDivider(baos);
        
        // TOTAL line (bold but same size)
        writeBytes(baos, BOLD_ON);
        writeString(baos, formatTotalRow("TOTAL:", "Rs " + df.format(finalPaid)));
        writeBytes(baos, BOLD_OFF);
        
        writeDivider(baos);
        
        writeString(baos, formatTotalRow("Paid:", "Rs " + df.format(paid)));
        
        if (balance != 0) {
            writeBytes(baos, BOLD_ON);
            String label = balance > 0 ? "Balance:" : "Change:";
            writeString(baos, formatTotalRow(label, "Rs " + df.format(Math.abs(balance))));
            writeBytes(baos, BOLD_OFF);
        }
        
        // ===== GST SUMMARY =====
        if (totalGSTAmount > 0) {
            writeDivider(baos);
            writeBytes(baos, ALIGN_CENTER);
            writeBytes(baos, BOLD_ON);
            writeString(baos, "GST SUMMARY\n");
            writeBytes(baos, BOLD_OFF);
            writeBytes(baos, ALIGN_LEFT);
            writeDivider(baos);
            writeBytes(baos, BOLD_ON);
            writeString(baos, formatGstTableRow("Base Amt", "SGST", "CGST", "TOTAL"));
            writeBytes(baos, BOLD_OFF);
            
            java.util.List<Integer> gstRates = new ArrayList<Integer>(gstWiseTaxable.keySet());
            Collections.sort(gstRates);
            for (Integer rate : gstRates) {
                if (rate > 0) {
                    double rowBase = gstWiseTaxable.get(rate);
                    double rowSgst = gstWiseSGST.get(rate);
                    double rowCgst = gstWiseCGST.get(rate);
                    double rowTotal = rowBase + rowSgst + rowCgst;
                    writeString(baos, formatGstTableRow(df.format(rowBase), df.format(rowSgst), df.format(rowCgst), df.format(rowTotal)));
                }
            }
            writeDivider(baos);
            writeString(baos, formatTotalRow("Total GST   :", "Rs " + df.format(totalGSTAmount)));
            writeString(baos, formatTotalRow("Total Sales :", "Rs " + df.format(subTotalBeforeDiscount)));
            writeString(baos, formatTotalRow("Total Savings:", "Rs " + df.format(totalDiscount + extradisc)));
            writeString(baos, formatTotalRow("Nett Sales  :", "Rs " + df.format(finalPaid)));
        }
        
        writeDivider(baos);
        
        // ===== FOOTER =====
        writeBytes(baos, ALIGN_CENTER);
        writeString(baos, numPaid.toUpperCase() + "\n");
        writeDivider(baos);
        writeBytes(baos, BOLD_ON);
        writeString(baos, "THANK YOU, VISIT AGAIN\n");
        writeBytes(baos, BOLD_OFF);
        writeString(baos, "No Refund, No Exchange for Offer Items\n");
        writeString(baos, "Exchange within 3 days with Compulsory Bill\n");
        writeString(baos, "We Cannot Spell SUCCESS without U\n");
        writeString(baos, "\n\n\n");
        
        // Feed lines before cut (ensure last content clears the cutter)
        writeBytes(baos, new byte[]{0x1B, 0x64, 0x06});
        
        // Partial cut paper
        writeBytes(baos, CUT_PAPER);
        
        return baos.toByteArray();
    }
    
    // ===== FORMATTING HELPERS =====
    
    /**
     * Write a divider line to the byte stream
     */
    private static void writeDivider(ByteArrayOutputStream baos) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < RECEIPT_WIDTH; i++) sb.append("-");
        sb.append("\n");
        writeString(baos, sb.toString());
    }
    
    private static String divider() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < RECEIPT_WIDTH; i++) sb.append("-");
        sb.append("\n");
        return sb.toString();
    }
    
    private static String formatItemHeader() {
        if (RECEIPT_WIDTH == RECEIPT_WIDTH_58MM) {
            // 58mm: col1=14 col2=5 col3=6 col4=7 = 32
            // Row 1: ITEM  QTY  DISC  AMT
            // Row 2: (code) RATE  GST%  GSTAMT
            return padRight("ITEM", 14) + padLeft("QTY", 5) + padLeft("DISC", 6) + padLeft("AMT", 7) + "\n"
                 + padRight("", 14)     + padLeft("RATE", 5) + padLeft("GST%", 6) + padLeft("GSTAMT", 7) + "\n";
        } else {
            // 80mm: col1=20 col2=8 col3=8 col4=12 = 48
            // Row 1: ITEM          QTY     DISC        AMT
            // Row 2: (code)        RATE    GST%     GSTAMT
            return padRight("ITEM", 20) + padLeft("QTY", 8) + padLeft("DISC", 8) + padLeft("AMT", 12) + "\n"
                 + padRight("", 20)     + padLeft("RATE", 8) + padLeft("GST%", 8) + padLeft("GSTAMT", 12) + "\n";
        }
    }
    
    private static String formatItemRow(int sno, String name, String code, String qty, String rate, String disc, int gstPer, String amt, double gstAmt) {
        StringBuilder sb = new StringBuilder();
        String gstStr = gstPer > 0 ? gstPer + "%" : "-";
        String gstAmtStr = gstAmt > 0 ? df.format(gstAmt) : "-";
        if (code == null) code = "";
        if (RECEIPT_WIDTH == RECEIPT_WIDTH_58MM) {
            // 58mm: col1=14 col2=5 col3=6 col4=7 = 32
            String snoPrefix = sno + ".";
            int nameWidth = 14 - snoPrefix.length();
            if (name.length() > nameWidth) name = name.substring(0, nameWidth);
            if (code.length() > 12) code = code.substring(0, 12);
            // Row 1: sno.name  qty  disc  amt
            sb.append(padRight(snoPrefix + name, 14));
            sb.append(padLeft(qty, 5));
            sb.append(padLeft(disc, 6));
            sb.append(padLeft(amt, 7));
            sb.append("\n");
            // Row 2: code  rate  gst%  gstamt
            sb.append(padRight("  " + code, 14));
            sb.append(padLeft(rate, 5));
            sb.append(padLeft(gstStr, 6));
            sb.append(padLeft(gstAmtStr, 7));
            sb.append("\n");
        } else {
            // 80mm: col1=20 col2=8 col3=8 col4=12 = 48
            String snoPrefix = sno + ".";
            int nameWidth = 20 - snoPrefix.length();
            if (name.length() > nameWidth) name = name.substring(0, nameWidth);
            if (code.length() > 18) code = code.substring(0, 18);
            // Row 1: sno.name  qty  disc  amt
            sb.append(padRight(snoPrefix + name, 20));
            sb.append(padLeft(qty, 8));
            sb.append(padLeft(disc, 8));
            sb.append(padLeft(amt, 12));
            sb.append("\n");
            // Row 2: code  rate  gst%  gstamt
            sb.append(padRight("  " + code, 20));
            sb.append(padLeft(rate, 8));
            sb.append(padLeft(gstStr, 8));
            sb.append(padLeft(gstAmtStr, 12));
            sb.append("\n");
        }
        sb.append("\n"); // blank line after each item
        return sb.toString();
    }

    private static String formatGstTableRow(String col1, String col2, String col3, String col4) {
        if (RECEIPT_WIDTH == RECEIPT_WIDTH_58MM) {
            // 58mm: 8+8+8+8 = 32
            return padRight(col1, 8) + padLeft(col2, 8) + padLeft(col3, 8) + padLeft(col4, 8) + "\n";
        } else {
            // 80mm: 12+12+12+12 = 48
            return padRight(col1, 12) + padLeft(col2, 12) + padLeft(col3, 12) + padLeft(col4, 12) + "\n";
        }
    }
    
    private static String formatTotalRow(String label, String value) {
        int padding = RECEIPT_WIDTH - label.length() - value.length();
        if (padding < 1) padding = 1;
        StringBuilder sb = new StringBuilder();
        sb.append(label);
        for (int i = 0; i < padding; i++) sb.append(" ");
        sb.append(value);
        sb.append("\n");
        return sb.toString();
    }
    
    private static String padRight(String s, int width) {
        if (s == null) s = "";
        if (s.length() >= width) return s.substring(0, width);
        StringBuilder sb = new StringBuilder(s);
        while (sb.length() < width) sb.append(" ");
        return sb.toString();
    }
    
    private static String padLeft(String s, int width) {
        if (s == null) s = "";
        if (s.length() >= width) return s;
        StringBuilder sb = new StringBuilder();
        while (sb.length() < width - s.length()) sb.append(" ");
        sb.append(s);
        return sb.toString();
    }

    private static String centerText(String text) {
        if (text == null) text = "";
        if (text.length() >= RECEIPT_WIDTH) return text.substring(0, RECEIPT_WIDTH);
        int totalPadding = RECEIPT_WIDTH - text.length();
        int leftPadding = totalPadding / 2;
        int rightPadding = totalPadding - leftPadding;
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < leftPadding; i++) sb.append(" ");
        sb.append(text);
        for (int i = 0; i < rightPadding; i++) sb.append(" ");
        return sb.toString();
    }

    /**
     * Test entry point - can still be run standalone
     */
    public static void main(String[] args) {
        try {
            System.out.println("Available printers:");
            for (String p : getAvailablePrinters()) {
                System.out.println("  - " + p);
            }
            
            if (args.length > 0) {
                System.out.println("\nPrinting bill: " + args[0]);
                printReceipt(args[0]);
                System.out.println("Printed successfully!");
            } else {
                System.out.println("\nUsage: java print.POSPrinter <billNo>");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
