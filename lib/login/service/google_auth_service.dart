import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/login/service/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleAuthService {
  final String baseUrl = "https://voucher-app-backend.vercel.app/api/auth";
  final UserService _userService = UserService();

  // Required methods for auth_service.dart
  Future<void> initDeepLinkHandling() async {
    print("Deep link handling initialized");
  }

  void dispose() {
    print("GoogleAuthService disposed");
  }

  // Improved Google sign-in method
  Future<void> signInWithGoogle() async {
    try {
      final googleAuthUrl = '$baseUrl/google';
      final Uri url = Uri.parse(googleAuthUrl);

      // Show dialog with manual option
      await Get.dialog(
        AlertDialog(
          title: const Text("Google Sign In"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("You'll be redirected to Google to sign in."),
              SizedBox(height: 10),
              Text("After signing in, you'll see a page with your token."),
              SizedBox(height: 10),
              Text(
                  "Since deep linking may not work properly yet, you'll need to copy the token and enter it manually."),
              SizedBox(height: 10),
              CircularProgressIndicator(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Get.back();

                // Launch URL using url_launcher
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );

                    // Show follow-up instructions after a delay
                    Future.delayed(const Duration(seconds: 2), () {
                      _showTokenEntryDialog();
                    });
                  } else {
                    throw Exception("Could not launch URL");
                  }
                } catch (e) {
                  print("Error launching URL: $e");
                  _showManualInstructions();
                }
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Google Sign In Error: $e");

      Get.snackbar(
        "Authentication Error",
        "Failed to open the browser. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Show manual instructions
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

  // Dialog to manually enter token
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

  // Process the auth token
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

  // Add this static method that was missing
  static void handleGoogleCallback(String token) {
    print("Received Google callback with token: $token");

    final googleAuthService = Get.find<GoogleAuthService>();
    googleAuthService.processAuthToken(token);
  }
}
