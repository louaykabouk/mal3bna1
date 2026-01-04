import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import 'language_page.dart';
import 'terms_page.dart';
import 'contact_us_page.dart';
import 'profile_management_screen.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'تأكيد حذف الحساب',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'سيتم حذف حسابك نهائياً ولا يمكن التراجع عن هذا الإجراء. هل تريد المتابعة؟',
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
                'حذف',
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
      await _deleteAccount(context);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(
                    'جاري حذف الحساب...',
                    style: GoogleFonts.cairo(),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // TODO: Replace with actual backend API call
      await Future.delayed(const Duration(seconds: 1));

      // Clear local session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to login and clear all previous routes
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف الحساب بنجاح',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء حذف الحساب. يرجى المحاولة مرة أخرى.',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (iconColor ?? const Color(0xFF4BCB78)).withValues(alpha: 0.1),
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFF4BCB78),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        textAlign: TextAlign.right,
      ),
      trailing: Icon(
        Icons.chevron_left,
        color: Colors.grey.shade400,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(themeControllerProvider);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'الإعدادات',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildSettingsTile(
              context,
              title: 'إدارة الحساب الشخصي',
              icon: Icons.person,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfileManagementScreen(),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey.shade300),
            _buildSettingsTile(
              context,
              title: 'اللغة',
              icon: Icons.language,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LanguagePage(),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey.shade300),
            _buildSettingsTile(
              context,
              title: 'الشروط والأحكام',
              icon: Icons.description,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TermsPage(),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey.shade300),
            _buildSettingsTile(
              context,
              title: 'تواصل معنا',
              icon: Icons.chat,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ContactUsPage(),
                  ),
                );
              },
            ),
            Divider(height: 1, color: Colors.grey.shade300),
            SwitchListTile(
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4BCB78).withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.dark_mode,
                  color: const Color(0xFF4BCB78),
                  size: 20,
                ),
              ),
              title: Text(
                'المظهر الداكن',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.right,
              ),
              value: c.isDark,
              onChanged: (v) => ref.read(themeControllerProvider).setDark(v),
              activeColor: const Color(0xFF4BCB78),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            Divider(height: 1, color: Colors.grey.shade300),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: Text(
                'حذف الحساب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.right,
              ),
              trailing: null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () => _showDeleteAccountConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }
}

