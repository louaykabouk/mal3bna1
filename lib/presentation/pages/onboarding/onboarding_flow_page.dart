import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../widgets/widgets.dart';
import 'onboarding_page_1.dart';
import 'onboarding_page_2.dart';
import 'onboarding_page_3.dart';

class OnboardingFlowPage extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingFlowPage({
    super.key,
    this.onComplete,
  });

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  int _currentIndex = 0;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[OnboardingFlowPage] initState() called');
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    debugPrint('[OnboardingFlowPage] Controllers initialized');
  }

  Future<void> _nextPage() async {
    if (_currentIndex == 2) {
      if (!mounted) return;
      if (_navigating) return;
      setState(() {
        _navigating = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          setState(() {
            _navigating = false;
          });
          return;
        }
        try {
          Navigator.of(context).pushReplacementNamed('/login');
        } catch (e) {
          if (mounted) {
            setState(() {
              _navigating = false;
            });
          }
        }
      });
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[OnboardingFlowPage] build() called');
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                RepaintBoundary(
                  child: SizedBox(
                    height: 260,
                    child: Lottie.asset(
                      'assets/animations/Ball Sport.json',
                      controller: _animationController,
                      onLoaded: (composition) {
                        _animationController
                          ..duration = composition.duration
                          ..reset()
                          ..repeat();
                      },
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 260,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.sports_soccer,
                            size: 100,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      children: [
                        OnboardingPage1Content(
                            pageController: _pageController),
                        OnboardingPage2Content(
                            pageController: _pageController),
                        OnboardingPage3Content(
                            pageController: _pageController),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          final page = _pageController.hasClients
                              ? (_pageController.page ?? 0.0)
                              : 0.0;
                          return Column(
                            children: [
                              AppSmoothDotsIndicator(
                                count: 3,
                                page: page,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              AppPrimaryButton(
                                label: _currentIndex == 2 ? 'Get Started' : 'Next',
                                onPressed: _navigating ? null : _nextPage,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
