import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_voucher_controller.dart';

class AddVoucherPopup extends StatelessWidget {
  final VoidCallback? onClose;
  final AddVoucherController controller = Get.put(AddVoucherController());

  AddVoucherPopup({Key? key, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Voucher',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Use the callback if provided, otherwise just close
                    if (onClose != null) {
                      onClose!();
                    } else {
                      Get.back();
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message display
                    Obx(
                      () => controller.errorMessage.value.isNotEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                controller.errorMessage.value,
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            )
                          : const SizedBox(),
                    ),

                    // Voucher Information
                    const Text(
                      'Voucher Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title field
                    _buildTextField(
                      controller: controller.titleController,
                      hintText: 'Title *',
                    ),
                    const SizedBox(height: 12),

                    // Description field
                    _buildTextField(
                      controller: controller.descriptionController,
                      hintText: 'Description',
                    ),
                    const SizedBox(height: 20),

                    // Price Option Details
                    const Text(
                      'Price Option Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dynamic price options
                    Obx(
                      () => Column(
                        children: [
                          for (final option in controller.priceOptions)
                            Column(
                              children: [
                                _buildTextField(
                                  controller: option['title']!,
                                  hintText: 'Price title *',
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: option['salePrice']!,
                                  hintText: 'Sale Price - Ex. \$200 *',
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: option['actualPrice']!,
                                  hintText: 'Actual Price - Ex. \$200 *',
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),

                          // Button to add a new price option
                          OutlinedButton(
                            onPressed: controller.addPriceOption,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              side: const BorderSide(color: Colors.teal),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text(
                              'Add new Price Option',
                              style: TextStyle(color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Coupon Code
                    const Text(
                      'Coupon Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: controller.couponCodeController,
                      hintText: 'Enter Coupon Code - Ex. SUMMER2025',
                    ),
                    const SizedBox(height: 20),

                    // Category
                    const Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Row(
                        children: [
                          Checkbox(
                            value: controller.isExperienceSelected.value,
                            onChanged: (value) {
                              controller.isExperienceSelected.value = value!;
                              if (value) {
                                controller.isExcursionsSelected.value = false;
                              } else if (!controller
                                  .isExcursionsSelected.value) {
                                // Don't allow both to be deselected
                                controller.isExperienceSelected.value = true;
                              }
                            },
                            activeColor: Colors.teal,
                          ),
                          const Text('Experience'),
                        ],
                      ),
                    ),
                    Obx(
                      () => Row(
                        children: [
                          Checkbox(
                            value: controller.isExcursionsSelected.value,
                            onChanged: (value) {
                              controller.isExcursionsSelected.value = value!;
                              if (value) {
                                controller.isExperienceSelected.value = false;
                              } else if (!controller
                                  .isExperienceSelected.value) {
                                // Don't allow both to be deselected
                                controller.isExcursionsSelected.value = true;
                              }
                            },
                            activeColor: Colors.teal,
                          ),
                          const Text('Excursion'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Terms & Expiry
                    const Text(
                      'Terms & Expiry date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Terms
                    _buildTextField(
                      controller: controller.termsController,
                      hintText: 'Terms & Condition',
                    ),
                    const SizedBox(height: 12),

                    // Duration + Unit
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: controller.durationController,
                            hintText: 'Duration',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.selectedDurationUnit.value,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
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
                                  controller.selectedDurationUnit.value = val;
                                }
                              },
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
                    const SizedBox(height: 24),

                    // Bottom row buttons
                    Row(
                      children: [
                        // Preview button
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Preview'),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Save button
                        Expanded(
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () async {
                                      await controller.saveVoucher();
                                      // Close only if success
                                      if (controller.isSuccess.value) {
                                        if (onClose != null) {
                                          onClose!();
                                        } else {
                                          Get.back();
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A helper method for building standard text fields.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
