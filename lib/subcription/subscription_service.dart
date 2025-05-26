import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../login/service/user_service.dart';

class SubscriptionService extends GetxService {
  final String baseUrl = 'https://voucher-app-backend.vercel.app/api';
  final UserService _userService = UserService();

  // For initialization in GetX
  Future<SubscriptionService> init() async {
    return this;
  }

  // Master method to handle entire subscription flow
  Future<bool> processSubscription(String planName, double planPrice) async {
    try {
      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Please log in first');
        return false;
      }

      final sellerId = await _userService.getUserId();
      if (sellerId == null || sellerId.isEmpty) {
        Get.snackbar('Error', 'No sellerId found or not logged in as seller');
        return false;
      }

      // Step 1: Create Subscription - planName is already the backend key
      // FIXED: Don't try to convert planName - it should already be the correct backend key
      final clientSecret = await _createSubscription(
        token,
        sellerId,
        planName, // Already the correct plan name for backend
        planPrice,
      );
      if (clientSecret == null) return false; // Something went wrong

      // Step 2: Show Stripe Payment Sheet
      final paymentSuccess = await _showStripePaymentSheet(clientSecret);
      if (!paymentSuccess) return false;

      // Step 3: Confirm payment success on backend
      return await _confirmPaymentSuccess(token, sellerId, planName);
    } catch (e) {
      print('Error in processSubscription: $e');
      Get.snackbar('Error', 'Something went wrong: $e');
      return false;
    }
  }

  // Creates the subscription on your backend => returns a Stripe clientSecret
  Future<String?> _createSubscription(
    String token,
    String sellerId,
    String planName,
    double planPrice,
  ) async {
    try {
      final initUrl = Uri.parse('$baseUrl/subscription/seller/subscribe');

      // FIXED: Changed from "planName" to "plan" to match backend expectations
      final response = await http.post(
        initUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "sellerId": sellerId,
          "plan":
              planName, // FIXED: Changed key to "plan" to match API expectation
        }),
      );

      if (response.statusCode != 200) {
        print('Error creating subscription: ${response.body}');
        Get.snackbar(
          'Failed to create subscription',
          response.body,
        );
        return null;
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];
      if (clientSecret == null) {
        Get.snackbar('Error', 'No clientSecret returned by backend');
        return null;
      }

      return clientSecret;
    } catch (e) {
      print('Error in _createSubscription: $e');
      Get.snackbar('Error', 'Failed to create subscription: $e');
      return null;
    }
  }

  // Opens the Stripe PaymentSheet
  Future<bool> _showStripePaymentSheet(String clientSecret) async {
    try {
      // 1) Initialize PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Lanza Seller Subscription',
        ),
      );

      // 2) Present PaymentSheet
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      // Payment canceled or Stripe error
      Get.snackbar(
        'Payment Cancelled',
        e.error.localizedMessage ?? 'Unknown Stripe error',
      );
      return false;
    } catch (e) {
      print('Error in _showStripePaymentSheet: $e');
      Get.snackbar('Error', 'Payment failed: $e');
      return false;
    }
  }

  // Tells the backend that the payment was successful
  Future<bool> _confirmPaymentSuccess(
    String token,
    String sellerId,
    String planName,
  ) async {
    try {
      final confirmUrl =
          Uri.parse('$baseUrl/subscription/seller/payment-success');
      final confirmResp = await http.post(
        confirmUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "sellerId": sellerId,
          "plan":
              planName, // FIXED: Changed key to "plan" to match API expectation
        }),
      );

      if (confirmResp.statusCode != 200) {
        print('Error on payment-success: ${confirmResp.body}');
        Get.snackbar(
          'Warning',
          'Stripe payment successful, but finalizing subscription failed.',
        );
        return false;
      }

      return true;
    } catch (e) {
      print('Error in _confirmPaymentSuccess: $e');
      Get.snackbar('Error', 'Failed to confirm payment: $e');
      return false;
    }
  }
}
