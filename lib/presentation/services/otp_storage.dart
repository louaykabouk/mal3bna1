import 'package:shared_preferences/shared_preferences.dart';

class OtpStorage {
  static const String _resetEmailKey = 'reset_email';
  static const String _resetOtpKey = 'reset_otp';
  static const String _resetOtpExpiryKey = 'reset_otp_expiry';

  /// Save reset OTP data
  Future<void> saveResetOtp({
    required String email,
    required String otp,
    required int expiryMillis,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_resetEmailKey, email);
    await prefs.setString(_resetOtpKey, otp);
    await prefs.setInt(_resetOtpExpiryKey, expiryMillis);
  }

  /// Get reset email
  Future<String?> getResetEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_resetEmailKey);
  }

  /// Get reset OTP
  Future<String?> getResetOtp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_resetOtpKey);
  }

  /// Get OTP expiry
  Future<int?> getResetOtpExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_resetOtpExpiryKey);
  }

  /// Check if OTP is valid (not expired)
  Future<bool> isOtpValid() async {
    final expiry = await getResetOtpExpiry();
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  /// Verify OTP
  Future<bool> verifyOtp(String enteredOtp) async {
    final storedOtp = await getResetOtp();
    if (storedOtp == null) return false;
    if (!await isOtpValid()) return false;
    return storedOtp == enteredOtp;
  }

  /// Clear reset OTP data
  Future<void> clearResetOtp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_resetEmailKey);
    await prefs.remove(_resetOtpKey);
    await prefs.remove(_resetOtpExpiryKey);
  }
}

final otpStorage = OtpStorage();

