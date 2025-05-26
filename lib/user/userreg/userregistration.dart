import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/login/service/auth_service.dart';
import 'package:reword_frontend/login/service/google_auth_service.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final Map<String, TextEditingController> _controllers = {
    "Full Name": TextEditingController(),
    "Email Address": TextEditingController(),
    "Password": TextEditingController(),
    "Confirm Password": TextEditingController(),
    "Phone Number": TextEditingController(),
  };

  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = Get.find<GoogleAuthService>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Handle Google sign up
  Future<void> _handleGoogleSignUp() async {
    if (!_termsAccepted) {
      Get.snackbar(
        "Terms Not Accepted",
        "You must accept the terms and conditions to sign up",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      await _googleAuthService.signInWithGoogle();
      // Navigation is handled by GoogleAuthService
    } catch (e) {
      print("Google Sign-up error: $e");
      Get.snackbar(
        "Google Sign-Up Error",
        "An unexpected error occurred. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isGoogleLoading = false;
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

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/signin.png', fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Join Us Today!",
                      style: TextStyle(fontSize: 18, color: Colors.teal),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Discover the best experiences and excursions.",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField("Full Name", _controllers["Full Name"]!),
                    const SizedBox(height: 15),
                    _buildInputField(
                        "Email Address", _controllers["Email Address"]!),
                    const SizedBox(height: 15),
                    _buildInputField("Password", _controllers["Password"]!,
                        isPassword: true),
                    const SizedBox(height: 15),
                    _buildInputField(
                        "Confirm Password", _controllers["Confirm Password"]!,
                        isPassword: true),
                    const SizedBox(height: 15),
                    _buildInputField(
                        "Phone Number", _controllers["Phone Number"]!),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (bool? value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _termsAccepted = !_termsAccepted;
                              });
                            },
                            child: const Text(
                              "I agree to the Terms & Conditions",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _termsAccepted && !_isLoading
                          ? () async {
                              setState(() {
                                _isLoading = true;
                              });

                              final fullName =
                                  _controllers["Full Name"]!.text.trim();
                              final email =
                                  _controllers["Email Address"]!.text.trim();
                              final password =
                                  _controllers["Password"]!.text.trim();
                              final confirmPassword =
                                  _controllers["Confirm Password"]!.text.trim();
                              final phoneNumber =
                                  _controllers["Phone Number"]!.text.trim();

                              // Basic validation
                              if (fullName.isEmpty ||
                                  email.isEmpty ||
                                  password.isEmpty ||
                                  phoneNumber.isEmpty) {
                                Get.snackbar(
                                    'Error', 'All fields are required.');
                                setState(() => _isLoading = false);
                                return;
                              }

                              if (password != confirmPassword) {
                                Get.snackbar(
                                    'Error', 'Passwords do not match.');
                                setState(() => _isLoading = false);
                                return;
                              }

                              // Call register with isSeller: false for a user (buyer) account.
                              final response = await _authService.register(
                                name: fullName,
                                email: email,
                                password: password,
                                phoneNumber: phoneNumber,
                                isSeller: false,
                              );

                              setState(() => _isLoading = false);

                              if (response != null &&
                                  response['error'] == null) {
                                // Trigger verification email for Gmail users
                                if (email.toLowerCase().contains("gmail.com")) {
                                  final verificationResponse =
                                      await _authService
                                          .sendVerificationEmail(email);
                                  if (verificationResponse != null &&
                                      verificationResponse['error'] == null) {
                                    Get.snackbar(
                                      'Success',
                                      'Registration successful. A verification email has been sent to your email address. Please verify your account.',
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Warning',
                                      'Registration successful but failed to send verification email. Please try again later.',
                                    );
                                  }
                                } else {
                                  Get.snackbar('Success',
                                      'Account created! Please log in.');
                                }
                                Get.offNamed('/userlogin2');
                              } else {
                                final errorMsg = response?['error'] ??
                                    'Registration failed.';
                                Get.snackbar('Error', errorMsg);
                              }
                            }
                          : null,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed('/userlogin2');
                        },
                        child: const Text(
                          "I have an account?",
                          style: TextStyle(
                              color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "or sign up with",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                            'assets/images/Google.png', _handleGoogleSignUp,
                            isLoading: _isGoogleLoading),
                        const SizedBox(width: 15),
                        _buildSocialButton('assets/images/Apple.png', () {}),
                        const SizedBox(width: 15),
                        _buildSocialButton('assets/images/Facebook.png', () {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
