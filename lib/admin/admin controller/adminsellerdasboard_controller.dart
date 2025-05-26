import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../login/service/user_service.dart';

class SellerDashboardController extends GetxController {
  final String sellerId;
  final UserService userService = UserService();

  var sellerData = Rx<Seller?>(null);
  var isLoading = true.obs;
  var error = ''.obs;

  // Stats that will be displayed
  var soldVouchers = 0.obs;
  var expiredVouchers = 0.obs;
  var totalCustomers = 0.obs;

  SellerDashboardController({required this.sellerId});

  @override
  void onInit() {
    super.onInit();
    print("SellerDashboardController initialized with sellerId: $sellerId");
    fetchSellerDetails();
  }

  Future<void> fetchSellerDetails() async {
    isLoading.value = true;
    error.value = '';

    try {
      print("Fetching seller details for ID: $sellerId");
      String? token = await userService.getToken();
      if (token != null) {
        final response = await http.get(
          Uri.parse('https://voucher-app-backend.vercel.app/api/admin/sellers'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          // The endpoint returns an array of sellers
          final List<dynamic> data = json.decode(response.body);

          // Find the matching seller by sellerId
          final sellerInfo = data.firstWhere(
            (seller) => seller['sellerId'] == sellerId,
            orElse: () => null,
          );

          if (sellerInfo != null) {
            sellerData.value = Seller.fromJson(sellerInfo);
            print("Seller data set: ${sellerData.value?.name}");

            // Instead of using dummy data, pull stats from the API if they exist.
            soldVouchers.value = sellerInfo['soldVouchers'] ?? 0;
            expiredVouchers.value = sellerInfo['expiredVouchers'] ?? 0;
            totalCustomers.value = sellerInfo['totalCustomers'] ?? 0;
          } else {
            error.value = 'Seller not found for ID $sellerId';
            print("Error: Seller with ID $sellerId not found");
          }
        } else {
          error.value = 'Failed to load seller details: ${response.statusCode}';
          print('Response body: ${response.body}');
        }
      } else {
        error.value = 'Authentication token not found';
        print("Error: Authentication token not found");
      }
    } catch (e) {
      error.value = 'Error: ${e.toString()}';
      print('Error fetching seller details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }
}

class Seller {
  final String sellerId;
  final String name;
  final String email;
  final String storeName;
  final double totalRevenue;
  final int activeVouchers;

  Seller({
    required this.sellerId,
    required this.name,
    required this.email,
    required this.storeName,
    required this.totalRevenue,
    required this.activeVouchers,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    print("Creating Seller from json: $json");
    return Seller(
      sellerId: json['sellerId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      storeName: json['storeName'] ?? '',
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      activeVouchers: json['activeVouchers'] ?? 0,
    );
  }
}
