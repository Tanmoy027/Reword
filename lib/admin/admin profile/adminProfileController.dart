import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/service/auth_service.dart';
import '../../login/service/user_service.dart';
import '../../welcome/choice_page.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userId = ''.obs;
  var profileImageBytes = Rx<Uint8List?>(null);
  var imageLoadError = false.obs;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  void fetchUserData() async {
    final token = await _userService.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    // Get local info first
    final userInfo = await _userService.getUserInfo();
    userName.value = userInfo['name'] ?? 'No Name';
    userEmail.value = userInfo['email'] ?? 'No Email';
    userId.value = await _userService.getUserId() ?? '';

    // Get profile data from API
    final url =
        Uri.parse("https://your-backend-url.com/api/profile/view-profile");
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true && data["user"] != null) {
          var user = data["user"];
          userName.value = user["name"] ?? userName.value;
          userEmail.value = user["email"] ?? userEmail.value;
          userId.value = user["_id"] ?? userId.value;

          // Process profile image data if available
          if (user["profileImage"] != null) {
            try {
              if (user["profileImage"]["url"] != null) {
                final imageResponse =
                    await http.get(Uri.parse(user["profileImage"]["url"]));
                if (imageResponse.statusCode == 200) {
                  profileImageBytes.value = imageResponse.bodyBytes;
                }
              }
            } catch (e) {
              profileImageBytes.value = null;
              imageLoadError.value = true;
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch profile data: $e");
    }
  }

  void logout() async {
    var response = await _authService.logout();
    if (response != null && response['status'] == 'success') {
      Get.offAll(() => ChoicePage());
    } else {
      Get.snackbar("Error", "Logout failed. Please try again.");
    }
  }
}
