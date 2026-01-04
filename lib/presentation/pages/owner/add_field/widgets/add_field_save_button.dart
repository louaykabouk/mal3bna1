import 'package:flutter/material.dart';
import '../../../../widgets/app_primary_button.dart';
import '../../../../theme/app_spacing.dart';

class AddFieldSaveButton extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback? onSave;

  const AddFieldSaveButton({
    super.key,
    required this.isEditMode,
    required this.isLoading,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: AppPrimaryButton(
        label: isEditMode ? 'تعديل' : 'حفظ',
        onPressed: isLoading ? null : onSave,
        isLoading: isLoading,
      ),
    );
  }
}


