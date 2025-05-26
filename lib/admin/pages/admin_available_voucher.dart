import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../admin controller/admin_available_voucher_controller.dart';

class AdminAvailableVoucherPage extends StatelessWidget {
  final AdminAvailableVoucherController controller =
      Get.put(AdminAvailableVoucherController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Available Vouchers',
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() => ListView.builder(
              itemCount: controller.vouchers.length,
              itemBuilder: (context, index) {
                final voucher = controller.vouchers[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          voucher.description,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '€${voucher.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.addToCart(voucher);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF158482),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }
}
