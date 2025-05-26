import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../login/service/user_service.dart';

class AdminClientsCustomersController extends GetxController {
  var clients = <Client>[].obs;
  var customers = <Customer>[].obs;
  var sellers = <Seller>[].obs;
  var isLoading = true.obs;

  final UserService userService = UserService();

  @override
  void onInit() {
    super.onInit();
    fetchSellers();
  }

  Future<void> fetchSellers() async {
    isLoading.value = true;
    print("Fetching sellers...");
    String? token = await userService.getToken();
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('https://voucher-app-backend.vercel.app/api/admin/sellers'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          print("API Response: $data");

          sellers.value =
              (data as List).map((seller) => Seller.fromJson(seller)).toList();

          print("Parsed sellers: ${sellers.length}");
          for (var seller in sellers) {
            print("Seller ID: ${seller.sellerId}, Name: ${seller.name}");
          }

          // Convert sellers to clients for display in the clients section
          clients.value = sellers
              .map((seller) => Client(
                    seller.sellerId,
                    seller.name,
                    seller.email,
                    true, // Default published
                    true, // Default active
                  ))
              .toList();

          // Also populate customers with seller data
          customers.value = sellers
              .map((seller) => Customer(
                    seller.sellerId,
                    seller.name,
                    seller.email,
                  ))
              .toList();
        } else {
          print('Failed to load sellers: ${response.statusCode}');
          print('Response body: ${response.body}');
          Get.snackbar(
            'Error',
            'Failed to load clients and customers data',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        print('Error fetching sellers: $e');
        Get.snackbar(
          'Error',
          'An error occurred while loading data',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      print('No authentication token found');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Authentication required',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navigate to seller dashboard view
  void navigateToAdminSellerDashboardView(String sellerId) {
    print('Navigating to seller dashboard with ID: $sellerId');
    Get.toNamed(
      '/adminseller-dashboard',
      arguments: {'sellerId': sellerId},
    );
  }

  void togglePublished(Client client) {
    client.published = !client.published;
    clients.refresh();
  }

  void toggleActive(Client client) {
    client.active = !client.active;
    clients.refresh();
  }

  void removeClient(Client client) {
    clients.remove(client);
    Get.snackbar("Deleted", "${client.name} removed!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }
}

class Seller {
  final String sellerId;
  final String name;
  final String email;
  final String storeName;
  final double totalRevenue;
  final int activeVouchers;

  Seller(
      {required this.sellerId,
      required this.name,
      required this.email,
      required this.storeName,
      required this.totalRevenue,
      required this.activeVouchers});

  factory Seller.fromJson(Map<String, dynamic> json) {
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

class Client {
  final String sellerId;
  final String name;
  final String email;
  bool published;
  bool active;

  Client(this.sellerId, this.name, this.email, this.published, this.active);
}

class Customer {
  final String sellerId;
  final String name;
  final String email;

  Customer(this.sellerId, this.name, this.email);
}
