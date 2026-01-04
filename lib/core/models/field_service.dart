import 'package:flutter/material.dart';

enum FieldService {
  water, // ماء
  ball, // كرة
  seating, // جلسة
  parking, // مواقف
  lockerRoom, // ملابس
}

extension FieldServiceExtension on FieldService {
  String get arabicName {
    switch (this) {
      case FieldService.water:
        return 'ماء';
      case FieldService.ball:
        return 'كرة';
      case FieldService.seating:
        return 'جلسة';
      case FieldService.parking:
        return 'مواقف';
      case FieldService.lockerRoom:
        return 'ملابس';
    }
  }

  IconData get icon {
    switch (this) {
      case FieldService.water:
        return Icons.water_drop;
      case FieldService.ball:
        return Icons.sports_soccer;
      case FieldService.seating:
        return Icons.chair;
      case FieldService.parking:
        return Icons.local_parking;
      case FieldService.lockerRoom:
        return Icons.checkroom;
    }
  }
}

