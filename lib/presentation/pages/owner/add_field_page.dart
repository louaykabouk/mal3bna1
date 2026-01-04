import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/field_service.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/image_compression_service.dart';
import '../../models/field_model.dart';
import '../../theme/app_spacing.dart';
import 'add_field/widgets/add_field_header.dart';
import 'add_field/widgets/add_field_image_picker.dart';
import 'add_field/widgets/add_field_text_input.dart';
import 'add_field/widgets/add_field_price_input.dart';
import 'add_field/widgets/add_field_size_selector.dart';
import 'add_field/widgets/add_field_services_selector.dart';
import 'add_field/widgets/add_field_city_selector.dart';
import 'add_field/widgets/add_field_save_button.dart';

class AddFieldPage extends ConsumerStatefulWidget {
  final FieldModel? fieldToEdit;

  const AddFieldPage({
    super.key,
    this.fieldToEdit,
  });

  @override
  ConsumerState<AddFieldPage> createState() => _AddFieldPageState();
}

class _AddFieldPageState extends ConsumerState<AddFieldPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _selectedImage;
  final Set<FieldService> _selectedServices = {};
  String? _selectedFieldSize;
  String? _selectedCity;
  bool _isSaving = false;
  bool _isUploading = false;
  bool _hasImageError = false;
  bool _hasSizeError = false;
  bool _hasCityError = false;
  bool _hasAttemptedValidation = false;
  late final TextStyle _cairoFont = GoogleFonts.cairo();

  bool get _isEditMode => widget.fieldToEdit != null;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_onPriceChanged);

    if (_isEditMode && widget.fieldToEdit != null) {
      final field = widget.fieldToEdit!;
      _nameController.text = field.name;
      _priceController.text = field.price.toString();
      _selectedFieldSize = field.size;

      _selectedServices.clear();
      for (final serviceName in field.services) {
        for (final service in FieldService.values) {
          if (service.arabicName == serviceName) {
            _selectedServices.add(service);
            break;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.removeListener(_onPriceChanged);
    _priceController.dispose();
    super.dispose();
  }

  void _onPriceChanged() {
    if (_priceController.text.trim().isNotEmpty) {
      if (_formKey.currentState != null) {
        _formKey.currentState!.validate();
      }
    }
  }

  Future<void> _pickImage() async {
    if (_isUploading) return; // Prevent multiple simultaneous operations
    
    setState(() {
      _isUploading = true;
    });

    try {
      final imageFile = await imageCompressionService.pickAndCompressImage(
        source: ImageSource.gallery,
      );

      if (imageFile != null && mounted) {
        setState(() {
          _selectedImage = imageFile;
          _hasImageError = false;
        });
      }
    } on ImageTooLargeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message,
              style: _cairoFont,
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('[AddFieldPage] Error picking image: $e');
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
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال السعر';
    }
    final price = int.tryParse(value.trim());
    if (price == null) {
      return 'السعر يجب أن يكون رقماً';
    }
    if (price <= 0) {
      return 'السعر يجب أن يكون أكبر من صفر';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال اسم الملعب';
    }
    if (value.trim().length < 2) {
      return 'يجب أن يكون الاسم على الأقل حرفين';
    }
    return null;
  }

  Future<void> _saveField() async {
    setState(() {
      _hasAttemptedValidation = true;
    });

    final isFormValid = _formKey.currentState!.validate();
    final isImageValid = _selectedImage != null;
    final isSizeValid = _selectedFieldSize != null && _selectedFieldSize!.isNotEmpty;
    final isCityValid = _selectedCity != null && _selectedCity!.isNotEmpty;

    setState(() {
      _hasImageError = !isImageValid;
      _hasSizeError = !isSizeValid;
      _hasCityError = !isCityValid;
    });

    if (!isFormValid || !isImageValid || !isSizeValid || !isCityValid) {
      if (!isImageValid || !isSizeValid || !isCityValid) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[AddFieldPage] Error: No user logged in');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'يجب تسجيل الدخول أولاً',
                style: _cairoFont,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final uid = user.uid;
      final email = user.email ?? '';
      final price = int.parse(_priceController.text.trim());
      final name = _nameController.text.trim();
      final city = _selectedCity!;

      debugPrint('[AddFieldPage] Starting field save - UID: $uid, Email: $email');
      debugPrint('[AddFieldPage] Field name: $name, City: $city, Price: $price');

      String? imageUrl;
      if (_selectedImage != null) {
        debugPrint('[AddFieldPage] Uploading image to Cloudinary...');
        setState(() {
          _isUploading = true;
        });
        
        try {
          imageUrl = await cloudinaryService.uploadImage(_selectedImage!);
          debugPrint('[AddFieldPage] Image uploaded successfully. URL: $imageUrl');
        } catch (e) {
          debugPrint('[AddFieldPage] Error uploading image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'حدث خطأ أثناء رفع الصورة',
                  style: _cairoFont,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isSaving = false;
            _isUploading = false;
          });
          return;
        } finally {
          if (mounted) {
            setState(() {
              _isUploading = false;
            });
          }
        }
      }

      final fieldData = <String, dynamic>{
        'name': name,
        'city': city,
        'price': price,
        'size': _selectedFieldSize!,
        'ownerId': uid,
        'ownerEmail': email,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl ?? '',
        'services': _selectedServices.map((s) => s.arabicName).toList(),
      };

      debugPrint('[AddFieldPage] Saving field data to Firestore: $fieldData');

      if (_isEditMode && widget.fieldToEdit != null) {
        await _firestore
            .collection('fields')
            .doc(widget.fieldToEdit!.id)
            .update(fieldData);

        debugPrint('[AddFieldPage] Updated field in Firestore: ${widget.fieldToEdit!.id}');

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم تعديل الملعب بنجاح',
                style: _cairoFont,
              ),
              backgroundColor: const Color(0xFF4BCB78),
            ),
          );
        }
      } else {
        final docRef = await _firestore.collection('fields').add(fieldData);

        debugPrint('[AddFieldPage] Created new field in Firestore: ${docRef.id}');
        debugPrint('[AddFieldPage] Field saved successfully with ownerId: $uid');

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إضافة الملعب بنجاح',
                style: _cairoFont,
              ),
              backgroundColor: const Color(0xFF4BCB78),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[AddFieldPage] Error saving field: $e');
      debugPrint('[AddFieldPage] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء الحفظ: $e',
              style: _cairoFont,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
        resizeToAvoidBottomInset: true,
        appBar: AddFieldHeader(isEditMode: _isEditMode),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AddFieldTextInput(
                          controller: _nameController,
                          labelText: 'اسم الملعب',
                          hintText: 'أدخل اسم الملعب',
                          validator: _validateName,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AddFieldCitySelector(
                          selectedCity: _selectedCity,
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                              _hasCityError = false;
                            });
                          },
                          showError: _hasCityError,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AddFieldImagePicker(
                          selectedImage: _selectedImage,
                          onPickImage: _pickImage,
                          showError: _hasImageError,
                          isLoading: _isUploading,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AddFieldPriceInput(
                          controller: _priceController,
                          validator: _validatePrice,
                          hasAttemptedValidation: _hasAttemptedValidation,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AddFieldSizeSelector(
                          selectedSize: _selectedFieldSize,
                          onChanged: (value) {
                            setState(() {
                              _selectedFieldSize = value;
                              _hasSizeError = false;
                            });
                          },
                          showError: _hasSizeError,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AddFieldServicesSelector(
                          selectedServices: _selectedServices,
                          onServiceToggled: (FieldService service) {
                            setState(() {
                              if (_selectedServices.contains(service)) {
                                _selectedServices.remove(service);
                              } else {
                                _selectedServices.add(service);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
                AddFieldSaveButton(
                  isEditMode: _isEditMode,
                  isLoading: _isSaving,
                  onSave: _saveField,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
