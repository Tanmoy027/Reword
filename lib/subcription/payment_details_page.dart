import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> method;

  const PaymentDetailsPage({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "${method["name"]} Details",
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(method["icon"], color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    method["name"],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (method.containsKey("email"))
              Text(
                "Email: ${method["email"]}",
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            if (method["balance"] != null)
              Text(
                "Balance: ${method["balance"]}",
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            if (method.containsKey("details"))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  method["details"],
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Get.snackbar("Payment", "Proceeding with ${method["name"]}",
                  backgroundColor: Colors.transparent, // Set background color to transparent
                  overlayColor: Colors.black.withOpacity(0.5), // Use a color with transparency
                  overlayBlur: 5.0, // Set overlay blur to enhance the gradient effect
                  boxShadows: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.2),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    "Proceed to Pay",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
