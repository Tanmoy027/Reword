import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/forgotpassword/forgot_Pass.dart';
import 'package:reword_frontend/login/service/auth_service.dart';
import 'package:reword_frontend/login/service/user_service.dart';

// 1. Import Firebase Messaging
import 'package:firebase_messaging/firebase_messaging.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
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

    // 2. Get FCM token for admin
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print("Admin FCM Token: $fcmToken"); // Make sure this line exists

    // 3. Pass FCM token to admin login
    final response = await _authService.adminLogin(
      email: email,
      password: password,
      fmcToken: fcmToken, // <-- new
    );

    setState(() {
      _isLoading = false;
    });

    if (response != null && !response.containsKey("error")) {
      Get.offAllNamed('/adminDashboard');
    } else {
      Get.snackbar(
        "Login Failed",
        response?["error"] ?? "Please check your credentials",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
                        "Admin Portal",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Manage your platform and users",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField("Email Address",
                          controller: _emailController),
                      const SizedBox(height: 15),
                      _buildTextField("Password",
                          obscureText: true, controller: _passwordController),
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
                      const SizedBox(height: 25),
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          "Admin access only",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
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
