import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/service/user_service.dart';

class SellerDashboardController extends GetxController {
  final UserService userService = UserService();

  // Loading indicator
  var isLoading = true.obs;

  // All stats from single endpoint /api/vouchers/seller/voucher-stats
  var totalSales = 0.0.obs;
  var totalVouchers = 0.obs;
  var expiredVouchers = 0.obs;
  var voucherStatsSold = 0.obs;
  var totalCustomers = 0.obs;
  var sellerId = ''.obs;

  // For toggling "Experiences" vs "Excursions"
  var isExperiencesSelected = true.obs;

  // Totals by category (we'll keep these for UI purposes)
  var experiencesTotal = 0.obs;
  var excursionsTotal = 0.obs;

  // Expired by category (we'll keep these for UI purposes)
  var experiencesExpired = 0.obs;
  var excursionsExpired = 0.obs;

  // Computed active per category
  int get experiencesActive =>
      experiencesTotal.value - experiencesExpired.value;
  int get excursionsActive => excursionsTotal.value - excursionsExpired.value;

  // Computed overall active vouchers
  int get activeVouchers => totalVouchers.value - expiredVouchers.value;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  /// Toggle between "Experiences" and "Excursions" in the UI
  void toggleCategory(bool isExp) {
    isExperiencesSelected.value = isExp;
  }

  /// Fetch stats from the single endpoint
  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      final token = await userService.getToken();
      if (token == null || token.isEmpty) {
        throw 'No token found. Please log in again.';
      }

      // Clear old data
      totalSales.value = 0;
      totalVouchers.value = 0;
      expiredVouchers.value = 0;
      voucherStatsSold.value = 0;
      totalCustomers.value = 0;
      sellerId.value = '';
      experiencesTotal.value = 0;
      excursionsTotal.value = 0;
      experiencesExpired.value = 0;
      excursionsExpired.value = 0;

      await _fetchVoucherStats(token);

      // For demo purposes, set some experience/excursion dummy data
      // In a real app, you might want to get this from another endpoint
      // or add it to the voucher-stats endpoint
      setDummyCategoryData();
    } catch (e) {
      print("Exception in fetchStats: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Get all data from the single endpoint
  Future<void> _fetchVoucherStats(String token) async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/vouchers/seller/voucher-stats'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Map all fields from the response
        sellerId.value = data['sellerId'] ?? '';
        totalCustomers.value = data['totalCustomers'] ?? 0;
        totalVouchers.value = data['totalVouchers'] ?? 0;
        expiredVouchers.value = data['expiredVouchers'] ?? 0;
        voucherStatsSold.value = data['totalVouchersSold'] ?? 0;

        // Convert totalRevenue to double
        final double revenue =
            double.tryParse(data['totalRevenue']?.toString() ?? '0') ?? 0.0;
        totalSales.value = revenue;

        // Debug printouts
        print('API Stats - sellerId: ${sellerId.value}');
        print('API Stats - totalCustomers: ${totalCustomers.value}');
        print('API Stats - totalVouchers: ${totalVouchers.value}');
        print('API Stats - expiredVouchers: ${expiredVouchers.value}');
        print('API Stats - totalVouchersSold: ${voucherStatsSold.value}');
        print('API Stats - totalRevenue: ${totalSales.value}');
      } else {
        print('Warning: /seller/voucher-stats failed => '
            '${res.statusCode}, body=${res.body}');
      }
    } catch (e) {
      print('Exception in _fetchVoucherStats: $e');
    }
  }

  /// Set dummy data for category breakdown (experiences vs excursions)
  /// In a real app, you would get this from the API
  void setDummyCategoryData() {
    // For demo purposes, distribute total vouchers between experiences and excursions
    final total = totalVouchers.value;
    final expTotal = (total * 0.6).round(); // 60% experiences
    final excTotal = total - expTotal; // 40% excursions

    experiencesTotal.value = expTotal;
    excursionsTotal.value = excTotal;

    // For demo purposes, distribute expired vouchers
    final expired = expiredVouchers.value;
    final expExpired = (expired * 0.7).round(); // 70% experiences expired
    final excExpired = expired - expExpired; // 30% excursions expired

    experiencesExpired.value = expExpired;
    excursionsExpired.value = excExpired;

    print('Experiences total: $expTotal, Excursions total: $excTotal');
    print('Experiences expired: $expExpired, Excursions expired: $excExpired');
  }
}
