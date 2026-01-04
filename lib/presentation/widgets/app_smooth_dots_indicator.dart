import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppSmoothDotsIndicator extends StatelessWidget {
  final int count;
  final double page;

  const AppSmoothDotsIndicator({
    super.key,
    required this.count,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFF4BCB78);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          final t = (1.0 - (page - index).abs()).clamp(0.0, 1.0);
          final width = 8.0 + (22.0 - 8.0) * t;
          final inactiveColor = baseColor.withValues(alpha: 0.35);
          final color = Color.lerp(inactiveColor, baseColor, t) ?? baseColor;

          return Container(
            width: width,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: color,
            ),
          );
        },
      ),
    );
  }
}
