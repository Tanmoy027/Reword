import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../welcome/choice_page.dart';

class PasswordController extends GetxController {
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  var resetCode = ''.obs; // Changed from resetToken to resetCode
}

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String? initialCode; // Changed from initialToken to initialCode
  final String role;

  const CreateNewPasswordScreen({
    super.key,
    required this.email,
    this.initialCode, // Changed from initialToken to initialCode
    required this.role,
  });

  @override
  _CreateNewPasswordScreenState createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final PasswordController controller = Get.put(PasswordController());
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController codeController =
      TextEditingController(); // Changed from tokenController
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    // If initial code is provided, pre-fill the code field
    if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
      codeController.text = widget.initialCode!;
      controller.resetCode.value =
          widget.initialCode!; // Changed from resetToken to resetCode
    }
  }

  Future<void> resetPassword() async {
    // Validate code
    if (codeController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the reset code', // Changed from reset token to reset code
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
      // Print debug info
      print('Resetting password');
      print(
          'Code: ${codeController.text.trim()}'); // Changed from Token to Code
      print('Role: ${widget.role}');

      // Determine the endpoint based on role
      String endpoint = widget.role == 'seller'
          ? 'https://voucher-app-backend.vercel.app/api/auth/seller/reset-password'
          : 'https://voucher-app-backend.vercel.app/api/auth/reset-password';

      // Make API call to reset password using Dio
      final response = await dio.post(
        endpoint,
        data: {
          'code': codeController.text.trim(), // Changed from token to code
          'newPassword': passwordController.text.trim(),
          'role': widget.role, // Added role parameter
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Print response for debugging
      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      // Handle response
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
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Response: ${e.response?.data}');

      String errorMessage = 'Failed to reset password';
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        }
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      // Handle network or other errors
      print('Error resetting password: $e');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
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

              // Display account type and email
              Text(
                "Reset password for ${widget.role} account: ${widget.email}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),

              // Reset Code Input (changed from Token)
              Text("Reset Code",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              SizedBox(height: 10),
              TextField(
                controller: codeController, // Changed from tokenController
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  hintText:
                      "Enter reset code from email", // Changed from token to code
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.paste),
                    onPressed: () async {
                      // Paste from clipboard
                      final clipboardData =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (clipboardData != null && clipboardData.text != null) {
                        codeController.text = clipboardData.text!;
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
                    fillColor: Colors.grey.shade200,
                    hintText: "Enter your password here",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
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
                    fillColor: Colors.grey.shade200,
                    hintText: "Re-enter your password here",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
