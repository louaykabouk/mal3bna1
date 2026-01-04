import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../widgets/widgets.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  void _startResendCooldown() {
    _canResend = false;
    _resendCooldown = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          _canResend = true;
        }
      });
      return _resendCooldown > 0;
    });
  }

  Future<void> _handleResend() async {
    if (!_canResend || _isLoading) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await authService.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال رابط التحقق مرة أخرى',
              style: _cairoFont,
            ),
            backgroundColor: const Color(0xFF4BCB78),
          ),
        );
      }
      _startResendCooldown();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء إرسال الرابط',
              style: _cairoFont,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCheckVerification() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await authService.reloadUser();
      final user = authService.currentUser;

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'لم يتم العثور على حساب',
                style: _cairoFont,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (!user.emailVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'لم يتم التحقق من البريد الإلكتروني بعد',
                style: _cairoFont,
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Email is verified - AuthGate will handle routing based on Firestore role
      // No manual navigation needed, just reload user to trigger authStateChanges
      await authService.reloadUser();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ، يرجى المحاولة مرة أخرى',
              style: _cairoFont,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    if (!mounted) return;

    try {
      await FirebaseAuth.instance.signOut();
      // AuthGate will handle navigation to login page
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء تسجيل الخروج',
              style: _cairoFont,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final email = user?.email ?? '';

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey.shade800,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'التحقق من البريد الإلكتروني',
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: _cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: const Color(0xFF4BCB78),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'تم إرسال رابط التحقق إلى بريدك',
                  style: AppTextStyles.h2.copyWith(
                    fontFamily: _cairoFont.fontFamily,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  email,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontFamily: _cairoFont.fontFamily,
                    color: const Color(0xFF4BCB78),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'الرجاء فتح بريدك الإلكتروني والضغط على رابط التحقق',
                  style: AppTextStyles.body.copyWith(
                    fontFamily: _cairoFont.fontFamily,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppPrimaryButton(
                  label: 'تحققت، متابعة',
                  onPressed: _isLoading ? null : _handleCheckVerification,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: _canResend && !_isLoading ? _handleResend : null,
                  child: Text(
                    _canResend
                        ? 'إعادة إرسال رابط التحقق'
                        : 'إعادة إرسال رابط التحقق (${_resendCooldown}ث)',
                    style: _cairoFont.copyWith(
                      color: _canResend ? const Color(0xFF4BCB78) : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: _isLoading ? null : _handleSignOut,
                  child: Text(
                    'تسجيل الخروج',
                    style: _cairoFont.copyWith(
                      color: Colors.red,
                    ),
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

