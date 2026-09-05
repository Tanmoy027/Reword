import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reword_frontend/admin/pages/dashboard_page.dart';
import 'package:reword_frontend/login/login.dart';
import 'package:reword_frontend/profile/profile.dart';
import 'package:reword_frontend/seller/mainpages/seller_dashboard_screen.dart';
import 'package:reword_frontend/seller/mainpages/sellervoucher/voucher_dashboard.dart';
import 'package:reword_frontend/login/login2.dart';
import 'package:reword_frontend/seller/sellerlogin/sellerlogin.dart';
import 'package:reword_frontend/seller/sellerreigistration/sellerregistration1.dart';
import 'package:reword_frontend/user/user_home.dart';
import 'package:reword_frontend/user/userreg/userregistration.dart';
import 'package:reword_frontend/welcome/choice_page.dart';
import 'package:reword_frontend/welcome/stating.dart';
import 'package:reword_frontend/admin/admin%20profile/admin_profile_page.dart';
import 'package:reword_frontend/admin/pages/admin_clients_customers.dart';
import 'package:reword_frontend/admin/pages/adminlogin.dart';
import 'package:reword_frontend/admin/pages/sellerdasbordaccess.dart';
import 'package:reword_frontend/login/service/user_service.dart';
import 'package:reword_frontend/login/service/google_auth_service.dart';
import 'package:reword_frontend/login/service/facebook_auth_service.dart'; // Add this import
import 'package:reword_frontend/notification/notificationpage.dart';
import 'package:reword_frontend/seller/mainpages/coustomer/customer_details_page.dart';
import 'package:reword_frontend/user/order/userorderui.dart';
import 'package:reword_frontend/user/profile/profileuser.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//import 'forgotpassword/deep_link_service.dart';
import 'user/favorites/my_favorites_page.dart';
import 'user/favorites/my_favorites_controller.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If your app supports background/terminated notifications, handle them here
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Optional: set a background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Stripe
  Stripe.publishableKey =
      'API KEY';
  await Stripe.instance.applySettings();

  // Create a UserService instance and register it with GetX
  final userService = UserService();
  Get.put<UserService>(userService, permanent: true);

  // Add GoogleAuthService to GetX
  final googleAuthService = GoogleAuthService();
  Get.put<GoogleAuthService>(googleAuthService, permanent: true);

  // Add FacebookAuthService to GetX
  final facebookAuthService = FacebookAuthService();
  Get.put<FacebookAuthService>(facebookAuthService, permanent: true);

  // Check if user is logged in
  bool isLoggedIn = await userService.isLoggedIn();
  String initialRoute = '/starting';

  if (isLoggedIn) {
    // Check if user is admin
    bool isAdmin = await userService.isAdmin();
    if (isAdmin) {
      initialRoute = '/adminDashboard';
    } else {
      // Check if user is seller
      bool isSeller = await userService.isSeller();
      if (isSeller) {
        initialRoute = '/sellerHome';
      } else {
        initialRoute = '/userhome';
      }
    }
  }

  // Start the app
  runApp(MyApp(initialRoute: initialRoute));

  // Set up the platform channel to handle method calls from native code
  const platform = MethodChannel('com.example.reword_frontend/auth');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'handleGoogleToken') {
      final token = call.arguments as String;
      print("Received token from platform channel: $token");
      GoogleAuthService.handleGoogleCallback(token);
      return true;
    }
    return null;
  });
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coupon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/starting', page: () => StatingPage()),
        GetPage(name: '/choice', page: () => ChoicePage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/userlogin2', page: () => logain2()),
        GetPage(name: '/userregis', page: () => Registration()),
        GetPage(name: '/sellerregis', page: () => sellerRegistration()),
        GetPage(name: '/sellerlogin', page: () => logainseller()),
        GetPage(name: '/sellerHome', page: () => SellerDashboardScreen()),
        GetPage(name: '/vouchers', page: () => VoucherDashboard()),
        GetPage(name: '/userhome', page: () => UserHomePage()),
        GetPage(name: '/adminDashboard', page: () => DashboardPage()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/profileuser', page: () => ProfilePageuser()),
        GetPage(name: '/profileForAdmin', page: () => AdminProfilePage()),
        GetPage(name: '/notification', page: () => OnboardingScreen()),
        GetPage(name: '/customers', page: () => CustomerDetailsPage()),
        GetPage(name: '/adminLogin', page: () => AdminLogin()),
        GetPage(
            name: '/customersForAdmin',
            page: () => AdminClientsCustomersPage()),
        GetPage(
          name: '/adminseller-dashboard',
          page: () => AdminSellerDashboardView(), // No controller parameter
        ),
        GetPage(
            name: '/saved',
            page: () {
              // Initialize FavoritesController just before showing the page
              Get.put(FavoritesController(), permanent: true);
              return MyFavoritesPage();
            }),
        GetPage(name: '/userorder', page: () => OrderHistoryScreen()),
      ],
    );
  }
}
