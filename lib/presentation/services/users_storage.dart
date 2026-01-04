import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UsersStorage {
  static const String _usersKey = 'users';

  /// Get all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(usersJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Save all users
  Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = jsonEncode(users);
    await prefs.setString(_usersKey, usersJson);
  }

  /// Find user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final users = await getUsers();
    try {
      return users.firstWhere(
        (user) => user['email']?.toString().toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  /// Update user password by email
  Future<bool> updateUserPassword(String email, String newPassword) async {
    final users = await getUsers();
    final userIndex = users.indexWhere(
      (user) => user['email']?.toString().toLowerCase() == email.toLowerCase(),
    );

    if (userIndex == -1) {
      return false;
    }

    users[userIndex]['password'] = newPassword;
    await saveUsers(users);
    return true;
  }

  /// Add new user (for registration)
  Future<void> addUser(Map<String, dynamic> user) async {
    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }
}

final usersStorage = UsersStorage();

