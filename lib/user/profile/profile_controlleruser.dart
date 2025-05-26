import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:reword_frontend/login/service/auth_service.dart';
import 'package:reword_frontend/welcome/choice_page.dart';

import '../../login/service/user_service.dart';

class ProfileControlleruser extends GetxController {
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
    final url = Uri.parse(
        "https://voucher-app-backend.vercel.app/api/profile/view-profile");
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
        print("Profile data response: $data");

        if (data["success"] == true && data["user"] != null) {
          var user = data["user"];
          userName.value = user["name"] ?? userName.value;
          userEmail.value = user["email"] ?? userEmail.value;
          userId.value = user["_id"] ?? userId.value;

          // Process profile image data
          if (user["profileImage"] != null) {
            try {
              // Check if we have a direct image URL
              if (user["profileImage"]["url"] != null) {
                // If we have a URL, fetch the image data directly
                final imageResponse =
                    await http.get(Uri.parse(user["profileImage"]["url"]));
                if (imageResponse.statusCode == 200) {
                  profileImageBytes.value = imageResponse.bodyBytes;
                }
              }
              // If no URL but has data.data array
              else if (user["profileImage"]["data"] != null) {
                // The data might be Base64 encoded
                String base64String = '';

                if (user["profileImage"]["data"] is String) {
                  base64String = user["profileImage"]["data"];
                } else if (user["profileImage"]["data"]["data"] != null) {
                  if (user["profileImage"]["data"]["data"] is String) {
                    base64String = user["profileImage"]["data"]["data"];
                  } else if (user["profileImage"]["data"]["data"] is List) {
                    // If it's a byte array, convert it to a string first
                    List<dynamic> binaryData =
                        user["profileImage"]["data"]["data"];

                    // Check if the data is likely a Base64 string broken into a char array
                    if (binaryData.isNotEmpty &&
                        binaryData[0] is int &&
                        binaryData[0] >= 32 &&
                        binaryData[0] <= 126) {
                      // Convert ASCII values to string
                      base64String = String.fromCharCodes(
                          binaryData.map<int>((x) => x as int).toList());
                    } else {
                      // Use it directly as a byte array
                      profileImageBytes.value = Uint8List.fromList(
                          binaryData.map<int>((x) => x as int).toList());
                    }
                  }
                }

                // If we have a base64 string, decode it
                if (base64String.isNotEmpty) {
                  try {
                    // Remove data URL prefix if present
                    if (base64String.contains(',')) {
                      base64String = base64String.split(',')[1];
                    }
                    profileImageBytes.value = base64Decode(base64String);
                  } catch (e) {
                    print("Error decoding base64 image: $e");
                    imageLoadError.value = true;
                  }
                }
              }

              print(
                  "Successfully processed image data with length: ${profileImageBytes.value?.length}");
            } catch (e) {
              print("Error processing image data: $e");
              profileImageBytes.value = null;
              imageLoadError.value = true;
            }
          } else {
            print("No profile image data found in response");
            profileImageBytes.value = null;
          }
        }
      }
    } catch (e) {
      print("Error fetching profile data: $e");
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
