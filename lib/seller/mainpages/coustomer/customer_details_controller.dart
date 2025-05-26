import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/login/service/user_service.dart';

class CustomerDetailsController extends GetxController {
  var selectedCategory = 'customers'.obs;
  var expandedCustomerIndex = (-1).obs;
  var customers = <Customer>[].obs;
  var filteredCustomers = <Customer>[].obs;

  // Manually count the customers
  var experienceCustomerCount = 0.obs;
  var expersionsCustomerCount = 0.obs;

  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void toggleExpansion(int index, bool isExpanded) {
    expandedCustomerIndex.value = isExpanded ? index : -1;
  }

  // Filter customers based on search query
  void filterCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomers.assignAll(customers);
    } else {
      filteredCustomers.assignAll(customers
          .where((customer) =>
              customer.name.toLowerCase().contains(query.toLowerCase()) ||
              customer.email.toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
  }

  // Fetch the real list of customers for the seller from the backend
  Future<void> fetchCustomers() async {
    customers.clear();
    filteredCustomers.clear();
    experienceCustomerCount.value = 0;
    expersionsCustomerCount.value = 0;

    try {
      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        print('Token not found. Please log in.');
        return;
      }

      final url = 'https://voucher-app-backend.vercel.app/api/order/customers';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched customers: $data'); // Debug print

        if (data is List) {
          final customerList = data.map((custJson) {
            return Customer(
              name: custJson['name'] ?? '',
              email: custJson['email'] ?? '',
              totalVouchers: custJson['totalBought'] ?? 0,
              returned: custJson['returned'] ?? 0,
              vouchers: (custJson['vouchers'] as List).map((vJson) {
                return Voucher(
                  title: vJson['voucherId'] ?? 'Voucher',
                  status: vJson['status'] ?? '',
                  expiryDate: vJson['expiryDate'] ?? '',
                  purchaseDate: 'N/A',
                );
              }).toList(),
            );
          }).toList();

          customers.assignAll(customerList);
          filteredCustomers.assignAll(customerList);

          // Manually count Experience and Expersions customers
          countCustomerCategories();
        } else {
          print('Unexpected data format: $data');
        }
      } else {
        print('Error fetching customers: ${response.body}');
      }
    } catch (e) {
      print('Exception fetching customers: $e');
    }
  }

  // Function to manually count Experience and Expersions customers
  void countCustomerCategories() {
    int expCount = 0;
    int expersCount = 0;

    for (var customer in customers) {
      if (customer.totalVouchers > 50) {
        expCount++;
      } else {
        expersCount++;
      }
    }

    experienceCustomerCount.value = expCount;
    expersionsCustomerCount.value = expersCount;

    print('Experience Customers: $expCount');
    print('Expersions Customers: $expersCount');
  }
}

class Customer {
  final String name;
  final String email;
  final int totalVouchers;
  final int returned;
  final List<Voucher> vouchers;

  Customer({
    required this.name,
    required this.email,
    required this.totalVouchers,
    required this.returned,
    required this.vouchers,
  });
}

class Voucher {
  final String title;
  final String status;
  final String expiryDate;
  final String purchaseDate;

  Voucher({
    required this.title,
    required this.status,
    required this.expiryDate,
    required this.purchaseDate,
  });
}
