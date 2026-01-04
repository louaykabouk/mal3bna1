import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/settings/settings_page.dart';
import '../pages/owner/owner_field_reviews_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF4BCB78),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: const Color(0xFF4BCB78),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerMenuItem(
                    title: 'عرض التقييمات',
                    icon: Icons.star_rate_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const OwnerFieldReviewsScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _DrawerMenuItem(
                    title: 'عروض اللحظات الأخيرة',
                    icon: Icons.local_offer,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to last minute offers page
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _DrawerMenuItem(
                    title: 'الإعدادات',
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _DrawerLogoutItem(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF4BCB78).withValues(alpha: 0.1),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4BCB78),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          color: Colors.grey.shade800,
        ),
        textAlign: TextAlign.right,
      ),
      trailing: null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      onTap: onTap,
    );
  }
}

class _DrawerLogoutItem extends StatelessWidget {
  const _DrawerLogoutItem();

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'تسجيل الخروج',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            style: GoogleFonts.cairo(
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'تسجيل خروج',
                style: GoogleFonts.cairo(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Close drawer first if opened from drawer
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Sign out from Firebase - AuthGate will handle navigation to login
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Handle error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء تسجيل الخروج',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withValues(alpha: 0.1),
        ),
        child: Icon(
          Icons.logout,
          color: Colors.red,
          size: 20,
        ),
      ),
      title: Text(
        'تسجيل الخروج',
        style: GoogleFonts.cairo(
          fontSize: 16,
          color: Colors.red,
        ),
        textAlign: TextAlign.right,
      ),
      trailing: null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      onTap: () => _showLogoutConfirmationDialog(context),
    );
  }
}

