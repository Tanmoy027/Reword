import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/login/service/user_service.dart';

class FacebookAuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final UserService _userService = UserService();
  final String baseUrl = "https://voucher-app-backend.vercel.app/api/auth";

  // Initialize service
  Future<void> init() async {
    print("Facebook auth service initialized");
  }

  // Cleanup resources
  void dispose() {
    print("FacebookAuthService disposed");
  }

  // Sign in with Facebook through Firebase
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // Sign out first to ensure a fresh sign-in
      await _facebookAuth.logOut();
      await _auth.signOut();

      // Trigger the sign-in flow
      final LoginResult result = await _facebookAuth.login();

      if (result.status != LoginStatus.success) {
        return {"error": "Facebook login failed: ${result.message}"};
      }

      // Create a credential from the access token
      // Fix: Use accessToken instead of token
      final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString // Use tokenString instead of token
          );

      // Sign in with Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Get the ID token
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        return {"error": "Failed to get Firebase ID token"};
      }

      // Call backend API
      final result2 = await _callFirebaseAuthEndpoint(idToken);

      if (result2 != null && !result2.containsKey('error')) {
        // Navigate to home page
        Get.offAllNamed('/userhome');
        return {"success": true};
      }

      return result2;
    } catch (e) {
      print("Facebook Sign In Error: $e");

      Get.snackbar(
        "Authentication Error",
        "Failed to sign in with Facebook. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );

      return {"error": e.toString()};
    }
  }

  // Call the Firebase Auth endpoint
  Future<Map<String, dynamic>?> _callFirebaseAuthEndpoint(
      String idToken) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/firebase-auth"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "idToken": idToken,
          "role": "buyer", // Only for user/buyer as per requirement
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Firebase Auth Response: $responseBody');

        final token = responseBody['token'] ?? '';
        var user = responseBody['user'] as Map<String, dynamic>?;

        if (user != null) {
          // Save user data
          await _userService.saveUserData(
            token: token,
            userId: user['_id'] ?? '',
            name: user['name'] ?? '',
            email: user['email'] ?? '',
            isSeller: false, // This is only for buyers
          );

          return responseBody;
        } else {
          print('Error: User data is missing in the response');
          return {"error": "User data is missing in the response"};
        }
      } else {
        print('Failed Firebase Auth Response: ${response.body}');
        return {
          "error":
              jsonDecode(response.body)["message"] ?? "Authentication failed"
        };
      }
    } catch (e) {
      print("Firebase Auth API Error: $e");
      return {
        "error": "An error occurred connecting to the server. Please try again."
      };
    }
  }
}
