import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../../widgets/app_drawer.dart';
import 'owner_fields_page.dart';
import 'add_live_match_screen.dart';
import 'add_event_screen.dart';
import 'activities_list_screen.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Sport Life',
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.grey.shade700,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection(
                context,
                title: 'ملاعبك',
                icon: Icons.help_outline, // Not used, replaced by Image.asset
                cairoFont: cairoFont,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSection(
                context,
                title: 'فعاليات',
                icon: Icons.calendar_today, // Not used, replaced by SVG asset
                cairoFont: cairoFont,
                isEventsSection: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSection(
                context,
                title: 'الإيرادات',
                icon: Icons.attach_money,
                cairoFont: cairoFont,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required TextStyle cairoFont,
    bool isEventsSection = false,
  }) {
    final isFieldsSection = title == 'ملاعبك';
    
    return GestureDetector(
      onTap: isFieldsSection
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OwnerFieldsPage(),
                ),
              );
            }
          : isEventsSection
              ? () => _showEventsOptions(context, cairoFont)
              : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4BCB78).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Use asset icon for "ملاعبك" section, SVG for "فعاليات", regular icon for others
            if (isFieldsSection)
              Image.asset(
                'assets/icons/soccer-field.png',
                width: 52,
                height: 52,
                color: const Color(0xFF4BCB78),
                colorBlendMode: BlendMode.srcIn,
              )
            else if (isEventsSection)
              SvgPicture.asset(
                'assets/icons/trophy-solid-full.svg',
                width: 48,
                height: 48,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF4BCB78),
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(
                icon,
                size: 48,
                color: const Color(0xFF4BCB78),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.h2.copyWith(
                fontFamily: cairoFont.fontFamily,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isFieldsSection
                  ? 'اضغط للعرض'
                  : isEventsSection
                      ? 'مباريات مباشرة'
                      : 'قريباً',
              style: AppTextStyles.body.copyWith(
                fontFamily: cairoFont.fontFamily,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventsOptions(BuildContext context, TextStyle cairoFont) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    'اختر نوع الإضافة',
                    style: AppTextStyles.h3.copyWith(
                      fontFamily: cairoFont.fontFamily,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      // View Activities button (combined list)
                      AppPrimaryButton(
                        label: 'عرض الفعاليات والمباريات',
                        onPressed: () {
                          Navigator.of(context).pop(); // Close bottom sheet
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ActivitiesListScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Add Live Match button
                      AppPrimaryButton(
                        label: 'إضافة مباراة مباشرة',
                        onPressed: () {
                          Navigator.of(context).pop(); // Close bottom sheet
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddLiveMatchScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Add Event button
                      AppPrimaryButton(
                        label: 'إضافة فعالية',
                        onPressed: () {
                          Navigator.of(context).pop(); // Close bottom sheet
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddEventScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

