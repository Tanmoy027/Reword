import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../user/user_home.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PaymentSuccessPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final double amount;

  const PaymentSuccessPage({
    Key? key,
    required this.order,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract voucher details from the order response
    final voucher = (order['vouchers'] != null && order['vouchers'].isNotEmpty)
        ? order['vouchers'][0]
        : {};

    // Parse purchase date if available
    DateTime? purchaseDate;
    try {
      purchaseDate = voucher['purchaseDate'] != null
          ? DateTime.parse(voucher['purchaseDate'])
          : null;
    } catch (e) {
      purchaseDate = null;
    }
    final dateStr = purchaseDate != null
        ? "${purchaseDate.toLocal().toString().split(' ')[0]}"
        : "N/A";
    final timeStr = purchaseDate != null
        ? "${purchaseDate.toLocal().toString().split(' ')[1].substring(0, 5)}"
        : "N/A";

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.teal[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Section
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.green,
                              child: Icon(Icons.check,
                                  color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Payment Success!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomPaint(
                              painter: DashedLinePainter(),
                              size: const Size(double.infinity, 1),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Details Section with real order details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Reference: ${order['_id']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow("Purchase Date", dateStr),
                          _buildDetailRow("Purchase Time", timeStr),
                          _buildDetailRow("Payment Method", "Credit Card"),
                          _buildDetailRow(
                              "Amount", "\€${amount.toStringAsFixed(2)}"),
                          if (voucher['status'] != null)
                            _buildDetailRow(
                                "Voucher Status", voucher['status']),
                          if (voucher['expiryDate'] != null)
                            _buildDetailRow(
                                "Expiry Date", voucher['expiryDate']),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Back to Home Button
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () => Get.offAll(() => UserHomePage()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Generate PDF receipt
  Future<File?> _generateReceipt(BuildContext context) async {
    final pdf = pw.Document();

    // Extract voucher details
    final voucher = (order['vouchers'] != null && order['vouchers'].isNotEmpty)
        ? order['vouchers'][0]
        : {};

    // Format date and time
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    // Parse purchase date if available
    DateTime? purchaseDate;
    try {
      purchaseDate = voucher['purchaseDate'] != null
          ? DateTime.parse(voucher['purchaseDate'])
          : now;
    } catch (e) {
      purchaseDate = now;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(purchaseDate);
    final timeStr = DateFormat('HH:mm:ss').format(purchaseDate);

    // Try to load logo image (assuming you have a logo in assets)
    pw.MemoryImage? logoImage;
    try {
      final ByteData logoData = await rootBundle.load('assets/logo.png');
      logoImage = pw.MemoryImage(
        logoData.buffer.asUint8List(),
      );
    } catch (e) {
      print('Logo image loading error: $e');
      // Continue without logo if it fails
    }

    // Create the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo if available
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('RECEIPT',
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('Generated: $formattedDate at $formattedTime'),
                    ],
                  ),
                  if (logoImage != null) pw.Image(logoImage, width: 100),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Order Information
              pw.Text(
                'ORDER INFORMATION',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              _buildPdfDetailRow('Order Reference:', order['_id'] ?? 'N/A'),
              _buildPdfDetailRow('Purchase Date:', dateStr),
              _buildPdfDetailRow('Purchase Time:', timeStr),
              _buildPdfDetailRow('Payment Method:', 'Credit Card'),

              pw.SizedBox(height: 20),

              // Voucher Information
              pw.Text(
                'VOUCHER DETAILS',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              _buildPdfDetailRow(
                  'Title:', voucher['title'] ?? 'Voucher Purchase'),
              _buildPdfDetailRow('Status:', voucher['status'] ?? 'Active'),
              _buildPdfDetailRow(
                  'Expiry Date:', voucher['expiryDate'] ?? 'N/A'),

              pw.SizedBox(height: 20),

              // Payment Information
              pw.Text(
                'PAYMENT DETAILS',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              pw.Divider(color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\€${amount.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total:',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('\€${amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(color: PdfColors.grey300),

              pw.SizedBox(height: 30),

              // Terms and conditions
              pw.Text(
                'Terms & Conditions',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'This is your official receipt. The voucher is valid until the expiry date. For any inquiries, please contact our customer service.',
                style: pw.TextStyle(fontSize: 10),
              ),

              pw.SizedBox(height: 20),

              // Thank you note
              pw.Center(
                child: pw.Text(
                  'Thank you for your purchase!',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF
    try {
      final output = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File('${output.path}/voucher_receipt_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      print('Error saving PDF: $e');
      rethrow;
    }
  }

  // Helper method for building PDF rows
  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child:
                pw.Text(label, style: pw.TextStyle(color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(value,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 7, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
