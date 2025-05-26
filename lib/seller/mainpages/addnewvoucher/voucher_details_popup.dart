import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'voucher_details_popup_controller.dart';
import '../sellervoucher/voucher_controller.dart';
import '../sellervoucher/voucher_model.dart';

class VoucherDetailsPopup extends StatelessWidget {
  final VoucherModel voucher;
  final bool isEditing;

  const VoucherDetailsPopup({
    super.key,
    required this.voucher,
    this.isEditing = true,
  });

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<VoucherController>();
    final controller = Get.put(
      VoucherDetailsController(
        voucher: voucher,
        mainController: mainController,
      ),
      tag: voucher.title, // or any unique tag
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, size: 24),
              onPressed: () => Get.back(),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Voucher Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title field
                    TextField(
                      controller: controller.titleController,
                      decoration: InputDecoration(
                        hintText: 'Voucher Title',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description field
                    TextField(
                      controller: controller.descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Price Option Details
                    const Text(
                      'Price Option Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price Options List
                    GetBuilder<VoucherDetailsController>(
                      id: 'priceOptions',
                      tag: voucher.title,
                      builder: (ctrl) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ctrl.priceOptions.length,
                          itemBuilder: (context, index) {
                            final option = ctrl.priceOptions[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price Option ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Title
                                  TextField(
                                    controller: TextEditingController(
                                      text: option['title'],
                                    ),
                                    onChanged: (val) {
                                      ctrl.updatePriceOptionTitle(index, val);
                                      ctrl.update(['priceOptions']);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Option Title',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Sale & Actual Price in a row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(
                                            text: option['salePrice'],
                                          ),
                                          onChanged: (val) {
                                            ctrl.updatePriceOptionSalePrice(
                                                index, val);
                                            ctrl.update(['priceOptions']);
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Sale Price',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 16),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(
                                            text: option['actualPrice'],
                                          ),
                                          onChanged: (val) {
                                            ctrl.updatePriceOptionActualPrice(
                                                index, val);
                                            ctrl.update(['priceOptions']);
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Actual Price',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 16),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Add Price Option Button
                    OutlinedButton(
                      onPressed: () {
                        controller.addPriceOption();
                        controller.update(['priceOptions']);
                      },
                      child: const Text('Add new Price Option'),
                    ),
                    const SizedBox(height: 20),

                    // Category (check if you need to display/update it)
                    // Terms
                    const Text(
                      'Terms & Expiry date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.termsController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Terms and conditions',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Duration + Unit
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.durationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Duration',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.selectedUnit.value,
                              items: const [
                                DropdownMenuItem(
                                  value: 'hours',
                                  child: Text('hours'),
                                ),
                                DropdownMenuItem(
                                  value: 'days',
                                  child: Text('days'),
                                ),
                                DropdownMenuItem(
                                  value: 'months',
                                  child: Text('months'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  controller.selectedUnit.value = val;
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Voucher will expire after the specified duration',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.previewVoucher();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              side: const BorderSide(color: Colors.teal),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Preview'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.saveVoucher,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
