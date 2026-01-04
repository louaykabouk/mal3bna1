import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_spacing.dart';

class AppPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final backgroundColor = _pressed
        ? const Color(0xFF3FAE68)
        : const Color(0xFF4BCB78);
    final disabledBackgroundColor = Colors.grey.shade400;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: isDisabled ? null : (_) {
        setState(() {
          _pressed = false;
        });
        widget.onPressed?.call();
      },
      onTapCancel: isDisabled ? null : () {
        setState(() {
          _pressed = false;
        });
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 125),
        curve: _pressed ? Curves.easeOut : Curves.easeIn,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: null,
            borderRadius: BorderRadius.circular(12),
            splashColor: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
            highlightColor: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 125),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              width: widget.fullWidth ? double.infinity : null,
              height: 50,
              decoration: BoxDecoration(
                color: isDisabled ? disabledBackgroundColor : backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.label,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          height: 0.9,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
