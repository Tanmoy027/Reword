import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/admin/pages/admin_available_voucher.dart';

import '../admin controller/admin_redeem_voucher_controller.dart';

class RedeemVoucherPage extends StatelessWidget {
  final RedeemVoucherController controller = Get.put(RedeemVoucherController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Redeem Voucher",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Scan QR code or enter voucher details",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildInputBox(),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF116A68),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Get.to(() => AdminAvailableVoucherPage());
                // Handle Redeem Logic
              },
              child: const Text(
                "Redeem Voucher",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40), // Bottom spacing after button
          ],
        ),
      ),
    );
  }

  /// Input Box with QR Code and PIN fields
  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
              "QR Code", Icons.qr_code, controller.qrCodeController),
          const SizedBox(height: 15),
          _buildTextField("Enter PIN", Icons.vpn_key, controller.pinController),
        ],
      ),
    );
  }

  /// Text Field Builder
  Widget _buildTextField(
      String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
