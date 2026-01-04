import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable search bar widget with filter and menu icons.
/// 
/// Features:
/// - Rounded capsule design
/// - RTL-friendly layout
/// - Configurable icons and callbacks
/// - Optional internal controller management
class AppSearchBar extends StatefulWidget {
  /// Optional controller. If null, an internal controller will be created.
  final TextEditingController? controller;
  
  /// Hint text displayed in the search field
  final String hintText;
  
  /// Callback when the filter icon (left side) is pressed
  final VoidCallback? onFilterPressed;
  
  /// Callback when the menu icon (right side) is pressed
  final VoidCallback? onMenuPressed;
  
  /// Callback when the search query changes
  final ValueChanged<String>? onQueryChanged;
  
  /// Optional focus node
  final FocusNode? focusNode;
  
  /// Whether the field should autofocus
  final bool autofocus;
  
  /// Optional margin around the widget
  final EdgeInsetsGeometry? margin;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'ابحث عن ملعب',
    this.onFilterPressed,
    this.onMenuPressed,
    this.onQueryChanged,
    this.focusNode,
    this.autofocus = false,
    this.margin,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;
  late final bool _usingInternalController;
  late final bool _usingInternalFocusNode;
  late final TextStyle _cairoFont;

  @override
  void initState() {
    super.initState();
    _cairoFont = GoogleFonts.cairo();
    _usingInternalController = widget.controller == null;
    _usingInternalFocusNode = widget.focusNode == null;
    
    _internalController = _usingInternalController
        ? TextEditingController()
        : widget.controller!;
    _internalFocusNode = _usingInternalFocusNode
        ? FocusNode()
        : widget.focusNode!;
    
    _internalController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _internalController.text;
    print('[SEARCH] SearchBar query="$text"');
    widget.onQueryChanged?.call(text);
  }

  @override
  void dispose() {
    _internalController.removeListener(_onTextChanged);
    if (_usingInternalController) {
      _internalController.dispose();
    }
    if (_usingInternalFocusNode) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu icon (right side in RTL)
          if (widget.onMenuPressed != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _internalFocusNode.unfocus();
                  widget.onMenuPressed?.call();
                },
                child: Icon(
                  Icons.menu,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          if (widget.onMenuPressed != null)
            VerticalDivider(
              thickness: 1,
              color: Colors.grey.shade300,
              width: 1,
            ),
          // Search icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.search,
              color: Colors.grey.shade600,
            ),
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: _internalController,
              focusNode: _internalFocusNode,
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.right,
              style: _cairoFont.copyWith(
                color: Colors.grey.shade800,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: _cairoFont.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              autofocus: widget.autofocus,
              onTap: () {
                if (!_internalFocusNode.hasFocus) {
                  _internalFocusNode.requestFocus();
                }
              },
            ),
          ),
          // Filter icon (left side in RTL)
          if (widget.onFilterPressed != null) ...[
            VerticalDivider(
              thickness: 1,
              color: Colors.grey.shade300,
              width: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: widget.onFilterPressed,
                child: Icon(
                  Icons.tune,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

