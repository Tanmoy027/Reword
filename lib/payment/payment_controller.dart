import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/payment/paymentSuccess.dart';
import 'dart:convert';
import 'package:reword_frontend/stripe/stripe_service.dart';
import 'package:reword_frontend/login/service/user_service.dart';
import 'package:reword_frontend/user/usercart/cart_controller.dart';

class PaymentController extends GetxController {
  // Payment state observables
  var isLoading = false.obs;
  var paymentAmount = 0.0.obs;
  var paymentSuccess = false.obs;
  var errorMessage = ''.obs;

  // Store relevant voucher data directly in this controller
  var sellerId = ''.obs;
  var voucherId = ''.obs;
  var priceOptionId = ''.obs;
  var expiryDate = ''.obs;
  var title = ''.obs;

  // Services
  late final StripeService _stripeService;
  late final CartController _cartController;

  // Constructor with amount parameter
  PaymentController({required double amount}) {
    paymentAmount.value = amount;
    print('Payment controller initialized with amount: $amount');

    // Immediately capture necessary data from cart controller
    _captureCartData();
  }

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<StripeService>()) {
      Get.lazyPut(() => StripeService());
    }
    _stripeService = Get.find<StripeService>();

    // Get the cart controller
    if (Get.isRegistered<CartController>()) {
      _cartController = Get.find<CartController>();
    } else {
      _cartController = Get.put(CartController());
    }

    // Make sure cart data is up-to-date
    _cartController.fetchCartItems();
  }

  // Capture cart data when controller is initialized
  void _captureCartData() {
    try {
      if (Get.isRegistered<CartController>()) {
        final cartController = Get.find<CartController>();

        // Log the current cart state
        print("Cart items count: ${cartController.cartItems.length}");
        if (cartController.cartItems.isNotEmpty) {
          print("First cart item: ${cartController.cartItems[0]}");
        }

        // Store all necessary data locally
        sellerId.value = cartController.cartSellerId.value;
        voucherId.value = cartController.cartVoucherId.value;
        priceOptionId.value = cartController.cartPriceOptionId.value;
        expiryDate.value = cartController.cartExpiry.value;
        title.value = cartController.cartTitle.value;

        // Log captured data
        print("Captured seller ID: ${sellerId.value}");
        print("Captured voucher ID: ${voucherId.value}");
        print("Captured price option ID: ${priceOptionId.value}");
        print("Captured title: ${title.value}");

        // If seller ID is still empty but we have a voucher ID, try to get it from the voucher
        if (sellerId.value.isEmpty && voucherId.value.isNotEmpty) {
          _fetchSellerIdForVoucher(voucherId.value);
        }

        // If seller ID is empty but we have cart items, try to get it from there
        if (sellerId.value.isEmpty && cartController.cartItems.isNotEmpty) {
          final firstItem = cartController.cartItems[0];
          // Check if there's a store ID field that might be the seller ID
          if (firstItem['storeId'] != null) {
            sellerId.value = firstItem['storeId'];
            print(
                "Retrieved seller ID from cart item storeId: ${sellerId.value}");
          }
          // Try other potential fields
          else if (firstItem['store'] != null &&
              firstItem['store']['_id'] != null) {
            sellerId.value = firstItem['store']['_id'];
            print(
                "Retrieved seller ID from cart item store._id: ${sellerId.value}");
          }
        }
      } else {
        print("Cart controller not registered");
      }
    } catch (e) {
      print("Error capturing cart data: $e");
    }
  }

  // New method to fetch seller ID directly when needed
  Future<void> _fetchSellerIdForVoucher(String voucherId) async {
    if (voucherId.isEmpty) return;

    try {
      final userService = Get.find<UserService>();
      final token = await userService.getToken();
      if (token == null || token.isEmpty) return;

      print("Fetching seller ID for voucher: $voucherId");

      final response = await http.get(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/vouchers/$voucherId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['voucher'] != null && data['voucher']['sellerId'] != null) {
          sellerId.value = data['voucher']['sellerId'];
          print("Retrieved seller ID from API: ${sellerId.value}");
        } else if (data['sellerId'] != null) {
          sellerId.value = data['sellerId'];
          print("Retrieved seller ID from API: ${sellerId.value}");
        }
      } else {
        print("Failed to fetch voucher details: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching seller ID: $e");
    }
  }

  // Process payment using Stripe Payment Sheet and then place the order
  Future<void> processStripePayment() async {
    if (paymentAmount.value <= 0) {
      Get.snackbar('Error', 'Invalid payment amount: €${paymentAmount.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    // Re-capture cart data to ensure we have the latest
    _captureCartData();

    // Make sure the cart is up to date on the server
    if (Get.isRegistered<CartController>()) {
      final cartController = Get.find<CartController>();
      await cartController.fetchCartItems();

      // Try one more time to capture the data after refresh
      _captureCartData();
    }

    try {
      isLoading(true);
      errorMessage('');

      // Check seller ID before proceeding
      if (sellerId.value.isEmpty) {
        // If we have the voucher ID but no seller ID, try one last time to fetch it
        if (voucherId.value.isNotEmpty) {
          await _fetchSellerIdForVoucher(voucherId.value);
        }

        // If still empty, show error
        if (sellerId.value.isEmpty) {
          Get.snackbar(
              'Error', 'Unable to process payment: Missing seller information',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 5));
          isLoading(false);
          return;
        }
      }

      // Check if cart is empty
      if (_cartController.cartItems.isEmpty) {
        Get.snackbar('Error',
            'Your cart appears to be empty. Please add items before checkout.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5));
        isLoading(false);
        return;
      }

      // Log the amount being processed for debugging
      print(
          'Processing payment for €${paymentAmount.value.toStringAsFixed(2)}');

      // Get client secret from backend
      final clientSecret =
          await _stripeService.fetchClientSecret(paymentAmount.value);
      if (clientSecret == null || clientSecret.isEmpty) {
        errorMessage('Failed to create payment intent');
        isLoading(false);
        return;
      }

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'King Spa & Sauna NJ',
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF158482),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12.0,
              shadow: PaymentSheetShadowParams(color: Colors.black),
            ),
          ),
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment succeeded, now place the order in the backend
      try {
        final orderData = await _placeOrder();
        if (orderData != null) {
          paymentSuccess(true);
          Get.snackbar('Payment Successful',
              'Your payment has been processed and order placed successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
          // Navigate to PaymentSuccessPage with order data and amount
          Get.to(() => PaymentSuccessPage(
              order: orderData, amount: paymentAmount.value));
        } else {
          paymentSuccess(false);
          Get.snackbar('Order Failed',
              'Payment was successful but order placement failed. Please contact support.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 5));
        }
      } catch (orderError) {
        print("Order placement error: $orderError");
        paymentSuccess(false);
        Get.snackbar('Order Failed',
            'Payment was successful but order placement failed: ${orderError.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5));
      }
    } catch (e) {
      paymentSuccess(false);
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
          Get.snackbar('Payment Canceled', 'You canceled the payment process.',
              snackPosition: SnackPosition.BOTTOM);
        } else {
          errorMessage(e.error.localizedMessage ?? 'Payment failed');
          Get.snackbar('Payment Failed', 'Error: ${e.error.localizedMessage}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        errorMessage('An unexpected error occurred: $e');
        print('Payment error: $e');
        Get.snackbar('Payment Failed', 'An unexpected error occurred: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } finally {
      isLoading(false);
    }
  }

  // Private function to place the order using your backend API.
  Future<Map<String, dynamic>?> _placeOrder() async {
    try {
      final userService = Get.find<UserService>();
      final token = await userService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Verify we have the seller ID before proceeding
      if (sellerId.value.isEmpty) {
        throw Exception('Missing seller ID');
      }
      if (voucherId.value.isEmpty) {
        throw Exception('Missing voucher ID');
      }

      print("Placing order with data:");
      print("Seller ID: ${sellerId.value}");
      print("Voucher ID: ${voucherId.value}");
      print("Price Option ID: ${priceOptionId.value}");
      print("Title: ${title.value}");
      print("Amount: ${paymentAmount.value}");

      // Use the correct endpoint
      final url = 'https://voucher-app-backend.vercel.app/api/order/place';

      // Construct payload based on backend API requirements
      final payload = {
        "sellerId": sellerId.value,
        "vouchers": [
          {
            "voucherId": voucherId.value,
            "priceOptionId": priceOptionId.value,
            "status": "Active",
            "expiryDate": expiryDate.value,
            "amount": paymentAmount.value,
            "title": title.value.isNotEmpty ? title.value : "Voucher Purchase",
          }
        ],
        "totalAmount": paymentAmount.value
      };

      print("Sending order payload: ${jsonEncode(payload)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(payload),
      );

      print("Order API response status: ${response.statusCode}");
      print("Order API response body: ${response.body}");

      // Handle different status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Order placed successfully: $data");

        // Clear the cart after successful order
        if (Get.isRegistered<CartController>()) {
          final cartController = Get.find<CartController>();
          await cartController.clearCart();
        }

        return data['order'];
      } else {
        // Detailed error message from API
        final errorMessage = _extractErrorMessage(response.body);
        throw Exception(
            'Order API error (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print("Order placement exception: $e");
      rethrow; // Rethrow to allow specific error handling
    }
  }

  // Helper to extract error message from API response
  String _extractErrorMessage(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      return data['message'] ?? data['error'] ?? responseBody;
    } catch (_) {
      return responseBody;
    }
  }
}
