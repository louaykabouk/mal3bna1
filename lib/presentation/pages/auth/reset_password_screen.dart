import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/users_storage.dart';
import '../../services/otp_storage.dart';
import '../../widgets/widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال كلمة السر الجديدة';
    }
    if (value.length < 6) {
      return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إعادة كتابة كلمة السر';
    }
    if (value != _newPasswordController.text) {
      return 'كلمة السر غير متطابقة';
    }
    return null;
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get reset email
      final email = await otpStorage.getResetEmail();
      if (email == null) {
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
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Update password
      final newPassword = _newPasswordController.text.trim();
      final success = await usersStorage.updateUserPassword(email, newPassword);

      if (!success) {
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
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Clear reset OTP data
      await otpStorage.clearResetOtp();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تغيير كلمة السر بنجاح',
              style: _cairoFont,
            ),
            backgroundColor: const Color(0xFF4BCB78),
          ),
        );
      }

      // Navigate back to login
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
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
            'تغيير كلمة السر',
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
                    'أدخل كلمة السر الجديدة',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontFamily: _cairoFont.fontFamily,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // New password field
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      textInputAction: TextInputAction.next,
                      validator: _validateNewPassword,
                      textAlign: TextAlign.right,
                      style: _cairoFont.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      cursorColor: const Color(0xFF4BCB78),
                      decoration: InputDecoration(
                        hintText: 'كلمة السر الجديدة',
                        hintTextDirection: TextDirection.rtl,
                        alignLabelWithHint: true,
                        hintStyle: AppTextStyles.body.copyWith(
                          fontFamily: _cairoFont.fontFamily,
                          color: Colors.grey.shade500,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
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
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Confirm password field
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmPassword,
                      textAlign: TextAlign.right,
                      onFieldSubmitted: (_) => _handleReset(),
                      style: _cairoFont.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      cursorColor: const Color(0xFF4BCB78),
                      decoration: InputDecoration(
                        hintText: 'إعادة كتابة كلمة السر',
                        hintTextDirection: TextDirection.rtl,
                        alignLabelWithHint: true,
                        hintStyle: AppTextStyles.body.copyWith(
                          fontFamily: _cairoFont.fontFamily,
                          color: Colors.grey.shade500,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
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
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppPrimaryButton(
                    label: 'تغيير',
                    onPressed: _isLoading ? null : _handleReset,
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

