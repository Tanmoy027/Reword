import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../login/service/user_service.dart';
import 'payment_method_screen.dart';
import 'subscription_service.dart';
import 'subscription_success_screen.dart';

class PaymentPage extends StatefulWidget {
  final String planName;
  final double planPrice;

  const PaymentPage({
    Key? key,
    required this.planName,
    required this.planPrice,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final String baseUrl = 'https://voucher-app-backend.vercel.app/api';
  final UserService _userService = UserService();
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();

  final List<Map<String, dynamic>> paymentMethods = [
    {
      "name": "Credit Card",
      "icon": Icons.credit_card,
      "balance": null,
    },
    {
      "name": "Google Pay",
      "icon": Icons.payment,
      "email": "n*********@gmail.com",
    },
    {
      "name": "Apple Pay",
      "icon": Icons.apple,
      "email": "n*********@gmail.com",
    },
    {
      "name": "Visa",
      "icon": Icons.credit_card,
    },
    {
      "name": "Master Card",
      "icon": Icons.credit_card,
    },
  ];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Select Payment Method",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Plan details section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.teal,
                        radius: 20,
                        child: Icon(Icons.card_membership, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.planName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Annual subscription: \$${widget.planPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Payment Methods
                Expanded(
                  child: ListView.builder(
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = paymentMethods[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to payment details screen
                          Get.to(
                            () => PaymentMethodScreen(),
                            arguments: {
                              'planName': widget.planName,
                              'planPrice': widget.planPrice,
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                child:
                                    Icon(method["icon"], color: Colors.black),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method["name"],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (method.containsKey("email"))
                                      Text(
                                        method["email"],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Direct Payment Button (Stripe PaymentSheet flow)
                GestureDetector(
                  onTap: _isLoading ? null : () => _handleDirectPayment(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A9D8F),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        "Proceed with Stripe",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2A9D8F),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Uses SubscriptionService to handle subscription creation,
  /// payment, and confirmation, then navigates to success screen.
  Future<void> _handleDirectPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _subscriptionService.processSubscription(
        widget.planName,
        widget.planPrice,
      );

      if (success) {
        // Navigate to success screen
        Get.offAll(() => SubscriptionSuccessScreen());
      }
    } catch (e) {
      print('Error in direct payment: $e');
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
