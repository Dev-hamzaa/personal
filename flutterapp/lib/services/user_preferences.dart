import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _roleKey = 'user_role';
  // Save user role
  static Future<void> setUserRole(String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Clear user data on logout
  static Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 