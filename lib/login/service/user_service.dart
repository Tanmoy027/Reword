// user_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String TOKEN_KEY = 'token';
  static const String USER_ID_KEY = 'userId';
  static const String USER_NAME_KEY = 'name';
  static const String USER_EMAIL_KEY = 'email';
  static const String USER_ROLE_KEY = 'role';
  static const String IS_SELLER_KEY = 'isSeller';

  Future<void> saveUserData({
    required String token,
    required String userId,
    required String name,
    required String email,
    required bool isSeller,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setString(USER_ID_KEY, userId);
    await prefs.setString(USER_NAME_KEY, name);
    await prefs.setString(USER_EMAIL_KEY, email);
    await prefs.setString(USER_ROLE_KEY, isSeller ? 'seller' : 'buyer');
    await prefs.setBool(IS_SELLER_KEY, isSeller);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ID_KEY);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ROLE_KEY);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isSeller() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_SELLER_KEY) ?? false;
  }

  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(USER_ROLE_KEY);
    return role == 'admin';
  }

  Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(USER_NAME_KEY) ?? 'No Name',
      'email': prefs.getString(USER_EMAIL_KEY) ?? 'No Email',
    };
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_ID_KEY);
    await prefs.remove(USER_NAME_KEY);
    await prefs.remove(USER_EMAIL_KEY);
    await prefs.remove(USER_ROLE_KEY);
    await prefs.remove(IS_SELLER_KEY);
  }
}
