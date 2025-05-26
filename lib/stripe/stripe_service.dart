import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:reword_frontend/login/service/user_service.dart';
import 'package:reword_frontend/user/usercart/cart_controller.dart';

class StripeService extends GetxService {
  final String baseUrl = 'https://voucher-app-backend.vercel.app/api';
  final UserService _userService = Get.find<UserService>();

  // Fetch client secret from the backend
  Future<String?> fetchClientSecret(double amount) async {
    try {
      // Get the cart controller
      final cartController = Get.find<CartController>();

      // Check if cart is empty
      if (cartController.cartItems.isEmpty) {
        await cartController.fetchCartItems(); // Refresh the cart first

        // If still empty after refresh, show proper error
        if (cartController.cartItems.isEmpty) {
          Get.snackbar(
            'Empty Cart',
            'Your cart is empty. Please add items before checkout.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return null;
        }
      }

      // Use the provided amount since CartController doesn't have calculateTotalPrice
      final finalAmount = amount;

      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Error',
          'Authentication required. Please log in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      final url = Uri.parse('$baseUrl/cart/checkout/stripe');

      // Log the amount being sent to Stripe for debugging
      print(
          'Sending payment amount to Stripe: €$finalAmount (${(finalAmount * 100).toInt()} cents)');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': (finalAmount * 100)
              .toInt(), // Convert to cents as Stripe requires
          'currency': 'eur', // Changed to EUR to match the € symbol in UI
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['clientSecret'];
      } else {
        print('Failed to fetch clientSecret: ${response.body}');

        // Parse error message if possible
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Unknown error';
        } catch (_) {
          errorMessage = 'Status code: ${response.statusCode}';
        }

        // Handle specific cart empty error
        if (errorMessage.toLowerCase().contains('cart is empty')) {
          Get.snackbar(
            'Cart Error',
            'Please ensure you have items in your cart before checkout',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        } else {
          Get.snackbar(
            'Payment Error',
            'Could not initialize payment: $errorMessage',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return null;
      }
    } catch (e) {
      print('Error fetching clientSecret: $e');
      Get.snackbar(
        'Payment Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }
}
