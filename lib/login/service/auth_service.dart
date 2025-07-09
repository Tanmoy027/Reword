import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'user_service.dart';
import 'google_auth_service.dart';
import 'facebook_auth_service.dart';

class AuthService {
  final String baseUrl = "https://voucher-app-backend.vercel.app/api/auth";
  final String adminBaseUrl =
      "https://voucher-app-backend.vercel.app/api/admin";
  final UserService _userService = UserService();
  final GoogleAuthService _googleAuthService = Get.find<GoogleAuthService>();
  final FacebookAuthService _facebookAuthService =
      Get.find<FacebookAuthService>();

  // Initialize the service
  Future<void> init() async {
    await _googleAuthService.initDeepLinkHandling();
    await _facebookAuthService.init();
  }

  // Google Sign In method for users (buyers)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      return await _googleAuthService.signInWithGoogle();
    } catch (e) {
      print("Google Sign In Error: $e");
      return {"error": e.toString()};
    }
  }

  // NEW: Google Sign In method for sellers
  Future<Map<String, dynamic>?> signInWithGoogleSeller() async {
    try {
      return await _googleAuthService.signInWithGoogleSeller();
    } catch (e) {
      print("Google Sign In Error (Seller): $e");
      return {"error": e.toString()};
    }
  }

  // NEW: Google Sign Up method for sellers
  Future<Map<String, dynamic>?> signUpWithGoogleSeller() async {
    try {
      return await _googleAuthService.signUpWithGoogleSeller();
    } catch (e) {
      print("Google Sign Up Error (Seller): $e");
      return {"error": e.toString()};
    }
  }

  // Facebook Sign In method
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      return await _facebookAuthService.signInWithFacebook();
    } catch (e) {
      print("Facebook Sign In Error: $e");
      return {"error": e.toString()};
    }
  }

  // Register User (Buyer or Seller)
  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    bool isSeller = false,
    String? storeName,
    String? location,
    String? description,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "name": name,
        "email": email,
        "password": password,
        "role": isSeller ? "seller" : "buyer",
      };

      if (isSeller) {
        requestBody.addAll({
          "storeName": storeName ?? "",
          "location": location ?? "",
          "description": description ?? "",
        });
      } else {
        requestBody["phoneNumber"] = phoneNumber;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Registration Failed Response: ${response.body}');
        return {
          "error": jsonDecode(response.body)["message"] ?? "Registration failed"
        };
      }
    } catch (e) {
      print("Registration Error: $e");
      return {"error": "An error occurred. Please try again."};
    }
  }

  // Login User (Buyer or Seller)
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role,
    String? fmcToken,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "email": email,
        "password": password,
        "role": role,
      };

      if (fmcToken != null) {
        requestBody["fmcToken"] = fmcToken;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Login Response Body: $responseBody');

        final token = responseBody['token'] ?? '';
        var user = responseBody['user'] as Map<String, dynamic>?;

        if (user != null) {
          // Use UserService to save user data
          await _userService.saveUserData(
            token: token,
            userId: user['_id'] ?? '',
            name: user['name'] ?? '',
            email: user['email'] ?? '',
            isSeller: user['role'] == 'seller',
          );
        } else {
          print('Error: User data is missing in the response');
          return {"error": "User data is missing in the response"};
        }

        return responseBody;
      } else {
        print('Failed Login Response: ${response.body}');
        return {
          "error": jsonDecode(response.body)["message"] ?? "Login failed"
        };
      }
    } catch (e) {
      print("Login Error: $e");
      return {"error": "An error occurred. Please try again."};
    }
  }

  // Admin Login
  Future<Map<String, dynamic>?> adminLogin({
    required String email,
    required String password,
    String? fmcToken,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "email": email,
        "password": password,
        "role": "admin",
      };

      if (fmcToken != null) {
        requestBody["fmcToken"] = fmcToken;
      }

      final response = await http.post(
        Uri.parse("$adminBaseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Admin Login Response Body: $responseBody');

        final token = responseBody['token'] ?? '';

        // Save admin data with a special flag
        await _userService.saveUserData(
          token: token,
          userId: responseBody['user']?['_id'] ?? 'admin',
          name: responseBody['user']?['name'] ?? 'Admin',
          email: email,
          isSeller: false, // Not a seller
        );

        // Save additional admin flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(UserService.USER_ROLE_KEY, 'admin');

        return responseBody;
      } else {
        print('Failed Admin Login Response: ${response.body}');
        return {
          "error": jsonDecode(response.body)["message"] ?? "Admin login failed"
        };
      }
    } catch (e) {
      print("Admin Login Error: $e");
      return {"error": "An error occurred. Please try again."};
    }
  }

  // Logout User
  Future<Map<String, dynamic>?> logout() async {
    // Clean up Google and Facebook auth sessions
    _googleAuthService.dispose();
    _facebookAuthService.dispose();

    final token = await _userService.getToken();

    if (token == null) {
      return {"error": "No active session"};
    }

    final response = await http.get(
      Uri.parse("$baseUrl/logout"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      await _userService.clearUserData(); // Use UserService to clear user data
      return {"status": "success"};
    } else {
      print('Failed Logout Response: ${response.body}');
      return {"error": "Logout failed"};
    }
  }

  // Email verification helper
  Future<Map<String, dynamic>?> sendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/google/callback"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}), // Adjust as needed
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Verification Email Failed Response: ${response.body}');
        return {
          "error": jsonDecode(response.body)["message"] ??
              "Verification email sending successfully"
        };
      }
    } catch (e) {
      print("Verification Email Error: $e");
      return {"error": "successfully sent verification email."};
    }
  }
}
