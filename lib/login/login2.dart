import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/forgotpassword/forgot_Pass.dart';
import 'package:reword_frontend/user/userreg/userregistration.dart';
import 'package:reword_frontend/login/service/auth_service.dart';
import 'package:reword_frontend/login/service/user_service.dart';
import 'package:reword_frontend/login/service/google_auth_service.dart';
import 'package:reword_frontend/login/service/facebook_auth_service.dart'; // Add this import
import 'package:reword_frontend/privacy_policy/privacy_policy.dart';

class logain2 extends StatefulWidget {
  const logain2({super.key});

  @override
  _logain2State createState() => _logain2State();
}

class _logain2State extends State<logain2> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final GoogleAuthService _googleAuthService = Get.find<GoogleAuthService>();
  final FacebookAuthService _facebookAuthService =
      Get.find<FacebookAuthService>(); // Add this

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false; // Add this
  bool _termsAccepted = false;

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
        "You must accept the terms and conditions to log in",
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

    // No FCM token for now
    final response = await _authService.login(
      email: email,
      password: password,
      role: "buyer", // we are logging in as a buyer
    );

    setState(() {
      _isLoading = false;
    });

    if (response != null && !response.containsKey("error")) {
      // If login is successful, navigate to user home
      Get.offAllNamed('/userhome');
    } else {
      // Show error
      Get.snackbar(
        "Login Error",
        response?["error"] ?? "Invalid email or password",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Google sign-in handler - updated to use Firebase
  Future<void> _handleGoogleSignIn() async {
    if (!_termsAccepted) {
      Get.snackbar(
        "Terms Not Accepted",
        "You must accept the terms and conditions to sign in with Google",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await _authService.signInWithGoogle();

      if (result != null && result.containsKey('error')) {
        Get.snackbar(
          "Google Sign-In Error",
          result['error'],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Google Sign-in error: $e");
      Get.snackbar(
        "Google Sign-In Error",
        "Failed to sign in with Google. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  // Facebook sign-in handler
  Future<void> _handleFacebookSignIn() async {
    if (!_termsAccepted) {
      Get.snackbar(
        "Terms Not Accepted",
        "You must accept the terms and conditions to sign in with Facebook",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isFacebookLoading = true;
    });

    try {
      final result = await _authService.signInWithFacebook();

      if (result != null && result.containsKey('error')) {
        Get.snackbar(
          "Facebook Sign-In Error",
          result['error'],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Facebook Sign-in error: $e");
      Get.snackbar(
        "Facebook Sign-In Error",
        "Failed to sign in with Facebook. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isFacebookLoading = false;
      });
    }
  }

  Widget _buildSocialButton(String iconPath, VoidCallback onPressed,
      {bool isLoading = false}) {
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
        onTap: isLoading ? null : onPressed,
        child: isLoading
            ? const Center(
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2)))
            : Padding(
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
          // Bottom container with blur and content
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
                        "Welcome Back, User!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Please login to continue",
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
                      // Forgot password row aligned to right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => Get.to(() => ForgotPasswordScreen()),
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: Colors.grey[700],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Terms and Conditions row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (bool? value) {
                              setState(() {
                                _termsAccepted = value!;
                              });
                            },
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  Get.to(() => const LegalPagesScreen()),
                              child: Text(
                                "I agree to the Terms & Conditions",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                                  color: Colors.white)
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: InkWell(
                          onTap: () => Get.to(() => Registration()),
                          child: Text(
                            "I don't have an account? Register",
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
                      const SizedBox(height: 20),
                      // Social login buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            'assets/images/Google.png',
                            _handleGoogleSignIn,
                            isLoading: _isGoogleLoading,
                          ),
                          const SizedBox(width: 15),
                          _buildSocialButton('assets/images/Apple.png', () {}),
                          const SizedBox(width: 15),
                          _buildSocialButton(
                            'assets/images/Facebook.png',
                            _handleFacebookSignIn,
                            isLoading: _isFacebookLoading,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
