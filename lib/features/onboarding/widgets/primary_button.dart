import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Full-width primary button that shows a loading spinner when [isLoading] is true.
/// Automatically disables interaction during loading to prevent double-taps.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: isLoading
                ? LinearGradient(
              colors: [
                AppTheme.brandRedDark.withOpacity(0.6),
                AppTheme.brandRedDark.withOpacity(0.6),
              ],
            )
                : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.brandRedLight, AppTheme.brandRedDark],),



            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: isLoading
                ? []
                : [
              BoxShadow(
                color: AppTheme.brandRed.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(label, style: AppTheme.buttonLabel),
          ),
        ),
      ),
    );
  }
}