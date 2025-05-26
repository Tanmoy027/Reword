import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAvailableVoucherController extends GetxController {
  var vouchers = <Voucher>[
    Voucher(
        "Gourmet Dinner", "5-course meal at a Michelin star restaurant", 120),
    Voucher("Skydiving Experience", "Thrilling tandem skydive from 14,000 feet",
        250),
    Voucher("Luxury Spa Package", "Full day of pampering at a 5-star spa", 180),
  ].obs;

  void addToCart(Voucher voucher) {
    Get.snackbar(
      "Added to Cart",
      "${voucher.title} added successfully!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF158482),
      colorText: Colors.white,
    );
  }
}

// Model for Voucher
class Voucher {
  final String title;
  final String description;
  final int price;

  Voucher(this.title, this.description, this.price);
}
