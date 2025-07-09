import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/login/service/user_service.dart';
import 'vm.dart';

class VController extends GetxController {
  final String storeId;

  VController({required this.storeId});

  // Observables for store info
  var storeName = ''.obs;
  var storeLocation = ''.obs;
  var storeDescription = ''.obs;
  var storeProfileImage = Rx<String?>(null);

  // List of vouchers (wrapped as `Vm`) for display in VDashboard
  var voucherss = <Vm>[].obs;
  // All vouchers without filtering
  var allVouchers = <Vm>[].obs;

  // Selected category filter
  var selectedCategory = 'All'.obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    fetchStoreVouchers();
  }

  // Filter vouchers by category
  void filterByCategory(String category) {
    selectedCategory.value = category;

    if (category == 'All') {
      voucherss.assignAll(allVouchers);
    } else {
      final filtered =
          allVouchers.where((voucher) => voucher.category == category).toList();
      voucherss.assignAll(filtered);
    }
  }

  // GET /api/vouchers/store/:storeId
  Future<void> fetchStoreVouchers() async {
    isLoading.value = true;
    errorMessage.value = '';

    final token = await _userService.getToken();
    if (token == null || token.isEmpty) {
      errorMessage.value = 'Token not found. Please log in.';
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://voucher-app-backend.vercel.app/api/vouchers/store/$storeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Store info
        final storeData = data['store'];
        storeName.value = storeData['storeName'] ?? 'Unknown Store';
        storeLocation.value = storeData['location'] ?? 'No location';
        storeDescription.value = storeData['description'] ?? '';
        storeProfileImage.value = storeData['profileImage'];

        final voucherArray = data['vouchers'] as List;
        final List<Vm> voucherList = [];

        // Process each voucher from the API
        for (var voucherJson in voucherArray) {
          final priceOptions = voucherJson['priceOptions'] as List?;

          if (priceOptions == null || priceOptions.isEmpty) {
            continue; // Skip vouchers without price options
          }

          // Get base voucher data
          final voucherId = voucherJson['_id'] ?? '';
          final sellerId = voucherJson['sellerId'] ?? '';
          final title = voucherJson['title'] ?? 'No Title';
          final expiryDate = voucherJson['expiryDate'] ?? '';
          final isActive =
              (voucherJson['voucherStatus'] ?? '').toLowerCase() == 'active';
          final category = voucherJson['category'] ?? '';

          // Process first price option - always add this voucher
          if (priceOptions.isNotEmpty) {
            final first = priceOptions[0];
            final priceOptionId = first['_id'] ?? '';
            final priceOptionTitle = first['title'] ?? 'Standard Deal';
            final oldPrice = (first['actualPrice'] ?? 0).toDouble();
            final newPrice = (first['salePrice'] ?? 0).toDouble();

            // Create first voucher object
            voucherList.add(Vm(
              id: voucherId,
              sellerId: sellerId,
              priceOptionId: priceOptionId,
              priceOptionId2: '', // Not needed for single card display
              title: title,
              priceOptionTitle1: priceOptionTitle,
              priceOptionTitle2: '', // Not needed for single card display
              oldPrice: oldPrice,
              newPrice: newPrice,
              oldPrice2: 0, // Not needed for single card display
              newPrice2: 0, // Not needed for single card display
              expires: expiryDate,
              isActive: isActive,
              inc: () {},
              dec: () {},
              category: category, // Add the category to the Vm
            ));
          }

          // Process second price option if available - add as separate voucher
          if (priceOptions.length > 1) {
            final second = priceOptions[1];
            final priceOptionId2 = second['_id'] ?? '';
            if (priceOptionId2.isNotEmpty) {
              final priceOptionTitle2 = second['title'] ?? 'Premium Bundle';
              final oldPrice2 = (second['actualPrice'] ?? 0).toDouble();
              final newPrice2 = (second['salePrice'] ?? 0).toDouble();

              // Create second voucher object
              voucherList.add(Vm(
                id: voucherId,
                sellerId: sellerId,
                priceOptionId:
                    priceOptionId2, // Use the second price option as primary
                priceOptionId2: '', // Not needed for single card display
                title: title,
                priceOptionTitle1:
                    priceOptionTitle2, // Use second option title as primary
                priceOptionTitle2: '', // Not needed for single card display
                oldPrice: oldPrice2, // Use second option price as primary
                newPrice: newPrice2, // Use second option price as primary
                oldPrice2: 0, // Not needed for single card display
                newPrice2: 0, // Not needed for single card display
                expires: expiryDate,
                isActive: isActive,
                inc: () {},
                dec: () {},
                category: category, // Add the category to the Vm
              ));
            }
          }
        }

        // Update the observable lists of vouchers
        allVouchers.assignAll(voucherList);
        voucherss.assignAll(voucherList); // Initially show all vouchers
      } else {
        errorMessage.value =
            'Failed to load store vouchers. Status: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
