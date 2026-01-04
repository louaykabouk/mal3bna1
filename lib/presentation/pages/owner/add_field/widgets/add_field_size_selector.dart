import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';

class AddFieldSizeSelector extends StatelessWidget {
  final String? selectedSize;
  final ValueChanged<String?> onChanged;
  final bool showError;

  static const List<Map<String, String>> sizes = [
    {'value': '5x5', 'label': '5×5'},
    {'value': '6x6', 'label': '6×6'},
    {'value': '7x7', 'label': '7×7'},
    {'value': '11x11', 'label': '11×11'},
  ];

  const AddFieldSizeSelector({
    super.key,
    this.selectedSize,
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
          'اختر حجم الملعب',
          style: AppTextStyles.h3.copyWith(
            fontFamily: cairoFont.fontFamily,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.start,
          textDirection: ui.TextDirection.rtl,
          children: sizes.map((size) {
            final isSelected = selectedSize == size['value'];
            return GestureDetector(
              onTap: () => onChanged(size['value']),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4BCB78)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: showError && !isSelected
                        ? Colors.red
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  size['label']!,
                  style: cairoFont.copyWith(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (showError) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              'الرجاء اختيار حجم الملعب',
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

