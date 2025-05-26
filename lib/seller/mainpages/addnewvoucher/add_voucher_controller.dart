import 'dart:convert';
import 'package:intl/intl.dart'; // for date formatting
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:reword_frontend/login/service/user_service.dart';

class AddVoucherController extends GetxController {
  final UserService _userService = UserService();

  // Loading & success states:
  var isLoading = false.obs;
  var isSuccess = false.obs;
  var errorMessage = ''.obs;

  // Form controllers:
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController termsController;
  late TextEditingController durationController;
  late TextEditingController
      couponCodeController; // Updated from conversionRate

  // Category toggles:
  var isExperienceSelected = true.obs;
  var isExcursionsSelected = false.obs;

  // For picking the duration unit (hours/days/months):
  var selectedDurationUnit = 'days'.obs;

  // Price options: a list of maps, each containing 3 text controllers
  var priceOptions = <Map<String, TextEditingController>>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize text fields
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    termsController = TextEditingController();
    durationController = TextEditingController();
    couponCodeController =
        TextEditingController(); // New controller for coupon code

    // Initialize a default single price option
    priceOptions.add({
      'title': TextEditingController(),
      'salePrice': TextEditingController(),
      'actualPrice': TextEditingController(),
    });
  }

  @override
  void onClose() {
    // Clean up controllers
    titleController.dispose();
    descriptionController.dispose();
    termsController.dispose();
    durationController.dispose();
    couponCodeController.dispose(); // Dispose the new controller

    for (final option in priceOptions) {
      option['title']?.dispose();
      option['salePrice']?.dispose();
      option['actualPrice']?.dispose();
    }
    super.onClose();
  }

  /// Adds a new triple of text controllers for a new price option row.
  void addPriceOption() {
    priceOptions.add({
      'title': TextEditingController(),
      'salePrice': TextEditingController(),
      'actualPrice': TextEditingController(),
    });
  }

  /// Preview method if you have a "Preview" feature
  void previewVoucher() {
    // Implement a preview if needed...
  }

  /// Saves/creates a new voucher via POST, then sets isSuccess=true if it worked.
  Future<void> saveVoucher() async {
    isLoading.value = true;
    isSuccess.value = false;
    errorMessage.value = '';

    try {
      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Token not found. Please login first.';
        isLoading.value = false;
        return;
      }

      // Build category from checkboxes
      String selectedCategory = '';
      if (isExperienceSelected.value) {
        selectedCategory = 'Experience';
      } else if (isExcursionsSelected.value) {
        selectedCategory = 'Excursion';
      }

      // Convert price option text controllers to data
      final List<Map<String, dynamic>> priceOptionsData =
          priceOptions.map((option) {
        return {
          'title': option['title']?.text.trim() ?? '',
          'salePrice':
              double.tryParse(option['salePrice']?.text.trim() ?? '0') ?? 0,
          'actualPrice':
              double.tryParse(option['actualPrice']?.text.trim() ?? '0') ?? 0,
        };
      }).toList();

      // Convert "duration" + "unit" --> a final expiry date (yyyy-MM-dd)
      final int durValue = int.tryParse(durationController.text.trim()) ?? 0;
      final String durUnit = selectedDurationUnit.value;

      DateTime now = DateTime.now();
      DateTime computedExpiry;
      if (durUnit == 'hours') {
        computedExpiry = now.add(Duration(hours: durValue));
      } else if (durUnit == 'months') {
        // a quick approximate method to add months
        computedExpiry = DateTime(
          now.year,
          now.month + durValue,
          now.day,
          now.hour,
          now.minute,
          now.second,
        );
      } else {
        // default is 'days'
        computedExpiry = now.add(Duration(days: durValue));
      }
      String expiryDateString =
          DateFormat('yyyy-MM-ddTHH:mm:ss.sssZ').format(computedExpiry);

      // Prepare request data
      final requestData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': selectedCategory,
        'expiryDate': expiryDateString,
        'priceOptions': priceOptionsData,
        'couponCode':
            couponCodeController.text.trim(), // Updated from conversionRate
        'terms': termsController.text.trim(),
      };

      // POST to create the voucher
      final response = await http.post(
        Uri.parse('https://voucher-app-backend.vercel.app/api/vouchers/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {
        // Mark success so the UI can close automatically
        isSuccess.value = true;
      } else {
        errorMessage.value =
            'Failed to create voucher.\nStatus: ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
