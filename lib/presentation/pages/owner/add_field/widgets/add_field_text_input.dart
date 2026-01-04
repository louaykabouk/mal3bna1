import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_spacing.dart';

class AddFieldTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final bool showError;

  const AddFieldTextInput({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.validator,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: cairoFont,
        labelStyle: cairoFont,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),
      style: cairoFont,
      textDirection: ui.TextDirection.rtl,
      validator: validator,
    );
  }
}

