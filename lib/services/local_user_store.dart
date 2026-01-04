import 'package:shared_preferences/shared_preferences.dart';

class LocalUserStore {
  static const String _keyFullName = 'local_user_fullName';
  static const String _keyAccountType = 'local_user_accountType';
  static const String _keyGovernorate = 'local_user_governorate';

  Future<void> saveUserProfile({
    required String fullName,
    required String accountType,
    required String governorate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFullName, fullName);
    await prefs.setString(_keyAccountType, accountType);
    await prefs.setString(_keyGovernorate, governorate);
  }

  Future<String?> getAccountType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccountType);
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullName);
  }

  Future<String?> getGovernorate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGovernorate);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyAccountType);
    await prefs.remove(_keyGovernorate);
  }
}

final localUserStore = LocalUserStore();

