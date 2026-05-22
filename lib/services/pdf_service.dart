import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../database/database.dart';
import '../modules/pos/models/cart_item.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndPrintInvoice({
    required String invoiceNumber,
    required Customer? customer,
    required List<CartItem> items,
    required double subtotal,
    required double taxTotal,
    required double grandTotal,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PRINTONEX ERP', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Business Management Software'),
                      pw.Text('GSTIN: 27AAAAA0000A1Z5'), // Placeholder
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('No: $invoiceNumber'),
                      pw.Text('Date: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}'),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Customer Info
              pw.Text('BILL TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(customer?.name ?? 'Walk-in Customer'),
              if (customer?.address != null) pw.Text(customer!.address!),
              if (customer?.phone != null) pw.Text('Phone: ${customer!.phone}'),
              if (customer?.gstNumber != null) pw.Text('GSTIN: ${customer!.gstNumber}'),
              pw.SizedBox(height: 30),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _pCell('Item Description', flex: 3, isHeader: true),
                      _pCell('Price', isHeader: true),
                      _pCell('Qty', isHeader: true),
                      _pCell('GST %', isHeader: true),
                      _pCell('Total', isHeader: true),
                    ],
                  ),
                  // Table Rows
                  ...items.map((item) => pw.TableRow(
                    children: [
                      _pCell(item.product.name, flex: 3),
                      _pCell(item.product.price.toStringAsFixed(2)),
                      _pCell(item.quantity.toString()),
                      _pCell('${item.product.gstRate}%'),
                      _pCell(item.total.toStringAsFixed(2)),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 30),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _summaryRow('Subtotal:', subtotal.toStringAsFixed(2)),
                      _summaryRow('Tax (GST):', taxTotal.toStringAsFixed(2)),
                      pw.Divider(),
                      _summaryRow('GRAND TOTAL:', grandTotal.toStringAsFixed(2), isGrand: true),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              pw.Divider(),
              pw.Center(child: pw.Text('Thank you for your business!', style: const pw.TextStyle(fontSize: 10))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _pCell(String text, {int flex = 1, bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 10),
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value, {bool isGrand = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isGrand ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.SizedBox(width: 20),
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              'INR $value',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: isGrand ? 14 : 10),
            ),
          ),
        ],
      ),
    );
  }
}
