import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/user/uservoucher/vcard.dart';
import 'package:reword_frontend/login/service/user_service.dart';
import '../../login/login.dart';
import '../usernavbar/usernavigationbar.dart';
import 'my_favorites_controller.dart';

class MyFavoritesPage extends StatelessWidget {
  const MyFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Safely initialize the controller
    FavoritesController favoritesController;
    try {
      // Try to find existing controller
      favoritesController = Get.find<FavoritesController>();
    } catch (_) {
      // Create new controller if not found
      favoritesController = Get.put(FavoritesController());
    }

    // Refresh favorites when page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      favoritesController.checkLoginStatus();
      favoritesController.fetchFavorites();
      print('Refreshing favorites page');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        actions: [
          // Add login button if not logged in
          Obx(() => !favoritesController.isLoggedIn.value
              ? TextButton(
                  onPressed: () => Get.to(() => LoginPage()),
                  child: const Text('Login'),
                )
              : const SizedBox.shrink()),
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              favoritesController.fetchFavorites();
              Get.snackbar(
                'Refreshing',
                'Updating your favorites...',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 1),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        // Show loading indicator
        if (favoritesController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show login prompt if not logged in
        if (!favoritesController.isLoggedIn.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Please log in to view your favorites',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.to(() => LoginPage()),
                  child: const Text('Login'),
                ),
              ],
            ),
          );
        }

        // Show error message if any
        if (favoritesController.errorMessage.value.isNotEmpty &&
            !favoritesController.errorMessage.value
                .contains('Token not found')) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${favoritesController.errorMessage.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => favoritesController.fetchFavorites(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Show empty state
        if (favoritesController.favoriteVouchers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No favorites yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add vouchers to your favorites to see them here',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/userhome'),
                  child: const Text('Browse Vouchers'),
                ),
              ],
            ),
          );
        }

        // Show favorites list - keeping your original design without added cancel icons
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoritesController.favoriteVouchers.length,
          itemBuilder: (context, index) {
            final voucher = favoritesController.favoriteVouchers[index];
            // Determine if this is the second price option based on the price option ID
            final isSecondOption =
                voucher.priceOptionId == voucher.priceOptionId2;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Vcard(
                voucher: voucher,
                isSecondOption: isSecondOption,
                buyNow: () {},
              ),
            );
          },
        );
      }),
      bottomNavigationBar: const UserNavigationBar(),
    );
  }
}
