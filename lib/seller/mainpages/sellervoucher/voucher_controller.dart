import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/login/service/user_service.dart';
import 'voucher_model.dart';

class VoucherController extends GetxController {
  final RxBool isExperiencesSelected = true.obs;
  final RxInt selectedMetricIndex = 0.obs;
  final RxList<VoucherModel> vouchers = <VoucherModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCategoryLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final UserService _userService = UserService();
  final RxInt activeVouchersCount = 0.obs;
  final RxInt expiredVouchersCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    isLoading.value = true;
    errorMessage.value = '';

    final token = await _userService.getToken();
    if (token == null || token.isEmpty) {
      errorMessage.value =
          'Authentication token not found. Please login again.';
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://voucher-app-backend.vercel.app/api/vouchers/seller'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debug the response
        print('Fetch vouchers response: ${response.body}');

        vouchers.assignAll(
          (data['vouchers'] as List)
              .map((v) => VoucherModel.fromJson(v))
              .toList(),
        );
        updateVoucherCounts();
      } else {
        errorMessage.value =
            'Failed to load vouchers. Status: ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExpiredVouchers() async {
    isLoading.value = true;
    errorMessage.value = '';

    final token = await _userService.getToken();
    if (token == null || token.isEmpty) {
      errorMessage.value =
          'Authentication token not found. Please login again.';
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/vouchers/seller/expired'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debug the response
        print('Fetch expired vouchers response: ${response.body}');

        // Make sure we're checking both potential structures
        if (data.containsKey('expiredVouchers') &&
            data['expiredVouchers'] is List) {
          vouchers.assignAll(
            (data['expiredVouchers'] as List)
                .map((v) => VoucherModel.fromJson(v))
                .toList(),
          );
        } else if (data.containsKey('vouchers') && data['vouchers'] is List) {
          vouchers.assignAll(
            (data['vouchers'] as List)
                .map((v) => VoucherModel.fromJson(v))
                .toList(),
          );
        } else {
          // If structure is different, show empty list and debug
          print('Unexpected response structure: $data');
          vouchers.clear();
        }
        updateVoucherCounts();

        // Show feedback to the user
        if (vouchers.isEmpty) {
          Get.snackbar(
            'Expired Vouchers',
            'No expired vouchers found',
            backgroundColor: Colors.amber.withOpacity(0.7),
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        errorMessage.value =
            'Failed to load expired vouchers. Status: ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void updateVoucherCounts() {
    activeVouchersCount.value = vouchers.where((v) => v.isActive).length;
    expiredVouchersCount.value = vouchers.where((v) => !v.isActive).length;
  }

  void toggleCategory(bool value) {
    // Only show loading if we're actually changing category
    if (isExperiencesSelected.value != value) {
      isCategoryLoading.value = true;

      // Simulate network delay
      Future.delayed(const Duration(milliseconds: 800), () {
        isExperiencesSelected.value = value;
        isCategoryLoading.value = false;
      });
    }
  }

  void selectMetric(int index) {
    selectedMetricIndex.value = index;
    switch (index) {
      case 0:
        fetchVouchers(); // All Vouchers
        break;
      case 1:
        // "Add new Voucher" – your UI will show Add popup
        break;
      case 2:
        // Expired Vouchers - fetch from the server
        fetchExpiredVouchers();
        break;
    }
  }

  void addVoucher(VoucherModel voucher) {
    vouchers.add(voucher);
    updateVoucherCounts();
  }

  /// Mark a voucher as expired
  Future<void> expireVoucher(String voucherId) async {
    final token = await _userService.getToken();
    if (token == null) {
      Get.snackbar('Error', 'No token found. Please login again.');
      return;
    }

    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final response = await http.put(
        Uri.parse(
          'https://voucher-app-backend.vercel.app/api/vouchers/seller/expire/$voucherId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        // Debug the response
        print('Expire voucher response: ${response.body}');

        // Update the voucher status in the local list
        final index = vouchers.indexWhere((v) => v.id == voucherId);
        if (index != -1) {
          vouchers[index].voucherStatus = 'expired';
          vouchers[index].isActive = false;
          vouchers.refresh(); // Force UI update
        }
        updateVoucherCounts();

        // Refetch vouchers if we're in the "All Vouchers" view
        if (selectedMetricIndex.value == 0) {
          await fetchVouchers();
        } else if (selectedMetricIndex.value == 2) {
          // If we're in the expired vouchers view, refresh that list
          await fetchExpiredVouchers();
        }

        Get.snackbar(
          'Success',
          'Voucher marked as expired',
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Expire Failed',
          'Status: ${response.statusCode}\n${response.body}',
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog if there's an error
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
