import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../login/service/auth_service.dart';
import '../login/service/user_service.dart';
import '../welcome/choice_page.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userId = ''.obs;
  var subscriptionType = 'Lanza Free'.obs;
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
              else if (user["profileImage"]["data"] != null &&
                  user["profileImage"]["data"]["data"] != null) {
                // The data might be Base64 encoded
                String base64String = '';
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

  void deleteAccount() async {
    try {
      final token = await _userService.getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Error", "You are not logged in");
        return;
      }

      // Set role as seller by default for this profile page
      final userRole = "seller"; // Setting default role as seller

      // Show confirmation dialog
      Get.defaultDialog(
        title: "Delete Account",
        middleText: "Are you sure you want to delete your account? This action cannot be undone. All your vouchers and orders will be deleted.",
        textConfirm: "Delete",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        cancelTextColor: Colors.black,
        onConfirm: () async {
          Get.back(); // Close the dialog
          Get.dialog(
            Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          // Using the correct API endpoint for account deletion from backend
          final url = Uri.parse("https://voucher-app-backend.vercel.app/api/auth/profile/delete");

          print("Attempting to delete seller account with URL: $url");
          print("Using auth token: ${token.substring(0, min(10, token.length))}...");
          print("User role: $userRole"); // Should be 'seller' for seller profiles
          
          try {
            // Send the delete request with authorization token
            // Include the role in the URL as a query parameter
            final urlWithRole = Uri.parse("${url.toString()}?role=$userRole");
            
            final response = await http.delete(
              urlWithRole,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'
              },
            );

            Get.back(); // Close loading dialog

            print("Delete account response status: ${response.statusCode}");
            print("Delete account response body: ${response.body}");

            if (response.statusCode == 200 || response.statusCode == 201) {
              try {
                final data = json.decode(response.body);
                // Check for success in the response
                if (data["message"] != null && !data.containsKey("error")) {
                  await _userService.clearUserData(); // Clear local user data
                  Get.offAll(() => ChoicePage()); // Navigate to login/choice page
                  Get.snackbar("Success", "Your seller account has been deleted successfully");
                } else {
                  Get.snackbar("Error", 
                    data["message"] ?? data["error"] ?? 
                    "Failed to delete account: Server indicated failure");
                }
              } catch (parseError) {
                print("Error parsing response: $parseError");
                // Even if we can't parse the response, assume success if status code is 200
                await _userService.clearUserData();
                Get.offAll(() => ChoicePage());
                Get.snackbar("Success", "Your seller account has been deleted successfully");
              }
            } else if (response.statusCode == 400) {
              // Handle 400 error - usually for invalid role
              Get.snackbar("Error", "Invalid user role. Please contact support.");
            } else if (response.statusCode == 401) {
              Get.snackbar("Authentication Error", 
                "You are not authorized to perform this action. Please log in again.");
            } else if (response.statusCode == 404) {
              // Handle 404 - seller not found in the database
              Get.snackbar("Error", 
                "Seller account not found. It may have already been deleted.");
            } else {
              String errorBody = "No response body";
              try {
                errorBody = response.body;
                final errorData = json.decode(errorBody);
                errorBody = errorData["message"] ?? errorData["error"] ?? errorBody;
              } catch (e) {
                // Use the raw error body if parsing fails
              }

              Get.snackbar("Error",
                  "Failed to delete account. Status: ${response.statusCode}, Details: $errorBody");
            }
          } catch (networkError) {
            Get.back(); // Make sure to close the dialog even if there's an error
            print("Network error during account deletion: $networkError");
            Get.snackbar("Network Error",
                "Could not connect to the server. Please check your internet connection and try again.");
          }
        },
      );
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    }
  }
}
