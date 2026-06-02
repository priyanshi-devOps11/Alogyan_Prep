import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/onboarding_model.dart';

/// Renders a single full-height onboarding slide.
///
/// Handles graceful fallback when the asset image is missing
/// (placeholder gradient illustration), so the screen never breaks
/// during development before final assets are added.
class OnboardingSlideCard extends StatelessWidget {
  const OnboardingSlideCard({
    super.key,
    required this.slide,
  });

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Illustration area ──────────────────────────────────────────────
        _IllustrationArea(
          assetPath: slide.assetPath,
          height: size.height * 0.46,
        ),

        const SizedBox(height: AppTheme.paddingL),

        // ── Text content ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (slide.accentTag != null) ...[
                _AccentTag(text: slide.accentTag!),
                const SizedBox(height: AppTheme.paddingS),
              ],
              Text(slide.title, style: AppTheme.displayLarge),
              const SizedBox(height: AppTheme.paddingS),
              Text(slide.subtitle, style: AppTheme.titleMedium),
              const SizedBox(height: AppTheme.paddingM),
              Text(slide.description, style: AppTheme.bodyRegular),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Private sub-widgets ──────────────────────────────────────────────────────

class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({
    required this.assetPath,
    required this.height,
  });

  final String assetPath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background — always visible
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.surfaceColor,
                  AppTheme.backgroundCard,
                  AppTheme.backgroundDark,
                ],
              ),
            ),
          ),

          // Decorative radial glow
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.brandOrange.withOpacity(0.18),
                    AppTheme.brandOrange.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Asset image (with graceful error fallback)
          Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                _PlaceholderIllustration(assetPath: assetPath),
          ),

          // Bottom fade-to-background gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.backgroundDark.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the real asset is missing. Keeps UI presentable during dev.
class _PlaceholderIllustration extends StatelessWidget {
  const _PlaceholderIllustration({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 72,
            color: AppTheme.textMuted.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            assetPath.split('/').last,
            style: AppTheme.bodyRegular.copyWith(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentTag extends StatelessWidget {
  const _AccentTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingS,
        vertical: AppTheme.paddingXS - 1,
      ),
      decoration: BoxDecoration(
        color: AppTheme.brandOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: AppTheme.brandOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(text, style: AppTheme.labelSmall),
    );
  }
}
