import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:reword_frontend/payment/payment_controller.dart';
import 'package:reword_frontend/user/usercart/cart_controller.dart';

class PaymentPage extends StatelessWidget {
  final PaymentController controller;

  PaymentPage({Key? key, required double amount})
      : controller = Get.put(PaymentController(amount: amount)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Payment",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() => Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Information",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    _buildOrderSummary(cartController),
                    SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF158482),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (controller.paymentAmount.value <= 0) {
                                Get.snackbar(
                                  'Error',
                                  'Invalid payment amount',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              try {
                                await controller.processStripePayment();
                              } catch (e) {
                                // Error handling is done in the controller
                              }
                            },
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Pay \€${controller.paymentAmount.value.toStringAsFixed(2)}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),

              // Overlay loading indicator for whole page
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF158482)),
                          ),
                          SizedBox(height: 20),
                          Text("Processing payment...",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  Widget _buildOrderSummary(CartController cartController) {
    // Use actual cart data instead of hardcoded placeholders
    final title = cartController.cartTitle.value.isNotEmpty
        ? cartController.cartTitle.value
        : 'Voucher Purchase';

    final originalPrice = cartController.cartOriginalPrice.value;
    final finalPrice = controller.paymentAmount.value;

    // Only calculate discount if there's a real price difference
    final discount =
        originalPrice > finalPrice ? originalPrice - finalPrice : 0.0;
    final bool hasDiscount = discount > 0;
    final int discountPercentage =
        hasDiscount ? ((discount / originalPrice) * 100).round() : 0;

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildOrderItem(title, "\€${originalPrice.toStringAsFixed(2)}"),
          // Only show discount if there's an actual discount
          if (hasDiscount)
            _buildOrderItem("Discount (${discountPercentage}% off)",
                "-\€${discount.toStringAsFixed(2)}",
                isDiscount: true),
          Divider(),
          _buildOrderItem("Total", "\€${finalPrice.toStringAsFixed(2)}",
              isBold: true),
        ],
      ),
    );
  }

  // Fixed layout to prevent overflow
  Widget _buildOrderItem(String title, String amount,
      {bool isDiscount = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use Expanded for the title to prevent overflow
          Expanded(
            flex: 7,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isDiscount ? Colors.green : Colors.black,
              ),
              // Allow the text to wrap when too long
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          SizedBox(width: 8), // Add some space between title and amount
          // Fixed width for the amount
          Container(
            alignment: Alignment.centerRight,
            width: 90,
            child: Text(
              amount,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isDiscount ? Colors.green : Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
