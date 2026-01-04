import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/governorates.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';

class AddFieldCitySelector extends StatelessWidget {
  final String? selectedCity;
  final ValueChanged<String?> onChanged;
  final bool showError;

  const AddFieldCitySelector({
    super.key,
    this.selectedCity,
    required this.onChanged,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'المدينة',
          style: AppTextStyles.h3.copyWith(
            fontFamily: cairoFont.fontFamily,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCity,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'اختر المدينة',
              hintStyle: cairoFont.copyWith(
                color: Colors.grey.shade600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4BCB78),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: cairoFont.copyWith(
              color: Colors.black87,
              fontSize: 16,
            ),
            dropdownColor: Colors.white,
            items: syrianGovernorates.map((governorate) {
              return DropdownMenuItem<String>(
                value: governorate,
                child: Text(
                  governorate,
                  style: cairoFont.copyWith(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار المدينة';
              }
              return null;
            },
          ),
        ),
        if (showError) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              'الرجاء اختيار المدينة',
              style: AppTextStyles.bodySmall.copyWith(
                fontFamily: cairoFont.fontFamily,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

