import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/service/user_service.dart';

class AdminNotificationController extends GetxController {
  final UserService _userService = UserService();

  final title = ''.obs;
  final message = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  // Text editing controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Updated recipient group options
  final allUsers = false.obs;
  final buyerUsers = false.obs;
  final sellerUsers = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add listeners to update the observable values when text changes
    titleController.addListener(() {
      title.value = titleController.text;
    });
    messageController.addListener(() {
      message.value = messageController.text;
    });
  }

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void setTitle(String value) {
    title.value = value;
    titleController.text = value;
  }

  void setMessage(String value) {
    message.value = value;
    messageController.text = value;
  }

  void clearFields() {
    title.value = '';
    message.value = '';
    titleController.clear();
    messageController.clear();
    errorMessage.value = '';
    successMessage.value = '';
  }

  void toggleAllUsers(bool? value) {
    if (value == true) {
      allUsers.value = true;
      buyerUsers.value = false;
      sellerUsers.value = false;
    } else {
      allUsers.value = false;
    }
    // Clear any previous error message when selection changes
    errorMessage.value = '';
  }

  void toggleBuyerUsers(bool? value) {
    buyerUsers.value = value ?? false;
    if (buyerUsers.value) {
      allUsers.value = false;
    }
    // Clear any previous error message when selection changes
    errorMessage.value = '';
  }

  void toggleSellerUsers(bool? value) {
    sellerUsers.value = value ?? false;
    if (sellerUsers.value) {
      allUsers.value = false;
    }
    // Clear any previous error message when selection changes
    errorMessage.value = '';
  }

  // Updated getter to ensure proper reactivity
  bool get isRecipientSelected {
    // Force the reactive values to be read correctly
    final all = allUsers.value;
    final buyers = buyerUsers.value;
    final sellers = sellerUsers.value;
    print(
        'Checking recipient selection: All: $all, Buyers: $buyers, Sellers: $sellers');
    return all || buyers || sellers;
  }

  Future<void> sendNotification() async {
    // Debug print to see the actual values of the checkboxes
    print(
        'Recipients - All: ${allUsers.value}, Buyers: ${buyerUsers.value}, Sellers: ${sellerUsers.value}');

    // Add direct check of isRecipientSelected here
    print('isRecipientSelected: ${isRecipientSelected}');

    if (titleController.text.trim().isEmpty) {
      errorMessage.value = "Notification title cannot be empty";
      return;
    }

    if (messageController.text.trim().isEmpty) {
      errorMessage.value = "Notification message cannot be empty";
      return;
    }

    // Force a fresh check of the recipient selection status
    final recipientSelected = isRecipientSelected;
    if (!recipientSelected) {
      errorMessage.value = "At least one recipient group must be selected";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final token = await _userService.getToken();

      if (token == null || token.isEmpty) {
        errorMessage.value =
            'Authentication token not found. Please login again.';
        isLoading.value = false;
        return;
      }

      final Map<String, dynamic> recipients = {
        'allUsers': allUsers.value,
        'buyerUsers': buyerUsers.value,
        'sellerUsers': sellerUsers.value,
      };

      // Debug print to check what's being sent in the API call
      print('Sending notification with recipients: $recipients');

      final response = await http.post(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/admin/send-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': titleController.text,
          'message': messageController.text,
          'recipients': recipients,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        successMessage.value = "Notification sent successfully";
        clearFields(); // Use the new clearFields method
      } else {
        try {
          final responseData = jsonDecode(response.body);
          errorMessage.value =
              responseData['message'] ?? 'Failed to send notification';
        } catch (e) {
          errorMessage.value =
              'Failed to send notification: ${response.statusCode}';
        }
      }
    } catch (e) {
      errorMessage.value = "An error occurred: ${e.toString()}";
      print('Error sending notification: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
