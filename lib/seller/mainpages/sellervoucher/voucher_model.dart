class VoucherModel {
  String id;
  String title;
  String? description;
  String? sellerId;
  String? storeName;
  String? location;
  String? category;
  String? expiryDate;
  List<PriceOption>? priceOptions;
  List<PriceOption>? formattedPriceOptions;
  double conversionRate;
  int unitsSold;
  double revenue;
  int daysRemaining;
  String? voucherStatus;
  bool isActive;

  VoucherModel({
    required this.id,
    required this.title,
    this.description,
    this.sellerId,
    this.storeName,
    this.location,
    this.category,
    this.expiryDate,
    this.priceOptions,
    this.formattedPriceOptions,
    required this.conversionRate,
    required this.unitsSold,
    required this.revenue,
    required this.daysRemaining,
    this.voucherStatus,
    required this.isActive,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse price options
    List<PriceOption> parsePriceOptions(List<dynamic>? options) {
      if (options == null) return [];
      return options.map((o) => PriceOption.fromJson(o)).toList();
    }

    final status = (json['voucherStatus'] ?? '').toLowerCase();
    final bool active = (status == 'active');

    return VoucherModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      sellerId: json['sellerId'],
      storeName: json['storeName'],
      location: json['location'],
      category: json['category'],
      expiryDate: json['expiryDate'],
      priceOptions: parsePriceOptions(json['priceOptions']),
      formattedPriceOptions: parsePriceOptions(json['formattedPriceOptions']),
      conversionRate: (json['conversionRate'] ?? 0).toDouble(),
      unitsSold: json['unitsSold'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      daysRemaining: json['daysRemaining'] ?? 0,
      voucherStatus: json['voucherStatus'],
      isActive: active,
    );
  }
}

class PriceOption {
  double actualPrice;
  double salePrice;
  String title;
  String id;

  PriceOption({
    required this.actualPrice,
    required this.salePrice,
    required this.title,
    required this.id,
  });

  factory PriceOption.fromJson(Map<String, dynamic> json) {
    return PriceOption(
      actualPrice: (json['actualPrice'] ?? 0).toDouble(),
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      title: json['title'] ?? '',
      id: json['id'] ?? json['_id'] ?? '',
    );
  }
}
