import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/image_validator.dart';
import '../../services/profile_storage.dart';
import '../../widgets/widgets.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final GlobalKey<FormState> _formKey;
  final ImagePicker _imagePicker = ImagePicker();
  final ProfileStorage _profileStorage = profileStorage;
  
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileStorage.loadProfile();
      if (mounted) {
        setState(() {
          _nameController.text = profile['fullName'] ?? '';
          _photoPath = profile['photoPath'];
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        final imageFile = File(image.path);
        
        // Validate image size before processing
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

        // Delete old photo if exists
        if (_photoPath != null) {
          await _profileStorage.deletePhotoFile(_photoPath);
        }

        // Save new photo to app directory
        final savedPath = await _profileStorage.saveImageToAppDirectory(imageFile);
        await _profileStorage.updatePhotoPath(savedPath);

        if (mounted) {
          setState(() {
            _photoPath = savedPath;
          });
        }
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    // Read values
    final name = _nameController.text.trim();

    // Save name and photo path to ProfileStorage
    await _profileStorage.updateName(name);
    if (_photoPath != null) {
      await _profileStorage.updatePhotoPath(_photoPath);
    }

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم الحفظ',
            style: _cairoFont,
          ),
          backgroundColor: const Color(0xFF4BCB78),
        ),
      );
    }

    // Navigate back
    if (mounted) {
      Navigator.of(context).pop();
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
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'إدارة الحساب الشخصي',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      // Avatar section
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 56,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: _photoPath != null
                                      ? FileImage(File(_photoPath!))
                                      : null,
                                  child: _photoPath == null
                                      ? Icon(
                                          Icons.person,
                                          size: 56,
                                          color: const Color(0xFF4BCB78),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4BCB78),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _pickImage,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: _pickImage,
                              child: Text(
                                _photoPath == null ? 'إضافة صورة' : 'تغيير الصورة',
                                style: _cairoFont.copyWith(
                                  color: const Color(0xFF4BCB78),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Full name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'الاسم الكامل',
                          hintText: 'أدخل الاسم الكامل',
                          hintStyle: _cairoFont,
                          labelStyle: _cairoFont,
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
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                        ),
                        style: _cairoFont,
                        textDirection: ui.TextDirection.rtl,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال الاسم الكامل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Age field
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: 'العمر',
                          hintText: 'أدخل العمر',
                          hintStyle: _cairoFont,
                          labelStyle: _cairoFont,
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
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                        ),
                        style: _cairoFont,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textDirection: ui.TextDirection.rtl,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال العمر';
                          }
                          final age = int.tryParse(value.trim());
                          if (age == null) {
                            return 'الرجاء إدخال رقم صحيح';
                          }
                          if (age < 5 || age > 100) {
                            return 'يجب أن يكون العمر بين 5 و 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Phone field
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'رقم الهاتف',
                          hintText: 'أدخل رقم الهاتف',
                          hintStyle: _cairoFont,
                          labelStyle: _cairoFont,
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
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                        ),
                        style: _cairoFont,
                        keyboardType: TextInputType.phone,
                        textDirection: ui.TextDirection.rtl,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final digitsOnly = value.trim().replaceAll(RegExp(r'[^\d]'), '');
                            if (digitsOnly.length < 8) {
                              return 'يجب أن يكون رقم الهاتف على الأقل 8 أرقام';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Address field
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'العنوان',
                          hintText: 'أدخل العنوان',
                          hintStyle: _cairoFont,
                          labelStyle: _cairoFont,
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
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                        ),
                        style: _cairoFont,
                        minLines: 2,
                        maxLines: 4,
                        textDirection: ui.TextDirection.rtl,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              // Save button at bottom
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppPrimaryButton(
                    label: 'حفظ',
                    onPressed: _handleSave,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

