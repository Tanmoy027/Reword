import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/services.dart';

import '../welcome/choice_page.dart';

class PasswordController extends GetxController {
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  var resetToken = ''.obs;
}

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String? initialToken;

  const CreateNewPasswordScreen(
      {super.key, required this.email, this.initialToken});

  @override
  _CreateNewPasswordScreenState createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final PasswordController controller = Get.put(PasswordController());
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If initial token is provided, pre-fill the token field
    if (widget.initialToken != null) {
      tokenController.text = widget.initialToken!;
      controller.resetToken.value = widget.initialToken!;
    }
  }

  Future<void> resetPassword() async {
    // Validate token
    if (tokenController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the reset token',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate passwords
    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a new password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Set loading state
    controller.isLoading.value = true;

    try {
      // Make API call to reset password
      final response = await http.post(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': tokenController.text.trim(), // Use token from text field
          'newPassword': passwordController.text.trim(),
        }),
      );

      // Print the response for debugging
      print('Reset Password Response: ${response.body}');
      print('Reset Token Used: ${tokenController.text}');

      // Handle response
      if (response.statusCode == 200) {
        // Password reset successful
        Get.snackbar(
          'Success',
          'Password has been reset successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF158482),
          colorText: Colors.white,
        );

        // Navigate to login screen
        Get.offAll(() => ChoicePage());
      } else {
        // Parse error message from the response
        final errorBody = json.decode(response.body);
        Get.snackbar(
          'Error',
          errorBody['message'] ?? 'Failed to reset password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Handle network or other errors
      print('Error resetting password: $e');
      Get.snackbar(
        'Error',
        'An error occurred. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Reset loading state
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Create",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text(
                "new password",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 30),

              // Display email (optional)
              Text(
                "Reset password for: ${widget.email}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),

              // Reset Token Input
              Text("Reset Token",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              SizedBox(height: 10),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  hintText: "Enter reset token from email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.paste),
                    onPressed: () async {
                      // Paste from clipboard
                      final clipboardData =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (clipboardData != null && clipboardData.text != null) {
                        tokenController.text = clipboardData.text!;
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // New Password
              Text("New Password",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              SizedBox(height: 10),
              Obx(
                () => TextField(
                  controller: passwordController,
                  obscureText: controller.isPasswordHidden.value,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF4F4F4F),
                    hintText: "Enter your password here",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        controller.isPasswordHidden.toggle();
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Confirm New Password
              Text("Re-enter New Password",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              SizedBox(height: 10),
              Obx(
                () => TextField(
                  controller: confirmPasswordController,
                  obscureText: controller.isConfirmPasswordHidden.value,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF4F4F4F),
                    hintText: "Re-enter your password here",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        controller.isConfirmPasswordHidden.toggle();
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Confirm Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF158482), // Button color
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed:
                          controller.isLoading.value ? null : resetPassword,
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Confirm Password",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
