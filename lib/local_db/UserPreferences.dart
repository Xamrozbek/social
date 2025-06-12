import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUserData({
    required String username,
    required String profileImageUrl,
    required String bio,
    required String email,
    required String phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('profileImageUrl', profileImageUrl);
    await prefs.setString('bio', bio);
    await prefs.setString('email', email);
    await prefs.setString('phoneNumber', phoneNumber);
  }

  static Future<Map<String, String?>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username'),
      'profileImageUrl': prefs.getString('profileImageUrl'),
      'bio': prefs.getString('bio'),
      'email': prefs.getString('email') ?? "ex: jon.smith@email.com",
      'phoneNumber': prefs.getString('phoneNumber'),
    };
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('profileImageUrl');
    await prefs.remove('bio');
    await prefs.remove('email');
    await prefs.remove('phoneNumber');
  }
}