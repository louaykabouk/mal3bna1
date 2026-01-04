import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for uploading images to Cloudinary
class CloudinaryService {
  static const String _cloudName = 'deaxdjcaz';
  static const String _uploadPreset = 'fields_unsigned';
  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Upload image file to Cloudinary and return secure URL
  Future<String> uploadImage(File imageFile) async {
    debugPrint('[CloudinaryService] Starting image upload...');
    
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      
      // Add upload preset
      request.fields['upload_preset'] = _uploadPreset;
      
      debugPrint('[CloudinaryService] Uploading to: $_uploadUrl');
      debugPrint('[CloudinaryService] Upload preset: $_uploadPreset');
      debugPrint('[CloudinaryService] File path: ${imageFile.path}');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final secureUrl = responseData['secure_url'] as String?;
        
        if (secureUrl != null && secureUrl.isNotEmpty) {
          debugPrint('[CloudinaryService] Upload successful. URL: $secureUrl');
          return secureUrl;
        } else {
          debugPrint('[CloudinaryService] Upload response missing secure_url: ${response.body}');
          throw Exception('Upload response missing secure_url');
        }
      } else {
        debugPrint('[CloudinaryService] Upload failed. Status: ${response.statusCode}');
        debugPrint('[CloudinaryService] Response body: ${response.body}');
        throw Exception('Upload failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('[CloudinaryService] Error uploading image: $e');
      debugPrint('[CloudinaryService] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

final cloudinaryService = CloudinaryService();

