// subscription_success_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionSuccessScreen extends StatelessWidget {
  const SubscriptionSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Optionally navigate to /sellerHome after a delay
    Future.delayed(const Duration(seconds: 2), () {
      // Example: go to sellerHome
      Get.offAllNamed('/sellerHome');
    });

    return Scaffold(
      body: Center(
        child: Text(
          'Subscription Successful!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
