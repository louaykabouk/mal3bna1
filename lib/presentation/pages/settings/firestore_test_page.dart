import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../services/firestore_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_primary_button.dart';

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  State<FirestoreTestPage> createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  bool _isLoading = false;

  Future<void> _testAddDocument() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await firestoreService.addDocument(
        collection: 'test',
        data: {
          'message': 'Hello Firestore',
          'platform': 'android',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إضافة المستند بنجاح!',
                style: _cairoFont,
              ),
              backgroundColor: const Color(0xFF4BCB78),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'فشل إضافة المستند',
                style: _cairoFont,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: $e',
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'غير محدد';
    
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return DateFormat('yyyy-MM-dd HH:mm:ss', 'ar').format(date);
      } else if (timestamp is DateTime) {
        return DateFormat('yyyy-MM-dd HH:mm:ss', 'ar').format(timestamp);
      }
      return timestamp.toString();
    } catch (e) {
      return timestamp.toString();
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
            'اختبار Firestore',
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
                Icon(
                  Icons.cloud_upload,
                  size: 80,
                  color: const Color(0xFF4BCB78),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'اختبار قاعدة البيانات',
                  style: AppTextStyles.h2.copyWith(
                    fontFamily: _cairoFont.fontFamily,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  label: 'إضافة مستند تجريبي',
                  onPressed: _isLoading ? null : _testAddDocument,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'آخر 20 مستند:',
                  style: AppTextStyles.h3.copyWith(
                    fontFamily: _cairoFont.fontFamily,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.streamCollection(
                    collection: 'test',
                    limit: 20,
                    orderBy: 'createdAt',
                    descending: true,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'خطأ: ${snapshot.error}',
                          style: _cairoFont.copyWith(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4BCB78),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'لا توجد مستندات بعد',
                          style: _cairoFont.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final message = data['message'] ?? 'بدون رسالة';
                        final platform = data['platform'] ?? 'غير محدد';
                        final createdAt = data['createdAt'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        message,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontFamily: _cairoFont.fontFamily,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_android,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      platform,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontFamily: _cairoFont.fontFamily,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTimestamp(createdAt),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontFamily: _cairoFont.fontFamily,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

