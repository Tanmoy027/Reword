import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:reword_frontend/forgotpassword/create_new_pass.dart';

class ForgotPasswordController extends GetxController {
  var email = ''.obs;
  var role = 'buyer'.obs; // Default to 'buyer'
  var isLoading = false.obs;
}

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());
  final TextEditingController emailController = TextEditingController();
  final dio = Dio();

  Future<void> requestPasswordReset() async {
    // Validate email
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
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
      print('Sending request to request-password-reset endpoint');
      print('Email: ${emailController.text.trim()}');
      print('Role: ${controller.role.value}');

      // Determine the endpoint based on role
      String endpoint = controller.role.value == 'seller'
          ? 'https://voucher-app-backend.vercel.app/api/auth/seller/request-password-reset'
          : 'https://voucher-app-backend.vercel.app/api/auth/request-password-reset';

      // Set timeout to prevent long waiting
      final response = await dio.post(
        endpoint,
        data: {
          'email': emailController.text.trim(),
          'role': controller.role.value,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      // Print response for debugging
      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      // Show success message
      Get.snackbar(
        'Success',
        'Password reset link sent to your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF158482),
        colorText: Colors.white,
      );

      // Navigate to Create New Password Screen
      Get.to(() => CreateNewPasswordScreen(
            email: emailController.text.trim(),
            role: controller.role.value,
          ));
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Response code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');

      String errorMessage;

      if (e.response?.statusCode == 504) {
        errorMessage =
            'The server is taking too long to respond. Please try again later or contact support.';
      } else if (e.response != null && e.response!.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        } else {
          errorMessage = 'Failed to send password reset link';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timed out. Please check your internet connection and try again.';
      } else {
        errorMessage =
            'Failed to send password reset link. Please try again later.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      // Handle other errors
      print('Exception details: $e');

      Get.snackbar(
        'Error',
        'Connection failed: ${e.toString()}',
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Forgot Password?",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Please enter your email address to receive a password reset link.",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Add role selector
            const Text(
              "Account Type",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title:
                            const Text("Buyer", style: TextStyle(fontSize: 14)),
                        value: "buyer",
                        groupValue: controller.role.value,
                        onChanged: (value) {
                          controller.role.value = value!;
                        },
                        activeColor: const Color(0xFF158482),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Seller",
                            style: TextStyle(fontSize: 14)),
                        value: "seller",
                        groupValue: controller.role.value,
                        onChanged: (value) {
                          controller.role.value = value!;
                        },
                        activeColor: const Color(0xFF158482),
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 16),

            const Text(
              "Email",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email, color: Colors.grey),
                hintText: "Enter your email",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                controller.email.value = value;
              },
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF158482),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : requestPasswordReset,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Send Reset Link",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                )),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle help action, maybe show a help dialog
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Need Help?'),
                      content: const Text(
                        'If you are having trouble resetting your password, please contact our support team at support@example.com',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  "Need help?",
                  style: TextStyle(
                    color: Color(0xFF158482),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
