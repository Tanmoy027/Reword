import 'dart:ui'; // For any potential custom blur or other Dart UI operations
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyEmailController extends GetxController {
  // You can add your OTP logic here if you want to handle the entered digits,
  // verify them, manage timers, etc.
  // Example:
  // var otpDigits = ['', '', '', ''].obs;
}

class VerifyEmailScreen extends StatelessWidget {
  VerifyEmailScreen({super.key});

  final VerifyEmailController controller = Get.put(VerifyEmailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Entire page background color
      backgroundColor: Colors.white,

      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Verify your email",
          style: TextStyle(color: Colors.black),
        ),
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Instructional text
            const Text(
              "To verify your account, enter the 4 digit OTP code that we sent to your email.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            // Row of 4 OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOtpBox(),
                _buildOtpBox(),
                _buildOtpBox(),
                _buildOtpBox(),
              ],
            ),

            const SizedBox(height: 40),

            // "Verify" Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF158482), // #158482
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Handle OTP verification
                  // Show a snackbar as an example of success:
                  Get.snackbar(
                    'Success',
                    'OTP Verified!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF158482),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(10),
                    borderRadius: 8,
                  );
                },
                child: const Text(
                  "Verify",
                  style: TextStyle(
                    color: Colors.white, // White text
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // "Didn't get the email?"
            const Text(
              "Didn't get the email?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            // Resend Email with timer
            const Text(
              "Resend Email (02:59)",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each OTP box
  Widget _buildOtpBox() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade300, // Gray background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            counterText: '', // Hides the counter (maxLength) text
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Optional: Move to next field automatically, etc.
            // You can also store each digit in your controller if desired.
          },
        ),
      ),
    );
  }
}
