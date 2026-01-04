import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/widgets.dart';
import '../../widgets/stadium_reviews_section.dart';
import '../../state/favorites_manager.dart';
import '../booking/booking_page.dart';

class FieldItem {
  final String id;
  final String title;
  final String location;
  final String price;
  final String imagePath;
  final String? size;

  FieldItem({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imagePath,
    this.size,
  });

  factory FieldItem.fromMap(Map<String, String> map) {
    return FieldItem(
      id: map['id'] ?? '',
      title: map['title'] ?? 'ملعب',
      location: map['location'] ?? '',
      price: map['price'] ?? '',
      imagePath: map['imagePath'] ?? '',
      size: map['size'],
    );
  }
}

class FieldDetailsPage extends StatefulWidget {
  final FieldItem field;

  const FieldDetailsPage({
    super.key,
    required this.field,
  });

  @override
  State<FieldDetailsPage> createState() => _FieldDetailsPageState();
}

class _FieldDetailsPageState extends State<FieldDetailsPage> {
  final FavoritesManager _favoritesManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _favoritesManager.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {});
  }

  bool get _isFavorite => _favoritesManager.isFavorite(widget.field.id);

  /// Builds the field image widget with proper network image handling
  Widget _buildFieldImage() {
    final imagePath = widget.field.imagePath.trim();
    
    debugPrint('[FieldDetailsPage] Building image for field: ${widget.field.id}');
    debugPrint('[FieldDetailsPage] Image path: "$imagePath"');
    debugPrint('[FieldDetailsPage] Image path isEmpty: ${imagePath.isEmpty}');
    debugPrint('[FieldDetailsPage] Image path starts with http: ${imagePath.startsWith('http')}');
    
    // Check if imagePath is a network URL or local asset
    final isNetworkUrl = imagePath.isNotEmpty && 
                        (imagePath.startsWith('http://') || imagePath.startsWith('https://'));
    
    if (isNetworkUrl) {
      // Normalize URL (ensure https)
      final normalizedUrl = imagePath.startsWith('http://')
          ? imagePath.replaceFirst('http://', 'https://')
          : imagePath;
      
      debugPrint('[FieldDetailsPage] Using network image: "$normalizedUrl"');
      
      return Stack(
        children: [
          CachedNetworkImage(
            imageUrl: normalizedUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4BCB78)),
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              debugPrint('[FieldDetailsPage] Error loading image: $url');
              debugPrint('[FieldDetailsPage] Error details: $error');
              return Container(
                color: Colors.grey.shade300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 60,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'فشل تحميل الصورة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildFavoriteButton(),
        ],
      );
    } else if (imagePath.isNotEmpty) {
      // Try as local asset
      debugPrint('[FieldDetailsPage] Using asset image: "$imagePath"');
      return Stack(
        children: [
          Image.asset(
            imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('[FieldDetailsPage] Error loading asset: $imagePath');
              debugPrint('[FieldDetailsPage] Error: $error');
              return _buildPlaceholder();
            },
          ),
          _buildFavoriteButton(),
        ],
      );
    } else {
      // No image URL provided - show placeholder
      debugPrint('[FieldDetailsPage] No image URL, showing placeholder');
      return Stack(
        children: [
          _buildPlaceholder(),
          _buildFavoriteButton(),
        ],
      );
    }
  }

  /// Builds placeholder widget when image is not available
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 60,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد صورة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the favorite button overlay
  Widget _buildFavoriteButton() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _favoritesManager.toggleFavorite(widget.field);
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
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
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite
                  ? const Color(0xFF4BCB78)
                  : Colors.grey.shade600,
              size: 24,
            ),
          ),
        ),
      ),
    );
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
            widget.field.title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.grey.shade800,
              ),
              onPressed: () {
                Share.share('احجز الآن في ملعبنا – ${widget.field.title}');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey.shade800,
              ),
              onPressed: () {
                // TODO: Menu functionality
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildFieldImage(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to terms
                          debugPrint('شروط الملاعب tapped');
                        },
                        icon: Icon(
                          Icons.description,
                          color: Colors.grey.shade800,
                          size: 20,
                        ),
                        label: Text(
                          'شروط الملاعب',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to map
                          debugPrint('مكان الملعب على الخريطة tapped');
                        },
                        icon: Icon(
                          Icons.map,
                          color: Colors.grey.shade800,
                          size: 20,
                        ),
                        label: Text(
                          'مكان الملعب على الخريطة',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'الخدمات المتاحة',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GridView.count(
                  crossAxisCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.7,
                  children: [
                    _ServiceItem(
                      icon: Icons.water_drop,
                      label: 'ماء',
                    ),
                    _ServiceItem(
                      icon: Icons.sports_soccer,
                      label: 'كرة',
                    ),
                    _ServiceItem(
                      icon: Icons.chair,
                      label: 'جلسة',
                    ),
                    _ServiceItem(
                      icon: Icons.local_parking,
                      label: 'مواقف',
                    ),
                    _ServiceItem(
                      icon: Icons.checkroom,
                      label: 'ملابس',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Ratings & Reviews Section
              StadiumReviewsSection(
                stadiumId: widget.field.id,
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 100,
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Material(
              color: const Color(0xFF4BCB78),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingPage(
                        fieldTitle: widget.field.title,
                        fieldId: widget.field.id,
                        fieldPrice: widget.field.price,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'استعرض فترات الحجز',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4BCB78).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4BCB78),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

