import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/widgets.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> with SingleTickerProviderStateMixin {
  static const bool _demoBypassOtp = true;
  
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<String> _previousTexts = List.filled(4, '');
  int _countdownSeconds = 116;
  Timer? _timer;
  bool _submitting = false;
  bool _hasOtpError = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  late final TextStyle _cairoFont = GoogleFonts.cairo();


  String get _countdownText {
    final minutes = (_countdownSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_countdownSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get _isResendEnabled => _countdownSeconds == 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
    _startTimer();
    // Ensure focus is cleared after widget builds to prevent auto-keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _startTimer() {
    _countdownSeconds = 116;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _onOtpChanged(int index, String value) {
    if (_submitting) return;
    
    if (value.length > 1) {
      final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length >= 4) {
        final digits = digitsOnly.substring(0, 4).split('');
        setState(() {
          _hasOtpError = false;
        });
        for (int i = 0; i < 4; i++) {
          _otpControllers[i].text = digits[i];
          _previousTexts[i] = digits[i];
        }
        FocusScope.of(context).requestFocus(_focusNodes[3]);
        _submitOtp();
        return;
      } else {
        _otpControllers[index].value = TextEditingValue(
          text: value.substring(0, 1),
          selection: TextSelection.collapsed(offset: 1),
        );
        value = value.substring(0, 1);
      }
    }
    
    final previousText = _previousTexts[index];
    _previousTexts[index] = value;
    
    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && previousText.isNotEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    
    if (_otpControllers.every((controller) => controller.text.isNotEmpty)) {
      _submitOtp();
    }
  }

  void _handleBackspace(int index) {
    if (_submitting) return;
    
    if (_otpControllers[index].text.isNotEmpty) {
      _otpControllers[index].clear();
    } else if (index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _otpControllers[index - 1].clear();
    }
  }

  void _triggerOtpError() {
    setState(() {
      _hasOtpError = true;
    });
    _shakeController.forward(from: 0);
    for (var controller in _otpControllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(_focusNodes[0]);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _hasOtpError = false;
      });
    });
  }

  Future<void> _submitOtp() async {
    if (_submitting) return;
    if (!mounted) return;
    
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length != 4 || _otpControllers.any((c) => c.text.isEmpty)) return;
    
    setState(() {
      _submitting = true;
    });
    
    try {
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      
      if (_demoBypassOtp) {
        // OTP verified - AuthGate will handle routing based on Firestore role
        // No manual navigation needed
        return;
      }
      
      if (code != '1234') {
        _triggerOtpError();
        return;
      }
      
      // OTP verified - AuthGate will handle routing based on Firestore role
      // No manual navigation needed
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _handleResend() {
    if (_isResendEnabled) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إعادة الإرسال (واجهة فقط)',
            style: _cairoFont,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final arg = ModalRoute.of(context)?.settings.arguments;
    final String destination = (arg is String && arg.trim().isNotEmpty) ? arg.trim() : '---';
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: DefaultTextStyle(
              style: _cairoFont,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  AppSpacing.lg,
                                  AppSpacing.lg,
                                  AppSpacing.lg,
                                  AppSpacing.lg + bottomInset,
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 520),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'ادخل رمز التحقق المرسل الى',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: Colors.black,
                                          fontFamily: _cairoFont.fontFamily,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        destination,
                                        style: GoogleFonts.cairo(
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: AppSpacing.xxl),
                                      AnimatedBuilder(
                                        animation: _shakeAnimation,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(_shakeAnimation.value, 0),
                                            child: child,
                                          );
                                        },
                                        child: Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: List.generate(4, (index) {
                                              final borderColor = _hasOtpError ? Colors.red : Colors.grey.shade300;
                                              final focusedBorderColor = _hasOtpError ? Colors.red : const Color(0xFF4BCB78);
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 64,
                                                    height: 64,
                                                    child: Focus(
                                                      onKeyEvent: (node, event) {
                                                        if (event is KeyDownEvent &&
                                                            event.logicalKey == LogicalKeyboardKey.backspace) {
                                                          _handleBackspace(index);
                                                          return KeyEventResult.handled;
                                                        }
                                                        return KeyEventResult.ignored;
                                                      },
                                                      child: TextField(
                                                        controller: _otpControllers[index],
                                                        focusNode: _focusNodes[index],
                                                        enabled: !_submitting,
                                                        autofocus: false,
                                                        textDirection: TextDirection.ltr,
                                                        textAlign: TextAlign.center,
                                                        keyboardType: TextInputType.number,
                                                        style: GoogleFonts.cairo(
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.digitsOnly,
                                                          LengthLimitingTextInputFormatter(4),
                                                        ],
                                                        decoration: InputDecoration(
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                            borderSide: BorderSide(color: borderColor),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                            borderSide: BorderSide(color: borderColor),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                            borderSide: BorderSide(
                                                              color: focusedBorderColor,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          filled: true,
                                                          fillColor: Colors.grey.shade50,
                                                        ),
                                                        onChanged: (value) {
                                                          _onOtpChanged(index, value);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  if (index < 3) const SizedBox(width: 16),
                                                ],
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xxl),
                                      AppPrimaryButton(
                                        label: 'التحقق',
                                        isLoading: _submitting,
                                        onPressed: _submitting ? null : _submitOtp,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      if (_countdownSeconds > 0)
                                        Text(
                                          'اعادة ارسال رمز التحقق خلال $_countdownText دقيقة',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            fontFamily: _cairoFont.fontFamily,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                      else
                                        GestureDetector(
                                          onTap: _handleResend,
                                          child: Text(
                                            'اعادة ارسال رمز التحقق',
                                            style: GoogleFonts.cairo(
                                              color: const Color(0xFF4BCB78),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
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

