import 'dart:ui';

class Vm {
  final String id; // Voucher ID
  final String sellerId; // Seller ID for the voucher
  final String priceOptionId;
  final String priceOptionId2; // Added second price option ID
  final String title;
  final String priceOptionTitle1; // Added price option title 1
  final String priceOptionTitle2; // Added price option title 2
  final double oldPrice;
  final double newPrice;
  final double oldPrice2;
  final double newPrice2;
  final String expires;
  final bool isActive;
  final VoidCallback inc;
  final VoidCallback dec;
  final String category; // Added category field

  Vm({
    required this.id,
    required this.sellerId,
    required this.priceOptionId,
    required this.priceOptionId2,
    required this.title,
    required this.priceOptionTitle1,
    required this.priceOptionTitle2,
    required this.oldPrice,
    required this.newPrice,
    required this.oldPrice2,
    required this.newPrice2,
    required this.expires,
    required this.isActive,
    required this.inc,
    required this.dec,
    this.category = '', // Default empty string
  });
}
