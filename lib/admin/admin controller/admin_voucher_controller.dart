import 'package:get/get.dart';

class VoucherController extends GetxController {
  var title = ''.obs;
  var description = ''.obs;
  var imageUrl = ''.obs;
  var terms = ''.obs;
  var normalPrice = ''.obs;
  var salePrice = ''.obs;
  var date = ''.obs;

  var foodCategory = false.obs;
  var entertainmentCategory = false.obs;
  var travelCategory = false.obs;
  var shoppingCategory = false.obs;

  var priceType = ''.obs;
  var priceValue = ''.obs;
}
