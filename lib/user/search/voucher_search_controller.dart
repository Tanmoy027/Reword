import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../my_controller.dart';
import '../userservice/store_model.dart';

class VoucherSearchController extends GetxController {
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final searchResults = <StoreModel>[].obs;

  // Get the existing MyController instance
  final MyController myController = Get.find<MyController>();

  void search(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;

    // Simulate a short delay to mimic network request
    Future.delayed(const Duration(milliseconds: 300), () {
      // Search through the existing storeList from MyController
      searchResults.value = myController.storeList.where((store) {
        return store.storeName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      isLoading.value = false;
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }
}
