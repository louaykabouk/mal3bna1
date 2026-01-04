import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../widgets/widgets.dart';
import 'verify_email_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  late final TapGestureRecognizer _registerTapRecognizer;
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  late final TextStyle _registerLinkStyle = GoogleFonts.cairo(
    fontWeight: FontWeight.bold,
    color: const Color(0xFF4BCB78),
  );

  @override
  void initState() {
    super.initState();
    _registerTapRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        if (!mounted) return;
        // Unfocus before navigating to prevent focus restoration on return
        FocusManager.instance.primaryFocus?.unfocus();
        await Navigator.of(context, rootNavigator: true).pushNamed('/register');
        // Unfocus when returning from Register
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              FocusManager.instance.primaryFocus?.unfocus();
              FocusScope.of(context).unfocus();
            }
          });
        }
      };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerTapRecognizer.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال كلمة السر';
    }
    if (value.length < 6) {
      return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  void _showForgotPasswordDialog(BuildContext context, TextStyle cairoFont) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(
              'إعادة تعيين كلمة السر',
              style: cairoFont.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'أدخل بريدك الإلكتروني لإرسال رابط إعادة التعيين',
                    style: cairoFont.copyWith(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.ltr,
                      validator: _validateEmail,
                      style: cairoFont.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      cursorColor: const Color(0xFF4BCB78),
                      decoration: InputDecoration(
                        hintText: 'البريد الإلكتروني',
                        hintTextDirection: TextDirection.rtl,
                        alignLabelWithHint: true,
                        hintStyle: AppTextStyles.body.copyWith(
                          fontFamily: cairoFont.fontFamily,
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
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop();
                      },
                child: Text(
                  'إلغاء',
                  style: cairoFont,
                ),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          final email = emailController.text.trim();
                          await authService.sendPasswordResetEmail(email);

                          if (context.mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم إرسال رابط إعادة التعيين',
                                  style: cairoFont,
                                ),
                                backgroundColor: const Color(0xFF4BCB78),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          String errorMessage = 'حدث خطأ أثناء الإرسال';
                          if (e.code == 'user-not-found') {
                            errorMessage = 'البريد الإلكتروني غير مسجل';
                          } else if (e.code == 'invalid-email') {
                            errorMessage = 'البريد الإلكتروني غير صحيح';
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  errorMessage,
                                  style: cairoFont,
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'حدث خطأ غير متوقع',
                                  style: cairoFont,
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setDialogState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFF4BCB78),
                        ),
                      )
                    : Text(
                        'إرسال',
                        style: cairoFont.copyWith(
                          color: const Color(0xFF4BCB78),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cairoFont = _cairoFont;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: DefaultTextStyle(
              style: cairoFont,
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
                                  'تسجيل الدخول',
                                  style: AppTextStyles.h1.copyWith(
                                    color: const Color(0xFF4BCB78),
                                    fontFamily: cairoFont.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Email field with RTL hint, LTR input
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          validator: _validateEmail,
                                          textAlign: TextAlign.right,
                                          textDirection: TextDirection.ltr,
                                          style: cairoFont.copyWith(
                                            color: Colors.black87,
                                            fontSize: 16,
                                          ),
                                          cursorColor: const Color(0xFF4BCB78),
                                          decoration: InputDecoration(
                                            hintText: 'البريد الإلكتروني',
                                            hintTextDirection: TextDirection.rtl,
                                            alignLabelWithHint: true,
                                            hintStyle: AppTextStyles.body.copyWith(
                                              fontFamily: cairoFont.fontFamily,
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
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xl),
                                      // Password field with show/hide toggle
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          textInputAction: TextInputAction.done,
                                          validator: _validatePassword,
                                          textAlign: TextAlign.right,
                                          onFieldSubmitted: (value) {
                                            // Submit handled by login button
                                          },
                                          style: cairoFont.copyWith(
                                            color: Colors.black87,
                                            fontSize: 16,
                                          ),
                                          cursorColor: const Color(0xFF4BCB78),
                                          decoration: InputDecoration(
                                            hintText: 'كلمة السر',
                                            hintTextDirection: TextDirection.rtl,
                                            alignLabelWithHint: true,
                                            hintStyle: AppTextStyles.body.copyWith(
                                              fontFamily: cairoFont.fontFamily,
                                              color: Colors.grey.shade500,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                                color: Colors.grey.shade600,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
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
                                    ],
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.md),
                              // Forgot password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _showForgotPasswordDialog(context, cairoFont),
                                  child: Text(
                                    'هل نسيت كلمة السر؟',
                                    style: AppTextStyles.body.copyWith(
                                      color: const Color(0xFF4BCB78),
                                      fontFamily: cairoFont.fontFamily,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFF4BCB78),
                                  ),
                                  Text(
                                    'تذكرني',
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.black,
                                      fontFamily: cairoFont.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              AppPrimaryButton(
                                label: 'تسجيل الدخول',
                                onPressed: _isLoading ? null : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  if (!mounted) return;

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final email = _emailController.text.trim();
                                    final password = _passwordController.text.trim();

                                    debugPrint('[LoginPage] Attempting sign in for email: $email');

                                    // Sign in with Firebase
                                    final userCredential = await authService.signInWithEmailPassword(
                                      email: email,
                                      password: password,
                                    );

                                    final user = userCredential.user;
                                    if (user == null) {
                                      debugPrint('[LoginPage] Sign in succeeded but user is null');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'حدث خطأ أثناء تسجيل الدخول',
                                              style: cairoFont,
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    debugPrint('[LoginPage] Sign in successful - UID: ${user.uid}, Email: ${user.email}, Verified: ${user.emailVerified}');

                                    // Check if email is verified
                                    if (!user.emailVerified) {
                                      debugPrint('[LoginPage] Email not verified, navigating to VerifyEmailPage');
                                      if (mounted) {
                                        Navigator.of(context, rootNavigator: true).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => const VerifyEmailPage(),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    // Email is verified - AuthGate will handle routing based on Firestore role
                                    // No manual navigation needed - authStateChanges will trigger AuthGate rebuild
                                    debugPrint('[LoginPage] Email verified - AuthGate will handle routing');
                                  } on FirebaseAuthException catch (e) {
                                    debugPrint('[LoginPage] FirebaseAuthException - Code: ${e.code}, Message: ${e.message}');
                                    String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
                                    if (e.code == 'user-not-found') {
                                      errorMessage = 'البريد الإلكتروني غير مسجل';
                                    } else if (e.code == 'wrong-password') {
                                      errorMessage = 'كلمة السر غير صحيحة';
                                    } else if (e.code == 'invalid-email') {
                                      errorMessage = 'البريد الإلكتروني غير صحيح';
                                    } else if (e.code == 'user-disabled') {
                                      errorMessage = 'تم تعطيل هذا الحساب';
                                    } else if (e.code == 'too-many-requests') {
                                      errorMessage = 'محاولات كثيرة، يرجى المحاولة لاحقاً';
                                    }

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            errorMessage,
                                            style: cairoFont,
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e, stackTrace) {
                                    debugPrint('[LoginPage] Generic error during sign in: $e');
                                    debugPrint('[LoginPage] Stack trace: $stackTrace');
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'حدث خطأ غير متوقع',
                                            style: cairoFont,
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
                                },
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.grey.shade700,
                                    fontFamily: cairoFont.fontFamily,
                                  ),
                                  children: [
                                    const TextSpan(text: 'ليس لديك حساب؟ '),
                                    TextSpan(
                                      text: 'انضم الآن!',
                                      recognizer: _registerTapRecognizer,
                                      style: _registerLinkStyle,
                                    ),
                                  ],
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
        ),
      ),
      ),
    );
  }
}
