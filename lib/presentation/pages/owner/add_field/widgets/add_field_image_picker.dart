import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';

class AddFieldImagePicker extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onPickImage;
  final bool showError;
  final bool isLoading;

  const AddFieldImagePicker({
    super.key,
    this.selectedImage,
    required this.onPickImage,
    this.showError = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'صورة الملعب',
          style: AppTextStyles.h3.copyWith(
            fontFamily: cairoFont.fontFamily,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: isLoading ? null : onPickImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: showError ? Colors.red : Colors.grey.shade300,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4BCB78)),
                    ),
                  )
                : selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: showError ? Colors.red.shade300 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'إضافة صورة',
                            style: AppTextStyles.body.copyWith(
                              fontFamily: cairoFont.fontFamily,
                              color: showError ? Colors.red.shade300 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        if (showError) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              'الرجاء إضافة صورة',
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

