import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Import your user nav bar
import 'search/search_screen.dart';
import 'usernavbar/usernavigationbar.dart';

// Import your home controller (which fetches stores)
import 'my_controller.dart';

// Import your StoreModel
import 'userservice/store_model.dart';
import 'uservoucher/vdashboard.dart';
// Import the SearchScreen

class UserHomePage extends StatelessWidget {
  UserHomePage({Key? key}) : super(key: key);

  final MyController controller = Get.put(MyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            SizedBox(width: 8),
            Text("Home"),
          ],
        ),
      ),
      body: Obx(() {
        // 1) Show a loading spinner if the controller is busy
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2) Show an error if something went wrong
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              "Error: ${controller.errorMessage.value}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 3) Otherwise, show your original UI
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome, Unlock Deals & Discounts",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Text(
                "Search for Vouchers & Deals",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Navigate to SearchScreen when search field is tapped
                  Get.to(() => SearchScreen(fromHomePage: true));
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search here...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // "Trending Gifts" with real store data:
              _dealSection("Trending Gifts"),

              // "Featured Deals" with real store data:
              _dealSection("Featured Deals"),
            ],
          ),
        );
      }),
      bottomNavigationBar: const UserNavigationBar(),
    );
  }

  // The "Trending Gifts" / "Featured Deals" section
  // shows real "storeList" from your controller
  Widget _dealSection(String title) {
    final stores = controller.storeList; // from MyController
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return _dealCard(store);
            },
          ),
        ),
      ],
    );
  }

  // Card showing storeName, bestPrice, etc.
  Widget _dealCard(StoreModel store) {
    return GestureDetector(
      onTap: () {
        // On tap: go to VDashboard with storeId
        Get.to(() => VDashboard(storeId: store.storeId));
      },
      child: Container(
        width: 236,
        height: 310,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display store profile image
            store.profileImage != null
                ? store.profileImage!.startsWith('data:image')
                    // For base64 encoded image
                    ? FutureBuilder<Uint8List>(
                        future: _decodeBase64Image(store.profileImage!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              color: Colors.grey.shade200,
                              width: 224,
                              height: 150,
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return Container(
                              color: Colors.grey.shade200,
                              width: 224,
                              height: 150,
                              child: const Icon(Icons.error),
                            );
                          }

                          return Image.memory(
                            snapshot.data!,
                            width: 224,
                            height: 150,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.network(
                        store.profileImage!,
                        width: 224,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            width: 224,
                            height: 150,
                            child: const Icon(Icons.error),
                          );
                        },
                      )
                : Container(
                    color: Colors.grey.shade200,
                    width: 224,
                    height: 150,
                    child: const Icon(Icons.store),
                  ),
            const SizedBox(height: 8),
            // Store Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                store.storeName.isNotEmpty ? store.storeName : "Untitled Store",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Safely show bestPrice or "N/A"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Text(
                    store.bestPrice > 0
                        ? "\€${store.bestPrice.toStringAsFixed(2)}"
                        : "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "RRP: \$70",
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "12% off",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size(224, 40),
                ),
                onPressed: () {
                  // Same as tapping card
                  Get.to(() => VDashboard(storeId: store.storeId));
                },
                child: const Text("Buy Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to decode base64 image
  Future<Uint8List> _decodeBase64Image(String base64String) async {
    final base64Data =
        base64String.split(',').last; // Remove the prefix if present
    return base64Decode(base64Data);
  }
}
