import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../field_details/field_details_page.dart';
import '../../state/favorites_manager.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final FavoritesManager _favoritesManager = FavoritesManager();
  
  // Cache GoogleFonts to avoid recreating on every build
  late final TextStyle _cairoFontTitle = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade800,
  );
  late final TextStyle _cairoFontEmpty = GoogleFonts.cairo(
    fontSize: 18,
    color: Colors.grey.shade600,
  );

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final favorites = _favoritesManager.favoritesList;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            'المفضلة',
            style: _cairoFontTitle,
          ),
          centerTitle: true,
        ),
        body: favorites.isEmpty
            ? Center(
                child: Text(
                  'لا توجد رياضة مفضلة',
                  style: _cairoFontEmpty,
                ),
              )
            : ListView.builder(
                key: const PageStorageKey('favorites_tab_scroll'),
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final field = favorites[index];
                  return PlaygroundCardWidget(
                    key: ValueKey(field.id),
                    title: field.title,
                    location: field.location,
                    price: field.price,
                    imagePath: field.imagePath,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => FieldDetailsPage(field: field),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

