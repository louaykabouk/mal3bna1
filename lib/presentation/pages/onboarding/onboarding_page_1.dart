import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class OnboardingPage1Content extends StatelessWidget {
  final PageController pageController;

  const OnboardingPage1Content({
    super.key,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: AnimatedBuilder(
        animation: pageController,
        builder: (context, child) {
          double pageOffset = 0.0;
          if (pageController.hasClients) {
            final page = pageController.page ?? 0.0;
            pageOffset = (page - 0).clamp(-1.0, 1.0);
          }
          final opacity = (1 - pageOffset.abs()).clamp(0.0, 1.0);
          final offset = pageOffset * 50.0;

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(offset, 0),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      'Welcome to Mal3bna',
                      style: AppTextStyles.h1.copyWith(
                        color: const Color(0xFF4BCB78),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Book your favorite football fields with ease. Find the perfect time and location for your game.',
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
