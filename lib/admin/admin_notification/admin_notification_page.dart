import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './admin_notification_controller.dart';
import '../admin naviagtionbar/admin_bottom_navigation.dart';

class AdminNotificationPage extends StatelessWidget {
  final AdminNotificationController controller =
      Get.put(AdminNotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text("Send Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Broadcast Notification",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Send a notification to selected users",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),

              // Recipient selection
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Recipients",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    Obx(() => CheckboxListTile(
                          title: Text("All Users"),
                          value: controller.allUsers.value,
                          onChanged: controller.toggleAllUsers,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        )),
                    Divider(height: 1),
                    Obx(() => CheckboxListTile(
                          title: Text("Buyers Only"),
                          value: controller.buyerUsers.value,
                          onChanged: controller.toggleBuyerUsers,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          enabled: !controller.allUsers.value,
                        )),
                    Divider(height: 1),
                    Obx(() => CheckboxListTile(
                          title: Text("Sellers Only"),
                          value: controller.sellerUsers.value,
                          onChanged: controller.toggleSellerUsers,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          enabled: !controller.allUsers.value,
                        )),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Notification title input
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.titleController, // Bind controller
                  decoration: InputDecoration(
                    hintText: "Notification Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Notification message input
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.messageController, // Bind controller
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Type your notification message here...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Error message
              Obx(() => controller.errorMessage.value.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    )
                  : SizedBox.shrink()),

              // Success message
              Obx(() => controller.successMessage.value.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Text(
                        controller.successMessage.value,
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    )
                  : SizedBox.shrink()),

              SizedBox(height: 20),

              // Send button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.sendNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.send, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Send Notification",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                    )),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomNavigation(),
    );
  }
}
