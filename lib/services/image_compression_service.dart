import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Exception thrown when an image cannot be compressed below the maximum size limit
class ImageTooLargeException implements Exception {
  final String message;
  ImageTooLargeException(this.message);
  
  @override
  String toString() => message;
}

/// Service for picking and compressing images
class ImageCompressionService {
  final ImagePicker _imagePicker = ImagePicker();
  
  /// Maximum allowed image size in bytes (10 MB)
  static const int maxSizeBytes = 10 * 1024 * 1024;
  
  /// Arabic error message for image size validation
  static const String imageSizeErrorMessage = 'لقد قمت برفع صورة حجمها أكبر من 10MB';
  
  /// Computes file size in MB
  double _getFileSizeInMB(File file) {
    final sizeInBytes = file.lengthSync();
    return sizeInBytes / (1024 * 1024);
  }
  
  /// Compresses an image file to JPEG format
  /// Tries quality levels: 70, 60, 50 (stops at first success)
  /// Returns the compressed file if successful, throws ImageTooLargeException if still too large
  Future<File> _compressImage(File imageFile) async {
    final originalSize = imageFile.lengthSync();
    debugPrint('[ImageCompressionService] Original image size: ${_getFileSizeInMB(imageFile).toStringAsFixed(2)} MB');
    
    // If already within limit, return as-is
    if (originalSize <= maxSizeBytes) {
      debugPrint('[ImageCompressionService] Image already within size limit, no compression needed');
      return imageFile;
    }
    
    // Get temporary directory for compressed image
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(imageFile.path);
    final targetPath = path.join(tempDir.path, '${fileName}_compressed.jpg');
    
    // Try compression with different quality levels
    final qualityLevels = [70, 60, 50];
    
    for (final quality in qualityLevels) {
      try {
        debugPrint('[ImageCompressionService] Attempting compression with quality: $quality');
        
        final compressedXFile = await FlutterImageCompress.compressAndGetFile(
          imageFile.absolute.path,
          targetPath,
          quality: quality,
          format: CompressFormat.jpeg,
        );
        
        if (compressedXFile == null) {
          debugPrint('[ImageCompressionService] Compression returned null for quality: $quality');
          continue;
        }
        
        // Convert XFile to File
        final compressedFile = File(compressedXFile.path);
        final compressedSize = compressedFile.lengthSync();
        debugPrint('[ImageCompressionService] Compressed size with quality $quality: ${_getFileSizeInMB(compressedFile).toStringAsFixed(2)} MB');
        
        if (compressedSize <= maxSizeBytes) {
          debugPrint('[ImageCompressionService] Compression successful with quality: $quality');
          return compressedFile;
        }
      } catch (e) {
        debugPrint('[ImageCompressionService] Error compressing with quality $quality: $e');
        continue;
      }
    }
    
    // If we get here, all compression attempts failed to get below the limit
    throw ImageTooLargeException(imageSizeErrorMessage);
  }
  
  /// Picks an image from the specified source and compresses it if necessary
  /// 
  /// Returns the image file if successful, or null if user cancelled.
  /// Throws [ImageTooLargeException] if image cannot be compressed below the limit.
  /// 
  /// Parameters:
  /// - [source]: The image source (gallery or camera)
  /// - [maxSizeMB]: Maximum allowed size in MB (default: 10)
  Future<File?> pickAndCompressImage({
    required ImageSource source,
    int maxSizeMB = 10,
  }) async {
    try {
      debugPrint('[ImageCompressionService] Picking image from: ${source.name}');
      
      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 100, // Get original quality first, we'll compress if needed
      );
      
      if (pickedFile == null) {
        debugPrint('[ImageCompressionService] User cancelled image selection');
        return null;
      }
      
      final imageFile = File(pickedFile.path);
      
      // Check initial size
      final initialSize = imageFile.lengthSync();
      debugPrint('[ImageCompressionService] Initial image size: ${_getFileSizeInMB(imageFile).toStringAsFixed(2)} MB');
      
      // If already within limit, return as-is
      if (initialSize <= maxSizeMB * 1024 * 1024) {
        debugPrint('[ImageCompressionService] Image is within size limit, returning original');
        return imageFile;
      }
      
      // Compress if needed
      debugPrint('[ImageCompressionService] Image exceeds size limit, compressing...');
      final compressedFile = await _compressImage(imageFile);
      
      return compressedFile;
    } catch (e) {
      if (e is ImageTooLargeException) {
        rethrow;
      }
      debugPrint('[ImageCompressionService] Error picking/compressing image: $e');
      rethrow;
    }
  }
}

/// Singleton instance of ImageCompressionService
final imageCompressionService = ImageCompressionService();

