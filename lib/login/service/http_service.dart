import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_service.dart';

class HttpService {
  final String baseUrl = "https://voucher-app-backend.vercel.app/api";
  final UserService _userService = UserService();

  // Get request with authentication
  Future<Map<String, dynamic>?> getAuthenticatedData(String endpoint) async {
    try {
      final token = await _userService.getToken();

      if (token == null) {
        return {"error": "No authentication token found"};
      }

      final response = await http.get(
        Uri.parse("$baseUrl/$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
        return {"error": "Failed to fetch data"};
      }
    } catch (e) {
      print("HTTP Error: $e");
      return {"error": "An error occurred. Please try again."};
    }
  }

  // Post request with authentication
  Future<Map<String, dynamic>?> postAuthenticatedData(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _userService.getToken();

      if (token == null) {
        return {"error": "No authentication token found"};
      }

      final response = await http.post(
        Uri.parse("$baseUrl/$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
        return {"error": "Failed to submit data"};
      }
    } catch (e) {
      print("HTTP Error: $e");
      return {"error": "An error occurred. Please try again."};
    }
  }
}
