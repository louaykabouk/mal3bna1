import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class OnboardingPage3Content extends StatelessWidget {
  final PageController pageController;

  const OnboardingPage3Content({
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
            final page = pageController.page ?? 2.0;
            pageOffset = (page - 2).clamp(-1.0, 1.0);
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
                      'Start Playing',
                      style: AppTextStyles.h1.copyWith(
                        color: const Color(0xFF4BCB78),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Join thousands of players who trust Mal3bna for their football field bookings. Let\'s get you started!',
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
