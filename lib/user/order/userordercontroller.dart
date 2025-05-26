import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../login/service/user_service.dart';

class OrderHistoryController {
  final UserService _userService = UserService();
  final String _baseUrl = 'https://voucher-app-backend.vercel.app/api';

  Future<List<Map<String, dynamic>>> fetchBuyerOrders() async {
    try {
      // Get the token from UserService
      final token = await _userService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Make API request to get the buyer's orders
      final response = await http.get(
        Uri.parse('$_baseUrl/order/buyer-orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['orders'] != null) {
          return List<Map<String, dynamic>>.from(data['orders']);
        }
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
            'Failed to load orders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Function to format date string
  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Function to check if a voucher is expired
  bool isVoucherExpired(String expiryDateString) {
    final expiryDate = DateTime.parse(expiryDateString);
    final now = DateTime.now();
    return expiryDate.isBefore(now);
  }
}
