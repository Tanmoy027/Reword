import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/login/service/auth_service.dart';
import 'dart:ui';

class LoginPage extends StatelessWidget {
  final AuthService _authService =
      AuthService(); // Create instance of AuthService

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/lognbackground.png',
              fit: BoxFit.cover,
            ),
          ),

          // Transparent White Box at Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.75)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset('assets/images/logo.png', height: 50),
                      const SizedBox(height: 10),

                      // Welcome Text
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Sign in to access your vouchers and experiences.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      // Sign In and Sign Up Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                                "Sign In", Colors.black, Colors.white, () {
                              Get.toNamed('/login2');
                            }),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildButton(
                                "Sign Up Free", Colors.teal, Colors.white, () {
                              Get.toNamed('/userReg');
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // OR Divider
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.grey)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("or"),
                          ),
                          Expanded(child: Divider(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Google Login
                      _buildSocialLoginButton("Continue with Google",
                          "assets/images/Google.png", () async {}),

                      const SizedBox(height: 10),

                      // Facebook Login (Dummy action for now)
                      _buildSocialLoginButton("Continue with Facebook",
                          "assets/images/Facebook.png", () {
                        // TODO: Implement Facebook login function
                      }),

                      const SizedBox(height: 10),

                      // Apple Login (Dummy action for now)
                      _buildSocialLoginButton(
                          "Continue with Apple", "assets/images/Apple.png", () {
                        // TODO: Implement Apple login function
                      }),

                      const SizedBox(height: 15),

                      // Terms and Conditions
                      const Text.rich(
                        TextSpan(
                          text: "I agree to the ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "Terms & Conditions",
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Button Widget
  Widget _buildButton(
      String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 16, color: textColor)),
    );
  }

  // Social Login Button
  Widget _buildSocialLoginButton(
      String text, String iconPath, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Colors.black12),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
}
