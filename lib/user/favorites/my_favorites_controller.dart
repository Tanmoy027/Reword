import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/service/user_service.dart';
import '../uservoucher/vm.dart';

class FavoritesController extends GetxController {
  // Get UserService lazily when needed
  UserService get _userService => Get.find<UserService>();

  // Observable variables
  var favoriteItems = <Map<String, dynamic>>[].obs;
  var favoriteVouchers = <Vm>[].obs;

  // Map to keep track of cart item IDs for each voucher
  var voucherToCartItemMap = <String, String>{}.obs;

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      checkLoginStatus();
      fetchFavorites();
    } catch (e) {
      print("Error initializing FavoritesController: $e");
      errorMessage.value = "Error initializing: $e";
    }
  }

  // Check login status
  Future<void> checkLoginStatus() async {
    try {
      final token = await _userService.getToken();
      isLoggedIn.value = token != null && token.isNotEmpty;
    } catch (e) {
      print("Error checking login status: $e");
      isLoggedIn.value = false;
    }
  }

  // Check if a voucher is in favorites
  bool isVoucherFavorite(String voucherId) {
    return favoriteItems.any((item) => item['voucherId'] == voucherId);
  }

  // Check if a voucher with specific price option is in favorites
  bool isVoucherWithPriceOptionInFavorites(
      String voucherId, String priceOptionId) {
    return favoriteItems.any((item) =>
        item['voucherId'] == voucherId &&
        item['priceOptionId'] == priceOptionId);
  }

  // Get the price option ID for a voucher
  String getPriceOptionForVoucher(String voucherId) {
    final item = favoriteItems.firstWhere(
      (item) => item['voucherId'] == voucherId,
      orElse: () => {'priceOptionId': ''},
    );
    return item['priceOptionId'] ?? '';
  }

  // Fetch favorites from the cart API
  Future<void> fetchFavorites() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        isLoggedIn.value = false;
        errorMessage.value = 'Token not found';
        isLoading.value = false;
        return;
      }

      isLoggedIn.value = true;

      final response = await http.get(
        Uri.parse('https://voucher-app-backend.vercel.app/api/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> cartItems = data['cart'] ?? [];

        print('Fetched ${cartItems.length} favorites from cart API');

        // Clear existing items
        favoriteItems.clear();
        favoriteVouchers.clear();
        voucherToCartItemMap.clear();

        // Convert each cart item to a favorites item
        for (var item in cartItems) {
          // Ensure all required fields are present
          if (item['voucherId'] != null && item['priceOptionId'] != null) {
            final String voucherId = item['voucherId'];
            final String cartItemId = item['_id'] ?? '';

            // Store the mapping of voucher ID to cart item ID
            if (cartItemId.isNotEmpty) {
              voucherToCartItemMap[voucherId] = cartItemId;
            }

            // Store the favorite item data
            favoriteItems.add({
              'voucherId': voucherId,
              'priceOptionId': item['priceOptionId'],
              'title': item['title'] ?? 'Unknown Voucher',
              'price': item['priceOption']?['salePrice'] ?? 0,
              'originalPrice': item['priceOption']?['actualPrice'] ?? 0,
              'expiryDate': item['expiryDate'] ?? '',
              'sellerId': item['sellerId'] ?? '',
              'cartItemId': cartItemId, // Store cart item ID for removal
            });

            // Create a basic voucher from cart item data
            favoriteVouchers.add(Vm(
              id: voucherId,
              sellerId: item['sellerId'] ?? '',
              priceOptionId: item['priceOptionId'],
              priceOptionId2: '',
              title: item['title'] ?? 'Unknown Voucher',
              priceOptionTitle1:
                  item['priceOption']?['title'] ?? 'Standard Option',
              priceOptionTitle2: '',
              oldPrice: (item['priceOption']?['actualPrice'] ?? 0).toDouble(),
              newPrice: (item['priceOption']?['salePrice'] ?? 0).toDouble(),
              oldPrice2: 0,
              newPrice2: 0,
              expires: item['expiryDate'] ?? '',
              isActive: true,
              inc: () {},
              dec: () {},
            ));
          }
        }

        print(
            'Created ${favoriteVouchers.length} voucher objects from cart data');
        print(
            'Mapped ${voucherToCartItemMap.length} vouchers to their cart item IDs');
      } else {
        print('Failed to fetch cart: ${response.statusCode}');
        print('Response body: ${response.body}');
        errorMessage.value =
            'Failed to fetch favorites: ${response.statusCode}';
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      errorMessage.value = 'Error fetching favorites: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Add to favorites
  Future<void> addToFavorites({
    required String voucherId,
    required String priceOptionId,
    required String title,
    required double price,
    required double originalPrice,
    required String expiryDate,
    required String sellerId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check if already in favorites with this price option
      if (isVoucherWithPriceOptionInFavorites(voucherId, priceOptionId)) {
        Get.snackbar(
          'Already in Favorites',
          'This voucher with this price option is already in your favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        isLoading.value = false;
        return;
      }

      // Get token for authentication
      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        isLoggedIn.value = false;
        Get.snackbar(
          'Login Required',
          'Please log in to add items to favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        isLoading.value = false;
        return;
      }

      isLoggedIn.value = true;

      // Add to cart API call
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

      print('Add to favorites API response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Extract the cartItem from the response
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['cartItem'] != null &&
              responseData['cartItem']['_id'] != null) {
            final cartItemId = responseData['cartItem']['_id'];
            print('Received cart item ID: $cartItemId for voucher: $voucherId');
            voucherToCartItemMap[voucherId] = cartItemId;
          }
        } catch (e) {
          print('Error parsing add response: $e');
        }

        // Refresh the whole list to ensure we have the latest data
        fetchFavorites();

        Get.snackbar(
          'Added to Favorites',
          'Item has been added to your favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else if (response.statusCode == 400 &&
          response.body
              .contains('Voucher already in cart with this price option')) {
        // If it's already in cart, still consider it added to favorites
        // and refresh the list to ensure we have it
        fetchFavorites();

        Get.snackbar(
          'Already in Favorites',
          'This voucher is already in your favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('Failed to add to favorites: ${response.statusCode}');
        print('Response body: ${response.body}');
        Get.snackbar(
          'Error',
          'Failed to add to favorites. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error adding to favorites: $e');
      errorMessage.value = 'Error adding to favorites: $e';
      Get.snackbar(
        'Error',
        'Failed to add to favorites. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Remove from favorites - Critical bug fix for backend mismatch
  Future<void> removeFromFavorites(String voucherId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get token for authentication
      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        isLoggedIn.value = false;
        Get.snackbar(
          'Login Required',
          'Please log in to remove items from favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        isLoading.value = false;
        return;
      }

      isLoggedIn.value = true;

      // Find matching items in our local favoriteItems
      final matchingItems = favoriteItems
          .where((item) => item['voucherId'] == voucherId)
          .toList();

      if (matchingItems.isEmpty) {
        Get.snackbar(
          'Not Found',
          'This item was not found in your favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        isLoading.value = false;
        return;
      }

      // THIS IS THE CRITICAL FIX: Your backend expects voucherId parameter but uses it as cartItemId
      // Use direct API request to communicate directly with server
      bool anyRemoved = false;

      for (var item in matchingItems) {
        // Get the actual cart item ID from our stored data
        final cartItemId = item['cartItemId'];

        if (cartItemId == null || cartItemId.isEmpty) {
          continue;
        }

        // First attempt - send the cartItemId to the voucherId parameter
        var response = await http.delete(
          Uri.parse(
              'https://voucher-app-backend.vercel.app/api/cart/remove/$cartItemId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          anyRemoved = true;
          break;
        } else {
          print(
              'Backend error response: ${response.statusCode}, body: ${response.body}');

          // Second attempt - try the actual voucher ID as a fallback
          response = await http.delete(
            Uri.parse(
                'https://voucher-app-backend.vercel.app/api/cart/remove/$voucherId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200 || response.statusCode == 204) {
            anyRemoved = true;
            break;
          }
        }
      }

      // Always remove locally regardless of server response
      favoriteItems.removeWhere((item) => item['voucherId'] == voucherId);
      favoriteVouchers.removeWhere((voucher) => voucher.id == voucherId);

      // Notify user
      if (anyRemoved) {
        Get.snackbar(
          'Removed from Favorites',
          'Item has been removed from your favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        // Refresh to get updated list
        await fetchFavorites();
      } else {
        Get.snackbar(
          'Removed Locally',
          'Item could not be removed from server but was removed locally',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      errorMessage.value = 'Error removing from favorites: $e';
      Get.snackbar(
        'Error',
        'Failed to remove from favorites. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear all favorites
  void clearFavorites() {
    favoriteItems.clear();
    favoriteVouchers.clear();
    voucherToCartItemMap.clear();
  }
}
