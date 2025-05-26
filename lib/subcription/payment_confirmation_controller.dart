import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/subcription/subscription_success_screen.dart';

class PaymentConfirmationController extends GetxController {
  final cardNumber = ''.obs;
  final cardHolderName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get payment details passed from previous screen
    if (Get.arguments != null) {
      cardNumber.value = Get.arguments['cardNumber'] ?? '';
      cardHolderName.value = Get.arguments['cardHolderName'] ?? '';
    }
  }

  void confirmPayment() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      Get.back(); // Close loading dialog

      // Navigate to success screen
      Get.off(() => SubscriptionSuccessScreen());
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Payment confirmation failed',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
