class StoreModel {
  final String storeName;
  final String location;
  final double bestPrice;
  final String storeId;
  final String? profileImage; // New field for profile image

  StoreModel({
    required this.storeName,
    required this.location,
    required this.bestPrice,
    required this.storeId,
    this.profileImage, // Include this in the constructor
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawPrice = json['bestPrice'] ?? 'N/A';
    double parsedPrice = 0.0;

    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice) ?? 0.0;
    }

    return StoreModel(
      storeName: json['storeName'] ?? '',
      location: json['location'] ?? '',
      bestPrice: parsedPrice,
      storeId: json['storeId'] ?? '',
      profileImage: json['profileImage'], // Add this line to get the image URL
    );
  }
}
