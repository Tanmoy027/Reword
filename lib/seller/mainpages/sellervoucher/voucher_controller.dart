import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/login/service/user_service.dart';
import 'voucher_model.dart';

class VoucherController extends GetxController {
  final RxBool isExperiencesSelected = true.obs;
  final RxInt selectedMetricIndex = 0.obs;
  final RxList<VoucherModel> vouchers = <VoucherModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCategoryLoading =
      false.obs; // New loading state for category switch
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
        // Expired Vouchers
        filterExpiredVouchers();
        break;
    }
  }

  void filterExpiredVouchers() {
    // Filter in-memory to show only non-active
    vouchers.assignAll(vouchers.where((v) => !v.isActive).toList());
  }

  void addVoucher(VoucherModel voucher) {
    vouchers.add(voucher);
    updateVoucherCounts();
  }

  /// DELETE a voucher by ID:
  /// -> If the real route is `DELETE /api/vouchers/<id>` instead of `delete/<id>`,
  ///    adjust the Uri.parse() below.
  Future<void> deleteVoucher(String voucherId) async {
    final token = await _userService.getToken();
    if (token == null) {
      Get.snackbar('Error', 'No token found. Please login again.');
      return;
    }

    try {
      // If the route is actually `DELETE /api/vouchers/<id>`,
      // then remove "/delete" from below:
      final response = await http.delete(
        Uri.parse(
          'https://voucher-app-backend.vercel.app/api/vouchers/delete/$voucherId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Remove from local list & re-fetch to ensure we see the current data
        vouchers.removeWhere((v) => v.id == voucherId);
        updateVoucherCounts();

        // Optional but recommended: fetch again from server
        await fetchVouchers();

        Get.snackbar('Deleted', 'Voucher deleted successfully');
      } else {
        Get.snackbar(
          'Delete Failed',
          'Status: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  /// Mark a voucher as expired (PUT /api/vouchers/:id with { voucherStatus: "expired" })
  /// -> If your server uses a different field or route to expire,
  ///    change the body or endpoint accordingly.
  Future<void> expireVoucher(String voucherId) async {
    final token = await _userService.getToken();
    if (token == null) {
      Get.snackbar('Error', 'No token found. Please login again.');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
          'https://voucher-app-backend.vercel.app/api/vouchers/$voucherId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'voucherStatus': 'expired',
        }),
      );

      if (response.statusCode == 200) {
        // Mark local item as expired
        final index = vouchers.indexWhere((v) => v.id == voucherId);
        if (index != -1) {
          vouchers[index].voucherStatus = 'expired';
          vouchers[index].isActive = false;
        }
        updateVoucherCounts();

        // Also re-fetch from server to ensure data is correct on refresh
        await fetchVouchers();

        Get.snackbar('Voucher Expired', 'Voucher marked as expired');
      } else {
        Get.snackbar(
          'Expire Failed',
          'Status: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
