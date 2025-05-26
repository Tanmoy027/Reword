// lib/cart/my_cart_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/payment/payment.dart';
import 'package:reword_frontend/stripe/stripe_service.dart';
import 'cart_controller.dart';

class MyCartPage extends StatelessWidget {
  MyCartPage({super.key});

  final CartController cartController = Get.find<CartController>();

  // Calculate the total amount to pay
  double calculateTotalAmount() {
    return cartController.getTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Cart"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => cartController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart Item Card
                    Card(
                      color: Color(0xFFDDEDEE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/spa.jpg',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cartController.cartTitle.value,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Adult Admission"),
                                  Text(
                                      "Expires in ${cartController.cartExpiry.value}",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  Row(
                                    children: [
                                      Text(
                                          "\€${cartController.cartPrice.value}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(width: 8),
                                      Text(
                                          "\€${cartController.cartOriginalPrice.value}",
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          )),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text("12% off",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Quantity Controller
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () =>
                                      cartController.increaseQuantity(),
                                ),
                                Text("${cartController.quantity.value}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () =>
                                      cartController.decreaseQuantity(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Gift Card Input
                    Text("Gift Card",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Input Code",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Payment Details
                    Text("Payment Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Subtotal", style: TextStyle(fontSize: 16)),
                        Text(
                            "\€${cartController.subtotal.value.toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("To Pay", style: TextStyle(fontSize: 16)),
                        Text("\€${calculateTotalAmount().toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Spacer(),
                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: () {
                          // Make sure StripeService is registered before navigating
                          if (!Get.isRegistered<StripeService>()) {
                            Get.put(StripeService());
                          }

                          // Call checkout method from controller
                          cartController.checkout();

                          // Get the actual total amount to pay
                          final totalAmount = calculateTotalAmount();

                          // Navigate to payment page with the correct amount
                          Get.to(() => PaymentPage(amount: totalAmount));
                        },
                        child: Text("Checkout",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}
