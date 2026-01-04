import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_tab_page.dart';
import '../academies/academies_page.dart';
import '../trainings/trainings_page.dart';
import '../bookings/bookings_page.dart';
import '../favorites/favorites_page.dart';
import '../../providers/tab_navigation_provider.dart';

class HomeShellPage extends ConsumerStatefulWidget {
  const HomeShellPage({super.key});

  @override
  ConsumerState<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends ConsumerState<HomeShellPage> {
  // Stable Navigator keys - created once, never recreated
  late final List<GlobalKey<NavigatorState>> _navKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );
  
  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => rootPage,
          settings: settings,
        );
      },
    );
  }

  void _handleBackButton() {
    final currentIndex = ref.read(selectedTabIndexProvider);
    final currentNavigator = _navKeys[currentIndex].currentState;
    
    // If current tab's navigator can pop -> pop inside the current tab
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
    } else if (currentIndex != 2) {
      // Else if not on first tab (الرئيسية = index 2) -> switch to first tab
      ref.read(selectedTabIndexProvider.notifier).state = 2;
    } else {
      // Else -> allow app to exit
      SystemNavigator.pop();
    }
  }

  void _onTabTapped(int index) {
    final currentIndex = ref.read(selectedTabIndexProvider);
    
    // If tapping the same tab, pop to root of that tab's navigator
    if (index == currentIndex) {
      _navKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      // Switch to the tapped tab - instant, no animation overhead
      ref.read(selectedTabIndexProvider.notifier).state = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(selectedTabIndexProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          _handleBackButton();
        }
      },
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: IndexedStack(
            index: currentIndex,
            children: [
              _buildTabNavigator(0, const AcademiesPage(key: PageStorageKey('academies_tab'))),
              _buildTabNavigator(1, const TrainingsPage(key: PageStorageKey('trainings_tab'))),
              _buildTabNavigator(2, const HomeTabPage(key: PageStorageKey('home_tab'))),
              _buildTabNavigator(3, const BookingsPage(key: PageStorageKey('bookings_tab'))),
              _buildTabNavigator(4, const FavoritesPage(key: PageStorageKey('favorites_tab'))),
            ],
          ),
          bottomNavigationBar: _CustomBottomNavigationBar(
            currentIndex: currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}

class _CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildSvgIcon(String assetPath, bool isSelected) {
    return SvgPicture.asset(
      assetPath,
      width: 28,
      height: 28,
      colorFilter: ColorFilter.mode(
        isSelected ? const Color(0xFF4BCB78) : Colors.grey.shade600,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 5;
    final indicatorLeft = screenWidth - (currentIndex + 1) * itemWidth + (itemWidth - 40) / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: const Color(0xFF4BCB78),
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          unselectedLabelStyle: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : Colors.white,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: _buildSvgIcon('assets/icons/trophy-solid-full.svg', currentIndex == 0),
              activeIcon: _buildSvgIcon('assets/icons/trophy-solid-full.svg', true),
              label: 'الأكاديميات',
            ),
            BottomNavigationBarItem(
              icon: _buildSvgIcon('assets/icons/person-running-solid-full.svg', currentIndex == 1),
              activeIcon: _buildSvgIcon('assets/icons/person-running-solid-full.svg', true),
              label: 'التمارين',
            ),
            BottomNavigationBarItem(
              icon: _buildSvgIcon('assets/icons/house-regular-full.svg', currentIndex == 2),
              activeIcon: _buildSvgIcon('assets/icons/house-regular-full.svg', true),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: _buildSvgIcon('assets/icons/clock-regular-full.svg', currentIndex == 3),
              activeIcon: _buildSvgIcon('assets/icons/clock-regular-full.svg', true),
              label: 'حجوزاتي',
            ),
            BottomNavigationBarItem(
              icon: _buildSvgIcon('assets/icons/heart-regular-full.svg', currentIndex == 4),
              activeIcon: _buildSvgIcon('assets/icons/heart-regular-full.svg', true),
              label: 'المفضلة',
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: indicatorLeft,
          child: Container(
            width: 40,
            height: 3,
            color: const Color(0xFF4BCB78),
          ),
        ),
      ],
    );
  }
}
