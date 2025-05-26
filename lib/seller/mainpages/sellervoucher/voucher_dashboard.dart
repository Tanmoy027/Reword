import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../sellernavigationbar/seller_navigation_bar.dart';
import '../addnewvoucher/add_voucher_popup.dart';
import 'voucher_card.dart';
import 'voucher_controller.dart';

class VoucherDashboard extends StatelessWidget {
  VoucherDashboard({Key? key}) : super(key: key);

  final VoucherController controller = Get.put(VoucherController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: const SellerNavigationBar(),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading vouchers',
                    style: TextStyle(fontSize: 18, color: Colors.red[700]),
                  ),
                  const SizedBox(height: 12),
                  Text(controller.errorMessage.value),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.fetchVouchers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter the vouchers by category
          final filteredVouchers = controller.vouchers.where((v) {
            final cat = (v.category ?? '').toLowerCase();
            if (controller.isExperiencesSelected.value) {
              return cat.contains('experience');
            } else {
              return cat.contains('excursion');
            }
          }).toList();

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 56,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        controller.toggleCategory(true),
                                    child: Obx(() {
                                      final sel = controller
                                          .isExperiencesSelected.value;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: sel
                                              ? Colors.teal
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Experiences',
                                          style: TextStyle(
                                            color: sel
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        controller.toggleCategory(false),
                                    child: Obx(() {
                                      final sel = !controller
                                          .isExperiencesSelected.value;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: sel
                                              ? Colors.teal
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Excursions',
                                          style: TextStyle(
                                            color: sel
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Voucher Status
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voucher Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Active
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Active Vouchers',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(() {
                                    return Text(
                                      '${controller.activeVouchersCount.value}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(width: 48),
                              // Expired
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expired Vouchers',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(() {
                                    return Text(
                                      '${controller.expiredVouchersCount.value}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Performance
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Performance Metrics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildMetricButton(context, 'All Vouchers', 0),
                                const SizedBox(width: 8),
                                _buildMetricButton(
                                    context, 'Add new Voucher', 1),
                                const SizedBox(width: 8),
                                _buildMetricButton(
                                    context, 'Expired Voucher', 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Voucher List
                    filteredVouchers.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 32.0),
                              child: Text(
                                'No vouchers found',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: filteredVouchers.map((voucher) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: VoucherCard(voucher: voucher),
                                );
                              }).toList(),
                            ),
                          ),
                  ],
                ),
              ),

              // Category loading overlay with blur
              Obx(() {
                return controller.isCategoryLoading.value
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white.withOpacity(0.6),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.teal,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading ${controller.isExperiencesSelected.value ? 'Experiences' : 'Excursions'}...',
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMetricButton(BuildContext context, String text, int index) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          controller.selectMetric(index);
          if (index == 1) {
            // Show bottom sheet for adding voucher
            Get.bottomSheet(
              SizedBox(
                height: Get.height * 0.7,
                child: AddVoucherPopup(
                  onClose: () {
                    // When user closes Add popup, reload vouchers:
                    controller.selectMetric(0);
                    Get.back();
                  },
                ),
              ),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: controller.selectedMetricIndex.value == index
                ? Colors.teal
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.selectedMetricIndex.value == index
                  ? Colors.teal
                  : Colors.grey,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: controller.selectedMetricIndex.value == index
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
