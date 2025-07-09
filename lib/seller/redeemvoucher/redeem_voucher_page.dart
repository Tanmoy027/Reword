import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../sellernavigationbar/seller_navigation_bar.dart';
import 'redeem_voucher_controller.dart';

class RedeemVoucherPage extends StatelessWidget {
  final RedeemVoucherController controller = Get.put(RedeemVoucherController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Redeem Voucher", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return controller.isLoading.value && controller.usedVouchers.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User and timestamp information
                    _buildUserInfoCard(),
                    SizedBox(height: 20),
                    _buildRedeemForm(),
                    SizedBox(height: 20),
                    if (controller.redeemSuccess.value) _buildSuccessCard(),
                    if (controller.errorMessage.value.isNotEmpty)
                      _buildErrorMessage(),
                    SizedBox(height: 20),
                    _buildUsedVouchersSection(),
                  ],
                ),
              );
      }),
      bottomNavigationBar: const SellerNavigationBar(),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        "Hello, ${controller.currentUser.value}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Obx(() => Text(
                        "Current Date: ${controller.currentDate.value}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Redeem Voucher",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            _buildTextField(
              controller: controller.couponCodeController,
              label: "Coupon Code",
              hint: "Enter coupon code",
              icon: Icons.confirmation_number,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: controller.buyerNameController,
              label: "Buyer Name",
              hint: "Enter buyer's name",
              icon: Icons.person,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: controller.buyerEmailController,
              label: "Buyer Email",
              hint: "Enter buyer's email",
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.clearForm(),
                  icon: Icon(Icons.clear),
                  label: Text("Clear"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Obx(() {
                  return ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.redeemVoucher(),
                    icon: controller.isLoading.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.check_circle),
                    label: Text("Redeem"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildSuccessCard() {
    final voucher = controller.redeemedVoucher.value;
    if (voucher == null) return SizedBox();

    String usedDate = "N/A";
    if (voucher["usedDate"] != null) {
      try {
        final date = DateTime.parse(voucher["usedDate"]);
        usedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
      } catch (e) {
        usedDate = voucher["usedDate"];
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  "Voucher Redeemed Successfully",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildInfoRow("Coupon Code", voucher["couponCode"] ?? "N/A"),
            _buildInfoRow("Title", voucher["title"] ?? "N/A"),
            _buildInfoRow("Buyer Name", voucher["buyerName"] ?? "N/A"),
            _buildInfoRow("Buyer Email", voucher["buyerEmail"] ?? "N/A"),
            _buildInfoRow("Used Date", usedDate),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.red[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsedVouchersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Used Vouchers",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => controller.fetchUsedVouchers(),
            ),
          ],
        ),
        SizedBox(height: 10),
        Obx(() {
          if (controller.isLoading.value && controller.usedVouchers.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.usedVouchers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No vouchers have been redeemed yet",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.usedVouchers.length,
            itemBuilder: (context, index) {
              final voucher = controller.usedVouchers[index];
              return _buildVoucherCard(voucher);
            },
          );
        }),
      ],
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> voucher) {
    final usedBy = (voucher['usedBy'] as List?) ?? [];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(
          voucher['title'] ?? 'No Title',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Code: ${voucher['couponCode'] ?? 'N/A'}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Used by ${usedBy.length} customer(s)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...usedBy.map((user) {
                  String usedAt = "N/A";
                  if (user["usedAt"] != null) {
                    try {
                      final date = DateTime.parse(user["usedAt"]);
                      usedAt = DateFormat('yyyy-MM-dd HH:mm').format(date);
                    } catch (e) {
                      usedAt = user["usedAt"];
                    }
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(user['name'] ?? 'No Name'),
                    subtitle: Text(user['email'] ?? 'No Email'),
                    trailing: Text(usedAt),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
