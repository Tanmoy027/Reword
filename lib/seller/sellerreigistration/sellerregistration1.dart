import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/login/service/auth_service.dart';

class sellerRegistration extends StatefulWidget {
  const sellerRegistration({super.key});

  @override
  _sellerRegistrationState createState() => _sellerRegistrationState();
}

class _sellerRegistrationState extends State<sellerRegistration> {
  final Map<String, TextEditingController> _controllers = {
    "Full Name": TextEditingController(),
    "Email Address": TextEditingController(),
    "Password": TextEditingController(),
    "Confirm Password": TextEditingController(),
    "Store Name": TextEditingController(),
    "Location": TextEditingController(),
  };

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isAgreed = false; // State variable for checkbox
  final String _defaultDescription =
      "This is a new shop"; // Default description

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateInputs() {
    if (_controllers["Full Name"]!.text.trim().isEmpty) {
      return "Full name is required";
    }

    final email = _controllers["Email Address"]!.text.trim();
    if (email.isEmpty) {
      return "Email address is required";
    }
    if (!GetUtils.isEmail(email)) {
      return "Please enter a valid email address";
    }

    final password = _controllers["Password"]!.text;
    if (password.isEmpty) {
      return "Password is required";
    }
    if (password.length < 6) {
      return "Password must be at least 6 characters long";
    }

    if (_controllers["Confirm Password"]!.text != password) {
      return "Passwords do not match";
    }

    if (_controllers["Store Name"]!.text.trim().isEmpty) {
      return "Store name is required";
    }

    if (!_isAgreed) {
      // Check if terms and conditions are agreed
      return "You must agree to the Terms & Conditions";
    }

    return null; // No errors
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
                      "Become a Seller and Grow Your Business",
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
                    _buildInputField("Store Name", _controllers["Store Name"]!),
                    const SizedBox(height: 15),
                    _buildInputField("Location", _controllers["Location"]!),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text(
                        "Agree to Terms & Conditions",
                        style: TextStyle(color: Colors.black54),
                      ),
                      value: _isAgreed,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreed = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
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
                      onPressed: _isLoading || !_isAgreed
                          ? null
                          : () async {
                              final validationError = _validateInputs();
                              if (validationError != null) {
                                Get.snackbar(
                                  "Error",
                                  validationError,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              final fullName =
                                  _controllers["Full Name"]!.text.trim();
                              final email =
                                  _controllers["Email Address"]!.text.trim();
                              final password = _controllers["Password"]!.text;
                              final storeName =
                                  _controllers["Store Name"]!.text.trim();
                              final location =
                                  _controllers["Location"]!.text.trim();

                              try {
                                final response = await _authService.register(
                                  name: fullName,
                                  email: email,
                                  password: password,
                                  phoneNumber: "", // Not required for seller
                                  isSeller: true,
                                  storeName: storeName,
                                  location: location,
                                  description: _defaultDescription,
                                );

                                setState(() {
                                  _isLoading = false;
                                });

                                if (response != null &&
                                    !response.containsKey("error")) {
                                  // If registering with a Gmail address, trigger email verification.
                                  if (email
                                      .toLowerCase()
                                      .contains("gmail.com")) {
                                    final verificationResponse =
                                        await _authService
                                            .sendVerificationEmail(email);
                                    if (verificationResponse != null &&
                                        !verificationResponse
                                            .containsKey("error")) {
                                      Get.snackbar(
                                        "Success",
                                        "Registration successful. A verification email has been sent to your email address. Please verify your account.",
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    } else {
                                      Get.snackbar(
                                        "Warning",
                                        "Registration successful but failed to send verification email. Please try again later.",
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  } else {
                                    Get.snackbar(
                                      "Success",
                                      "Registration successful. Please log in.",
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                  Get.toNamed('/sellerlogin');
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    response?["error"] ??
                                        "Registration failed.",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                Get.snackbar(
                                  "Error",
                                  "An error occurred: ${e.toString()}",
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.back(); // Go back to the login page
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // For Gmail registration, please use the form.
                        _buildSocialButton('assets/images/Google.png', () {
                          Get.snackbar(
                            "Info",
                            "To receive a verification email, please complete registration using the form.",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }),
                        const SizedBox(width: 10),
                        _buildSocialButton('assets/images/Apple.png', () {}),
                        const SizedBox(width: 10),
                        _buildSocialButton('assets/images/Facebook.png', () {}),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}
