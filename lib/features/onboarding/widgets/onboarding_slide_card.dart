import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';

class OnboardingSlideCard extends StatelessWidget {
  const OnboardingSlideCard({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IllustrationArea(assetPath: slide.assetPath, height: size.height * 0.46),
        const SizedBox(height: AppTheme.spacingL),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AccentTag(text: slide.accentTag),
              const SizedBox(height: AppTheme.spacingS),
              Text(slide.title, style: AppTheme.displayLarge),
              const SizedBox(height: AppTheme.spacingS),
              Text(slide.subtitle, style: AppTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingM),
              Text(slide.description, style: AppTheme.bodyRegular),
            ],
          ),
        ),
      ],
    );
  }
}

class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({required this.assetPath, required this.height});

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
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.bgSurface, AppTheme.bgCard, AppTheme.bgCanvas],
              ),
            ),
          ),
          // Radial glow
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
          // Asset image
          Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, size: 72,
                      color: AppTheme.textMuted.withOpacity(0.4)),
                  const SizedBox(height: 10),
                  Text(assetPath.split('/').last,
                      style: AppTheme.bodyRegular.copyWith(
                          color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ),
          // Bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.bgCanvas.withOpacity(0.9),
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

class _AccentTag extends StatelessWidget {
  const _AccentTag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.brandOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: AppTheme.brandOrange.withOpacity(0.3),
        ),
      ),
      child: Text(text, style: AppTheme.labelSmall),
    );
  }
}