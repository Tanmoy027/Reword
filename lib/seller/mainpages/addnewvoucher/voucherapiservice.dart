import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../login/service/user_service.dart';

class VoucherApiService {
  static const String baseUrl =
      'https://voucher-app-backend.vercel.app/api/vouchers/add';
  final UserService _userService = UserService();

  // Get token from UserService
  Future<String?> getToken() async {
    return await _userService.getToken();
  }

  Future<Map<String, dynamic>> addVoucher({
    required String category,
    required String title,
    required String description,
    required String expiryDate,
    required List<Map<String, dynamic>> priceOptions,
    required double conversionRate,
  }) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/vouchers/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'category': category,
          'title': title,
          'description': description,
          'expiryDate': expiryDate,
          'priceOptions': priceOptions,
          'conversionRate': conversionRate,
        }),
      );

      final responseData = jsonDecode(response.body);
      print('Server response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 401) {
        await _userService.clearUserData();
        Get.offAllNamed('/sellerlogin');
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to add voucher: '
            '${responseData['message'] ?? response.body}');
      }
    } catch (e) {
      print('Error adding voucher: $e');
      throw Exception('Error adding voucher: $e');
    }
  }

  // A simple test method (unchanged)
  Future<bool> testConnection() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token available');
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/vouchers'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('Test connection: ${response.statusCode}, ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Connection test error: $e');
      return false;
    }
  }
}
