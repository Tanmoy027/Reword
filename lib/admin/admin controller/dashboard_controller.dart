import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../login/service/user_service.dart';

class DashboardController extends GetxController {
  var isLoading = true.obs;
  var totalRevenue = "€0.00".obs;
  var totalCustomers = "0".obs;
  var activeVouchers = "0".obs;
  var sales = "0".obs;
  var activeVoucherCount = 0.obs;
  var soldVoucherCount = 0.obs;
  var sellersWithVouchers = "0".obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdminStats();
  }

  // Fetching statistics from backend
  Future<void> fetchAdminStats() async {
    isLoading.value = true;
    try {
      final token = await UserService().getToken();
      final url = Uri.parse(
          'https://voucher-app-backend.vercel.app/api/admin/admin-stats');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        totalRevenue.value = "€${data['totalRevenue']}";
        totalCustomers.value = data['totalCustomers'].toString();
        activeVouchers.value = data['totalActiveVouchers'].toString();
        sales.value = data['totalSoldVouchers'].toString();
        activeVoucherCount.value = data['totalActiveVouchers'];
        soldVoucherCount.value = data['totalSoldVouchers'];
        sellersWithVouchers.value = data['sellersWithVouchers'].toString();
      } else {
        // Handle error if necessary
        print('Failed to load stats: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to load dashboard data',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Exception while loading stats: $e');
      Get.snackbar(
        'Error',
        'An error occurred while loading data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
