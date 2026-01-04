import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_spacing.dart';

class SportCategoryItem extends StatelessWidget {
  final String title;
  final Widget? icon;
  final IconData? iconData;
  final bool isSelected;
  final VoidCallback onTap;

  const SportCategoryItem({
    super.key,
    required this.title,
    this.icon,
    this.iconData,
    required this.isSelected,
    required this.onTap,
  }) : assert(
          icon != null || iconData != null,
          'Either icon or iconData must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final selectedColor = const Color(0xFF4BCB78);
    final unselectedBackgroundColor = isDark
        ? colorScheme.surfaceContainerHighest
        : Colors.grey.shade100;
    final selectedTextColor = Colors.white;
    final unselectedTextColor = isDark
        ? colorScheme.onSurface
        : Colors.grey.shade800;
    final iconColor = isSelected
        ? Colors.white
        : (isDark ? colorScheme.onSurfaceVariant : Colors.grey.shade600);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : unselectedBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? colorScheme.outline.withValues(alpha: 0.2)
                        : Colors.transparent,
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.2 : 0.05,
                ),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: ui.TextDirection.rtl,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                ),
                textDirection: ui.TextDirection.rtl,
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildIcon(iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color iconColor) {
    if (icon != null) {
      return SizedBox(
        width: 32,
        height: 32,
        child: icon!,
      );
    }

    if (iconData != null) {
      return Icon(
        iconData!,
        size: 32,
        color: iconColor,
      );
    }

    // Fallback icon
    return Icon(
      Icons.sports,
      size: 32,
      color: iconColor,
    );
  }
}



