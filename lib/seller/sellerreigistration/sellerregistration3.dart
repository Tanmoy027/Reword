import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerRegistration2 extends StatefulWidget {
  const SellerRegistration2({super.key});

  @override
  _SellerRegistration2State createState() => _SellerRegistration2State();
}

class _SellerRegistration2State extends State<SellerRegistration2> {
  final Map<String, TextEditingController> _controllers = {
    "Business Name": TextEditingController(),
    "Business Registration Number": TextEditingController(),
    "Business Address": TextEditingController(),
    "Phone Number": TextEditingController(),
    "Number": TextEditingController(),
    "Bank Account Number": TextEditingController(),
    "Bank Name": TextEditingController(),
    "Other": TextEditingController(),
  };

  final Map<String, bool> _paymentMethods = {
    "Bank Transfer": true,
    "PayPal": false,
    "Stripe": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/signin.png', // Background Image
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 50, // Adjust top padding
            left: 20,
            child: Image.asset(
              'assets/images/logo.png', // Replace with your logo
              height: 50,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                  top: 50), // Adds space before the white box starts
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8), // Transparent white
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                        height: 20), // Extra spacing before the content starts
                    const Text(
                      "Sell Your Experiences with Us!",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Join our community and reach more customers.",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Step Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepIndicator(1, false),
                        _buildStepIndicator(2, true),
                        _buildStepIndicator(3, false),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSectionTitle("Business Information"),
                    _buildInputField(
                        "Business Name", _controllers["Business Name"]!),
                    _buildInputField("Business Registration Number",
                        _controllers["Business Registration Number"]!),
                    _buildInputField(
                        "Business Address", _controllers["Business Address"]!),
                    _buildInputField(
                        "Phone Number", _controllers["Phone Number"]!),

                    _buildSectionTitle("Voucher Management"),
                    const Text(
                      "How many vouchers/services are intended to sell per month (optional for analytics)",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    _buildInputField("Number", _controllers["Number"]!),

                    _buildSectionTitle("Bank Details"),
                    _buildInputField("Bank Account Number",
                        _controllers["Bank Account Number"]!),
                    _buildInputField("Bank Name", _controllers["Bank Name"]!),

                    _buildSectionTitle("Preferred Payment Method"),
                    ..._paymentMethods.keys
                        .map((method) => _buildCheckbox(method)),
                    _buildInputField("Other", _controllers["Other"]!),

                    const SizedBox(height: 20),

                    // Next Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        Get.toNamed('/sellerReg3');
                      },
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Previous Button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF00897B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text(
                        "Previous",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF00897B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Center(
                      child: Text("Already have an account.",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds Input Fields
  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF00897B)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  // Builds Section Titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
      ),
    );
  }

  // Builds Checkbox Fields
  Widget _buildCheckbox(String label) {
    return Row(
      children: [
        Checkbox(
          value: _paymentMethods[label],
          onChanged: (value) {
            setState(() {
              _paymentMethods[label] = value!;
            });
          },
          activeColor: const Color(0xFF00897B),
        ),
        Text(label),
      ],
    );
  }

  // Builds Step Indicator
  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00897B) : Colors.white,
        border: Border.all(color: const Color(0xFF00897B)),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF00897B),
          ),
        ),
      ),
    );
  }
}
