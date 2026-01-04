import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';

class AddFieldPriceInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool hasAttemptedValidation;

  const AddFieldPriceInput({
    super.key,
    required this.controller,
    this.validator,
    this.hasAttemptedValidation = false,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'السعر',
            style: AppTextStyles.h3.copyWith(
              fontFamily: cairoFont.fontFamily,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14, right: 8),
                child: Text(
                  'ل.س',
                  style: cairoFont.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: validator,
                  style: cairoFont.copyWith(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  cursorColor: const Color(0xFF4BCB78),
                  decoration: InputDecoration(
                    hintText: 'السعر',
                    hintStyle: AppTextStyles.body.copyWith(
                      fontFamily: cairoFont.fontFamily,
                      color: Colors.grey.shade700.withValues(alpha: 0.5),
                    ),
                    errorText: null,
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 0,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF4BCB78),
                        width: 2,
                      ),
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    counterText: '',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) {
              if (hasAttemptedValidation) {
                final priceError = validator?.call(controller.text);
                if (priceError != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: Text(
                      priceError,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontFamily: cairoFont.fontFamily,
                        color: Colors.red,
                      ),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

