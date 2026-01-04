import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppPageIndicator extends StatelessWidget {
  final int currentIndex;
  final int count;

  const AppPageIndicator({
    super.key,
    required this.currentIndex,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          width: index == currentIndex ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: index == currentIndex
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

