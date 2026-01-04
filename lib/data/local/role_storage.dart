import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/user_role.dart';

class RoleStorage {
  static const String _rolePrefix = 'role:';
  static const String _lastEmailKey = 'last_email';

  /// Save role for a specific email
  Future<void> saveRoleForEmail(String email, UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_rolePrefix$email', role.name);
  }

  /// Get role for a specific email
  Future<UserRole?> getRoleForEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString('$_rolePrefix$email');
    if (roleString == null) return null;
    
    return UserRole.values.firstWhere(
      (role) => role.name == roleString,
      orElse: () => UserRole.user,
    );
  }

  /// Set the last email used for login/registration
  Future<void> setLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastEmailKey, email);
  }

  /// Get the last email used for login/registration
  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastEmailKey);
  }
}

