// my_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:reword_frontend/login/service/user_service.dart';

import 'userservice/store_model.dart';

class MyController extends GetxController {
  // Category toggles for design
  var selectedCategory = 'Experiences'.obs;
  var selectedTags = <String>[].obs;
  var selectedCategories = <String>[].obs;

  // Loading + error states for store fetching
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // The list of stores from backend:  GET /api/vouchers/stores
  var storeList = <StoreModel>[].obs;

  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  void toggleCategory(String title) {
    selectedCategory.value = title;
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  void toggleCategorySelection(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  // Fetch store data for “Trending Gifts” / “Featured Deals”
  Future<void> fetchStores() async {
    isLoading.value = true;
    errorMessage.value = '';

    final token = await _userService.getToken();
    if (token == null || token.isEmpty) {
      errorMessage.value = 'Authentication token not found. Please login.';
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://voucher-app-backend.vercel.app/api/vouchers/stores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        storeList.value =
            data.map((item) => StoreModel.fromJson(item)).toList();
      } else {
        errorMessage.value =
            'Failed to load stores. Status: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
