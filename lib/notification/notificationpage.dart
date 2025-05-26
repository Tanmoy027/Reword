import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reword_frontend/notification/notificationservice.dart';
// Import the notification service
// If your NotificationService is in a different path, update it accordingly

// NEW import for Firebase Messaging callbacks
import 'package:firebase_messaging/firebase_messaging.dart';

class OnboardingController extends GetxController {
  var notificationsEnabled = false.obs;
  var locationEnabled = false.obs;
  final NotificationService _notificationService = NotificationService();

  @override
  void onInit() {
    super.onInit();
    checkNotificationPermission();
    checkLocationPermission();

    // 1. Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Foreground message received: ${message.notification?.title}');

      // If you want to show a local notification while app is in the foreground:
      await _notificationService.showNotification(
        id: 0,
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? 'You have a new message!',
      );
    });

    // 2. Listen for messages when the app is opened from a background/terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked! Data: ${message.data}');

      // For example, navigate to a specific screen, e.g.:
      // Get.toNamed('/someRoute', arguments: message.data);
      // Or just print a log if you don't need to navigate.
    });
  }

  // Check for notifications permission
  Future<void> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) {
      // Also initialize notifications if already granted
      await _notificationService.initNotification();
      notificationsEnabled.value = true;
    }
  }

  // Request notification permission
  Future<void> enableNotifications() async {
    // Initialize notification service first
    await _notificationService.initNotification();

    // Then request permission
    final status = await Permission.notification.request();
    if (status.isGranted) {
      notificationsEnabled.value = true;
      // Send a test notification (optional)
      await _notificationService.showNotification(
        id: 0,
        title: 'Notifications Enabled',
        body: 'You will now receive updates and offers!',
      );
      // Navigate to '/choice' after enabling notifications
      navigateToChoice();
    }
  }

  // Check for location permission
  Future<void> checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      locationEnabled.value = true;
    } else {
      // Don't automatically request - wait for user to tap the button
    }
  }

  // Request location permission
  Future<void> enableLocation() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      locationEnabled.value = true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Show a dialog or notify the user about the denied permission
      // Navigate to settings if permission is permanently denied
      openAppSettings();
    }
  }

  // Navigate to '/choice' after enabling notifications
  void navigateToChoice() {
    // Small delay to ensure UI updates properly
    Future.delayed(Duration(milliseconds: 300), () {
      Get.toNamed('/choice');
    });
  }
}

class OnboardingScreen extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    // Mountain icon with location pin
                    Container(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.terrain,
                            size: 80,
                            color: Color(0xFF4CD4A9),
                          ),
                          Positioned(
                            top: 0,
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: Color(0xFF4CD4A9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60),
                    // Card with notification and location options
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Discover amazing deals and experiences',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'To get the most out of our app, please enable notifications and location services.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(() => ElevatedButton.icon(
                                        onPressed: controller
                                                .notificationsEnabled.value
                                            ? null
                                            : controller.enableNotifications,
                                        icon: Icon(Icons.notifications,
                                            color: Colors.white, size: 18),
                                        label: Text(
                                          'Enable Notifications',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                      )),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Obx(() => ElevatedButton.icon(
                                        onPressed:
                                            controller.locationEnabled.value
                                                ? null
                                                : controller.enableLocation,
                                        icon: Icon(Icons.location_on,
                                            color: Colors.black, size: 18),
                                        label: Text(
                                          'Enable Location',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Get Started button
              Container(
                margin: EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to '/choice' screen
                    Get.toNamed('/choice');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GET Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Lanza Free',
                            style: TextStyle(
                              color: Color(0xFF4CD4A9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Color(0xFF4CD4A9)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
