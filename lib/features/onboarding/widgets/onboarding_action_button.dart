import 'package:flutter/material.dart';

// Clean absolute import targeting your global design tokens
import 'package:alogyan_prep/core/theme/app_theme.dart';

/// Bottom-right CTA button that morphs smoothly between:
///   • Arrow icon (intermediate slides) ➔ calls [onNext]
///   • "Get Started" text + check icon (final slide) ➔ calls [onGetStarted]
class OnboardingActionButton extends StatelessWidget {
  const OnboardingActionButton({
    super.key,
    required this.isLastPage,
    required this.onNext,
    required this.onGetStarted,
  });

  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: isLastPage
          ? _GetStartedButton(
        key: const ValueKey('get_started_cta'),
        onTap: onGetStarted,
      )
          : _ArrowButton(
        key: const ValueKey('arrow_next_cta'),
        onTap: onNext,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Intermediate Page Arrow Action Component
// ─────────────────────────────────────────────────────────────────────────────

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.brandRedLight, AppTheme.brandRedDark],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.brandRed.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Final Page "Get Started" Confirmation Component
// ─────────────────────────────────────────────────────────────────────────────

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.brandRedLight, AppTheme.brandRedDark],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brandRed.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Started',
              style: AppTheme.buttonLabel,
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}