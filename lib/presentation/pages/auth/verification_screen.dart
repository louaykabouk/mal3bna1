import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/otp_storage.dart';
import '../../widgets/widgets.dart';
import 'reset_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
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

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;

    try {
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
        return;
      }

      // Generate new OTP
      final otp = _generateOtp();
      final expiry = DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;

      await otpStorage.saveResetOtp(
        email: email,
        otp: otp,
        expiryMillis: expiry,
      );

      // Show OTP in dialog
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
      }

      _startResendCooldown();
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
    }
  }

  Future<void> _handleVerify() async {
    final code = _getOtpCode();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إدخال رمز التحقق كاملاً',
            style: _cairoFont,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if OTP is expired
      final isValid = await otpStorage.isOtpValid();
      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'انتهت صلاحية الرمز',
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

      // Verify OTP
      final isCorrect = await otpStorage.verifyOtp(code);
      if (!isCorrect) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'رمز التحقق غير صحيح',
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

      // Navigate to reset password screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ResetPasswordScreen(),
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
            'التحقق',
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
                Text(
                  'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontFamily: _cairoFont.fontFamily,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                // OTP input fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: _cairoFont.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4BCB78),
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) => _onCodeChanged(index, value),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  label: 'تحقق',
                  onPressed: _isLoading ? null : _handleVerify,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: _canResend ? _handleResend : null,
                  child: Text(
                    _canResend
                        ? 'إعادة إرسال'
                        : 'إعادة إرسال (${_resendCooldown}ث)',
                    style: _cairoFont.copyWith(
                      color: _canResend ? const Color(0xFF4BCB78) : Colors.grey,
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

