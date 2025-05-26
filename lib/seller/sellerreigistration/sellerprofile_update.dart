import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

import 'package:reword_frontend/login/service/user_service.dart';

class ProfileUpdateSeller extends StatefulWidget {
  const ProfileUpdateSeller({Key? key}) : super(key: key);

  @override
  State<ProfileUpdateSeller> createState() => _ProfileUpdateSellerState();
}

class _ProfileUpdateSellerState extends State<ProfileUpdateSeller> {
  // Controllers for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage; // Holds the chosen image file
  Uint8List?
      _profileImageBytes; // Holds the base64-decoded image data from backend
  bool _isUpdating = false;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Fetches the existing profile data and pre-populates the text fields.
  Future<void> _loadProfileData() async {
    final userService = UserService();
    final token = await userService.getToken();
    if (token == null || token.isEmpty) {
      _showError("User not authenticated");
      return;
    }

    _userId = await userService.getUserId() ?? '';

    final url = Uri.parse(
      "https://voucher-app-backend.vercel.app/api/profile/view-profile",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["user"] != null) {
          var user = data["user"];
          setState(() {
            _nameController.text = user["name"] ?? "";
            _emailController.text = user["email"] ?? "";
            _storeNameController.text = user["storeName"] ?? "";
            _locationController.text = user["location"] ?? "";
            _descriptionController.text = user["description"] ?? "";
            _userId = user["_id"] ?? _userId;

            // Use base64 image data from response if available
            if (user["profileImage"] != null &&
                user["profileImage"]["data"] != null) {
              _profileImageBytes = base64Decode(user["profileImage"]["data"]);
            } else {
              _profileImageBytes = null;
            }
          });
        }
      } else {
        _showError("Failed to load profile data: ${response.body}");
      }
    } catch (e) {
      _showError("An error occurred while loading profile: $e");
    }
  }

  // Function to handle image selection using image_picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress image to reduce size
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Debug: print file size
      final fileSize = await File(pickedFile.path).length();
      print('Selected image size: ${fileSize / 1024} KB');
    } else {
      Get.snackbar(
        "No Image Selected",
        "Please select an image from your gallery",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Updated function: send multipart with file bytes and content type.
  Future<void> _updateProfile() async {
    setState(() => _isUpdating = true);

    try {
      final userService = UserService();
      final token = await userService.getToken();
      if (token == null || token.isEmpty) {
        _showError("User not authenticated");
        setState(() => _isUpdating = false);
        return;
      }

      final apiUrl =
          "https://voucher-app-backend.vercel.app/api/profile/update-profile";

      if (_selectedImage != null) {
        // Create a multipart request
        var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));

        // Add authorization header
        request.headers['Authorization'] = 'Bearer $token';

        // Add text fields
        request.fields['name'] = _nameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['storeName'] = _storeNameController.text.trim();
        request.fields['location'] = _locationController.text.trim();
        request.fields['description'] = _descriptionController.text.trim();

        // Read file bytes
        final bytes = await _selectedImage!.readAsBytes();

        // Get file extension for mime type
        final extension = path.extension(_selectedImage!.path).toLowerCase();
        String mimeType = 'image/jpeg'; // Default
        if (extension == '.png') mimeType = 'image/png';
        if (extension == '.jpg' || extension == '.jpeg')
          mimeType = 'image/jpeg';

        // Add file to the request
        request.files.add(
          http.MultipartFile.fromBytes(
            'profileImage',
            bytes,
            filename: 'profile_image$extension',
            contentType: MediaType.parse(mimeType),
          ),
        );

        // Send the request
        final response = await request.send();
        final responseData = await http.Response.fromStream(response);

        print("Status Code: ${response.statusCode}");
        print("Response Body: ${responseData.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(responseData.body);
          if (data["success"] == true) {
            _showSuccessAndReload(data["message"]);
          } else {
            _showError(data["message"] ?? "Failed to update profile");
          }
        } else {
          String errorMessage = "Failed to update profile";
          try {
            final errorData = jsonDecode(responseData.body);
            errorMessage = errorData["message"] ?? errorMessage;
          } catch (_) {}
          _showError("$errorMessage (${response.statusCode})");
        }
      } else {
        // No image update (your existing code for this case works fine)
        // ...
      }
    } catch (e) {
      _showError("An error occurred during update: $e");
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showSuccessAndReload(String? message) {
    Get.snackbar(
      "Success",
      message ?? "Profile updated successfully",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade200,
    );
    _loadProfileData();
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/signin.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 60,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Update Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade100,
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _profileImageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      _profileImageBytes!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cloud_upload,
                                            size: 40, color: Colors.grey),
                                        SizedBox(height: 10),
                                        Text(
                                          "Upload Store Profile Photo",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text("Change Image"),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF00897B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: _inputDecoration("Name"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      decoration: _inputDecoration("Email"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _storeNameController,
                      decoration: _inputDecoration("Store Name"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _locationController,
                      decoration: _inputDecoration("Location"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _descriptionController,
                      decoration: _inputDecoration("Description"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isUpdating
                            ? Colors.grey.shade400
                            : const Color(0xFF00897B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 5,
                      ),
                      onPressed: _isUpdating ? null : _updateProfile,
                      child: _isUpdating
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Update Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF00897B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFF00897B)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text(
                        "Previous",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00897B)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
    );
  }
}
