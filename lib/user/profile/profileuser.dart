import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../bespoke/bespoke_experience.dart';
import '../../privacy_policy/privacy_policy.dart';
import '../../forgotpassword/forgot_Pass.dart'; // Add this import

import '../usernavbar/usernavigationbar.dart';
import 'profile_controlleruser.dart';

import 'userprofileupdate.dart'; // Import the user profile update page
// Import the legal pages screen

class ProfilePageuser extends StatelessWidget {
  final ProfileControlleruser controller =
      Get.put(ProfileControlleruser(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Display profile image
            Obx(() {
              return Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black12,
                    child: controller.profileImageBytes.value != null
                        ? ClipOval(
                            child: Image.memory(
                              controller.profileImageBytes.value!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print("Error rendering image: $error");
                                return Icon(Icons.person,
                                    size: 50, color: Colors.grey);
                              },
                            ),
                          )
                        : Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  if (controller.imageLoadError.value)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline,
                            color: Colors.white, size: 16),
                      ),
                    ),
                ],
              );
            }),
            SizedBox(height: 10),
            Obx(() => Text(controller.userName.value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Obx(() => Text(controller.userEmail.value,
                style: TextStyle(color: Colors.grey))),
            SizedBox(height: 20),
            _buildMenuItem(Icons.payment, "Payment Method", () {
              Get.snackbar("Payment", "Payment method clicked");
            }),
            _buildMenuItem(Icons.card_giftcard, "Bespoke Experience", () {
              Get.to(() => BespokeExperiencePage());
            }),
            _buildMenuItem(Icons.edit, "Edit Profile", () {
              Get.to(() =>
                  ProfileUpdateUser()); // Navigate to the ProfileUpdateUser page
            }),
            _buildMenuItem(Icons.delete_forever, "Delete Account", () {
              // Show customized warning dialog
              showDialog(
                context: Get.context!,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    "Delete Account",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.black,
                        size: 60,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "If you delete your account, all your data will be deleted.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "This action cannot be undone.",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.black, width: 1.5),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          "CANCEL",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        try {
                          controller.deleteAccount();
                        } catch (e) {
                          print("Error calling deleteAccount: $e");
                          Get.snackbar("Error", "Failed to delete account: $e");
                        }
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          "DELETE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }, isLogout: false),
            _buildMenuItem(Icons.security, "Privacy Policy", () {
              Get.to(() => const LegalPagesScreen());
            }),
            _buildMenuItem(Icons.lock_reset, "Reset Password", () {
              Get.to(() => ForgotPasswordScreen());
            }),
            SizedBox(height: 10),
            _buildMenuItem(Icons.logout, "Sign Out", () {
              controller.logout();
            }, isLogout: true),
          ],
        ),
      ),
      bottomNavigationBar: UserNavigationBar(),
    );
  }

  Widget _buildMenuItem(IconData icon, String text, Function() onTap,
      {String? trailingText, bool isLogout = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        tileColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon,
            color: Colors
                .white), // Remove the IconButton and use a simple Icon instead
        title: Text(text, style: TextStyle(color: Colors.white)),
        trailing: trailingText != null
            ? Text(trailingText, style: TextStyle(color: Colors.green))
            : null,
        onTap: onTap, // Only have one onTap handler
      ),
    );
  }
}
