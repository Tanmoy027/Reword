import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../login/service/user_service.dart';

class PaymentController extends GetxController {
  final UserService _userService = UserService();
  final baseUrl = 'https://voucher-app-backend.vercel.app/api';

  // Form fields
  final cardHolderName = ''.obs;
  final cardNumber = ''.obs;
  final expiryDate = ''.obs;
  final cvv = ''.obs;
  final selectedMethod = 'Credit Card'.obs;
  final isFormValid = false.obs;

  // List of payment methods
  final paymentMethods = <String>[
    'Credit Card',
    'Visa',
    'MasterCard',
  ];

  @override
  void onInit() {
    super.onInit();
    // Listen to form fields changes to validate the form
    ever(cardHolderName, (_) => validateForm());
    ever(cardNumber, (_) => validateForm());
    ever(expiryDate, (_) => validateForm());
    ever(cvv, (_) => validateForm());
  }

  // Set payment method
  void setPaymentMethod(String method) {
    selectedMethod.value = method;
  }

  // Validate the form
  void validateForm() {
    isFormValid.value = cardHolderName.value.isNotEmpty &&
        cardNumber.value.isNotEmpty &&
        expiryDate.value.isNotEmpty &&
        cvv.value.isNotEmpty &&
        validateCardHolderName(cardHolderName.value) == null &&
        validateCardNumber(cardNumber.value) == null &&
        validateExpiryDate(expiryDate.value) == null &&
        validateCvv(cvv.value) == null;
  }

  // Validate card holder name
  String? validateCardHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the card holder name';
    }
    if (value.length < 3) {
      return 'Name is too short';
    }
    return null;
  }

  // Validate card number
  String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the card number';
    }

    // Remove spaces for validation
    final sanitized = value.replaceAll(' ', '');

    if (sanitized.length != 16) {
      return 'Card number must be 16 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(sanitized)) {
      return 'Card number must contain only digits';
    }
    return null;
  }

  // Validate expiry date
  String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the expiry date';
    }

    if (!RegExp(r'^\d{2}/\d{4}$').hasMatch(value)) {
      return 'Invalid format. Use MM/YYYY';
    }

    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) {
      return 'Invalid date format';
    }

    if (month < 1 || month > 12) {
      return 'Invalid month';
    }

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card is expired';
    }

    return null;
  }

  // Validate CVV
  String? validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the CVV';
    }
    if (value.length != 3) {
      return 'CVV must be 3 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'CVV must contain only digits';
    }
    return null;
  }

  // Submit form and proceed to payment
  Future<void> submitForm() async {
    try {
      final arguments = Get.arguments as Map<String, dynamic>;
      final planName = arguments['planName'] as String;
      final planPrice = arguments['planPrice'] as double;

      // Here you could do a separate flow, or
      // call your direct subscription logic.

      // For demonstration, let's just show a confirmation:
      Get.snackbar(
        'Card Info',
        'Payment details received.\nPlan: $planName\nPrice: \$${planPrice.toStringAsFixed(2)}',
      );
      // Then proceed with your subscription logic if desired
      // ...
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process payment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
