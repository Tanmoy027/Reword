import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/user/usercart/my_cart_page.dart';
import 'package:reword_frontend/user/usercart/cart_controller.dart';
import 'package:reword_frontend/user/uservoucher/vm.dart';

import '../favorites/my_favorites_controller.dart';

class Vcard extends StatelessWidget {
  final Vm voucher;
  final bool
      isSecondOption; // Flag to identify if this is the second price option
  final VoidCallback buyNow;

  const Vcard(
      {super.key,
      required this.voucher,
      this.isSecondOption = false, // Default to false for first option
      required this.buyNow});

  @override
  Widget build(BuildContext context) {
    // Get CartController instance
    final CartController cartController = Get.put(CartController());
    // Get FavoritesController instance
    final FavoritesController favoritesController =
        Get.put(FavoritesController());

    // Determine which price option values to use based on isSecondOption flag
    final String priceOptionTitle =
        isSecondOption ? voucher.priceOptionTitle2 : voucher.priceOptionTitle1;
    final double oldPrice =
        isSecondOption ? voucher.oldPrice2 : voucher.oldPrice;
    final double newPrice =
        isSecondOption ? voucher.newPrice2 : voucher.newPrice;
    final String priceOptionId =
        isSecondOption ? voucher.priceOptionId2 : voucher.priceOptionId;

    // Check if this voucher with this specific price option is already in favorites
    bool isInFavoritesWithThisPriceOption() {
      return favoritesController.isVoucherWithPriceOptionInFavorites(
          voucher.id, priceOptionId);
    }

    // Calculate if there's an actual discount
    final bool hasDiscount = oldPrice > newPrice;

    // Print seller ID for debugging
    print('Vcard build - Seller ID: ${voucher.sellerId}');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Voucher Information Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + favorite icon
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
                    Obx(() => IconButton(
                          color: isInFavoritesWithThisPriceOption()
                              ? Colors.red
                              : Colors.grey[600],
                          onPressed: () {
                            if (isInFavoritesWithThisPriceOption()) {
                              favoritesController
                                  .removeFromFavorites(voucher.id);
                            } else {
                              favoritesController.addToFavorites(
                                voucherId: voucher.id,
                                priceOptionId:
                                    priceOptionId, // Use the selected price option ID
                                title: voucher.title,
                                price: newPrice, // Use the selected price
                                originalPrice:
                                    oldPrice, // Use the selected original price
                                expiryDate: voucher.expires,
                                sellerId: voucher.sellerId,
                              );
                            }
                          },
                          icon: Icon(
                            isInFavoritesWithThisPriceOption()
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                // Price Option Title
                const Text(
                  'Price Option',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Single Price Option
                Row(
                  children: [
                    Text('$priceOptionTitle: '),
                    // Only show old price if there's a real discount
                    hasDiscount
                        ? Flexible(
                            child: Text(
                              "RRP: \€$oldPrice -> ",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(),
                    hasDiscount ? const SizedBox(width: 8) : Container(),
                    Text('| \€$newPrice'),
                  ],
                ),
                const SizedBox(height: 12),
                // Terms & Conditions
                const Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms and Condition',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('Valid for one-time entry'),
                        Text('Re-entry not permitted'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Dashed Line
          CustomPaint(
            painter: DashedLinePainter(),
            size: const Size(double.infinity, 1),
          ),
          // Buttons Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              // Use different color based on isSecondOption flag
              color: isSecondOption
                  ? const Color(0xFFF3DAA5) // #F3DAA5 for second option
                  : Colors.purple.shade50, // Original color for first option
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                // Only show discount text if there's a real discount
                hasDiscount
                    ? Text(
                        '${((oldPrice - newPrice) / oldPrice * 100).toStringAsFixed(0)}% off',
                      )
                    : Container(),
                const SizedBox(width: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      print(
                          'Buy Now pressed with seller ID: ${voucher.sellerId}');

                      // FIXED: Always use buyNow=true for direct purchase
                      cartController.addToCart(
                        sellerId: voucher.sellerId,
                        voucherId: voucher.id,
                        priceOptionId:
                            priceOptionId, // Use the selected price option ID
                        title: voucher.title,
                        price: newPrice, // Use the selected price
                        originalPrice:
                            oldPrice, // Use the selected original price
                        expiryDate: voucher.expires,
                        buyNow: true, // Direct purchase
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(color: Colors.teal),
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
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
