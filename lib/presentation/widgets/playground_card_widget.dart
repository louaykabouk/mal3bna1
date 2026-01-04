import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_spacing.dart';

class PlaygroundCardWidget extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final String imagePath;
  final VoidCallback onTap;

  const PlaygroundCardWidget({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.imagePath,
    required this.onTap,
  });

  static final TextStyle _cairoPriceStyle = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static final TextStyle _cairoTitleStyle = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static final TextStyle _cairoLocationStyle = GoogleFonts.cairo(
    fontSize: 14,
    color: Colors.white.withValues(alpha: 0.9),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImage(imagePath),
              ),
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
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4BCB78),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    price,
                    style: _cairoPriceStyle,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: _cairoTitleStyle,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: _cairoLocationStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    // Check if imagePath is a URL (starts with http:// or https://)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network image from Cloudinary
      return Image.network(
        imagePath,
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
          return Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(
                Icons.sports_soccer,
                size: 48,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    } else {
      // Asset image
      return Builder(
        builder: (context) {
          final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
          final screenWidth = MediaQuery.of(context).size.width;
          final imageWidth = (screenWidth * devicePixelRatio).round();
          final imageHeight = (200 * devicePixelRatio).round();
          
          return Image.asset(
            imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            cacheWidth: imageWidth.clamp(700, 1200),
            cacheHeight: imageHeight,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(
                    Icons.sports_soccer,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }
}

