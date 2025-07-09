import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/login/service/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleAuthService extends GetxService {
  final String baseUrl = "https://voucher-app-backend.vercel.app/api/auth";
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Required methods for auth_service.dart
  Future<void> initDeepLinkHandling() async {
    print("Deep link handling initialized");
  }

  void dispose() {
    print("GoogleAuthService disposed");
  }

  // Firebase Google sign-in method with enhanced error logging
  Future<Map<String, dynamic>?> signInWithFirebaseGoogle(
      {String role = "buyer"}) async {
    try {
      // Sign out first to ensure a fresh sign-in
      print("Signing out from previous sessions...");
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Start the sign-in process
      print("Starting Google sign in flow...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google sign in was cancelled by user");
        return {"error": "Google sign in was cancelled"};
      }

      print("Google Sign In successful for: ${googleUser.email}");
      print("Google Account ID: ${googleUser.id}");

      // Get authentication credentials
      print("Getting Google authentication tokens...");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("Access token available: ${googleAuth.accessToken != null}");
      print("ID token available: ${googleAuth.idToken != null}");

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print("Failed to get Google auth tokens");
        return {"error": "Failed to get authentication tokens from Google"};
      }

      // Create a credential for Firebase
      print("Creating Firebase credential...");
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      print("Signing in to Firebase with credential...");
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      print("Firebase sign in successful: ${userCredential.user?.email}");
      print("Firebase user ID: ${userCredential.user?.uid}");

      // Get the ID token
      print("Requesting Firebase ID token...");
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        print("Failed to get Firebase ID token");
        return {"error": "Failed to get Firebase ID token"};
      }

      print("Firebase ID token obtained successfully");

      // Call backend API with the role parameter
      print("Calling backend API with Firebase ID token for role: $role");
      return await _callFirebaseAuthEndpoint(idToken, role);
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Exception: [${e.code}] ${e.message}");
      return {"error": "Authentication error: ${e.message}"};
    } on PlatformException catch (e) {
      print("Platform Exception: [${e.code}] ${e.message}");
      if (e.code == 'sign_in_failed' || e.code == 'network_error') {
        return {
          "error":
              "Google Sign In failed. Check your internet connection and try again."
        };
      }
      return {"error": "Platform error: ${e.message}"};
    } catch (e) {
      print("Google Sign In Error (Generic): $e");
      return {"error": e.toString()};
    }
  }

  // Call the Firebase Auth endpoint
  Future<Map<String, dynamic>?> _callFirebaseAuthEndpoint(
      String idToken, String role) async {
    try {
      print("Sending request to backend API: $baseUrl/firebase-auth");
      final response = await http.post(
        Uri.parse("$baseUrl/firebase-auth"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "idToken": idToken,
          "role": role, // Use the role parameter
        }),
      );

      print("Backend API response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Firebase Auth Response: $responseBody');

        final token = responseBody['token'] ?? '';
        var user = responseBody['user'] as Map<String, dynamic>?;

        if (user != null) {
          // Save user data
          print("Saving user data to local storage...");
          await _userService.saveUserData(
            token: token,
            userId: user['_id'] ?? '',
            name: user['name'] ?? '',
            email: user['email'] ?? '',
            isSeller: role == 'seller', // Set based on role
          );
          print("User data saved successfully");

          return responseBody;
        } else {
          print('Error: User data is missing in the response');
          return {"error": "User data is missing in the response"};
        }
      } else {
        print('Failed Firebase Auth Response: ${response.body}');
        try {
          final errorData = jsonDecode(response.body);
          return {"error": errorData["message"] ?? "Authentication failed"};
        } catch (e) {
          return {
            "error":
                "Authentication failed with status code: ${response.statusCode}"
          };
        }
      }
    } catch (e) {
      print("Firebase Auth API Error: $e");
      return {"error": "An error occurred connecting to the server: $e"};
    }
  }

  // Main signInWithGoogle method for buyers
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print("Starting Google Sign In process for buyer...");

      // Use Firebase Google sign-in with "buyer" role
      final result = await signInWithFirebaseGoogle(role: "buyer");

      if (result != null && !result.containsKey('error')) {
        print("Google Sign In successful for buyer, navigating to home page");
        // Navigate to home page
        Get.offAllNamed('/userhome');
        return {"success": true};
      } else {
        print("Google Sign In failed for buyer: ${result?['error']}");
        return result;
      }
    } catch (e) {
      print("Google Sign In Error in main method for buyer: $e");

      Get.snackbar(
        "Authentication Error",
        "Failed to sign in with Google: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}",
        snackPosition: SnackPosition.BOTTOM,
      );

      return {"error": e.toString()};
    }
  }

  // NEW: Sign In with Google for sellers
  Future<Map<String, dynamic>?> signInWithGoogleSeller() async {
    try {
      print("Starting Google Sign In process for seller...");

      // Use Firebase Google sign-in with "seller" role
      final result = await signInWithFirebaseGoogle(role: "seller");

      if (result != null && !result.containsKey('error')) {
        print(
            "Google Sign In successful for seller, navigating to seller home page");
        // Navigate to seller home page
        Get.offAllNamed('/sellerHome');
        return {"success": true};
      } else {
        print("Google Sign In failed for seller: ${result?['error']}");
        return result;
      }
    } catch (e) {
      print("Google Sign In Error in main method for seller: $e");

      Get.snackbar(
        "Authentication Error",
        "Failed to sign in with Google: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}",
        snackPosition: SnackPosition.BOTTOM,
      );

      return {"error": e.toString()};
    }
  }

  // NEW: Sign Up with Google for sellers
  Future<Map<String, dynamic>?> signUpWithGoogleSeller() async {
    try {
      print("Starting Google Sign Up process for seller...");

      // Use Firebase Google sign-in with "seller" role
      // For signup we use the same endpoint but handle registration on backend
      final result = await signInWithFirebaseGoogle(role: "seller");

      if (result != null && !result.containsKey('error')) {
        print(
            "Google Sign Up successful for seller, navigating to seller home page");
        // Navigate to seller home page
        Get.offAllNamed('/sellerHome');
        return {"success": true};
      } else {
        print("Google Sign Up failed for seller: ${result?['error']}");
        return result;
      }
    } catch (e) {
      print("Google Sign Up Error in main method for seller: $e");

      Get.snackbar(
        "Authentication Error",
        "Failed to sign up with Google: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}",
        snackPosition: SnackPosition.BOTTOM,
      );

      return {"error": e.toString()};
    }
  }

  // Legacy methods for deep linking approach - kept for reference
  Future<void> _showManualInstructions() async {
    final googleAuthUrl = '$baseUrl/google';

    await Get.dialog(
      AlertDialog(
        title: const Text("Manual Sign In"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please open this URL in your browser:"),
            SelectableText(googleAuthUrl),
            const SizedBox(height: 20),
            const Text(
                "After signing in, you'll see a token on the success page. Copy it and enter it in the app."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: googleAuthUrl));
              Get.snackbar(
                "Copied",
                "URL copied to clipboard",
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text("Copy URL"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showTokenEntryDialog();
            },
            child: const Text("Enter Token"),
          ),
        ],
      ),
    );
  }

  Future<void> _showTokenEntryDialog() async {
    final TextEditingController tokenController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: const Text("Enter Authentication Token"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "After signing in with Google, paste the token you received:"),
            const SizedBox(height: 15),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                hintText: "Paste token here",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final token = tokenController.text.trim();
              if (token.isNotEmpty) {
                Get.back();
                processAuthToken(token);
              } else {
                Get.snackbar(
                  "Invalid Token",
                  "Please enter a valid token",
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );

    tokenController.dispose();
  }

  void processAuthToken(String token) {
    if (token.isNotEmpty) {
      print("Processing auth token: $token");

      _userService.saveUserData(
        token: token,
        userId: '', // Will be filled after token validation
        name: '',
        email: '',
        isSeller: false,
      );

      Get.offAllNamed('/userhome');

      Get.snackbar(
        "Authentication Successful",
        "You've been signed in successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        duration: const Duration(seconds: 3),
      );
    }
  }

  static void handleGoogleCallback(String token) {
    print("Received Google callback with token: $token");

    final googleAuthService = Get.find<GoogleAuthService>();
    googleAuthService.processAuthToken(token);
  }
}
