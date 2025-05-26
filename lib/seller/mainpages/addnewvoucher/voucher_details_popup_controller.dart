import 'dart:convert';
import 'package:intl/intl.dart'; // for date formatting
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/login/service/user_service.dart';
import 'package:reword_frontend/seller/mainpages/sellervoucher/voucher_model.dart';

import '../preview/voucher_preview_popup.dart';
import '../sellervoucher/voucher_controller.dart';

class VoucherDetailsController extends GetxController {
  final VoucherModel voucher;
  final VoucherController mainController;
  final UserService _userService = UserService();

  // Observables for main fields
  var title = ''.obs;
  var description = ''.obs;
  var terms = ''.obs;
  var expiryDate = ''.obs;

  // Instead of storing an actual date, we store a duration + a unit:
  late TextEditingController durationController;
  var selectedUnit = 'days'.obs;

  var priceOptions = <Map<String, String>>[].obs;
  var isExperienceSelected = true.obs;
  var isExcursionsSelected = false.obs;

  // Additional text controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController termsController;
  // We’ll keep an expiryDateController if you want, or skip it

  VoucherDetailsController({
    required this.voucher,
    required this.mainController,
  });

  @override
  void onInit() {
    super.onInit();
    // Initialize from voucher
    title.value = voucher.title;
    description.value = voucher.description ?? '';
    terms.value = 'Valid once only';
    expiryDate.value = voucher.expiryDate ?? '2025-12-31';

    // If we wanted to guess the old “duration” from the existing expiry date:
    // (this is purely optional)
    final existingDate = DateTime.tryParse(expiryDate.value) ?? DateTime.now();
    final now = DateTime.now();
    final difference = existingDate.difference(now);
    // Just store it in days, for example:
    int approxDays = difference.inDays;
    // Then we store that in the duration text field:
    durationController = TextEditingController(text: approxDays.toString());
    // Default unit to 'days':
    selectedUnit.value = 'days';

    // Other text controllers
    titleController = TextEditingController(text: title.value);
    descriptionController = TextEditingController(text: description.value);
    termsController = TextEditingController(text: terms.value);

    // Convert PriceOption objects to Map<String, String> for the UI
    priceOptions.value = voucher.priceOptions != null
        ? voucher.priceOptions!
            .map((option) => {
                  'title': option.title,
                  'salePrice': option.salePrice.toString(),
                  'actualPrice': option.actualPrice.toString(),
                })
            .toList()
        : [];
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    termsController.dispose();
    durationController.dispose();
    super.onClose();
  }

  void addPriceOption() {
    priceOptions.add({'title': '', 'salePrice': '', 'actualPrice': ''});
  }

  void updatePriceOptionTitle(int index, String value) {
    final option = priceOptions[index];
    option['title'] = value;
    priceOptions[index] = option;
  }

  void updatePriceOptionSalePrice(int index, String value) {
    final option = priceOptions[index];
    option['salePrice'] = value;
    priceOptions[index] = option;
  }

  void updatePriceOptionActualPrice(int index, String value) {
    final option = priceOptions[index];
    option['actualPrice'] = value;
    priceOptions[index] = option;
  }

  /// Saves the updated voucher to the backend via PUT,
  /// then updates it locally if successful.
  void saveVoucher() async {
    // Convert the “duration” + “unit” into a new expiryDate
    final int durValue = int.tryParse(durationController.text.trim()) ?? 0;
    final now = DateTime.now();
    DateTime computedExpiry;

    if (selectedUnit.value == 'hours') {
      computedExpiry = now.add(Duration(hours: durValue));
    } else if (selectedUnit.value == 'months') {
      computedExpiry = DateTime(
        now.year,
        now.month + durValue,
        now.day,
        now.hour,
        now.minute,
        now.second,
      );
    } else {
      computedExpiry = now.add(Duration(days: durValue));
    }

    final newExpiryString = DateFormat('yyyy-MM-dd').format(computedExpiry);

    // 1) Convert form fields & price options into a new VoucherModel:
    List<PriceOption> convertedPriceOptions = priceOptions.map((option) {
      return PriceOption(
        title: option['title'] ?? '',
        salePrice: double.tryParse(option['salePrice'] ?? '0') ?? 0,
        actualPrice: double.tryParse(option['actualPrice'] ?? '0') ?? 0,
        id: '',
      );
    }).toList();

    final updatedVoucher = VoucherModel(
      id: voucher.id,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      expiryDate: newExpiryString,
      priceOptions: convertedPriceOptions,
      unitsSold: voucher.unitsSold,
      revenue: voucher.revenue,
      conversionRate: voucher.conversionRate,
      daysRemaining: voucher.daysRemaining,
      isActive: voucher.isActive,
      voucherStatus: voucher.voucherStatus,
      sellerId: voucher.sellerId,
      storeName: voucher.storeName,
      location: voucher.location,
      category: voucher.category,
    );

    // 2) Make a PUT call to your backend
    final token = await _userService.getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar('Error', 'Token not found. Please log in again.');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
          'https://voucher-app-backend.vercel.app/api/vouchers/${voucher.id}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': updatedVoucher.title,
          'description': updatedVoucher.description,
          'priceOptions': updatedVoucher.priceOptions?.map((p) {
            return {
              'title': p.title,
              'salePrice': p.salePrice,
              'actualPrice': p.actualPrice,
            };
          }).toList(),
          'expiryDate': updatedVoucher.expiryDate,
          // If your backend supports “terms” or other fields, add them.
        }),
      );

      if (response.statusCode == 200) {
        // 3) Update the voucher in memory if PUT was successful
        final index = mainController.vouchers
            .indexWhere((v) => v.id == updatedVoucher.id);
        if (index != -1) {
          mainController.vouchers[index] = updatedVoucher;
          mainController.updateVoucherCounts();
        }
        Get.back(); // close popup
      } else {
        Get.snackbar(
          'Update Failed',
          'Status code: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  /// Show a preview of the new voucher data (doesn't save anything).
  void previewVoucher() {
    // Convert price options
    List<PriceOption> convertedPriceOptions = priceOptions.map((option) {
      return PriceOption(
        title: option['title'] ?? '',
        salePrice: double.tryParse(option['salePrice'] ?? '0') ?? 0,
        actualPrice: double.tryParse(option['actualPrice'] ?? '0') ?? 0,
        id: '',
      );
    }).toList();

    final previewVoucher = VoucherModel(
      id: voucher.id,
      title: titleController.text,
      description: descriptionController.text,
      expiryDate: expiryDate.value,
      priceOptions: convertedPriceOptions,
      unitsSold: voucher.unitsSold,
      revenue: voucher.revenue,
      conversionRate: voucher.conversionRate,
      daysRemaining: voucher.daysRemaining,
      isActive: voucher.isActive,
      voucherStatus: termsController.text,
    );

    Get.dialog(
      VoucherPreviewPopup(
        voucher: previewVoucher,
      ),
    );
  }
}
