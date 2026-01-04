import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/governorates.dart';
import '../../../core/constants/sports.dart';
import '../../../core/models/sport_type.dart';
import '../../widgets/widgets.dart';
import '../../widgets/sport_category_item.dart';
import '../../widgets/app_search_bar.dart';
import '../../providers/theme_provider.dart';
import '../field_details/field_details_page.dart';
import '../settings/settings_page.dart';

class HomeTabPage extends ConsumerStatefulWidget {
  const HomeTabPage({super.key});

  @override
  ConsumerState<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends ConsumerState<HomeTabPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<SportType> _selectedSports = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  
  // Cache GoogleFonts to avoid recreating on every build
  late final TextStyle _cairoFont = GoogleFonts.cairo();

  double _filterPriceMax = 600;
  String? _filterCity;
  String? _filterFieldSize;
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchFocusChanged() {
    final isFocused = _searchFocusNode.hasFocus;
    setState(() {
      if (isFocused) {
        _isSearching = true;
      } else {
        if (_searchController.text.trim().isEmpty) {
          _isSearching = false;
        }
      }
    });
  }

  void _onSearchTextChanged() {
    final hasText = _searchController.text.trim().isNotEmpty;
    final isFocused = _searchFocusNode.hasFocus;
    setState(() {
      _isSearching = isFocused || hasText;
    });
  }

  void _exitSearchMode() {
    if (!_isSearching && _searchController.text.isEmpty) return;
    _searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      // Trigger rebuild to apply filters
    });
  }
  
  /// Applies non-search filters (price, city, field size) to the search results
  List<Map<String, String>> _applyNonSearchFilters(List<Map<String, String>> playgrounds) {
    return playgrounds.where((playground) {
      // Search filter
      final searchQuery = _searchController.text.trim().toLowerCase();
      if (searchQuery.isNotEmpty) {
        final title = playground['title']?.toLowerCase() ?? '';
        final location = playground['location']?.toLowerCase() ?? '';
        if (!title.contains(searchQuery) && !location.contains(searchQuery)) {
          return false;
        }
      }

      // Price filter
      if (_filterPriceMax < 600) {
        final priceText = playground['price'] ?? '';
        final priceMatch = RegExp(r'(\d+)').firstMatch(priceText);
        if (priceMatch != null) {
          final price = int.tryParse(priceMatch.group(1) ?? '0') ?? 0;
          final maxPrice = (_filterPriceMax * 1000).toInt();
          if (price > maxPrice) {
            return false;
          }
        }
      }

      // City filter
      if (_filterCity != null && _filterCity!.isNotEmpty) {
        final location = playground['location'] ?? '';
        if (!location.contains(_filterCity!)) {
          return false;
        }
      }

      // Field size filter
      if (_filterFieldSize != null && _filterFieldSize!.isNotEmpty) {
        final size = playground['size'] ?? '';
        if (size != _filterFieldSize) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _filterPriceMax = 600;
      _filterCity = null;
      _filterFieldSize = null;
      _filterDate = null;
    });
  }

  /// Converts Firestore document to Map format expected by UI
  Map<String, String> _documentToMap(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    
    debugPrint('[HomeTabPage] Converting document ${doc.id} to map');
    debugPrint('[HomeTabPage] Document data: $data');
    
    final name = data['name'] as String? ?? 'ملعب بدون اسم';
    final city = data['city'] as String? ?? '';
    final price = data['price'] as int? ?? 0;
    final rawImageUrl = (data['imageUrl'] as String?) ?? '';
    final size = data['size'] as String?;
    
    // Trim and normalize image URL
    final imageUrl = rawImageUrl.trim();
    debugPrint('[HomeTabPage] Raw imageUrl: "$rawImageUrl"');
    debugPrint('[HomeTabPage] Trimmed imageUrl: "$imageUrl"');
    
    // Format price
    final formattedPrice = '$price ل.س';
    
    // Format location
    final location = city.isNotEmpty ? '$city، سوريا' : 'سوريا';
    
    // Normalize URL (ensure https) or use placeholder
    final imagePath = imageUrl.isNotEmpty 
        ? (imageUrl.startsWith('http://') 
            ? imageUrl.replaceFirst('http://', 'https://')
            : imageUrl)
        : 'assets/icons/soccer-field.png'; // Placeholder asset
    
    debugPrint('[HomeTabPage] Final imagePath: "$imagePath"');
    
    return {
      'id': doc.id,
      'title': name,
      'location': location,
      'price': formattedPrice,
      'imagePath': imagePath,
      if (size != null) 'size': size,
    };
  }

  void _openFilterBottomSheet(BuildContext context) {
    final rootContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        rootContext: rootContext,
        initialPrice: _filterPriceMax,
        initialCity: _filterCity,
        initialFieldSize: _filterFieldSize,
        initialDate: _filterDate,
        onApply: (price, city, fieldSize, date) {
          setState(() {
            _filterPriceMax = price;
            _filterCity = city;
            _filterFieldSize = fieldSize;
            _filterDate = date;
          });
          _applyFilters();
        },
        onReset: () {
          _resetFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && _isSearching) {
          _exitSearchMode();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: _AppDrawer(),
        endDrawer: null,
        body: SafeArea(
          child: DefaultTextStyle(
            style: _cairoFont,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                if (_searchController.text.trim().isEmpty) {
                  _exitSearchMode();
                }
              },
              child: CustomScrollView(
                key: const PageStorageKey('home_tab_scroll'),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 12, AppSpacing.lg, AppSpacing.md),
                      child: AppSearchBar(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        hintText: 'ابحث عن ملعب',
                        onMenuPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        onFilterPressed: () {
                          _openFilterBottomSheet(context);
                        },
                        onQueryChanged: (value) {
                          _applyFilters();
                        },
                        autofocus: false,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 12),
                          child: Text(
                            'اختر الرياضة',
                            style: _cairoFont.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            itemCount: sportsList.length,
                            itemBuilder: (context, index) {
                              final sport = sportsList[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index > 0 ? 12 : 0,
                                ),
                                child: SportCategoryItem(
                                  title: sport.title,
                                  icon: Image.asset(
                                    sport.iconPath,
                                    width: 32,
                                    height: 32,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.sports,
                                        size: 32,
                                        color: _selectedSports.contains(sport.type)
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      );
                                    },
                                  ),
                                  isSelected: _selectedSports.contains(sport.type),
                                  onTap: () {
                                    setState(() {
                                      if (_selectedSports.contains(sport.type)) {
                                        _selectedSports.remove(sport.type);
                                      } else {
                                        _selectedSports.add(sport.type);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                      child: _OffersCarousel(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    sliver: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('fields')
                          .snapshots(),
                      builder: (context, snapshot) {
                        // Loading state
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFF4BCB78),
                              ),
                            ),
                          );
                        }

                        // Error state
                        if (snapshot.hasError) {
                          debugPrint('[HomePage] Firestore error: ${snapshot.error}');
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'حدث خطأ أثناء تحميل البيانات',
                                style: _cairoFont.copyWith(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        // No data state
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          debugPrint('[HomePage] No fields found in Firestore');
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'لا توجد ملاعب متاحة حالياً',
                                style: _cairoFont.copyWith(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        // Convert Firestore documents to Map format
                        final allPlaygrounds = snapshot.data!.docs
                            .map((doc) => _documentToMap(doc))
                            .toList();

                        // Debug: Log number of documents
                        debugPrint('[HomePage] Loaded ${allPlaygrounds.length} fields from Firestore collection "fields"');
                        if (allPlaygrounds.isNotEmpty) {
                          debugPrint('[HomePage] First field: ${allPlaygrounds.first['title']}');
                        }

                        // Apply filters
                        final finalFiltered = _applyNonSearchFilters(allPlaygrounds);

                        // Show empty state if filters result in no matches
                        if (finalFiltered.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'لا توجد نتائج مطابقة للبحث',
                                style: _cairoFont.copyWith(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        // Display filtered results
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final playground = finalFiltered[index];
                              return RepaintBoundary(
                                child: PlaygroundCardWidget(
                                  key: ValueKey(playground['id']),
                                  title: playground['title']!,
                                  location: playground['location']!,
                                  price: playground['price']!,
                                  imagePath: playground['imagePath']!,
                                  onTap: () async {
                                    _exitSearchMode();
                                    final fieldItem = FieldItem.fromMap(playground);
                                    await Navigator.of(context, rootNavigator: true).push(
                                      MaterialPageRoute(
                                        builder: (_) => FieldDetailsPage(field: fieldItem),
                                      ),
                                    );
                                    if (mounted) {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      _searchFocusNode.unfocus();
                                      setState(() {
                                        _isSearching = false;
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                            childCount: finalFiltered.length,
                          ),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OffersCarousel extends StatefulWidget {
  const _OffersCarousel();

  @override
  State<_OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<_OffersCarousel> {
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  final List<Map<String, String>> _offers = [
    {'discount': '30%', 'title': 'حسم', 'badge': 'عرض'},
    {'discount': '25%', 'title': 'حسم', 'badge': 'عرض'},
    {'discount': '40%', 'title': 'حسم', 'badge': 'عرض'},
    {'discount': '35%', 'title': 'حسم', 'badge': 'عرض'},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _offers.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _offers.length,
            itemBuilder: (context, index) {
              final offer = _offers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to offer details
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Row(
                          textDirection: ui.TextDirection.rtl,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        offer['title']!,
                                        style: GoogleFonts.cairo(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Flexible(
                                      child: Text(
                                        offer['discount']!,
                                        style: GoogleFonts.cairo(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF4BCB78),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey.shade200,
                                      Colors.grey.shade300,
                                    ],
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/demo_offer.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.grey.shade200,
                                            Colors.grey.shade300,
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.local_offer,
                                        size: 60,
                                        color: Colors.grey.shade600,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
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
                              offer['badge']!,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _offers.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF4BCB78)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF4BCB78),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: const Color(0xFF4BCB78),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerMenuItem(
                    title: 'استعلام عن حجز',
                    icon: Icons.bookmark,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to booking inquiry page
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _DrawerMenuItem(
                    title: 'عروض اللحظات الأخيرة',
                    icon: Icons.local_offer,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to last minute offers page
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _DrawerMenuItem(
                    title: 'الإعدادات',
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _DrawerLogoutItem(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const DrawerMenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (iconColor ?? const Color(0xFF4BCB78)).withValues(alpha: 0.1),
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFF4BCB78),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          color: Colors.grey.shade800,
        ),
        textAlign: TextAlign.right,
      ),
      trailing: null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      onTap: onTap,
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DrawerMenuTile(
      title: title,
      icon: icon,
      onTap: onTap,
    );
  }
}

// ignore: unused_element
class _DrawerSubMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerSubMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.chevron_left,
              color: Colors.grey.shade400,
              size: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 32),
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4BCB78).withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4BCB78),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _DrawerDarkModeItem extends ConsumerWidget {
  const _DrawerDarkModeItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.read(themeControllerProvider);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.chevron_left,
            color: Colors.grey.shade400,
            size: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Text(
                'المظهر الداكن',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4BCB78).withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.dark_mode,
              color: const Color(0xFF4BCB78),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              themeController.setDark(value);
            },
            activeColor: const Color(0xFF4BCB78),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _DrawerDeleteAccountItem extends StatelessWidget {
  const _DrawerDeleteAccountItem();

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'تأكيد حذف الحساب',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'سيتم حذف حسابك نهائياً ولا يمكن التراجع عن هذا الإجراء. هل تريد المتابعة؟',
            style: GoogleFonts.cairo(
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'حذف',
                style: GoogleFonts.cairo(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteAccount(context);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // Close drawer first
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(
                    'جاري حذف الحساب...',
                    style: GoogleFonts.cairo(),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // TODO: Replace with actual backend API call
      // Example for custom backend:
      // final response = await http.delete(
      //   Uri.parse('https://your-api.com/account/delete'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // if (response.statusCode != 200) throw Exception('Failed to delete account');

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Clear local session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to login and clear all previous routes
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف الحساب بنجاح',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء حذف الحساب. يرجى المحاولة مرة أخرى.',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDeleteConfirmationDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.chevron_left,
              color: Colors.grey.shade400,
              size: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 32),
                child: Text(
                  'حذف الحساب',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerLogoutItem extends StatelessWidget {
  const _DrawerLogoutItem();

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'تسجيل الخروج',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            style: GoogleFonts.cairo(
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'تسجيل خروج',
                style: GoogleFonts.cairo(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Close drawer first if opened from drawer
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Sign out from Firebase - AuthGate will handle navigation to login
      await FirebaseAuth.instance.signOut();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تسجيل الخروج بنجاح',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message only if signOut throws
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء تسجيل الخروج. يرجى المحاولة مرة أخرى.',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DrawerMenuItem(
      title: 'تسجيل خروج',
      icon: Icons.logout,
      onTap: () => _showLogoutConfirmationDialog(context),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final BuildContext rootContext;
  final double initialPrice;
  final String? initialCity;
  final String? initialFieldSize;
  final DateTime? initialDate;
  final Function(double, String?, String?, DateTime?) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    required this.rootContext,
    required this.initialPrice,
    required this.initialCity,
    required this.initialFieldSize,
    required this.initialDate,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late double _priceValue;
  String? _selectedCity;
  String? _selectedFieldSize;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _priceValue = widget.initialPrice;
    _selectedCity = widget.initialCity;
    _selectedFieldSize = widget.initialFieldSize;
    _selectedDate = widget.initialDate;
  }

  Future<void> _showCupertinoDatePicker() async {
    FocusScope.of(widget.rootContext).unfocus();

    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime minDate = DateTime.now().subtract(const Duration(days: 365));
    final DateTime maxDate = DateTime.now().add(const Duration(days: 365 * 3));

    int selectedDay = initialDate.day;
    int selectedMonth = initialDate.month;
    int selectedYear = initialDate.year.clamp(minDate.year, maxDate.year);
    
    final daysInInitialMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    if (selectedDay > daysInInitialMonth) {
      selectedDay = daysInInitialMonth;
    }

    await showModalBottomSheet(
      context: widget.rootContext,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Localizations.override(
        context: context,
        locale: const Locale('en', 'US'),
        child: Container(
          height: 250,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'DONE',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF4BCB78),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.cairo(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          backgroundColor: Colors.white,
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedDay - 1,
                          ),
                          onSelectedItemChanged: (int index) {
                            selectedDay = index + 1;
                            final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
                            if (selectedDay > daysInMonth) {
                              selectedDay = daysInMonth;
                            }
                          },
                          children: List.generate(31, (index) {
                            return Center(
                              child: Text(
                                (index + 1).toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          backgroundColor: Colors.white,
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedMonth - 1,
                          ),
                          onSelectedItemChanged: (int index) {
                            selectedMonth = index + 1;
                            final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
                            if (selectedDay > daysInMonth) {
                              selectedDay = daysInMonth;
                            }
                          },
                          children: List.generate(12, (index) {
                            return Center(
                              child: Text(
                                (index + 1).toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          backgroundColor: Colors.white,
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedYear - minDate.year,
                          ),
                          onSelectedItemChanged: (int index) {
                            selectedYear = minDate.year + index;
                            final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
                            if (selectedDay > daysInMonth) {
                              selectedDay = daysInMonth;
                            }
                          },
                          children: List.generate(
                            maxDate.year - minDate.year + 1,
                            (index) {
                              return Center(
                                child: Text(
                                  (minDate.year + index).toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),
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
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'اختر التاريخ';
    return DateFormat('dd / MM / yyyy', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              color: const Color(0xFF2F4B57),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: DefaultTextStyle(
              style: GoogleFonts.cairo(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'السعر',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${_priceValue.toInt()} ألف',
                            style: GoogleFonts.cairo(
                              color: const Color(0xFF4BCB78),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '600',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _priceValue,
                        min: 0,
                        max: 600,
                        divisions: 600,
                        activeColor: const Color(0xFF4BCB78),
                        inactiveColor: Colors.grey.shade700,
                        onChanged: (newValue) {
                          setModalState(() {
                            _priceValue = newValue.roundToDouble();
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'المدينة',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.white,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'اختر المدينة',
                            hintStyle: GoogleFonts.cairo(
                              color: Colors.grey.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: GoogleFonts.cairo(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          dropdownColor: Colors.white,
                          items: syrianGovernorates.map((governorate) {
                            return DropdownMenuItem<String>(
                              value: governorate,
                              child: Text(
                                governorate,
                                style: GoogleFonts.cairo(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              _selectedCity = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'حجم الملعب',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.white,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedFieldSize,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'اختر حجم الملعب',
                            hintStyle: GoogleFonts.cairo(
                              color: Colors.grey.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: GoogleFonts.cairo(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          dropdownColor: Colors.white,
                          items: ['5x5', '7x7', '11x11'].map((size) {
                            return DropdownMenuItem<String>(
                              value: size,
                              child: Text(
                                size,
                                style: GoogleFonts.cairo(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              _selectedFieldSize = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'التاريخ',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          _showCupertinoDatePicker();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatDate(_selectedDate),
                            style: GoogleFonts.cairo(
                              color: _selectedDate == null ? Colors.grey.shade600 : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                widget.onReset();
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'إعادة تعيين',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppPrimaryButton(
                              label: 'بحث',
                              onPressed: () {
                                widget.onApply(_priceValue, _selectedCity, _selectedFieldSize, _selectedDate);
                                Navigator.of(context).pop();
                              },
                              fullWidth: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

