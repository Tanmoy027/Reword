import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/forgotpassword/forgot_Pass.dart';
import 'package:reword_frontend/seller/sellerreigistration/sellerregistration1.dart';
import 'package:reword_frontend/login/service/auth_service.dart';
import 'package:reword_frontend/login/service/user_service.dart';

// 1. Import Firebase Messaging
import 'package:firebase_messaging/firebase_messaging.dart';

class logainseller extends StatefulWidget {
  const logainseller({super.key});

  @override
  _logainsellerState createState() => _logainsellerState();
}

class _logainsellerState extends State<logainseller> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _termsAccepted = false; // Track checkbox state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_termsAccepted) {
      Get.snackbar(
        "Terms Not Accepted",
        "You must accept the Terms & Conditions and Privacy Policy to log in",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter both email and password",
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 2. Fetch the FCM token for the seller
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print("Seller FCM Token: $fcmToken");

    // 3. Pass fcmToken to auth_service
    final response = await _authService.login(
      email: email,
      password: password,
      role: "seller", // Ensure role is seller
      fmcToken: fcmToken, // Pass the token here
    );

    setState(() {
      _isLoading = false;
    });

    if (response != null && !response.containsKey("error")) {
      // If login is successful, navigate to seller home
      Get.offAllNamed('/sellerHome');
    } else {
      Get.snackbar(
        "Login Failed",
        response?["error"] ?? "Please check your credentials",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildSocialButton(String iconPath, VoidCallback onPressed) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            iconPath,
            width: 36,
            height: 36,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/carousel.png',
              fit: BoxFit.cover,
            ),
          ),
          // Bottom container with blur effect and content
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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Join Us Today! as Seller",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Discover the best experiences and excursions.",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        "Email Address",
                        controller: _emailController,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        "Password",
                        obscureText: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 10),

                      // Forgot password link (centered)
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () => Get.to(() => ForgotPasswordScreen()),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Colors.grey[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Checkbox row for Terms & Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (bool? value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              "I agree to the Terms & Conditions and Privacy Policy",
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Registration link
                      Center(
                        child: InkWell(
                          onTap: () => Get.to(() => sellerRegistration()),
                          child: Text(
                            "I don't have an account?",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // New Admin Login link
                      Center(
                        child: InkWell(
                          onTap: () => Get.toNamed('/adminLogin'),
                          child: Text(
                            "Admin Login",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // "or sign in with" text
                      Center(
                        child: Text(
                          "or sign in with",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Social login buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton('assets/images/Google.png', () {}),
                          const SizedBox(width: 15),
                          _buildSocialButton('assets/images/Apple.png', () {}),
                          const SizedBox(width: 15),
                          _buildSocialButton(
                              'assets/images/Facebook.png', () {}),
                        ],
                      ),
                      const SizedBox(height: 15),
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

  Widget _buildTextField(String hint,
      {bool obscureText = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
