import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'voucher_model.dart';
import '../addnewvoucher/voucher_details_popup.dart';
import 'voucher_controller.dart';

class VoucherCard extends GetView<VoucherController> {
  final VoucherModel voucher;

  const VoucherCard({
    super.key,
    required this.voucher,
  });

  /// Show the voucher details popup
  void _showVoucherDetailsPopup() {
    Get.bottomSheet(
      VoucherDetailsPopup(voucher: voucher),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Top: Title + Delete icon
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Trash
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        voucher.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      color: Colors.grey[600],
                      onPressed: () => controller.deleteVoucher(voucher.id),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Some stats rows...
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text('Units Sold:'),
                    const SizedBox(width: 8),
                    Text('${voucher.unitsSold}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.euro_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text('Revenue:'),
                    const SizedBox(width: 8),
                    Text('\$${voucher.revenue.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.pie_chart_outline, size: 20),
                    const SizedBox(width: 8),
                    const Text('Conversion Rate:'),
                    const SizedBox(width: 8),
                    Text('${voucher.conversionRate.toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 8),
                    const Text('Time Remaining:'),
                    const SizedBox(width: 8),
                    Text(
                      '${voucher.daysRemaining} days',
                      style: TextStyle(
                        color: voucher.daysRemaining < 10
                            ? Colors.red[400]
                            : Colors.blue[400],
                      ),
                    ),
                  ],
                ),

                // Show status row only if voucherStatus is not null
                if (voucher.voucherStatus != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        voucher.isActive
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 20,
                        color: voucher.isActive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      const Text('Status:'),
                      const SizedBox(width: 8),
                      Text(
                        voucher.voucherStatus ?? 'Unknown',
                        style: TextStyle(
                          color: voucher.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Dashed line
          CustomPaint(
            painter: DashedLinePainter(),
            size: const Size(double.infinity, 1),
          ),

          // Bottom: Buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Edit -> opens voucher details popup
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showVoucherDetailsPopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Expire -> calls expireVoucher if it's still active
                Expanded(
                  child: OutlinedButton(
                    onPressed: voucher.isActive
                        ? () => controller.expireVoucher(voucher.id)
                        : null,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      side: BorderSide(
                        color: voucher.isActive ? Colors.teal : Colors.grey,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Expire',
                      style: TextStyle(
                        color: voucher.isActive ? Colors.teal : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dashed line painter
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
