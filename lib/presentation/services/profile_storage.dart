import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfileStorage {
  static const String _keyFullName = 'profile_fullName';
  static const String _keyPhotoPath = 'profile_photoPath';

  Future<void> saveProfile({
    required String fullName,
    String? photoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFullName, fullName);
    if (photoPath != null) {
      await prefs.setString(_keyPhotoPath, photoPath);
    } else {
      await prefs.remove(_keyPhotoPath);
    }
  }

  Future<Map<String, String?>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString(_keyFullName);
    final photoPath = prefs.getString(_keyPhotoPath);

    // Verify photo file exists, if not clear the path
    String? validPhotoPath = photoPath;
    if (photoPath != null) {
      final file = File(photoPath);
      if (!await file.exists()) {
        validPhotoPath = null;
        await prefs.remove(_keyPhotoPath);
      }
    }

    return {
      'fullName': fullName ?? '',
      'photoPath': validPhotoPath,
    };
  }

  Future<void> updateName(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFullName, fullName);
  }

  Future<void> updatePhotoPath(String? photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    if (photoPath != null) {
      await prefs.setString(_keyPhotoPath, photoPath);
    } else {
      await prefs.remove(_keyPhotoPath);
    }
  }

  Future<String> saveImageToAppDirectory(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_photo_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final savedFile = await imageFile.copy('${appDir.path}/$fileName');
    return savedFile.path;
  }

  Future<void> deletePhotoFile(String? photoPath) async {
    if (photoPath != null) {
      try {
        final file = File(photoPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors when deleting
      }
    }
  }
}

final profileStorage = ProfileStorage();

