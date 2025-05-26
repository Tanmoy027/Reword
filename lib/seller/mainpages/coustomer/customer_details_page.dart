import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/seller/sellernavigationbar/seller_navigation_bar.dart';
import 'customer_details_controller.dart';

class CustomerDetailsPage extends StatelessWidget {
  const CustomerDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerDetailsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Customer Insights
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Obx(() => _insightCard(
                        'Total Customers',
                        '${controller.customers.length}',
                        const Color(0xFF4CAF50) // Green shade
                        )),
                    const SizedBox(width: 8),
                    Obx(() => _insightCard(
                        'Experience Customers',
                        '${controller.experienceCustomerCount.value}',
                        const Color(0xFF2196F3) // Blue shade
                        )),
                    const SizedBox(width: 8),
                    Obx(() => _insightCard(
                        'Expersions Customers',
                        '${controller.expersionsCustomerCount.value}',
                        const Color(0xFFFFC107) // Amber shade
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    controller.filterCustomers(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),

          // Customer List
          Expanded(
            child: Obx(() {
              if (controller.filteredCustomers.isEmpty) {
                return const Center(child: Text('No customers found.'));
              }
              return ListView.builder(
                itemCount: controller.filteredCustomers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: ExpansionTile(
                        title: Text(
                          controller.filteredCustomers[index].name,
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          controller.filteredCustomers[index].email,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF008080),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            controller.expandedCustomerIndex.value == index
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                        onExpansionChanged: (isExpanded) {
                          controller.toggleExpansion(index, isExpanded);
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Total voucher and returned section
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.shopping_cart,
                                            size: 16),
                                        const SizedBox(width: 4),
                                        const Text('Total voucher bought: '),
                                        Text(
                                            '${controller.filteredCustomers[index].totalVouchers}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.euro, size: 16),
                                        const SizedBox(width: 4),
                                        const Text('Returned: '),
                                        Text(
                                            '${controller.filteredCustomers[index].returned}'),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Vouchers header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Vouchers',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'View All',
                                        style: TextStyle(
                                          color: Color(0xFF008080),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Voucher list
                                ...controller.filteredCustomers[index].vouchers
                                    .map((voucher) {
                                  return Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  voucher.title,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.edit, size: 14),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            voucher.status,
                                            style: TextStyle(
                                              color: voucher.status == 'Active'
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            voucher.expiryDate,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            voucher.purchaseDate,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const SellerNavigationBar(),
    );
  }

  Widget _insightCard(String title, String value, Color backgroundColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: backgroundColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: backgroundColor.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: backgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
