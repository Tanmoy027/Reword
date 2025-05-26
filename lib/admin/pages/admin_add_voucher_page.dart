import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/admin/admin%20controller/admin_voucher_controller.dart';
import 'package:reword_frontend/admin/pages/admin_redeem_voucher_page.dart';

class AddVoucherPage extends StatelessWidget {
  final VoucherController controller = Get.put(VoucherController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Voucher"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Voucher Title", controller.title),
            _buildTextField("Description", controller.description, maxLines: 3),
            _buildTextField("Image URL", controller.imageUrl),
            _buildTextField("Terms and Conditions", controller.terms,
                maxLines: 3),
            _buildTextField("dd/mm/yyyy", controller.date, isDatePicker: true),
            _buildTextField("Normal Price (€)", controller.normalPrice),
            _buildTextField("Sale Price (€)", controller.salePrice),

            const SizedBox(height: 15),
            const Text("Categories",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildCheckbox("Food", controller.foodCategory),
            _buildCheckbox("Entertainment", controller.entertainmentCategory),
            _buildCheckbox("Travel", controller.travelCategory),
            _buildCheckbox("Shopping", controller.shoppingCategory),

            const SizedBox(height: 15),
            const Text("Price Options",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        "Type (e.g., Adult, Child)", controller.priceType)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildTextField("Price (€)", controller.priceValue)),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF116A68),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Get.to(() => RedeemVoucherPage());
                // Handle voucher submission
              },
              child: const Text("Add Price Option",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),

            const SizedBox(height: 30), // Extra bottom space
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, RxString value,
      {int maxLines = 1, bool isDatePicker = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: (val) => value.value = val,
      ),
    );
  }

  Widget _buildCheckbox(String title, RxBool value) {
    return Obx(() => CheckboxListTile(
          title: Text(title),
          value: value.value,
          onChanged: (val) => value.value = val!,
          controlAffinity: ListTileControlAffinity.leading,
        ));
  }
}
