//dashboard.dart code

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/user/uservoucher/vcard.dart';
import 'package:reword_frontend/user/uservoucher/vcontroller.dart';

class VDashboard extends StatelessWidget {
  final String storeId; // We pass the storeId from the Home page
  VDashboard({super.key, required this.storeId});

  // Instead of direct `Get.put(VController())`, we pass storeId
  late final VController controller = Get.put(VController(storeId: storeId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // If loaded successfully, show the existing design:
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // Dynamic store profile image, handle the same way as in the home page
                    _buildStoreImage(controller.storeProfileImage.value),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
                // Store info section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dynamic storeName from the backend
                      Text(
                        controller.storeName.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Static rating (keep your design)
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 16),
                          Text(" 4.8 (12 Reviews)"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Dynamic location from the backend
                      Text(
                        controller.storeLocation.value,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            "Vouchers",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View all'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                // Voucher List - Modified to handle second price options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children:
                        List.generate(controller.voucherss.length, (index) {
                      final voucher = controller.voucherss[index];

                      // Determine if this is a second price option for the same voucher as the previous one
                      bool isSecondOption = false;
                      if (index > 0) {
                        final prevVoucher = controller.voucherss[index - 1];
                        if (prevVoucher.id == voucher.id) {
                          isSecondOption = true;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Vcard(
                          voucher: voucher,
                          isSecondOption:
                              isSecondOption, // Pass the flag to Vcard
                          buyNow: () {
                            // e.g. navigate to cart or etc.
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Helper method to build the store image
  Widget _buildStoreImage(String? profileImage) {
    if (profileImage != null) {
      if (profileImage.startsWith('data:image')) {
        // For base64 encoded image
        return FutureBuilder<Uint8List>(
          future: _decodeBase64Image(profileImage),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.grey.shade200,
                width: double.infinity,
                height: 200,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Container(
                color: Colors.grey.shade200,
                width: double.infinity,
                height: 200,
                child: const Icon(Icons.error),
              );
            }

            return Image.memory(
              snapshot.data!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        // For URL-based image
        return Image.network(
          profileImage,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Container(
              color: Colors.grey.shade200,
              width: double.infinity,
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              width: double.infinity,
              height: 200,
              child: const Icon(Icons.error),
            );
          },
        );
      }
    } else {
      // Default placeholder if no image is available
      return Container(
        color: Colors.grey.shade200,
        width: double.infinity,
        height: 200,
        child: const Icon(Icons.store, size: 60),
      );
    }
  }

  // Helper function to decode base64 image
  Future<Uint8List> _decodeBase64Image(String base64String) async {
    final base64Data =
        base64String.split(',').last; // Remove the prefix if present
    return base64Decode(base64Data);
  }
}
