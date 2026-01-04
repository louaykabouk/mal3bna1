import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/field_model.dart';
import '../../widgets/widgets.dart';
import 'add_field_page.dart';
import 'owner_field_schedule_page.dart';

class OwnerFieldsPage extends ConsumerStatefulWidget {
  const OwnerFieldsPage({super.key});

  @override
  ConsumerState<OwnerFieldsPage> createState() => _OwnerFieldsPageState();
}

class _OwnerFieldsPageState extends ConsumerState<OwnerFieldsPage> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();

  // Helper function to format field size (convert "5x5" to "5×5")
  String _formatFieldSize(String size) {
    return size.replaceAll('x', '×');
  }

  // Helper function to get field display name
  String _getFieldDisplayName(FieldModel field) {
    if (field.name.trim().isNotEmpty) {
      return field.name;
    }
    return 'ملعب بدون اسم';
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    
    // If not authenticated, redirect to login
    if (user == null) {
      debugPrint('[OwnerFieldsPage] No user logged in, redirecting to login');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final uid = user.uid;
    final email = user.email ?? 'no-email';
    
    // Debug logging
    debugPrint('[OwnerFieldsPage] Current user UID: $uid');
    debugPrint('[OwnerFieldsPage] Current user email: $email');
    debugPrint('[OwnerFieldsPage] Querying fields where ownerId == $uid');
    
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'ملاعبك',
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: _cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('fields')
                    .where('ownerId', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Debug logging
                  if (snapshot.hasError) {
                    debugPrint('[OwnerFieldsPage] Firestore error: ${snapshot.error}');
                    debugPrint('[OwnerFieldsPage] Error details: ${snapshot.error.toString()}');
                  }
                  
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4BCB78),
                      ),
                    );
                  }
                  
                  // Error state
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'حدث خطأ أثناء تحميل الملاعب',
                              style: AppTextStyles.h3.copyWith(
                                fontFamily: _cairoFont.fontFamily,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${snapshot.error}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontFamily: _cairoFont.fontFamily,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Get documents
                  final docs = snapshot.data?.docs ?? [];
                  debugPrint('[OwnerFieldsPage] Query returned ${docs.length} documents');
                  
                  // Convert to FieldModel list
                  final fields = docs.map((doc) {
                    try {
                      return FieldModel.fromFirestore(doc);
                    } catch (e) {
                      debugPrint('[OwnerFieldsPage] Error parsing document ${doc.id}: $e');
                      return null;
                    }
                  }).whereType<FieldModel>().toList();
                  
                  debugPrint('[OwnerFieldsPage] Successfully parsed ${fields.length} fields');
                  
                  // Empty state
                  if (fields.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/soccer-field.png',
                            width: 68,
                            height: 68,
                            color: Colors.grey.withValues(alpha: 0.45),
                            colorBlendMode: BlendMode.srcIn,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'لا توجد ملاعب بعد',
                            style: AppTextStyles.h3.copyWith(
                              fontFamily: _cairoFont.fontFamily,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // List of fields
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: fields.length,
                    itemBuilder: (context, index) {
                      final field = fields[index];
                      return _buildFieldCard(context, ref, field);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppPrimaryButton(
                label: 'إضافة ملعب',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddFieldPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFieldOptions(BuildContext context, WidgetRef ref, FieldModel field) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Edit option
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Color(0xFF4BCB78),
                ),
                title: Text(
                  'تعديل الملعب',
                  style: AppTextStyles.body.copyWith(
                    fontFamily: _cairoFont.fontFamily,
                    color: Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop(); // Close bottom sheet
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddFieldPage(fieldToEdit: field),
                    ),
                  );
                },
              ),
              // Delete option
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  'حذف الملعب',
                  style: AppTextStyles.body.copyWith(
                    fontFamily: _cairoFont.fontFamily,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop(); // Close bottom sheet
                  _showDeleteConfirmation(context, ref, field);
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, FieldModel field) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'حذف الملعب',
            style: AppTextStyles.h3.copyWith(
              fontFamily: _cairoFont.fontFamily,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذا الملعب؟',
            style: AppTextStyles.body.copyWith(
              fontFamily: _cairoFont.fontFamily,
              color: Colors.black87,
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'إلغاء',
                style: AppTextStyles.body.copyWith(
                  fontFamily: _cairoFont.fontFamily,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            // Delete button
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close confirmation dialog
                
                try {
                  await FirebaseFirestore.instance
                      .collection('fields')
                      .doc(field.id)
                      .delete();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم حذف الملعب بنجاح',
                          style: _cairoFont,
                        ),
                        backgroundColor: const Color(0xFF4BCB78),
                      ),
                    );
                  }
                  
                  debugPrint('[OwnerFieldsPage] Deleted field: ${field.id}');
                } catch (e) {
                  debugPrint('[OwnerFieldsPage] Error deleting field: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'حدث خطأ أثناء حذف الملعب: $e',
                          style: _cairoFont,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'حذف',
                style: AppTextStyles.body.copyWith(
                  fontFamily: _cairoFont.fontFamily,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldCard(
    BuildContext context,
    WidgetRef ref,
    FieldModel field,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OwnerFieldSchedulePage(
              fieldName: _getFieldDisplayName(field),
              fieldId: field.id,
            ),
          ),
        );
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
          children: [
            // Full-width image
            field.imageUrl != null && field.imageUrl!.isNotEmpty
                ? _buildNetworkImage(field.imageUrl!)
                : _buildImagePlaceholder(),
            // Gradient overlay for bottom text readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Top overlays
            // Top-left: Price badge only
            PositionedDirectional(
              top: 12,
              start: 12, // Start in RTL = left visually
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4BCB78),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${field.price} ل.س',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontFamily: _cairoFont.fontFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Top-right: Field Size Badge only
            if (field.size.isNotEmpty)
              PositionedDirectional(
                top: 12,
                end: 12, // End in RTL = right visually
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4BCB78),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatFieldSize(field.size),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontFamily: _cairoFont.fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Bottom-left: Three-dots Menu Button
            PositionedDirectional(
              bottom: 12,
              start: 12, // Start in RTL = left visually
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showFieldOptions(context, ref, field),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            // Bottom-right: Services chips only
            if (field.services.isNotEmpty)
              PositionedDirectional(
                bottom: 12,
                end: 12, // End in RTL = right visually
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  textDirection: TextDirection.rtl,
                  children: field.services.map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        service,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontFamily: _cairoFont.fontFamily,
                          color: const Color(0xFF4BCB78),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: const Color(0xFF4BCB78),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[OwnerFieldsPage] Error loading image: $imageUrl, error: $error');
        return _buildImagePlaceholder();
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade300,
      child: Center(
        child: Image.asset(
          'assets/icons/soccer-field.png',
          width: 48,
          height: 48,
          color: Colors.grey.shade400,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }
}

