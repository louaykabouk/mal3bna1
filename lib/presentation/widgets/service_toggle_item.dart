import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/field_service.dart';

class ServiceToggleItem extends StatelessWidget {
  final FieldService service;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceToggleItem({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();
    final primaryColor = const Color(0xFF4BCB78);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              service.icon,
              color: isSelected ? Colors.white : primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.arabicName,
            style: cairoFont.copyWith(
              fontSize: 12,
              color: isSelected
                  ? primaryColor
                  : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

