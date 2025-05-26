import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCreditCardPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryMonthController = TextEditingController();
  final TextEditingController expiryYearController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();

  RxBool rememberDetails = false.obs;
  RxBool emailDeals = false.obs;

  AddCreditCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('Add Credit Card'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Card Holder Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(labelText: 'Card Number'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryMonthController,
                    decoration: InputDecoration(labelText: 'MM'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: expiryYearController,
                    decoration: InputDecoration(labelText: 'YYYY'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: cvcController,
              decoration: InputDecoration(labelText: 'CVC'),
            ),
            SizedBox(height: 20),
            Obx(
              () => SwitchListTile(
                title: Text('Remember my details'),
                value: rememberDetails.value,
                onChanged: (value) => rememberDetails.value = value,
              ),
            ),
            Obx(
              () => SwitchListTile(
                title: Text('Please email me the latest deals in my location'),
                value: emailDeals.value,
                onChanged: (value) => emailDeals.value = value,
              ),
            ),
            Row(
              children: [
                Checkbox(value: true, onChanged: (_) {}),
                Expanded(
                  child: Text(
                      'I agree to the Terms & Conditions and Privacy Policy.'),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
