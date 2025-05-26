import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../bespoke/bespoke_experience.dart';

import '../usernavbar/usernavigationbar.dart';
import 'profile_controlleruser.dart';

import 'userprofileupdate.dart'; // Import the user profile update page

class ProfilePageuser extends StatelessWidget {
  final ProfileControlleruser controller = Get.put(ProfileControlleruser());

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
            _buildMenuItem(Icons.settings, "General Settings", () {
              Get.snackbar("Settings", "General settings clicked");
            }),
            _buildMenuItem(Icons.security, "Account Security", () {
              Get.snackbar("Security", "Account security clicked");
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
        leading: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
        ),
        title: Text(text, style: TextStyle(color: Colors.white)),
        trailing: trailingText != null
            ? Text(trailingText, style: TextStyle(color: Colors.green))
            : null,
        onTap: isLogout
            ? () {
                controller.logout();
              }
            : onTap,
      ),
    );
  }
}
