import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/login/service/user_service.dart';
import 'package:reword_frontend/payment/payment.dart';
import 'package:reword_frontend/user/usercart/my_cart_page.dart';

class CartController extends GetxController {
  final UserService _userService = UserService();

  // Cart items count/quantity
  var quantity = 1.obs;
  var subtotal = 0.0.obs;
  var selectedPriceOption = Rx<Map<String, dynamic>?>(null);

  // Cart item data
  var cartTitle = ''.obs;
  var cartPrice = 0.0.obs;
  var cartOriginalPrice = 0.0.obs;
  var cartExpiry = ''.obs;

  // Store seller and voucher IDs
  var cartSellerId = ''.obs;
  var cartVoucherId = ''.obs;
  var cartPriceOptionId = ''.obs;

  // Loading state
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Store cart items for checking duplicates
  var cartItems = [].obs;

  @override
  void onInit() {
    super.onInit();
    updateSubtotal();
    fetchCartItems(); // Fetch cart items when controller initializes
  }

  // Check if a voucher with specific price option is already in cart
  bool isVoucherWithPriceOptionInCart(String voucherId, String priceOptionId) {
    return cartItems.any((item) =>
        item['voucherId'] == voucherId &&
        item['priceOptionId'] == priceOptionId);
  }

  // Fetch current cart items from the server
  Future<void> fetchCartItems() async {
    try {
      isLoading.value = true;
      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse('https://voucher-app-backend.vercel.app/api/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['cart'] ?? [];
        cartItems.assignAll(items);
        print('Fetched ${cartItems.length} cart items');

        // Update cart summary data for UI display
        if (cartItems.isNotEmpty) {
          // Use the first cart item for display
          final firstItem = cartItems[0];
          cartTitle.value = firstItem['title'] ?? '';

          // Important: Get seller ID properly - the API might not include it directly
          // Try to get sellerId from different fields
          if (firstItem['sellerId'] != null) {
            cartSellerId.value = firstItem['sellerId'];
          } else {
            // If sellerId is not in the cart item, fetch it from the voucher
            await _fetchSellerIdFromVoucher(firstItem['voucherId']);
          }

          print('Updated cartSellerId: ${cartSellerId.value}');
          cartVoucherId.value = firstItem['voucherId'] ?? '';
          cartPriceOptionId.value = firstItem['priceOptionId'] ?? '';
          cartExpiry.value = firstItem['expiryDate'] ?? '';

          // CRITICAL: Make sure to extract price from priceOption
          if (firstItem['priceOption'] != null) {
            cartPrice.value =
                (firstItem['priceOption']['salePrice'] ?? 0.0).toDouble();
            cartOriginalPrice.value =
                (firstItem['priceOption']['actualPrice'] ?? 0.0).toDouble();
            print('Cart price updated to: ${cartPrice.value}');
          }

          // Update the subtotal
          updateSubtotal();
        } else {
          // Reset cart data if cart is empty
          resetCartData();
        }
      } else {
        print('Failed to fetch cart items: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // New method to fetch seller ID from voucher details
  Future<void> _fetchSellerIdFromVoucher(String voucherId) async {
    if (voucherId == null || voucherId.isEmpty) {
      print('Cannot fetch seller ID: voucher ID is empty');
      return;
    }

    try {
      final token = await _userService.getToken();
      if (token == null || token.isEmpty) return;

      // Call the voucher details API to get the seller ID
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
        // Extract sellerId from voucher details
        if (data['voucher'] != null && data['voucher']['sellerId'] != null) {
          cartSellerId.value = data['voucher']['sellerId'];
          print('Retrieved sellerId from voucher API: ${cartSellerId.value}');
        } else if (data['sellerId'] != null) {
          cartSellerId.value = data['sellerId'];
          print('Retrieved sellerId from voucher API: ${cartSellerId.value}');
        } else {
          print('Seller ID not found in voucher details');
          // If your API has store information in the response, you could use that
          // For example: cartSellerId.value = data['storeId'];
        }
      } else {
        print('Failed to fetch voucher details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching voucher details: $e');
    }
  }

  // Reset cart data
  void resetCartData() {
    cartTitle.value = '';
    cartSellerId.value = '';
    cartVoucherId.value = '';
    cartPriceOptionId.value = '';
    cartExpiry.value = '';
    cartPrice.value = 0.0;
    cartOriginalPrice.value = 0.0;
    quantity.value = 1;
    updateSubtotal();
  }

  // Increase quantity
  void increaseQuantity() {
    quantity.value++;
    updateSubtotal();
  }

  // Decrease quantity
  void decreaseQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
      updateSubtotal();
    }
  }

  // Update subtotal based on price and quantity
  void updateSubtotal() {
    subtotal.value = cartPrice.value * quantity.value;
    print('Subtotal updated: ${subtotal.value}');
  }

  // Get total amount to pay
  double getTotalAmount() {
    return subtotal.value;
  }

  // Add item to cart with duplicate checking
  Future<void> addToCart({
    required String sellerId,
    required String voucherId,
    required String priceOptionId,
    required String title,
    required double price,
    required double originalPrice,
    required String expiryDate,
    bool buyNow = false, // Parameter for direct purchase
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Set cart item data - do this BEFORE any API calls to ensure data is saved
    cartTitle.value = title;
    cartPrice.value = price;
    cartOriginalPrice.value = originalPrice;
    cartExpiry.value = expiryDate;
    cartSellerId.value = sellerId;
    print('Setting cartSellerId: $sellerId');
    cartVoucherId.value = voucherId;
    cartPriceOptionId.value = priceOptionId;
    quantity.value = 1; // Reset quantity
    updateSubtotal();

    final token = await _userService.getToken();
    if (token == null || token.isEmpty) {
      errorMessage.value = 'Token not found. Please log in.';
      isLoading.value = false;
      Get.snackbar(
        'Login Required',
        'Please log in to purchase vouchers',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // FIRST always add to cart API - whether regular or buy now flow
    try {
      // Check if already in cart (for both regular flow and buy now)
      await fetchCartItems();
      if (isVoucherWithPriceOptionInCart(voucherId, priceOptionId)) {
        // Item is already in cart - for buy now, just proceed to payment
        if (buyNow) {
          isLoading.value = false;
          _navigateToPaymentPage(price);
          return;
        } else {
          // For regular cart flow, show message and navigate to cart
          Get.snackbar(
            'Already in Cart',
            'This voucher with this price option is already in your cart',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          isLoading.value = false;
          Get.to(() => MyCartPage());
          return;
        }
      }

      // Not in cart, need to add it
      final response = await http.post(
        Uri.parse('https://voucher-app-backend.vercel.app/api/cart/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'voucherId': voucherId,
          'priceOptionId': priceOptionId,
        }),
      );

      print('Add to cart API response: ${response.statusCode}');
      print('Add to cart API body: ${response.body}');

      if (response.statusCode == 201) {
        // Refresh cart items to update our local state
        await fetchCartItems();

        // Handle flow based on buyNow flag
        if (buyNow) {
          isLoading.value = false;
          _navigateToPaymentPage(price);
        } else {
          Get.snackbar(
            'Success',
            'Voucher added to cart',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          isLoading.value = false;
          // Navigate to cart page for regular cart flow
          Get.to(() => MyCartPage());
        }
      } else if (response.statusCode == 400 &&
          response.body
              .contains('Voucher already in cart with this price option')) {
        // Item is already in cart (this shouldn't normally happen since we check earlier)
        if (buyNow) {
          isLoading.value = false;
          _navigateToPaymentPage(price);
        } else {
          Get.snackbar(
            'Already in Cart',
            'This voucher with this price option is already in your cart',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          isLoading.value = false;
          Get.to(() => MyCartPage());
        }
      } else {
        errorMessage.value =
            'Failed to add to cart. Status: ${response.statusCode}';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      isLoading.value = false;
    }
  }

  // Helper method to navigate to payment page
  void _navigateToPaymentPage(double price) {
    // Print debug info before navigating
    print('Navigating to payment with:');
    print('Seller ID: ${cartSellerId.value}');
    print('Voucher ID: ${cartVoucherId.value}');
    print('Price Option ID: ${cartPriceOptionId.value}');
    print('Title: ${cartTitle.value}');
    print('Price: $price');

    Get.to(() => PaymentPage(amount: price));
  }

  // Proceed to checkout
  void checkout() {
    if (cartItems.isEmpty || subtotal.value <= 0) {
      Get.snackbar(
        'Error',
        'Your cart is empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Print debug info before checkout
    print('Checking out with:');
    print('Seller ID: ${cartSellerId.value}');
    print('Voucher ID: ${cartVoucherId.value}');
    print('Price Option ID: ${cartPriceOptionId.value}');
    print('Subtotal: ${subtotal.value}');

    // Go to payment page with the current subtotal
    _navigateToPaymentPage(subtotal.value);
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      isLoading.value = true;

      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'Login Required',
          'Please log in to remove items from cart',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final response = await http.delete(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/cart/remove/$cartItemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Refresh cart to update UI
        await fetchCartItems();
        Get.snackbar(
          'Item Removed',
          'Item has been removed from your cart',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('Failed to remove item: ${response.statusCode}');
        print('Response: ${response.body}');
        Get.snackbar(
          'Error',
          'Failed to remove item from cart',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error removing item: $e');
      Get.snackbar(
        'Error',
        'An error occurred while removing the item',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      isLoading.value = true;

      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        isLoading.value = false;
        return;
      }

      final response = await http.delete(
        Uri.parse('https://voucher-app-backend.vercel.app/api/cart/clear'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        cartItems.clear();
        resetCartData();

        Get.snackbar(
          'Cart Cleared',
          'All items have been removed from your cart',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to clear cart',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error clearing cart: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
