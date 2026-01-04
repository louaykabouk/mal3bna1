import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/users_storage.dart';
import '../../services/otp_storage.dart';
import '../../widgets/widgets.dart';
import 'verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    final email = value.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();

      // Check if email exists
      final emailExists = await usersStorage.emailExists(email);
      if (!emailExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'هذا البريد غير مسجل',
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

      // Generate OTP
      final otp = _generateOtp();
      final expiry = DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;

      // Save OTP data
      await otpStorage.saveResetOtp(
        email: email,
        otp: otp,
        expiryMillis: expiry,
      );

      // Show OTP in dialog for testing
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              title: Text(
                'رمز التحقق',
                style: _cairoFont.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'رمز التحقق: $otp (للتجربة فقط)',
                style: _cairoFont,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'حسناً',
                    style: _cairoFont,
                  ),
                ),
              ],
            ),
          ),
        );

        // Navigate to verification screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const VerificationScreen(),
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
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
            'نسيت كلمة السر',
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'أدخل بريدك الإلكتروني لإرسال رمز التحقق',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontFamily: _cairoFont.fontFamily,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Email field with LTR text direction
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: _validateEmail,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.ltr,
                      style: _cairoFont.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      cursorColor: const Color(0xFF4BCB78),
                      decoration: InputDecoration(
                        hintText: 'البريد الإلكتروني',
                        hintTextDirection: TextDirection.rtl,
                        alignLabelWithHint: true,
                        hintStyle: AppTextStyles.body.copyWith(
                          fontFamily: _cairoFont.fontFamily,
                          color: Colors.grey.shade500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 0,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF4BCB78),
                            width: 2,
                          ),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      onFieldSubmitted: (_) => _handleSubmit(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppPrimaryButton(
                    label: 'إرسال رمز التحقق',
                    onPressed: _isLoading ? null : _handleSubmit,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

