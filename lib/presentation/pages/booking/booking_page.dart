import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';

class BookingPage extends StatefulWidget {
  final String fieldTitle;
  final String? fieldId;
  final String? fieldPrice;

  const BookingPage({
    super.key,
    required this.fieldTitle,
    this.fieldId,
    this.fieldPrice,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'رجالية';
  String _selectedSize = '6x6';
  final TextEditingController _discountCodeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String get _bookingPrice => widget.fieldPrice ?? '0 ريال';

  void _changeDate(int direction) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: direction));
    });
  }

  String _formatArabicDate(DateTime date) {
    final weekday = _getWeekdayName(date.weekday);
    final month = _getMonthName(date.month);
    return '$weekday ${date.day} $month';
  }

  List<DateTime?> _buildMonthGrid(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;
    
    final List<DateTime?> grid = List.filled(42, null);
    
    int gridIndex = startWeekday % 7;
    for (int day = 1; day <= daysInMonth; day++) {
      grid[gridIndex] = DateTime(month.year, month.month, day);
      gridIndex++;
    }
    
    return grid;
  }

  String _getEnglishMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month < months.length) {
      return months[month];
    }
    return 'Jan';
  }

  Future<void> _openDatePickerSheet() async {
    DateTime tempPickedDate = _selectedDate;
    DateTime visibleMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final monthGrid = _buildMonthGrid(visibleMonth);
          
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A3A52),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1, 1);
                            });
                          },
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Text(
                          '${_getEnglishMonthName(visibleMonth.month)} ${visibleMonth.year}',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 1);
                            });
                          },
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'أحد',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'إثنين',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'ثلاثاء',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'أربعاء',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'خميس',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'جمعة',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'سبت',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: 42,
                      itemBuilder: (context, index) {
                        final date = monthGrid[index];
                        if (date == null) {
                          return const SizedBox.shrink();
                        }
                        
                        final isSelected = date.year == tempPickedDate.year &&
                            date.month == tempPickedDate.month &&
                            date.day == tempPickedDate.day;
                        
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              tempPickedDate = date;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4BCB78)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4BCB78)
                                    : const Color(0xFF4BCB78).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Center(
                                  child: Text(
                                    'إغلاق',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Material(
                            color: const Color(0xFF4BCB78),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDate = tempPickedDate;
                                });
                                Navigator.of(context).pop();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Center(
                                  child: Text(
                                    'تأكيد',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    if (weekday >= 1 && weekday < weekdays.length) {
      return weekdays[weekday];
    }
    return 'الاثنين';
  }

  String _getMonthName(int month) {
    const months = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    if (month >= 1 && month < months.length) {
      return months[month];
    }
    return 'يناير';
  }

  @override
  void dispose() {
    _discountCodeController.dispose();
    _notesController.dispose();
    super.dispose();
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
            'حجز',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.grey.shade800,
              ),
              onPressed: () {
                // TODO: Menu functionality
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4BCB78),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _openDatePickerSheet,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'اختر التاريخ',
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.clip,
                                          textDirection: ui.TextDirection.rtl,
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _changeDate(1);
                                  },
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _formatArabicDate(_selectedDate),
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      textDirection: ui.TextDirection.rtl,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _changeDate(-1);
                                  },
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: const Color(0xFF4BCB78),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تصنيف الفترة',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اختر التصنيف حسب فئة اللاعبين ( رجال، نساء )',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _CategoryCard(
                              title: 'فترات نسائية',
                              isSelected: _selectedCategory == 'نسائية',
                              onTap: () {
                                setState(() {
                                  _selectedCategory = 'نسائية';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _CategoryCard(
                              title: 'فترات رجالية',
                              isSelected: _selectedCategory == 'رجالية',
                              onTap: () {
                                setState(() {
                                  _selectedCategory = 'رجالية';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'اختر حجم الملعب',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'يختلف السعر حسب حجم الملعب',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _SizeCard(
                          size: _selectedSize,
                          isSelected: true,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: Text(
                          'مناسب لمجموعة من (12) لاعبين',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'اختر الفترة',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اختر أحد الفترات المتاحة | قد تختلف الفترات حسب حجم الملعب',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'لا توجد فترات متاحة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'الفترات بعد منتصف الليل',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'لا توجد فترات متاحة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'اختر رقم الملعب',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'قد يختلف السعر بناءً على رقم الملعب',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Divider(
                        height: AppSpacing.xl * 2,
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: const Color(0xFF4BCB78),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'كود الخصم',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اختر أو أضف كود الخصم ثم اختر تفعيل للاستفادة من كود الخصم',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _discountCodeController,
                              textDirection: ui.TextDirection.rtl,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: 'أدخل كود الخصم',
                                hintStyle: GoogleFonts.cairo(
                                  color: Colors.grey.shade400,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF4BCB78),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF4BCB78),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF4BCB78),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: 12,
                                ),
                              ),
                              style: GoogleFonts.cairo(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Material(
                            color: const Color(0xFF4BCB78),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                debugPrint('تطبيق كود الخصم: ${_discountCodeController.text}');
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: 12,
                                ),
                                child: Text(
                                  'تطبيق',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: const Color(0xFF4BCB78),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'سعر الحجز',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اجمالي سعر الحجز النهائي',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: Text(
                          'سعر حجز الملعب',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4BCB78),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                _bookingPrice,
                                style: GoogleFonts.cairo(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Center(
                        child: Text(
                          'أترك رسالتك أو طلبك للملعب',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _notesController,
                        textDirection: ui.TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 5,
                        minLines: 4,
                        decoration: InputDecoration(
                          hintText: 'أكتب هنا ..',
                          hintStyle: GoogleFonts.cairo(
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF4BCB78),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF4BCB78),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF4BCB78),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                        ),
                        style: GoogleFonts.cairo(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'لديك عدد غيابات عن الحجوزات',
                              value: '0',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _StatCard(
                              title: 'لديك عدد الغاءات للحجوزات',
                              value: '0',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              textDirection: ui.TextDirection.rtl,
                              textAlign: TextAlign.right,
                              text: TextSpan(
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                                children: [
                                  const TextSpan(text: 'قيامك بالحجز عن طريق تطبيق ملعبنا يعني موافقتك على '),
                                  TextSpan(
                                    text: 'الشروط والأحكام',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: const Color(0xFF4BCB78),
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: navigate to Terms & Conditions page
                                      },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            RichText(
                              textDirection: ui.TextDirection.rtl,
                              textAlign: TextAlign.right,
                              text: TextSpan(
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                children: [
                                  const TextSpan(text: 'يمكنك إلغاء الحجز قبل '),
                                  TextSpan(
                                    text: '96 ساعة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const TextSpan(text: ' من تاريخ الحجز واسترداد كامل المبلغ.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 100,
                      ),
                    ],
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

class _CategoryCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4BCB78) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4BCB78) : const Color(0xFF4BCB78),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFF4BCB78).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: isSelected ? Colors.white : const Color(0xFF4BCB78),
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeCard extends StatelessWidget {
  final String size;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeCard({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4BCB78) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4BCB78),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_soccer,
              color: isSelected ? Colors.white : const Color(0xFF4BCB78),
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              size,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE74C3C),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

