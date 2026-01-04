import 'package:flutter/material.dart';

class LiveMatch {
  final String id;
  final String fieldId;
  final String fieldName;
  final DateTime date;
  final TimeOfDay time;
  final double pricePerPerson;
  final int capacity;
  final String? conditions;
  final DateTime createdAt;

  LiveMatch({
    required this.id,
    required this.fieldId,
    required this.fieldName,
    required this.date,
    required this.time,
    required this.pricePerPerson,
    required this.capacity,
    this.conditions,
    required this.createdAt,
  });

  LiveMatch copyWith({
    String? id,
    String? fieldId,
    String? fieldName,
    DateTime? date,
    TimeOfDay? time,
    double? pricePerPerson,
    int? capacity,
    String? conditions,
    DateTime? createdAt,
  }) {
    return LiveMatch(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      date: date ?? this.date,
      time: time ?? this.time,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      capacity: capacity ?? this.capacity,
      conditions: conditions ?? this.conditions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

