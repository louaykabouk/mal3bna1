import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/governorates.dart';
import '../../../core/models/user_role.dart';
import '../../../core/utils/image_validator.dart';
import '../../../services/auth_service.dart';
import '../../../services/local_user_store.dart';
import '../../services/profile_storage.dart';
import '../../widgets/widgets.dart';
import 'verify_email_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _selectedGovernorate;
  UserRole _selectedRole = UserRole.user;
  File? _selectedImageFile;
  late final TextStyle _cairoFont = GoogleFonts.cairo();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }
    if (value.trim().length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        final imageFile = File(image.path);
        
        // Validate image size before setting
        if (!validateImageSize(imageFile)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  imageSizeErrorMessage,
                  style: _cairoFont,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImageFile = imageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء اختيار الصورة',
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
              style: _cairoFont,
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                Text(
                                  'إنشاء حساب جديد',
                                  style: AppTextStyles.h1.copyWith(
                                    color: const Color(0xFF4BCB78),
                                    fontFamily: _cairoFont.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Center(
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF4BCB78),
                                          width: 2,
                                        ),
                                      ),
                                      child: _selectedImageFile != null
                                          ? ClipOval(
                                              child: Image.file(
                                                _selectedImageFile!,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Color(0xFF4BCB78),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                AppTextField(
                                  controller: _nameController,
                                  label: 'الاسم الكامل',
                                  keyboardType: TextInputType.text,
                                  validator: _validateName,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: AppSpacing.xl),
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
                                    style: GoogleFonts.cairo(
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
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                // Password field with show/hide toggle
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    validator: _validatePassword,
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.cairo(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                    cursorColor: const Color(0xFF4BCB78),
                                    decoration: InputDecoration(
                                      hintText: 'كلمة السر',
                                      hintTextDirection: TextDirection.rtl,
                                      alignLabelWithHint: true,
                                      hintStyle: AppTextStyles.body.copyWith(
                                        fontFamily: _cairoFont.fontFamily,
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
                                const SizedBox(height: AppSpacing.xl),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: Colors.white,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedGovernorate,
                                        decoration: InputDecoration(
                                          labelText: 'المحافظة',
                                          labelStyle: AppTextStyles.body.copyWith(
                                            fontFamily: _cairoFont.fontFamily,
                                          ),
                                          floatingLabelBehavior: FloatingLabelBehavior.never,
                                          alignLabelWithHint: true,
                                          isDense: false,
                                          contentPadding: const EdgeInsets.only(
                                            top: 16,
                                            bottom: 12,
                                          ),
                                          enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey),
                                          ),
                                          focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF4BCB78), width: 2),
                                          ),
                                        ),
                                        style: GoogleFonts.cairo(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          height: 1.2,
                                        ),
                                      dropdownColor: Colors.white,
                                      iconEnabledColor: const Color(0xFF4BCB78),
                                      iconDisabledColor: Colors.grey,
                                      items: syrianGovernorates.map((governorate) {
                                        return DropdownMenuItem<String>(
                                          value: governorate,
                                          child: Text(
                                            governorate,
                                            style: GoogleFonts.cairo(
                                              color: Colors.black87,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGovernorate = value;
                                        });
                                      },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  'نوع الحساب',
                                  style: AppTextStyles.body.copyWith(
                                    fontFamily: _cairoFont.fontFamily,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SegmentedButton<UserRole>(
                                    segments: [
                                      ButtonSegment<UserRole>(
                                        value: UserRole.user,
                                        label: Text(
                                          UserRole.user.arabicName,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      ButtonSegment<UserRole>(
                                        value: UserRole.owner,
                                        label: Text(
                                          UserRole.owner.arabicName,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                    selected: {_selectedRole},
                                    onSelectionChanged: (Set<UserRole> newSelection) {
                                      setState(() {
                                        _selectedRole = newSelection.first;
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                                        (Set<WidgetState> states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return const Color(0xFF4BCB78);
                                          }
                                          return Colors.transparent;
                                        },
                                      ),
                                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                                        (Set<WidgetState> states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return Colors.white;
                                          }
                                          return Colors.black87;
                                        },
                                      ),
                                      side: WidgetStateProperty.all(BorderSide.none),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'قبول كافة الاحكام وشروط الاستخدام وسياسة الخصوصية',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.black,
                                          fontFamily: _cairoFont.fontFamily,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Checkbox(
                                      value: _termsAccepted,
                                      onChanged: (value) {
                                        setState(() {
                                          _termsAccepted = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF4BCB78),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                AppPrimaryButton(
                                  label: 'تسجيل',
                                  onPressed: (_termsAccepted && _selectedGovernorate != null && !_isLoading)
                                      ? () async {
                                          if (!_formKey.currentState!.validate()) {
                                            return;
                                          }

                                          final fullName = _nameController.text.trim();
                                          if (fullName.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'الرجاء إدخال الاسم الكامل',
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
                                            final email = _emailController.text.trim();
                                            final password = _passwordController.text.trim();

                                            // Create user with Firebase Auth
                                            final userCredential = await authService.registerWithEmailPassword(
                                              email: email,
                                              password: password,
                                            );

                                            final user = userCredential.user;
                                            if (user == null) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'حدث خطأ أثناء إنشاء الحساب',
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

                                            // Update display name
                                            await authService.updateDisplayName(fullName);

                                            // Send verification email
                                            await authService.sendEmailVerification();

                                            // Save profile (name + photo)
                                            String? savedPhotoPath;
                                            if (_selectedImageFile != null) {
                                              try {
                                                savedPhotoPath = await profileStorage.saveImageToAppDirectory(_selectedImageFile!);
                                              } catch (e) {
                                                // Continue even if image save fails
                                              }
                                            }
                                            await profileStorage.saveProfile(
                                              fullName: fullName,
                                              photoPath: savedPhotoPath,
                                            );

                                            // Save user profile locally (accountType, governorate)
                                            await localUserStore.saveUserProfile(
                                              fullName: fullName,
                                              accountType: _selectedRole.name,
                                              governorate: _selectedGovernorate!,
                                            );

                                            // Save role to Firestore using UID - create/update users/{uid} document
                                            final uid = user.uid;
                                            debugPrint('[RegisterPage] Creating/updating users/$uid document with role: ${_selectedRole.name}, email: $email');
                                            await FirebaseFirestore.instance.collection('users').doc(uid).set({
                                              'role': _selectedRole.name,
                                              'email': email,
                                              'createdAt': FieldValue.serverTimestamp(),
                                            }, SetOptions(merge: true));
                                            debugPrint('[RegisterPage] Successfully saved user document to Firestore');

                                            // Navigate to verify email page
                                            if (mounted) {
                                              Navigator.of(context, rootNavigator: true).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) => const VerifyEmailPage(),
                                                ),
                                              );
                                            }
                                          } on FirebaseAuthException catch (e) {
                                            String errorMessage = 'حدث خطأ أثناء إنشاء الحساب';
                                            if (e.code == 'weak-password') {
                                              errorMessage = 'كلمة السر ضعيفة جداً';
                                            } else if (e.code == 'email-already-in-use') {
                                              errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
                                            } else if (e.code == 'invalid-email') {
                                              errorMessage = 'البريد الإلكتروني غير صحيح';
                                            }

                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    errorMessage,
                                                    style: _cairoFont,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'حدث خطأ غير متوقع',
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
                                      : null,
                                  isLoading: _isLoading,
                                ),
                                ],
                              ),
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
