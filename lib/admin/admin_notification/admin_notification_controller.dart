import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../login/service/user_service.dart';

class AdminNotificationController extends GetxController {
  final UserService _userService = UserService();

  // Loading state
  var isLoading = false.obs;

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Recipient selection
  var selectedRecipient = ''.obs; // 'all', 'buyers', 'sellers'

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void selectRecipient(String recipient) {
    selectedRecipient.value = recipient;
  }

  void clearForm() {
    titleController.clear();
    messageController.clear();
    selectedRecipient.value = '';
  }

  Future<void> sendNotification() async {
    // Validate inputs
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a notification title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (messageController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a notification message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedRecipient.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a recipient group',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final token = await _userService.getToken();

      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Error',
          'Authentication token not found. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Prepare request body to match backend expectations
      bool sendToUsers = false;
      bool sendToSellers = false;

      if (selectedRecipient.value == 'all') {
        sendToUsers = true;
        sendToSellers = true;
      } else if (selectedRecipient.value == 'buyers') {
        sendToUsers = true;
      } else if (selectedRecipient.value == 'sellers') {
        sendToSellers = true;
      }

      final requestBody = {
        'title': titleController.text.trim(),
        'message': messageController.text.trim(),
        'sendToUsers': sendToUsers,
        'sendToSellers': sendToSellers,
      };

      print('Sending notification with body: $requestBody');

      final response = await http.post(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/admin/send-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Notification sent successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF158482),
          colorText: Colors.white,
        );
        clearForm();
      } else {
        print('Failed to send notification: ${response.statusCode}');
        print('Response body: ${response.body}');

        try {
          final responseData = jsonDecode(response.body);
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to send notification',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to send notification: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Exception while sending notification: $e');
      Get.snackbar(
        'Error',
        'An error occurred while sending notification',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
