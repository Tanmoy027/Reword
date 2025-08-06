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

                    // All Users Radio
                    Obx(() => RadioListTile<String>(
                          title: Text("All Users"),
                          value: 'all',
                          groupValue: controller.selectedRecipient.value,
                          onChanged: (value) =>
                              controller.selectRecipient(value!),
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xFF158482),
                        )),

                    Divider(height: 1),

                    // Buyers Only Radio
                    Obx(() => RadioListTile<String>(
                          title: Text("Buyers Only"),
                          value: 'buyers',
                          groupValue: controller.selectedRecipient.value,
                          onChanged: (value) =>
                              controller.selectRecipient(value!),
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xFF158482),
                        )),

                    Divider(height: 1),

                    // Sellers Only Radio
                    Obx(() => RadioListTile<String>(
                          title: Text("Sellers Only"),
                          value: 'sellers',
                          groupValue: controller.selectedRecipient.value,
                          onChanged: (value) =>
                              controller.selectRecipient(value!),
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xFF158482),
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
                  controller: controller.titleController,
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
                  controller: controller.messageController,
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

              SizedBox(height: 30),

              // Send button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.sendNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF158482),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.send, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Send Notification",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
