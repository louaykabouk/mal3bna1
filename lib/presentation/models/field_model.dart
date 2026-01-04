import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore field name constants
class FieldModelKeys {
  static const String name = 'name';
  static const String imageUrl = 'imageUrl';
  static const String price = 'price';
  static const String size = 'size';
  static const String services = 'services';
  static const String city = 'city';
  static const String ownerId = 'ownerId';
  static const String ownerEmail = 'ownerEmail';
  static const String createdAt = 'createdAt';
}

class FieldModel {
  final String id;
  final String name;
  final String? imageUrl; // Network URL from Cloudinary/Firebase Storage
  final int price;
  final String size;
  final List<String> services;

  FieldModel({
    required this.id,
    String? name,
    this.imageUrl,
    required this.price,
    required this.size,
    required this.services,
  }) : name = name ?? '';

  /// Create FieldModel from Firestore document
  factory FieldModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    
    debugPrint('[FieldModel] Loading document ${doc.id}');
    debugPrint('[FieldModel] Document data: $data');
    
    // Extract services - handle both List<String> and List<dynamic>
    List<String> servicesList = [];
    if (data[FieldModelKeys.services] != null) {
      final servicesData = data[FieldModelKeys.services];
      if (servicesData is List) {
        servicesList = servicesData.map((e) => e.toString()).toList();
      }
    }
    
    // Extract imageUrl - trim whitespace and validate
    final rawImageUrl = data[FieldModelKeys.imageUrl] as String? ?? '';
    final imageUrl = rawImageUrl.trim();
    
    debugPrint('[FieldModel] Raw imageUrl: "$rawImageUrl"');
    debugPrint('[FieldModel] Trimmed imageUrl: "$imageUrl"');
    debugPrint('[FieldModel] ImageUrl isEmpty: ${imageUrl.isEmpty}');
    
    if (imageUrl.isNotEmpty) {
      // Ensure URL is https
      final normalizedUrl = imageUrl.startsWith('http://') 
          ? imageUrl.replaceFirst('http://', 'https://')
          : imageUrl;
      debugPrint('[FieldModel] Final normalized imageUrl: "$normalizedUrl"');
      
      return FieldModel(
        id: doc.id,
        name: data[FieldModelKeys.name] as String? ?? 'ملعب بدون اسم',
        imageUrl: normalizedUrl,
        price: (data[FieldModelKeys.price] as num?)?.toInt() ?? 0,
        size: data[FieldModelKeys.size] as String? ?? '',
        services: servicesList,
      );
    }
    
    return FieldModel(
      id: doc.id,
      name: data[FieldModelKeys.name] as String? ?? 'ملعب بدون اسم',
      imageUrl: null,
      price: (data[FieldModelKeys.price] as num?)?.toInt() ?? 0,
      size: data[FieldModelKeys.size] as String? ?? '',
      services: servicesList,
    );
  }

  FieldModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? price,
    String? size,
    List<String>? services,
  }) {
    return FieldModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      size: size ?? this.size,
      services: services ?? this.services,
    );
  }
}

