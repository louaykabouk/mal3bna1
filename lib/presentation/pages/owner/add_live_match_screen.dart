import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../../models/live_match_model.dart';
import '../../models/field_model.dart';
import '../../models/activity_item.dart';
import '../../providers/owner_fields_provider.dart';
import '../../stores/live_match_store.dart';
import '../../stores/activities_store.dart';
import 'activities_list_screen.dart';

class AddLiveMatchScreen extends ConsumerStatefulWidget {
  const AddLiveMatchScreen({super.key});

  @override
  ConsumerState<AddLiveMatchScreen> createState() => _AddLiveMatchScreenState();
}

class _AddLiveMatchScreenState extends ConsumerState<AddLiveMatchScreen> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  late final TextEditingController _priceController;
  late final TextEditingController _capacityController;
  late final TextEditingController _conditionsController;
  late final GlobalKey<FormState> _formKey;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  FieldModel? _selectedField;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _capacityController = TextEditingController();
    _conditionsController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _capacityController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  // Helper function to get field display name
  String _getFieldDisplayName(FieldModel field) {
    if (field.name.trim().isNotEmpty) {
      return field.name;
    }
    return 'ملعب بدون اسم';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar', 'SA'),
      builder: (context, child) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    // Read values BEFORE any navigation
    final price = double.parse(_priceController.text.trim());
    final capacity = int.parse(_capacityController.text.trim());
    final conditions = _conditionsController.text.trim().isEmpty
        ? null
        : _conditionsController.text.trim();

    if (_selectedDate == null || _selectedTime == null || _selectedField == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إكمال جميع الحقول المطلوبة',
            style: _cairoFont,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create LiveMatch
    final liveMatch = LiveMatch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fieldId: _selectedField!.id,
      fieldName: _getFieldDisplayName(_selectedField!),
      date: _selectedDate!,
      time: _selectedTime!,
      pricePerPerson: price,
      capacity: capacity,
      conditions: conditions,
      createdAt: DateTime.now(),
    );

    // Save to store
    LiveMatchStore().addLiveMatch(liveMatch);

    // Create ActivityItem for unified list
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final activityItem = ActivityItem(
      id: liveMatch.id,
      type: ActivityType.liveMatch,
      title: 'مباراة مباشرة',
      dateTime: dateTime,
      fieldName: _getFieldDisplayName(_selectedField!),
      peopleCount: capacity,
      pricePerPerson: price.toInt(),
      rules: conditions,
      liveMatchId: liveMatch.id,
    );

    // Add to activities store
    ActivitiesStore().addLiveMatch(activityItem);

    // Navigate to Activities list
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ActivitiesListScreen(),
      ),
    );

    // Show success message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'تم حفظ المباراة المباشرة',
              style: _cairoFont,
            ),
            backgroundColor: const Color(0xFF4BCB78),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(ownerFieldsProvider);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'إضافة مباراة مباشرة',
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: _cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
        ),
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
                        // Match Date
                        Text(
                          'تاريخ المباراة',
                          style: AppTextStyles.body.copyWith(
                            fontFamily: _cairoFont.fontFamily,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedDate == null
                                    ? Colors.grey.shade300
                                    : const Color(0xFF4BCB78),
                                width: _selectedDate == null ? 1 : 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: _selectedDate == null
                                      ? Colors.grey.shade400
                                      : const Color(0xFF4BCB78),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  _selectedDate == null
                                      ? 'اختر التاريخ'
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                  style: AppTextStyles.body.copyWith(
                                    fontFamily: _cairoFont.fontFamily,
                                    color: _selectedDate == null
                                        ? Colors.grey.shade500
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_selectedDate == null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              'الرجاء اختيار تاريخ المباراة',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontFamily: _cairoFont.fontFamily,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        // Match Time
                        Text(
                          'وقت المباراة',
                          style: AppTextStyles.body.copyWith(
                            fontFamily: _cairoFont.fontFamily,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        InkWell(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedTime == null
                                    ? Colors.grey.shade300
                                    : const Color(0xFF4BCB78),
                                width: _selectedTime == null ? 1 : 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: _selectedTime == null
                                      ? Colors.grey.shade400
                                      : const Color(0xFF4BCB78),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  _selectedTime == null
                                      ? 'اختر الوقت'
                                      : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                  style: AppTextStyles.body.copyWith(
                                    fontFamily: _cairoFont.fontFamily,
                                    color: _selectedTime == null
                                        ? Colors.grey.shade500
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_selectedTime == null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              'الرجاء اختيار وقت المباراة',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontFamily: _cairoFont.fontFamily,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        // Field Selection
                        Text(
                          'الملعب',
                          style: AppTextStyles.body.copyWith(
                            fontFamily: _cairoFont.fontFamily,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: DropdownButtonFormField<FieldModel>(
                            value: _selectedField,
                            isExpanded: true,
                            decoration: InputDecoration(
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
                            hint: Text(
                              'اختر الملعب',
                              style: _cairoFont,
                              overflow: TextOverflow.ellipsis,
                            ),
                            items: fields.map((field) {
                              return DropdownMenuItem<FieldModel>(
                                value: field,
                                child: Text(
                                  _getFieldDisplayName(field),
                                  style: _cairoFont,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (context) {
                              return fields.map((field) {
                                return Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    _getFieldDisplayName(field),
                                    style: _cairoFont,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList();
                            },
                            onChanged: (field) {
                              if (mounted) {
                                setState(() {
                                  _selectedField = field;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'الرجاء اختيار الملعب';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Price per person
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: 'سعر للشخص',
                            hintText: '0',
                            hintStyle: _cairoFont,
                            labelStyle: _cairoFont,
                            suffixText: 'ل.س',
                            suffixStyle: _cairoFont.copyWith(
                              color: Colors.grey.shade600,
                            ),
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال السعر';
                            }
                            final price = double.tryParse(value.trim());
                            if (price == null || price <= 0) {
                              return 'يجب أن يكون السعر أكبر من صفر';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Number of persons
                        TextFormField(
                          controller: _capacityController,
                          decoration: InputDecoration(
                            labelText: 'عدد الأشخاص',
                            hintText: '2',
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال عدد الأشخاص';
                            }
                            final capacity = int.tryParse(value.trim());
                            if (capacity == null || capacity < 2) {
                              return 'يجب أن يكون العدد على الأقل 2';
                            }
                            if (capacity > 50) {
                              return 'يجب أن يكون العدد على الأكثر 50';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Conditions (optional)
                        TextFormField(
                          controller: _conditionsController,
                          decoration: InputDecoration(
                            labelText: 'الشروط (اختياري)',
                            hintText: 'أدخل الشروط...',
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
                          maxLines: 3,
                          minLines: 2,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                // Save button
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppPrimaryButton(
                    label: 'حفظ المباراة المباشرة',
                    onPressed: _handleSave,
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
