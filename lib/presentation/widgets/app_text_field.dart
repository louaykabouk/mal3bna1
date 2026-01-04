import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final int? maxLength;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLength,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Brand color
    final primaryColor = const Color(0xFF4BCB78);
    
    // Theme-aware colors
    final enabledBorderColor = isDark 
        ? colorScheme.outline.withValues(alpha: 0.5)
        : Colors.grey;
    final focusedBorderColor = primaryColor;
    final labelColor = isDark
        ? colorScheme.onSurface
        : Colors.grey.shade700;
    final textColor = isDark
        ? colorScheme.onSurface
        : Colors.black87;
    
    // Get Cairo font
    final cairoFont = GoogleFonts.cairo();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        autofocus: autofocus,
        maxLength: maxLength,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        inputFormatters: inputFormatters,
        validator: validator,
        style: cairoFont.copyWith(
          color: textColor,
          fontSize: 16,
        ),
        cursorColor: primaryColor,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: AppTextStyles.body.copyWith(
            fontFamily: cairoFont.fontFamily,
            color: labelColor.withValues(alpha: 0.5),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 0,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: enabledBorderColor,
              width: 1,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: focusedBorderColor,
              width: 2,
            ),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: enabledBorderColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2,
            ),
          ),
          counterText: '',
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }
}

