import 'dart:io';

/// Maximum allowed image size in bytes (10 MB)
const int maxImageSizeBytes = 10 * 1024 * 1024;

/// Arabic error message for image size validation
const String imageSizeErrorMessage = 'لقد قمت برفع صورة حجمها أكبر من 10MB';

/// Validates if an image file size is within the allowed limit.
/// 
/// Returns `true` if the image size is valid (≤ 10 MB), `false` otherwise.
/// 
/// Throws [FileSystemException] if the file cannot be accessed.
bool validateImageSize(File imageFile) {
  final fileSize = imageFile.lengthSync();
  return fileSize <= maxImageSizeBytes;
}

/// Validates if an image file size is within the allowed limit asynchronously.
/// 
/// Returns `true` if the image size is valid (≤ 10 MB), `false` otherwise.
/// 
/// Throws [FileSystemException] if the file cannot be accessed.
Future<bool> validateImageSizeAsync(File imageFile) async {
  final fileSize = await imageFile.length();
  return fileSize <= maxImageSizeBytes;
}


