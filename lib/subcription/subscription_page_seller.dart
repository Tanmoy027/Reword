import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'payment_page.dart';

class SubscriptionPageSeller extends StatelessWidget {
  const SubscriptionPageSeller({Key? key}) : super(key: key);

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
            onPressed: () {
              Get.snackbar(
                'Subscription Info',
                'Choose a plan that suits your business needs. '
                    'Higher tier plans offer more listings and lower commission.',
                duration: const Duration(seconds: 5),
              );
            },
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
                  Text(
                    "Lanza Premium ",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    "now!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Current Free Plan
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

              // PageView of Plans
              SizedBox(
                height: 380,
                child: PageView(
                  controller: PageController(
                    viewportFraction: 0.9,
                    initialPage: 0,
                  ),
                  children: [
                    // Plan #1: "basic"
                    _subscriptionCard(
                      displayName: "Seller Premium", // Shown to user
                      planKey: "basic", // Actual key for backend
                      displayPrice: "\$50/yearly",
                      numericPrice: 50.0,
                      benefits: [
                        "20 Product listings",
                        "Reduced commission",
                        "Basic analytics",
                        "Standard support",
                        "Lower commission rates",
                      ],
                      color: Colors.deepPurple[400]!,
                    ),
                    // Plan #2: "standard"
                    _subscriptionCard(
                      displayName: "Seller Premium Pro", // Shown to user
                      planKey: "standard", // Actual key
                      displayPrice: "\$80/yearly",
                      numericPrice: 80.0,
                      benefits: [
                        "30 Product listings",
                        "Lower commission",
                        "Advanced analytics",
                        "Priority support",
                        "Lower commission rates",
                        "Early access to features",
                      ],
                      color: Colors.pink[400]!,
                    ),
                    // Plan #3: "premium"
                    _subscriptionCard(
                      displayName: "Seller Premium Pro Max",
                      planKey: "premium",
                      displayPrice: "\$100/yearly",
                      numericPrice: 100.0,
                      benefits: [
                        "40 Product listings",
                        "Lowest transaction fees",
                        "Premium analytics",
                        "Customer insights",
                        "Advanced marketing tools",
                        "24/7 Priority support",
                      ],
                      color: Colors.orange[400]!,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Skip
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
                          "Upgrade for more product listings",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.snackbar(
                          "Skipped",
                          "You can upgrade anytime from your seller dashboard.",
                          duration: const Duration(seconds: 3),
                        );
                      },
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Renders each plan card
  Widget _subscriptionCard({
    required String displayName, // e.g. "Seller Premium"
    required String planKey, // e.g. "basic"
    required String displayPrice, // e.g. "$50/yearly"
    required double numericPrice,
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
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            displayPrice,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Display benefits
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // "Get Started" => PaymentPage with planKey
          ElevatedButton(
            onPressed: () {
              // Pass the real planKey ("basic"/"standard"/"premium") to PaymentPage
              Get.to(
                () => PaymentPage(
                  planName:
                      planKey, // FIXED: Passing the backend plan key, not the display name
                  planPrice: numericPrice, // 50, 80, or 100
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
