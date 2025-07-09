import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../login/service/user_service.dart';

class RedeemVoucherController extends GetxController {
  final couponCodeController = TextEditingController();
  final buyerNameController = TextEditingController();
  final buyerEmailController = TextEditingController();

  final UserService _userService =
      UserService(); // Create an instance of UserService

  var isLoading = false.obs;
  var usedVouchers = [].obs;
  var totalUsedVouchers = 0.obs;
  var redeemSuccess = false.obs;
  var redeemedVoucher = Rx<Map<String, dynamic>?>(null);
  var errorMessage = ''.obs;
  var currentDate = ''.obs;
  var currentUser = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsedVouchers();
    setCurrentDateTime();
    getUserName();
  }

  @override
  void onClose() {
    couponCodeController.dispose();
    buyerNameController.dispose();
    buyerEmailController.dispose();
    super.onClose();
  }

  // Set the current date and time
  void setCurrentDateTime() {
    final now = DateTime.now().toUtc();
    currentDate.value =
        '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
  }

  // Format numbers as two digits
  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  // Get the current user's name
  Future<void> getUserName() async {
    try {
      final userInfo = await _userService.getUserInfo();
      currentUser.value = userInfo['name'] ?? 'Unknown User';
    } catch (e) {
      print('Error getting user name: $e');
    }
  }

  void clearForm() {
    couponCodeController.clear();
    buyerNameController.clear();
    buyerEmailController.clear();
    redeemSuccess.value = false;
    redeemedVoucher.value = null;
    errorMessage.value = '';
  }

  Future<void> redeemVoucher() async {
    if (couponCodeController.text.isEmpty) {
      errorMessage.value = 'Coupon code is required';
      return;
    }

    if (buyerNameController.text.isEmpty) {
      errorMessage.value = 'Buyer name is required';
      return;
    }

    if (buyerEmailController.text.isEmpty) {
      errorMessage.value = 'Buyer email is required';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get the auth token from UserService
      String? token = await _userService.getToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'Authentication error. Please login again.';
        isLoading.value = false;
        return;
      }

      final response = await http.post(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/vouchers/seller/mark-used'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'couponCode': couponCodeController.text,
          'buyerName': buyerNameController.text,
          'buyerEmail': buyerEmailController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        redeemSuccess.value = true;
        redeemedVoucher.value = data['voucher'];
        await fetchUsedVouchers(); // Refresh the used vouchers list
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to redeem voucher';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsedVouchers() async {
    try {
      isLoading.value = true;

      // Get the auth token from UserService
      String? token = await _userService.getToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'Authentication error. Please login again.';
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/vouchers/seller/used'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        usedVouchers.value = data['vouchers'] ?? [];
        totalUsedVouchers.value = data['total'] ?? 0;
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to fetch used vouchers';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
