import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../sellervoucher/voucher_model.dart';

// Controller to manage the counter state
class VoucherCountController extends GetxController {
  final RxInt count = 1.obs;

  void increment() {
    count.value++;
  }

  void decrement() {
    if (count.value > 1) {
      count.value--;
    }
  }
}

// Using GetX properly with a StatelessWidget
class VoucherPreviewPopup extends StatelessWidget {
  final VoucherModel voucher;
  final bool isFromAddVoucher;

  // Initialize the controller - best practice in GetX is to use Get.put or Get.find
  final VoucherCountController countController =
      Get.put(VoucherCountController());

  VoucherPreviewPopup({
    super.key,
    required this.voucher,
    this.isFromAddVoucher = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: () => Get.back(),
              ),
            ),

            // Scrollable content area
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Voucher title
                      Text(
                        voucher.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price Options header
                      const Text(
                        'Price Options',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Price options list - Fixed to access PriceOption properties directly
                      ...(voucher.priceOptions ?? [])
                          .map((option) => _buildPriceOption(
                                title: option.title,
                                actualPrice: option.actualPrice.toString(),
                                salePrice: option.salePrice.toString(),
                              ))
                          .toList(),

                      const SizedBox(height: 16),

                      // Terms and conditions - using description instead of terms
                      const Text(
                        'Term and Condition',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        voucher.description ??
                            'Valid for one-time entry.\nRe-entry not permitted.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Expiry date
                      Text(
                        'Expires in ${voucher.expiryDate ?? '2025-12-31'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),

                      // Counter
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: countController.decrement,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Obx to observe the count value
                          Obx(() => Text(
                                '${countController.count.value}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: countController.increment,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Dashed divider
            CustomPaint(
              painter: DashedLinePainter(),
              size: const Size(double.infinity, 1),
            ),

            // Discount section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '12% off',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'with promo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceOption({
    required String title,
    required String actualPrice,
    required String salePrice,
  }) {
    final hasDiscount = actualPrice.isNotEmpty &&
        salePrice.isNotEmpty &&
        actualPrice != salePrice &&
        actualPrice != "0.0";

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          if (hasDiscount)
            Text(
              'RRP: $actualPrice',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            salePrice,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasDiscount)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '12% off',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom Painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 7, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
