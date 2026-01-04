import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_model.dart';

class OwnerFieldsController extends StateNotifier<List<FieldModel>> {
  OwnerFieldsController() : super([]);

  void addField(FieldModel field) {
    state = [...state, field];
  }

  void removeField(String fieldId) {
    state = state.where((field) => field.id != fieldId).toList();
  }

  void updateField(FieldModel updatedField) {
    state = state.map((field) {
      return field.id == updatedField.id ? updatedField : field;
    }).toList();
  }
}

final ownerFieldsProvider = StateNotifierProvider<OwnerFieldsController, List<FieldModel>>(
  (ref) => OwnerFieldsController(),
);

