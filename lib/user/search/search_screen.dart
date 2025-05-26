import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../user_home.dart';
import '../uservoucher/vdashboard.dart';
import 'voucher_search_controller.dart';

class SearchScreen extends StatelessWidget {
  // Add a flag to determine if we came from the home page
  final bool fromHomePage;

  SearchScreen({super.key, this.fromHomePage = false});

  // Lazily initialize the controller when needed
  final VoucherSearchController searchController =
      Get.put(VoucherSearchController());
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Request focus when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            searchController.clearSearch();
            // If we came from home page, go back to home page
            // Otherwise, use default back navigation
            if (fromHomePage) {
              Get.offAll(() => UserHomePage());
            } else {
              Get.back();
            }
          },
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search stores....',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0D6E61)),
              suffixIcon: Obx(
                () => searchController.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _textController.clear();
                          searchController.clearSearch();
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: searchController.search,
          ),
        ),
      ),
      body: Obx(() {
        if (searchController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0D6E61)),
          );
        }

        if (searchController.searchQuery.value.isEmpty) {
          return const Center(
            child: Text(
              'Search for stores by name',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        if (searchController.searchResults.isEmpty) {
          return const Center(
            child: Text(
              'No stores found',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: searchController.searchResults.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final store = searchController.searchResults[index];
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D6E61).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: store.profileImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            store.profileImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.store,
                                color: Color(0xFF0D6E61),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.store,
                            color: Color(0xFF0D6E61),
                          ),
                        ),
                ),
                title: Text(
                  store.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Best Price: \€${store.bestPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D6E61),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  // Navigate to store dashboard
                  Get.to(() => VDashboard(storeId: store.storeId));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
