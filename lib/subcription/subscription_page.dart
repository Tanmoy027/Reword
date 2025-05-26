import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/subcription/subscription_page_seller.dart';

import '../payment/payment.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Unlock the",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Lanza Premium ",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  Text(
                    "now!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Current Plan Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.teal,
                      radius: 20,
                      child: Icon(Icons.account_circle, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Lanza Free",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Your Current Plan",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Toggle Buyer/Seller
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                // padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text("Buyer")),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: TextButton(
                            onPressed: () =>
                                Get.off(() => SubscriptionPageSeller()),
                            child: Text("Seller",
                                style: TextStyle(color: Colors.grey[600]))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Scrollable Subscription Cards
              SizedBox(
                height: 380,
                child: PageView(
                  controller:
                      PageController(viewportFraction: 0.9, initialPage: 1),
                  children: [
                    _subscriptionCard(
                      title: "Buyer Premium",
                      price: "\$20/yearly",
                      benefits: [
                        "Exclusive discounts",
                        "Access to members-only deals",
                        "Loyalty rewards",
                        "Earn points on purchases",
                        "Priority support",
                        "Priority customer service",
                        "Early access",
                        "Preview new offers before others",
                      ],
                      color: Colors.deepPurple[400]!,
                    ),
                    _subscriptionCard(
                      title: "Buyer Premium Pro",
                      price: "\$30/yearly",
                      benefits: [
                        "Exclusive discounts",
                        "Access to members-only deals",
                        "Loyalty rewards",
                        "Earn points on purchases",
                        "Priority support",
                        "Priority customer service",
                        "Early access",
                        "Preview new offers before others",
                      ],
                      color: Colors.pink[400]!,
                    ),
                    _subscriptionCard(
                      title: "Buyer Premium Pro Max",
                      price: "\$40/yearly",
                      benefits: [
                        "Boosted Listings",
                        "Seller Analytics",
                        "Lower transaction fees",
                        "Customer insights",
                        "Advanced marketing tools",
                        "Priority customer support",
                      ],
                      color: Colors.orange[400]!,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Benefits and Skip Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline_sharp,
                            color: Colors.teal, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "1 Month of Lanza Premium",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Get.snackbar(
                          "Skipped", "Subscription skipped for now."),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "Skip For Now",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subscriptionCard({
    required String title,
    required String price,
    required List<String> benefits,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            price,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ...benefits.map((benefit) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        benefit,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          ElevatedButton(
            // {
            //   Get.snackbar("Subscribed", "You have subscribed to $title");
            // },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {},
            child: const Text("Get Started",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
